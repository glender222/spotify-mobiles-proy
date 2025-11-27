import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import '../../../domain/library/usecases/get_library_songs_usecase.dart';
import '../../../domain/library/usecases/remove_song_from_library_usecase.dart';
import '../../../domain/library/usecases/watch_library_songs_usecase.dart';
import '/ui/widgets/sort_widget.dart';
import '/utils/helper.dart';

/// Controller for Library Songs using Clean Architecture
class LibrarySongsController extends GetxController {
  // Use Cases injection
  final GetLibrarySongsUseCase _getLibrarySongsUseCase;
  final RemoveSongFromLibraryUseCase _removeSongFromLibraryUseCase;
  final WatchLibrarySongsUseCase _watchLibrarySongsUseCase;

  LibrarySongsController({
    required GetLibrarySongsUseCase getLibrarySongsUseCase,
    required RemoveSongFromLibraryUseCase removeSongFromLibraryUseCase,
    required WatchLibrarySongsUseCase watchLibrarySongsUseCase,
  })  : _getLibrarySongsUseCase = getLibrarySongsUseCase,
        _removeSongFromLibraryUseCase = removeSongFromLibraryUseCase,
        _watchLibrarySongsUseCase = watchLibrarySongsUseCase;

  // State
  late RxList<MediaItem> librarySongsList = RxList();
  final isSongFetched = false.obs;
  List<MediaItem> tempListContainer = [];
  SortWidgetController? sortWidgetController;
  final additionalOperationMode = OperationMode.none.obs;

  // Additional operations state
  final additionalOperationTempList = [].obs;
  final additionalOperationTempMap = <int, bool>{}.obs;

  @override
  void onInit() {
    // init(); // Stream handles initialization
    _watchLibrary();
    super.onInit();
  }

  void _watchLibrary() {
    _watchLibrarySongsUseCase().listen((songs) {
      librarySongsList.value =
          songs.map((entity) => entity.toMediaItem()).toList();
      isSongFetched.value = true;
    });
  }

  Future<void> init() async {
    try {
      // Use Clean Architecture - Get songs from Use Case
      final songs = await _getLibrarySongsUseCase();

      // Convert entities to MediaItems for UI compatibility
      librarySongsList.value =
          songs.map((entity) => entity.toMediaItem()).toList();

      isSongFetched.value = true;
    } catch (e) {
      printERROR('Failed to load library songs: $e');
      isSongFetched.value = true; // Still mark as fetched to avoid loading loop
    }
  }

  /// Refresh library songs
  Future<void> refreshLibrary() async {
    isSongFetched.value = false;
    await init();
  }

  /// Sort songs
  void onSort(SortType sortType, bool isAscending) {
    final songlist = librarySongsList.toList();
    sortSongsNVideos(songlist, sortType, isAscending);
    librarySongsList.value = songlist;
  }

  /// Search start
  void onSearchStart(String? tag) {
    tempListContainer = librarySongsList.toList();
  }

  /// Search
  void onSearch(String value, String? tag) {
    final songlist = tempListContainer
        .where((element) =>
            element.title.toLowerCase().contains(value.toLowerCase()))
        .toList();
    librarySongsList.value = songlist;
  }

  /// Search close
  void onSearchClose(String? tag) {
    librarySongsList.value = tempListContainer.toList();
    tempListContainer.clear();
  }

  /// Remove song from library
  Future<void> removeSong(MediaItem item, bool isDownloaded,
      {String? url}) async {
    try {
      // Remove from UI immediately
      if (tempListContainer.isNotEmpty) {
        tempListContainer.remove(item);
      }
      librarySongsList.remove(item);

      // Remove from repository (this will also delete file if needed)
      await _removeSongFromLibraryUseCase(item.id, deleteFile: true);
    } catch (e) {
      printERROR('Failed to remove song: $e');
      // Re-add to UI if failed
      librarySongsList.add(item);
    }
  }

  /// Delete multiple songs
  Future<void> deleteMultipleSongs(List<MediaItem> songs) async {
    for (MediaItem element in songs) {
      final isDownloaded = element.extras?['isDownloaded'] == true;
      await removeSong(element, isDownloaded);
    }
  }

  //========================
  // Additional Operations
  //========================

  void startAdditionalOperation(
      SortWidgetController sortWidgetController_, OperationMode mode) {
    sortWidgetController = sortWidgetController_;
    additionalOperationTempList.value = librarySongsList.toList();
    if (mode == OperationMode.addToPlaylist || mode == OperationMode.delete) {
      for (int i = 0; i < additionalOperationTempList.length; i++) {
        additionalOperationTempMap[i] = false;
      }
    }
    additionalOperationMode.value = mode;
  }

  void checkIfAllSelected() {
    sortWidgetController!.isAllSelected.value =
        !additionalOperationTempMap.containsValue(false);
  }

  void selectAll(bool selected) {
    for (int i = 0; i < additionalOperationTempList.length; i++) {
      additionalOperationTempMap[i] = selected;
    }
  }

  void performAdditionalOperation() {
    final currMode = additionalOperationMode.value;
    if (currMode == OperationMode.delete) {
      deleteMultipleSongs(selectedSongs()).then((value) {
        sortWidgetController?.setActiveMode(OperationMode.none);
        cancelAdditionalOperation();
      });
    } else if (currMode == OperationMode.addToPlaylist) {
      // Show add to playlist dialog
      // Import needed: import '../../widgets/add_to_playlist.dart';
      // This will be handled by UI layer
      printINFO('Add to playlist operation - handled by UI');
    }
  }

  List<MediaItem> selectedSongs() {
    return additionalOperationTempMap.entries
        .map((item) {
          if (item.value) {
            return additionalOperationTempList[item.key];
          }
        })
        .whereType<MediaItem>()
        .toList();
  }

  void cancelAdditionalOperation() {
    sortWidgetController!.isAllSelected.value = false;
    sortWidgetController = null;
    additionalOperationMode.value = OperationMode.none;
    additionalOperationTempList.clear();
    additionalOperationTempMap.clear();
  }
}
