import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:harmonymusic/ui/widgets/snackbar.dart';
import 'package:harmonymusic/utils/helper.dart';

import '../../../domain/library/usecases/get_library_playlists_usecase.dart';
import '../../../domain/library/usecases/create_playlist_usecase.dart';
import '../../../domain/library/usecases/rename_playlist_usecase.dart';
import '../../../domain/library/usecases/sync_piped_playlists_usecase.dart';
import '../../../domain/library/entities/library_playlist_entity.dart';
import '/models/playlist.dart';
import '/ui/widgets/sort_widget.dart';

/// Controller for Library Playlists using Clean Architecture
class LibraryPlaylistsController extends GetxController
    with GetTickerProviderStateMixin {
  // Use Cases injection
  final GetLibraryPlaylistsUseCase _getLibraryPlaylistsUseCase;
  final CreatePlaylistUseCase _createPlaylistUseCase;
  final RenamePlaylistUseCase _renamePlaylistUseCase;
  final SyncPipedPlaylistsUseCase _syncPipedPlaylistsUseCase;

  LibraryPlaylistsController({
    required GetLibraryPlaylistsUseCase getLibraryPlaylistsUseCase,
    required CreatePlaylistUseCase createPlaylistUseCase,
    required RenamePlaylistUseCase renamePlaylistUseCase,
    required SyncPipedPlaylistsUseCase syncPipedPlaylistsUseCase,
  })  : _getLibraryPlaylistsUseCase = getLibraryPlaylistsUseCase,
        _createPlaylistUseCase = createPlaylistUseCase,
        _renamePlaylistUseCase = renamePlaylistUseCase,
        _syncPipedPlaylistsUseCase = syncPipedPlaylistsUseCase;

  // Animation
  late AnimationController controller;

  // State
  final playlistCreationMode = "local".obs;

  static final initPlst = [
    Playlist(
        title: "recentlyPlayed".tr,
        playlistId: "LIBRP",
        thumbnailUrl: Playlist.thumbPlaceholderUrl,
        isCloudPlaylist: false),
    Playlist(
        title: "favorites".tr,
        playlistId: "LIBFAV",
        thumbnailUrl: Playlist.thumbPlaceholderUrl,
        isCloudPlaylist: false),
    Playlist(
        title: "cachedOrOffline".tr,
        playlistId: "SongsCache",
        thumbnailUrl: Playlist.thumbPlaceholderUrl,
        isCloudPlaylist: false),
    Playlist(
        title: "downloads".tr,
        playlistId: "SongDownloads",
        thumbnailUrl: Playlist.thumbPlaceholderUrl,
        isCloudPlaylist: false)
  ];

  late RxList<Playlist> libraryPlaylists = RxList(initPlst);
  final isContentFetched = false.obs;
  final creationInProgress = false.obs;
  final textInputController = TextEditingController();
  List<Playlist> tempListContainer = [];

  // Import progress
  final isImporting = false.obs;
  final importProgress = 0.0.obs;

  @override
  void onInit() {
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    refreshLib();
    super.onInit();
  }

  Future<void> refreshLib() async {
    try {
      // Get playlists from Use Case
      final playlistEntities = await _getLibraryPlaylistsUseCase();

      // Convert entities to Playlist models for UI compatibility
      final customPlaylists =
          playlistEntities.map((entity) => entity.toPlaylist()).toList();

      libraryPlaylists.value = [...initPlst, ...customPlaylists];

      // Sync Piped playlists if logged in
      try {
        await _syncPipedPlaylistsUseCase();
        // Refresh after sync
        final updatedEntities = await _getLibraryPlaylistsUseCase();
        final updatedPlaylists =
            updatedEntities.map((e) => e.toPlaylist()).toList();
        libraryPlaylists.value = [...initPlst, ...updatedPlaylists];
      } catch (e) {
        printERROR('Piped sync failed or not logged in: $e');
      }

      isContentFetched.value = true;
    } catch (e) {
      printERROR('Failed to load playlists: $e');
      isContentFetched.value = true;
    }
  }

  Future<bool> createNewPlaylist({
    bool createPlaylistNaddSong = false,
    List<dynamic>? songItems,
  }) async {
    String title = textInputController.text;
    if (title.trim().isEmpty) {
      return false;
    }

    try {
      creationInProgress.value = true;

      final playlistId = playlistCreationMode.value == "piped"
          ? "PIPED_TEMP_${DateTime.now().millisecondsSinceEpoch}"
          : "LIB${DateTime.now().millisecondsSinceEpoch}";

      final playlist = LibraryPlaylistEntity(
        id: playlistId,
        title: title,
        addedAt: DateTime.now(),
        thumbnailUrl: songItems != null && songItems.isNotEmpty
            ? songItems[0].artUri.toString()
            : Playlist.thumbPlaceholderUrl,
        description: playlistCreationMode.value == "piped"
            ? "Piped Playlist"
            : "Library Playlist",
        isCloudPlaylist: playlistCreationMode.value == "piped",
        isPipedPlaylist: playlistCreationMode.value == "piped",
      );

      await _createPlaylistUseCase(
        playlist,
        syncToPiped: playlistCreationMode.value == "piped",
      );

      creationInProgress.value = false;
      await refreshLib();
      return true;
    } catch (e) {
      printERROR('Failed to create playlist: $e');
      creationInProgress.value = false;
      return false;
    }
  }

  Future<bool> renamePlaylist(Playlist playlist) async {
    String title = textInputController.text;
    if (title.trim().isEmpty) {
      return false;
    }

    try {
      await _renamePlaylistUseCase(
        playlist.playlistId,
        title,
        syncToPiped: playlist.isPipedPlaylist,
      );

      await refreshLib();
      return true;
    } catch (e) {
      printERROR('Failed to rename playlist: $e');
      return false;
    }
  }

  Future<void> syncPipedPlaylist() async {
    try {
      await _syncPipedPlaylistsUseCase();
      await refreshLib();
    } catch (e) {
      printERROR('Failed to sync piped playlists: $e');
      rethrow;
    }
  }

  Future<void> blacklistPipedPlaylist(Playlist playlist) async {
    final box = await Hive.openBox('blacklistedPlaylist');
    box.add(playlist.playlistId);
    libraryPlaylists.remove(playlist);
    box.close();
  }

  Future<void> resetBlacklistedPlaylist() async {
    final box = await Hive.openBox('blacklistedPlaylist');
    box.clear();
    syncPipedPlaylist();
  }

  Future<void> updatePlaylistIntoDb(Playlist playlist) async {
    final box = await Hive.openBox("LibraryPlaylists");
    box.put(playlist.playlistId, playlist.toJson());
    final index = libraryPlaylists
        .indexWhere((element) => element.playlistId == playlist.playlistId);
    if (index != -1) {
      libraryPlaylists[index] = playlist;
      libraryPlaylists.refresh();
    }
  }

  void changeCreationMode(String? val) {
    playlistCreationMode.value = val!;
  }

  /// Sort playlists
  void onSort(SortType sortType, bool isAscending) {
    final playlists = libraryPlaylists.toList();
    playlists.removeRange(0, 4);
    sortPlayLists(playlists, sortType, isAscending);
    playlists.insertAll(0, initPlst);
    libraryPlaylists.value = playlists;
  }

  /// Search
  void onSearchStart(String? tag) {
    tempListContainer = libraryPlaylists.toList();
  }

  void onSearch(String value, String? tag) {
    final songlist = tempListContainer
        .where((element) =>
            element.title.toLowerCase().contains(value.toLowerCase()))
        .toList();
    libraryPlaylists.value = songlist;
  }

  void onSearchClose(String? tag) {
    libraryPlaylists.value = tempListContainer.toList();
    tempListContainer.clear();
  }

  @override
  void dispose() {
    textInputController.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> importPlaylistFromJson(BuildContext context) async {
    try {
      isImporting.value = true;
      importProgress.value = 0.1;

      // Show progress dialog
      if (context.mounted) {
        _showImportProgressDialog(context);
      }

      // Use file_picker to select JSON file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'importPlaylist'.tr,
      );

      if (result == null || result.files.isEmpty) {
        // User cancelled the picker
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        isImporting.value = false;
        importProgress.value = 0.0;
        return;
      }

      importProgress.value = 0.2;

      final file = File(result.files.single.path!);
      if (!await file.exists()) {
        throw FileSystemException("fileNotFound".tr);
      }

      final jsonString = await file.readAsString();
      importProgress.value = 0.3;

      final jsonData = jsonDecode(jsonString);
      importProgress.value = 0.4;

      // Validate JSON structure
      if (!jsonData.containsKey('playlistInfo') ||
          !jsonData.containsKey('songs')) {
        throw FormatException("invalidPlaylistFile".tr);
      }

      // Create new playlist ID
      final playlistInfo = jsonData['playlistInfo'];
      final newPlaylistId = "LIB${DateTime.now().millisecondsSinceEpoch}";
      importProgress.value = 0.5;

      // Create playlist object
      // Note: We are using direct Hive access here for compatibility with the legacy import format
      // Ideally this should be moved to a Use Case, but for now we keep the logic here
      // to ensure 100% functionality migration.

      final newPlaylist = LibraryPlaylistEntity(
        id: newPlaylistId,
        title: "${playlistInfo['title']} (${"imported".tr})",
        addedAt: DateTime.now(),
        thumbnailUrl: playlistInfo['thumbnailUrl'] ??
            (playlistInfo['thumbnails'] != null &&
                    playlistInfo['thumbnails'].isNotEmpty
                ? playlistInfo['thumbnails'][0]['url']
                : "https://via.placeholder.com/150"), // Placeholder
        isCloudPlaylist: false,
        isPipedPlaylist: false,
        description: playlistInfo['description'] ?? "importedPlaylist".tr,
      );
      importProgress.value = 0.6;

      // Save playlist to database
      final box = await Hive.openBox("LibraryPlaylists");
      // We need to convert Entity to JSON compatible with legacy format if needed
      // But LibraryPlaylistEntity.toJson() should work if it matches legacy structure
      // For now, we manually construct the map to be safe and match legacy Playlist.toJson
      box.put(newPlaylistId, {
        'title': newPlaylist.title,
        'playlistId': newPlaylist.id,
        'thumbnailUrl': newPlaylist.thumbnailUrl,
        'isCloudPlaylist': newPlaylist.isCloudPlaylist,
        'isPipedPlaylist': newPlaylist.isPipedPlaylist,
        'description': newPlaylist.description,
      });

      importProgress.value = 0.7;

      // Save songs to playlist
      final songsBox = await Hive.openBox(newPlaylistId);
      final songsList = jsonData['songs'] as List;

      // Update progress as songs are added
      final totalSongs = songsList.length;
      for (int i = 0; i < totalSongs; i++) {
        await songsBox.put(i, songsList[i]);
        // Update progress from 70% to 95% based on song import progress
        importProgress.value = 0.7 + (0.25 * (i + 1) / totalSongs);
      }

      await songsBox.close();
      await box.close();
      importProgress.value = 1.0;

      // Close progress dialog if it's still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Refresh library to show the new playlist
      await refreshLib();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          snackbar(
            context,
            "${"playlistImportedMsg".tr}: ${newPlaylist.title}",
            size: SanckBarSize.MEDIUM,
          ),
        );
      }
    } catch (e) {
      // Close progress dialog if it's still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      printERROR("Error importing playlist: $e");

      String errorMsg = "importError".tr;
      if (e is FileSystemException) {
        errorMsg = "importErrorFileAccess".tr;
      } else if (e is FormatException) {
        errorMsg = "importErrorFormat".tr;
      } else if (e.toString().contains("invalidPlaylistFile")) {
        errorMsg = "invalidPlaylistFile".tr;
      } else if (e is HiveError) {
        errorMsg = "importErrorDatabase".tr;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            snackbar(context, errorMsg, size: SanckBarSize.MEDIUM));
      }
    } finally {
      isImporting.value = false;
      importProgress.value = 0.0;
    }
  }

  // Helper method to show import progress dialog
  void _showImportProgressDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          "importingPlaylist".tr,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => LinearProgressIndicator(
                  value: importProgress.value,
                  backgroundColor:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                )),
            const SizedBox(height: 16),
            Obx(() => Text(
                  "${(importProgress.value * 100).toInt()}%",
                  style: Theme.of(context).textTheme.bodyMedium,
                )),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
