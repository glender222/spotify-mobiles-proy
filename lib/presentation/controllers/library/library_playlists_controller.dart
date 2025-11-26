import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/library/usecases/get_library_playlists_usecase.dart';
import '../../../domain/library/usecases/create_playlist_usecase.dart';
import '../../../domain/library/usecases/rename_playlist_usecase.dart';
import '../../../domain/library/usecases/sync_piped_playlists_usecase.dart';
import '../../../domain/library/entities/library_playlist_entity.dart';
import '/models/playlist.dart';
import '/utils/helper.dart';
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
        print('Piped sync failed or not logged in: $e');
      }

      isContentFetched.value = true;
    } catch (e) {
      print('Failed to load playlists: $e');
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
      print('Failed to create playlist: $e');
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
      print('Failed to rename playlist: $e');
      return false;
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
}
