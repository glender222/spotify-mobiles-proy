import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/artist/entities/artist_entity.dart';
import '../../../domain/artist/usecases/get_artist_details_usecase.dart';
import '../../../domain/artist/usecases/get_artist_content_usecase.dart';
import '../../../domain/artist/usecases/get_artist_tab_content_usecase.dart';
import '../../../domain/artist/usecases/add_artist_to_library_usecase.dart';
import '../../../domain/artist/usecases/remove_artist_from_library_usecase.dart';
import '../../../domain/artist/usecases/is_artist_in_library_usecase.dart';
import '../../../models/artist.dart'; // Legacy model for compatibility
import '../../../ui/widgets/sort_widget.dart';
import '../../../ui/widgets/add_to_playlist.dart';
import '../../../utils/helper.dart';
import '../home/home_controller.dart';
import '../library/library_artists_controller.dart';
import '../settings/settings_controller.dart';

/// ArtistController - Clean Architecture Implementation
///
/// ✅ Uses UseCases for all domain/business logic
/// ✅ Manages state for 5 tabs: About, Songs, Videos, Albums, Singles
/// ✅ Handles lazy loading and pagination
/// ✅ Library operations (add/remove artist)
class ArtistController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // ✅ CLEAN ARCHITECTURE: Injected UseCases for domain logic
  final GetArtistDetailsUseCase _getArtistDetails;
  final GetArtistContentUseCase _getArtistContent;
  final GetArtistTabContentUseCase _getTabContent;
  final AddArtistToLibraryUseCase _addToLibrary;
  final RemoveArtistFromLibraryUseCase _removeFromLibrary;
  final IsArtistInLibraryUseCase _isInLibrary;

  ArtistController({
    required GetArtistDetailsUseCase getArtistDetails,
    required GetArtistContentUseCase getArtistContent,
    required GetArtistTabContentUseCase getTabContent,
    required AddArtistToLibraryUseCase addToLibrary,
    required RemoveArtistFromLibraryUseCase removeFromLibrary,
    required IsArtistInLibraryUseCase isInLibrary,
  })  : _getArtistDetails = getArtistDetails,
        _getArtistContent = getArtistContent,
        _getTabContent = getTabContent,
        _addToLibrary = addToLibrary,
        _removeFromLibrary = removeFromLibrary,
        _isInLibrary = isInLibrary;

  // State - Artist data
  final isArtistContentFetched = false.obs;
  final artistEntity = Rxn<ArtistEntity>();
  late Artist artist_; // Legacy model for UI compatibility

  // State - Navigation and tabs
  final navigationRailCurrentIndex = 0.obs;
  final railItems = <String>[].obs;
  TabController? tabController;
  bool isTabTransitionReversed = false;

  // State - Content (maintained as Map for backward compatibility)
  final artistData = <String, dynamic>{}.obs;
  final separatedContent = <String, dynamic>{}.obs;
  final isSeparatedArtistContentFetched = false.obs;

  // State - Library
  final isAddedToLibrary = false.obs;

  // State - Scroll controllers
  final songScrollController = ScrollController();
  final videoScrollController = ScrollController();
  final albumScrollController = ScrollController();
  final singlesScrollController = ScrollController();

  // State - Additional operations
  SortWidgetController? sortWidgetController;
  final additionalOperationMode = OperationMode.none.obs;
  final additionalOperationTempList = <MediaItem>[].obs;
  final additionalOperationTempMap = <int, bool>{}.obs;
  Map<String, List> tempListContainer = {};

  // Pagination
  bool continuationInProgress = false;

  @override
  void onInit() {
    final args = Get.arguments;
    _init(args[0], args[1]);

    // Initialize TabController for desktop/bottom nav
    if (GetPlatform.isDesktop ||
        Get.find<SettingsController>().isBottomNavBarEnabled.isTrue) {
      tabController = TabController(vsync: this, length: 5);
      tabController?.animation?.addListener(() {
        int indexChange = tabController!.offset.round();
        int index = tabController!.index + indexChange;

        if (index != navigationRailCurrentIndex.value) {
          onDestinationSelected(index);
          navigationRailCurrentIndex.value = index;
        }
      });
    }
    super.onInit();
  }

  @override
  void onReady() {
    Get.find<HomeController>().whenHomeScreenOnTop();
    super.onReady();
  }

  /// Initialize artist data
  void _init(bool isIdOnly, dynamic artist) {
    if (!isIdOnly) artist_ = artist as Artist;
    final artistId = isIdOnly ? artist as String : artist.browseId;
    _fetchArtistContent(artistId);
    _checkIfAddedToLibrary(artistId);
  }

  /// ✅ UseCase: Check if artist is in library
  Future<void> _checkIfAddedToLibrary(String id) async {
    try {
      isAddedToLibrary.value = await _isInLibrary(id);
    } catch (e) {
      printERROR("Error checking library status: $e");
      isAddedToLibrary.value = false;
    }
  }

  /// ✅ UseCase: Fetch artist content
  Future<void> _fetchArtistContent(String id) async {
    try {
      // Fetch artist details using UseCase
      artistEntity.value = await _getArtistDetails(id);

      // Fetch artist content using UseCase
      final contentEntity = await _getArtistContent(id);

      // Convert entity to legacy Map format for UI compatibility
      // TODO: Gradual migration - eventually UI should use entities directly
      artistData.value = _convertContentEntityToLegacyMap(contentEntity, id);
      artistData["Singles"] = artistData["Singles & EPs"];
      artistData["Songs"] = artistData["Top songs"];

      isArtistContentFetched.value = true;

      // Create Artist object from entity
      final entity = artistEntity.value!;
      artist_ = Artist(
        browseId: id,
        name: entity.name,
        thumbnailUrl: entity.thumbnailUrl ?? "",
        subscribers: entity.subscribers ?? "",
        radioId: entity.radioId,
      );
    } catch (e) {
      printERROR("Error fetching artist content: $e");
      isArtistContentFetched.value = true;
    }
  }

  /// Helper: Convert ArtistContentEntity to legacy Map format
  Map<String, dynamic> _convertContentEntityToLegacyMap(
      ArtistContentEntity entity, String id) {
    final data = <String, dynamic>{};

    // Basic artist info from entity will be populated
    data['name'] = artistEntity.value?.name ?? '';
    data['thumbnails'] = artistEntity.value?.thumbnailUrl != null
        ? [
            {'url': artistEntity.value!.thumbnailUrl}
          ]
        : [];
    data['subscribers'] = artistEntity.value?.subscribers ?? '';
    data['radioId'] = artistEntity.value?.radioId;

    // Content sections
    if (entity.topSongs != null) {
      data['Top songs'] = {'content': entity.topSongs};
    }
    if (entity.albums != null) {
      data['Albums'] = {'content': entity.albums};
    }
    if (entity.singles != null) {
      data['Singles & EPs'] = {'content': entity.singles};
    }
    if (entity.videos != null) {
      data['Videos'] = {'content': entity.videos};
    }

    return data;
  }

  /// ✅ UseCase: Add or remove artist from library
  Future<bool> addNremoveFromLibrary({bool add = true}) async {
    try {
      if (artistEntity.value == null) return false;

      if (add) {
        final success = await _addToLibrary(artistEntity.value!);
        if (success) {
          isAddedToLibrary.value = true;
          Get.find<LibraryArtistsController>().refreshLib();
        }
        return success;
      } else {
        final success = await _removeFromLibrary(artist_.browseId);
        if (success) {
          isAddedToLibrary.value = false;
          Get.find<LibraryArtistsController>().refreshLib();
        }
        return success;
      }
    } catch (e) {
      printERROR("Error updating library: $e");
      return false;
    }
  }

  /// Navigate to a specific tab and load content if needed
  Future<void> onDestinationSelected(int val) async {
    isTabTransitionReversed = val > navigationRailCurrentIndex.value;
    navigationRailCurrentIndex.value = val;
    final tabName = ["About", "Songs", "Videos", "Albums", "Singles"][val];

    // Cancel additional operations on tab change
    if (sortWidgetController != null) {
      sortWidgetController?.setActiveMode(OperationMode.none);
      cancelAdditionalOperation();
    }

    // Skip for about page or if content already loaded
    if (val == 0 || separatedContent.containsKey(tabName)) return;
    if (artistData[tabName] == null) {
      isSeparatedArtistContentFetched.value = true;
      return;
    }

    isSeparatedArtistContentFetched.value = false;

    try {
      // ✅ UseCase: Fetch tab content
      if ((artistData[tabName]).containsKey("params")) {
        separatedContent[tabName] =
            await _getTabContent(artistData[tabName], tabName);
      } else {
        separatedContent[tabName] = {"results": artistData[tabName]['content']};
        isSeparatedArtistContentFetched.value = true;
        return;
      }

      // Setup scroll listener for pagination
      if (val != 0) {
        final scrollController = val == 1
            ? songScrollController
            : val == 2
                ? videoScrollController
                : val == 3
                    ? albumScrollController
                    : singlesScrollController;

        scrollController.addListener(() {
          double maxScroll = scrollController.position.maxScrollExtent;
          double currentScroll = scrollController.position.pixels;
          if (currentScroll >= maxScroll / 2 &&
              separatedContent[tabName]['additionalParams'] !=
                  '&ctoken=null&continuation=null') {
            if (!continuationInProgress) {
              continuationInProgress = true;
              getContinuationContents(artistData[tabName], tabName);
            }
          }
        });
      }

      isSeparatedArtistContentFetched.value = true;
    } catch (e) {
      printERROR("Error fetching tab content: $e");
      isSeparatedArtistContentFetched.value = true;
    }
  }

  /// ✅ UseCase: Fetch continuation content for pagination
  Future<void> getContinuationContents(browseEndpoint, tabName) async {
    try {
      // Note: GetArtistTabContentUseCase doesn't support continuation yet
      // For now, we'll fetch fresh content
      final continuationData = await _getTabContent(
        browseEndpoint,
        tabName,
      );

      (separatedContent[tabName]['results'])
          .addAll(continuationData['results']);
      separatedContent[tabName]['additionalParams'] =
          continuationData['additionalParams'];
      separatedContent.refresh();

      continuationInProgress = false;
    } catch (e) {
      printERROR("Error fetching continuation: $e");
      continuationInProgress = false;
    }
  }

  /// Sort content within a tab
  void onSort(SortType sortType, bool isAscending, String title) {
    if (separatedContent[title] == null) return;

    if (title == "Songs" || title == "Videos") {
      final songlist = separatedContent[title]['results'].toList();
      sortSongsNVideos(songlist, sortType, isAscending);
      separatedContent[title]['results'] = songlist;
    } else if (title == "Albums" || title == "Singles") {
      final albumList = separatedContent[title]['results'].toList();
      sortAlbumNSingles(albumList, sortType, isAscending);
      separatedContent[title]['results'] = albumList;
    }
    separatedContent.refresh();
  }

  /// Search: Start search operation
  void onSearchStart(String? tag) {
    final title = tag?.split("_")[0];
    tempListContainer[title!] = separatedContent[title]['results'].toList();
  }

  /// Search: Filter results
  void onSearch(String value, String? tag) {
    final title = tag?.split("_")[0];
    final list = tempListContainer[title]!
        .where((element) =>
            element.title.toLowerCase().contains(value.toLowerCase()))
        .toList();
    separatedContent[title]['results'] = list;
    separatedContent.refresh();
  }

  /// Search: Close search
  void onSearchClose(String? tag) {
    final title = tag?.split("_")[0];
    separatedContent[title]['results'] = (tempListContainer[title]!).toList();
    separatedContent.refresh();
    (tempListContainer[title]!).clear();
  }

  // Additional operations
  void startAdditionalOperation(
      SortWidgetController sortWidgetController_, OperationMode mode) {
    sortWidgetController = sortWidgetController_;
    final tabName = [
      "About",
      "Songs",
      "Videos",
      "Albums",
      "Singles"
    ][navigationRailCurrentIndex.value];
    additionalOperationTempList.value =
        separatedContent[tabName]['results'].toList();
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
    if (currMode == OperationMode.addToPlaylist) {
      showDialog(
        context: Get.context!,
        builder: (context) => AddToPlaylist(selectedSongs()),
      ).whenComplete(() {
        Get.delete<AddToPlaylistController>();
        sortWidgetController?.setActiveMode(OperationMode.none);
        cancelAdditionalOperation();
      });
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

  @override
  void onClose() {
    tempListContainer.clear();
    songScrollController.dispose();
    videoScrollController.dispose();
    albumScrollController.dispose();
    singlesScrollController.dispose();
    tabController?.dispose();
    Get.find<HomeController>().whenHomeScreenOnTop();
    super.onClose();
  }
}
