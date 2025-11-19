import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/utils/helper.dart';
import 'package:harmonymusic/models/thumbnail.dart';
import 'dart:io';
import 'package:harmonymusic/services/permission_service.dart';
import 'package:harmonymusic/ui/widgets/snackbar.dart';
import 'package:hive/hive.dart';

import '../../../base_class/playlist_album_screen_con_base.dart';
import '../../../mixins/additional_opeartion_mixin.dart';
import '../../../models/album.dart' show Album;
import '../../../models/media_Item_builder.dart';
import '../../../models/playlist.dart';
import '../../../services/piped_service.dart';
import '../../../services/activity_service.dart';
import '../Home/home_screen_controller.dart';
import '../Library/library_controller.dart';
import '../../../domain/playlist/entities/playlist_entity.dart';
import '../../../domain/playlist/entities/track_entity.dart';
import '../../../domain/playlist/usecases/save_playlist_usecase.dart';
import '../../../domain/playlist/usecases/remove_playlist_usecase.dart';
import '../../../domain/playlist/usecases/get_online_playlist_details_usecase.dart';
import '../../../domain/playlist/usecases/update_local_playlist_usecase.dart';
import '../../../domain/playlist/usecases/export_playlist_usecase.dart';
import '../../../domain/playlist/entities/export_type.dart';

class PlaylistScreenController extends PlaylistAlbumScreenControllerBase
    with AdditionalOpeartionMixin, GetSingleTickerProviderStateMixin {
  final ActivityService _activityService = Get.find<ActivityService>();
  final SavePlaylistUseCase _savePlaylistUseCase = Get.find<SavePlaylistUseCase>();
  final RemovePlaylistUseCase _removePlaylistUseCase = Get.find<RemovePlaylistUseCase>();
  final GetOnlinePlaylistDetailsUseCase _getOnlinePlaylistDetailsUseCase = Get.find<GetOnlinePlaylistDetailsUseCase>();
  final UpdateLocalPlaylistUseCase _updateLocalPlaylistUseCase = Get.find<UpdateLocalPlaylistUseCase>();
  final ExportPlaylistUseCase _exportPlaylistUseCase = Get.find<ExportPlaylistUseCase>();

  final playlist = Playlist(
    title: "",
    playlistId: "",
    thumbnailUrl: Playlist.thumbPlaceholderUrl,
  ).obs;
  final isDefaultPlaylist = false.obs;
  final isExporting = false.obs;
  final exportProgress = 0.0.obs;
  String generatedYtmPlaylistUrl = '';

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _heightAnimation;

  AnimationController get animationController => _animationController;
  Animation<double> get scaleAnimation => _scaleAnimation;
  Animation<double> get heightAnimation => _heightAnimation;

  @override
  void onInit() {
    super.onInit();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1.0).animate(animationController);
    _heightAnimation = Tween<double>(begin: 10.0, end: 75.0).animate(CurvedAnimation(parent: animationController, curve: Curves.easeOutBack));

    final args = Get.arguments as List;
    final Playlist? playlist = args[0];
    final playlistId = args[1];
    fetchPlaylistDetails(playlist, playlistId);
    Future.delayed(const Duration(milliseconds: 200), () => Get.find<HomeScreenController>().whenHomeScreenOnTop());
  }

  @override
  void fetchPlaylistDetails(Playlist? playlist_, String playlistId) async {
    final isIdOnly = playlist_ == null;
    final isPipedPlaylist = playlist_?.isPipedPlaylist ?? false;
    isDefaultPlaylist.value = (playlistId == "SongDownloads" || playlistId == "SongsCache" || playlistId == "LIBRP" || playlistId == "LIBFAV");

    if (!isIdOnly && !playlist_.isCloudPlaylist) {
      playlist.value = playlist_;
      _animationController.forward();
      fetchSongsfromDatabase(playlistId);
      isContentFetched.value = true;
      Future.delayed(const Duration(seconds: 1), () => _updatePlaylistThumbSongBased());
      return;
    }

    if (!isIdOnly) {
      playlist.value = playlist_;
      _animationController.forward();
    }

    try {
      if (await checkIfAddedToLibrary(playlistId)) {
        final songsBox = await Hive.openBox(playlistId);
        if (songsBox.values.isEmpty) {
          _fetchSongOnline(playlistId, isIdOnly, isPipedPlaylist).then((value) {
            updateSongsIntoDb();
          });
        } else {
          fetchSongsfromDatabase(playlistId);
        }
      } else {
        _fetchSongOnline(playlistId, isIdOnly, isPipedPlaylist);
      }
      isContentFetched.value = true;
    } catch (e) {
      printERROR("Error fetching playlist details: $e");
    }
  }

  Future<void> _fetchSongOnline(String id, bool isIdOnly, bool isPipedPlaylist) async {
    isContentFetched.value = false;

    if (isPipedPlaylist) {
      songList.value = (await Get.find<PipedServices>().getPlaylistSongs(id));
      isContentFetched.value = true;
      checkDownloadStatus();
      return;
    }

    final playlistEntity = await _getOnlinePlaylistDetailsUseCase(id);

    final legacyPlaylist = Playlist(
      playlistId: playlistEntity.id,
      title: playlistEntity.title,
      description: playlistEntity.description,
      thumbnailUrl: playlistEntity.thumbnailUrl,
    );

    final mediaItems = playlistEntity.tracks.map((track) => MediaItem(
      id: track.id,
      title: track.title,
      artist: track.artist,
      album: track.album,
      artUri: track.thumbnailUrl != null ? Uri.parse(track.thumbnailUrl!) : null,
      duration: track.duration,
    )).toList();

    if (isIdOnly) {
      playlist.value = legacyPlaylist;
      _animationController.forward();
    }
    songList.value = mediaItems;
    checkDownloadStatus();
  }

  @override
  void syncPlaylistSongs() {
    _fetchSongOnline(playlist.value.playlistId, false, false).then((value) {
      updateSongsIntoDb();
      isContentFetched.value = true;
    });
  }

  @override
  Future<bool> checkIfAddedToLibrary(String id) async {
    final box = await Hive.openBox("LibraryPlaylists");
    isAddedToLibrary.value = box.containsKey(id);
    if (isAddedToLibrary.value) playlist.value = Playlist.fromJson(box.get(id));
    await box.close();
    return isAddedToLibrary.value;
  }

  @override
  Future<bool> addNremoveFromLibrary(dynamic content, {bool add = true}) async {
    try {
      if (content.isPipedPlaylist && !add) {
        final res = await Get.find<PipedServices>().deletePlaylist(content.playlistId);
        Get.find<LibraryPlaylistsController>().syncPipedPlaylist();
        return (res.code == 1);
      }

      final id = content.playlistId;

      if (add) {
        final tracks = songList.map((mediaItem) => TrackEntity(
          id: mediaItem.id,
          title: mediaItem.title,
          artist: mediaItem.artist ?? 'Unknown Artist',
          album: mediaItem.album,
          thumbnailUrl: mediaItem.artUri?.toString(),
          duration: mediaItem.duration,
        )).toList();

        final playlistEntity = PlaylistEntity(
          id: content.playlistId,
          title: content.title,
          description: content.description,
          thumbnailUrl: content.thumbnailUrl,
          tracks: tracks,
        );

        await _savePlaylistUseCase(playlistEntity);
        _activityService.addPlaylist(content.title, songList.toList());
      } else {
        await _removePlaylistUseCase(id);
      }

      isAddedToLibrary.value = add;
      Get.find<LibraryPlaylistsController>().refreshLib();

      if (!content.isCloudPlaylist && !add) {
        final plstbox = await Hive.openBox(content.playlistId);
        plstbox.deleteFromDisk();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> updateSongsIntoDb() async {
    final songsBox = await Hive.openBox(playlist.value.playlistId);
    await songsBox.clear();
    final songListCopy = songList.toList();
    for (int i = 0; i < songListCopy.length; i++) {
      await songsBox.put(i, MediaItemBuilder.toJson(songListCopy[i]));
    }
    if (playlist.value.playlistId != "SongDownloads") await songsBox.close();
    _updatePlaylistThumbSongBased();
    if (isAddedToLibrary.value) {
      _activityService.addPlaylist(playlist.value.title, songList.toList());
    }
  }

  @override
  Future<void> deleteMultipleSongs(List<MediaItem> songs) async {
    final songIdsToRemove = songs.map((s) => s.id).toSet();
    songList.removeWhere((song) => songIdsToRemove.contains(song.id));

    final updatedTracks = songList.map((mediaItem) => TrackEntity(
      id: mediaItem.id,
      title: mediaItem.title,
      artist: mediaItem.artist ?? 'Unknown Artist',
      album: mediaItem.album,
      thumbnailUrl: mediaItem.artUri?.toString(),
      duration: mediaItem.duration,
    )).toList();

    final playlistEntity = PlaylistEntity(
      id: playlist.value.playlistId,
      title: playlist.value.title,
      description: playlist.value.description,
      thumbnailUrl: playlist.value.thumbnailUrl,
      tracks: updatedTracks,
    );

    await _updateLocalPlaylistUseCase(playlistEntity);
    _updatePlaylistThumbSongBased();

    // The activity service should probably be called from the use case,
    // but for now we keep it here to minimize changes.
    if (isAddedToLibrary.value) {
      _activityService.addPlaylist(playlist.value.title, songList.toList());
    }
  }

  void addNRemoveItemsinList(MediaItem? item, {required String action, int? index}) {
    if (action == 'add') {
      index != null ? songList.insert(index, item!) : songList.add(item!);
    } else {
      index != null ? songList.removeAt(index) : songList.remove(item);
    }
    _updatePlaylistThumbSongBased();
    if (isAddedToLibrary.value) {
      _activityService.addPlaylist(playlist.value.title, songList.toList());
    }
  }

  @override
  void fetchAlbumDetails(Album? album_,String albumId) {}

  void _updatePlaylistThumbSongBased() {
    final currentPlaylist = playlist.value;
    if (isDefaultPlaylist.isTrue || currentPlaylist.isCloudPlaylist) return;
    Playlist updatedplaylist;
    if (songList.isNotEmpty) {
      updatedplaylist = currentPlaylist.copyWith(thumbnailUrl: songList[0].artUri.toString());
    } else {
      updatedplaylist = currentPlaylist.copyWith(thumbnailUrl: Playlist.thumbPlaceholderUrl);
    }
    if (Thumbnail(currentPlaylist.thumbnailUrl).extraHigh == Thumbnail(updatedplaylist.thumbnailUrl).extraHigh) return;
    playlist.value = updatedplaylist;
    Get.find<LibraryPlaylistsController>().updatePlaylistIntoDb(updatedplaylist);
  }

  @override
  void onClose() {
    _animationController.dispose();
    Get.find<HomeScreenController>().whenHomeScreenOnTop();
    super.onClose();
  }

  Future<void> exportPlaylist(BuildContext context, ExportType format) async {
    if (!await PermissionService.getExtStoragePermission()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackbar(context, "permissionDenied".tr, size: SanckBarSize.MEDIUM));
      }
      return;
    }

    try {
      isExporting.value = true;
      exportProgress.value = 0.1;
      if (context.mounted) {
        _showProgressDialog(context, "exportingPlaylist".tr);
      }

      // Business logic is now in the use case
      final filePath = await _exportPlaylistUseCase(playlistId: playlist.value.playlistId, format: format);
      
      exportProgress.value = 1.0;
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      final dir = Directory(filePath).parent;
      String locationMsg = _getLocationMessage(dir.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackbar(context, "${"playlistExportedMsg".tr}: $locationMsg", size: SanckBarSize.MEDIUM));
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      printERROR("Error exporting playlist: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackbar(context, "exportError".tr, size: SanckBarSize.MEDIUM));
      }
    } finally {
      isExporting.value = false;
      exportProgress.value = 0.0;
    }
  }

  String _getLocationMessage(String path) {
    if (Platform.isAndroid) {
      return "Downloads/HarmonyMusic";
    } else if (Platform.isIOS) {
      return "Files App > HarmonyMusic";
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return "Downloads/HarmonyMusic";
    } else {
      return path.split('/').last;
    }
  }

  void _showProgressDialog(BuildContext context, String title) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: exportProgress.value,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(height: 16),
                Text("${(exportProgress.value * 100).toInt()}%", style: Theme.of(context).textTheme.bodyMedium),
              ],
            )),
      ),
      barrierDismissible: false,
    );
  }
}
