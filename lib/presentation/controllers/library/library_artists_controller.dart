import 'package:get/get.dart';
import '../../../domain/library/usecases/get_library_artists_usecase.dart';
import '/models/artist.dart';
import '/utils/helper.dart';
import '/ui/widgets/sort_widget.dart';

/// Controller for Library Artists using Clean Architecture
class LibraryArtistsController extends GetxController {
  // Use Cases injection
  final GetLibraryArtistsUseCase _getLibraryArtistsUseCase;

  LibraryArtistsController({
    required GetLibraryArtistsUseCase getLibraryArtistsUseCase,
  }) : _getLibraryArtistsUseCase = getLibraryArtistsUseCase;

  // State
  RxList<Artist> libraryArtists = RxList();
  final isContentFetched = false.obs;
  List<Artist> tempListContainer = [];

  @override
  void onInit() {
    refreshLib();
    super.onInit();
  }

  Future<void> refreshLib() async {
    try {
      // Get artists from Use Case
      final artistEntities = await _getLibraryArtistsUseCase();

      // Convert entities to Artist models for UI compatibility
      libraryArtists.value =
          artistEntities.map((entity) => entity.toArtist()).toList();

      isContentFetched.value = true;
    } catch (e) {
      print('Failed to load library artists: $e');
      isContentFetched.value = true;
    }
  }

  /// Sort artists
  void onSort(SortType sortType, bool isAscending) {
    final artistList = libraryArtists.toList();
    sortArtist(artistList, sortType, isAscending);
    libraryArtists.value = artistList;
  }

  /// Search
  void onSearchStart(String? tag) {
    tempListContainer = libraryArtists.toList();
  }

  void onSearch(String value, String? tag) {
    final songlist = tempListContainer
        .where((element) =>
            element.name.toLowerCase().contains(value.toLowerCase()))
        .toList();
    libraryArtists.value = songlist;
  }

  void onSearchClose(String? tag) {
    libraryArtists.value = tempListContainer.toList();
    tempListContainer.clear();
  }
}
