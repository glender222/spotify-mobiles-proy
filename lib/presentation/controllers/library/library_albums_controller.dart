import 'package:get/get.dart';
import '../../../domain/library/usecases/get_library_albums_usecase.dart';
import '/models/album.dart';
import '/utils/helper.dart';
import '/ui/widgets/sort_widget.dart';

/// Controller for Library Albums using Clean Architecture
class LibraryAlbumsController extends GetxController {
  // Use Cases injection
  final GetLibraryAlbumsUseCase _getLibraryAlbumsUseCase;

  LibraryAlbumsController({
    required GetLibraryAlbumsUseCase getLibraryAlbumsUseCase,
  }) : _getLibraryAlbumsUseCase = getLibraryAlbumsUseCase;

  // State
  late RxList<Album> libraryAlbums = RxList();
  final isContentFetched = false.obs;
  List<Album> tempListContainer = [];

  @override
  void onInit() {
    refreshLib();
    super.onInit();
  }

  Future<void> refreshLib() async {
    try {
      // Get albums from Use Case
      final albumEntities = await _getLibraryAlbumsUseCase();

      // Convert entities to Album models for UI compatibility
      libraryAlbums.value =
          albumEntities.map((entity) => entity.toAlbum()).toList();

      isContentFetched.value = true;
    } catch (e) {
      printERROR('Failed to load library albums: $e');
      isContentFetched.value = true;
    }
  }

  /// Sort albums
  void onSort(SortType sortType, bool isAscending) {
    final albumList = libraryAlbums.toList();
    sortAlbumNSingles(albumList, sortType, isAscending);
    libraryAlbums.value = albumList;
  }

  /// Search
  void onSearchStart(String? tag) {
    tempListContainer = libraryAlbums.toList();
  }

  void onSearch(String value, String? tag) {
    final songlist = tempListContainer
        .where((element) =>
            element.title.toLowerCase().contains(value.toLowerCase()))
        .toList();
    libraryAlbums.value = songlist;
  }

  void onSearchClose(String? tag) {
    libraryAlbums.value = tempListContainer.toList();
    tempListContainer.clear();
  }
}
