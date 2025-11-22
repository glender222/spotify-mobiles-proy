import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../domain/home/usecases/get_home_page_content_usecase.dart';
import '../../../domain/home/usecases/get_recently_played_usecase.dart';
import '../../../domain/home/usecases/get_recommendations_usecase.dart';
import '../../../domain/home/usecases/get_cached_home_content_usecase.dart';
import '../../../domain/home/usecases/cache_home_content_usecase.dart';
import '../../../domain/home/usecases/get_quick_picks_usecase.dart';
import '../../../utils/update_check_flag_file.dart';
import '../../../utils/helper.dart';
import '/models/album.dart';
import '/models/playlist.dart';
import '/models/quick_picks.dart';
import '../settings/settings_controller.dart';
import '/ui/widgets/new_version_dialog.dart';
import '/ui/player/player_controller.dart';
import '../../../domain/home/entities/album_entity.dart';
import '../../../domain/playlist/entities/playlist_entity.dart';

class HomeController extends GetxController {
  final GetHomePageContentUseCase _getHomePageContentUseCase =
      Get.find<GetHomePageContentUseCase>();
  final GetRecentlyPlayedUseCase _getRecentlyPlayedUseCase =
      Get.find<GetRecentlyPlayedUseCase>();
  final GetRecommendationsUseCase _getRecommendationsUseCase =
      Get.find<GetRecommendationsUseCase>();
  final GetCachedHomeContentUseCase _getCachedHomeContentUseCase =
      Get.find<GetCachedHomeContentUseCase>();
  final CacheHomeContentUseCase _cacheHomeContentUseCase =
      Get.find<CacheHomeContentUseCase>();
  final GetQuickPicksUseCase _getQuickPicksUseCase =
      Get.find<GetQuickPicksUseCase>();

  final isContentFetched = false.obs;
  final networkError = false.obs;

  final recentlyPlayed = <MediaItem>[].obs;
  final recentPlaylists =
      <Playlist>[].obs; // This will be harder to refactor, handle later.
  final recommendations = <MediaItem>[].obs;
  final quickPicks = QuickPicks([]).obs;
  final middleContent = [].obs;
  final fixedContent = [].obs;

  // UI state variables - remain unchanged
  final tabIndex = 0.obs;
  final showVersionDialog = true.obs;
  final isHomeSreenOnTop = true.obs;
  final List<ScrollController> contentScrollControllers = [];
  bool reverseAnimationtransiton = false;

  @override
  onInit() {
    super.onInit();
    loadContent();
    if (updateCheckFlag) _checkNewVersion();
  }

  Future<void> loadContent() async {
    isContentFetched.value = false;
    networkError.value = false;
    try {
      // Load local history and recommendations (Clean Architecture)
      final localHistory = await _getRecentlyPlayedUseCase();
      final localRecommendations = await _getRecommendationsUseCase();

      recentlyPlayed.value = localHistory;
      recommendations.value = localRecommendations;

      // Also load home content sections (albums, playlists, etc.)
      final cachedContent = await _getCachedHomeContentUseCase();
      if (cachedContent.isNotEmpty) {
        // Load from cache
        fixedContent.value = _mapSectionsToLegacy(cachedContent);
        isContentFetched.value = true;
      } else {
        // Load from network if cache is empty
        await loadContentFromNetwork();
      }
    } catch (e) {
      networkError.value = true;
      printERROR('[Home] Failed to load content: $e');
    }
  }

  Future<void> loadContentFromNetwork({bool silent = false}) async {
    networkError.value = false;
    try {
      final homeSections = await _getHomePageContentUseCase();
      fixedContent.value = _mapSectionsToLegacy(homeSections);
      middleContent.value = []; // Simplifying for now

      // We still need to handle quick picks separately for now
      final String contentType =
          Hive.box("AppPrefs").get("discoverContentType") ?? "QP";
      final quickPicksEntity = await _getQuickPicksUseCase(contentType);
      quickPicks.value = QuickPicks(
          quickPicksEntity.items
              .map((track) => MediaItem(
                  id: track.id, title: track.title, artist: track.artist))
              .toList(),
          title: quickPicksEntity.title);

      isContentFetched.value = true;
      _cacheHomeContentUseCase(homeSections);
    } catch (e) {
      printERROR('[Home] Failed to load content from network: $e');
      if (!silent) {
        networkError.value = true;
        // Check if we have any cached content to show
        final cachedSections = await _getCachedHomeContentUseCase();
        if (cachedSections.isNotEmpty) {
          fixedContent.value = _mapSectionsToLegacy(cachedSections);
          isContentFetched.value = true;
          printINFO('[Home] Displaying cached content due to network error');
        }
      }
    }
  }

  List<dynamic> _mapSectionsToLegacy(List<dynamic> sections) {
    return sections
        .map((section) {
          if (section.items.every((item) => item is AlbumEntity)) {
            return AlbumContent(
              title: section.title ?? 'Untitled',
              albumList: (section.items as List)
                  .cast<AlbumEntity>()
                  .map((item) => Album(
                        browseId: item.id ?? '',
                        title: item.title ?? 'Unknown Album',
                        artists: [
                          {'name': item.artist ?? 'Unknown Artist'}
                        ],
                        thumbnailUrl: item.thumbnailUrl ?? '',
                      ))
                  .toList(),
            );
          } else if (section.items.every((item) => item is PlaylistEntity)) {
            return PlaylistContent(
              title: section.title ?? 'Untitled',
              playlistList: (section.items as List)
                  .cast<PlaylistEntity>()
                  .map((item) => Playlist(
                        playlistId: item.id ?? '',
                        title: item.title ?? 'Unknown Playlist',
                        thumbnailUrl: item.thumbnailUrl ?? '',
                      ))
                  .toList(),
            );
          }
          return null;
        })
        .where((item) => item != null)
        .toList();
  }

  Future<void> changeDiscoverContent(dynamic val, {String? songId}) async {
    try {
      final quickPicksEntity = await _getQuickPicksUseCase(val, songId: songId);
      quickPicks.value = QuickPicks(
          quickPicksEntity.items
              .map((track) => MediaItem(
                  id: track.id, title: track.title, artist: track.artist))
              .toList(),
          title: quickPicksEntity.title);
      if (val == "BOLI" && songId != null) {
        Hive.box("AppPrefs").put("recentSongId", songId);
      }
    } catch (e) {
      printERROR("Failed to change discover content: $e");
    }
  }

  // All other methods (UI logic, version check, etc.) remain unchanged for now.

  String getContentHlCode() {
    const List<String> unsupportedLangIds = ["ia", "ga", "fj", "eo"];
    final userLangId =
        Get.find<SettingsController>().currentAppLanguageCode.value;
    return unsupportedLangIds.contains(userLangId) ? "en" : userLangId;
  }

  void onSideBarTabSelected(int index) {
    reverseAnimationtransiton = index > tabIndex.value;
    tabIndex.value = index;
  }

  void onBottonBarTabSelected(int index) {
    reverseAnimationtransiton = index > tabIndex.value;
    tabIndex.value = index;
  }

  void _checkNewVersion() {
    showVersionDialog.value =
        Hive.box("AppPrefs").get("newVersionVisibility") ?? true;
    if (showVersionDialog.isTrue) {
      newVersionCheck(Get.find<SettingsController>().currentVersion)
          .then((value) {
        if (value) {
          showDialog(
              context: Get.context!,
              builder: (context) => const NewVersionDialog());
        }
      });
    }
  }

  void onChangeVersionVisibility(bool val) {
    Hive.box("AppPrefs").put("newVersionVisibility", !val);
    showVersionDialog.value = !val;
  }

  void whenHomeScreenOnTop() {
    if (Get.find<SettingsController>().isBottomNavBarEnabled.isTrue) {
      final currentRoute = getCurrentRouteName();
      final isHomeOnTop = currentRoute == '/homeScreen';
      final isResultScreenOnTop = currentRoute == '/searchResultScreen';
      final playerCon = Get.find<PlayerController>();

      isHomeSreenOnTop.value = isHomeOnTop;

      if (!playerCon.initFlagForPlayer) {
        if (isHomeOnTop) {
          playerCon.playerPanelMinHeight.value = 75.0;
        } else {
          Future.delayed(
              isResultScreenOnTop
                  ? const Duration(milliseconds: 300)
                  : Duration.zero, () {
            playerCon.playerPanelMinHeight.value =
                75.0 + Get.mediaQuery.viewPadding.bottom;
          });
        }
      }
    }
  }

  void disposeDetachedScrollControllers({bool disposeAll = false}) {
    final scrollControllersCopy = contentScrollControllers.toList();
    for (final contoller in scrollControllersCopy) {
      if (!contoller.hasClients || disposeAll) {
        contentScrollControllers.remove(contoller);
        contoller.dispose();
      }
    }
  }

  @override
  void dispose() {
    disposeDetachedScrollControllers(disposeAll: true);
    super.dispose();
  }

  // TODO: Refactor caching logic to be handled by a use case.
  // This is a temporary stub to prevent breaking other parts of the app.
  Future<void> cachedHomeScreenData(
      {bool updateAll = false,
      bool updateQuickPicksNMiddleContent = false}) async {}
}
