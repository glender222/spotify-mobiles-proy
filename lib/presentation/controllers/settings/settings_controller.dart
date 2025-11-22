import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../../domain/settings/usecases/clear_images_cache_usecase.dart';
import '../../../domain/settings/usecases/enable_ignoring_battery_optimizations_usecase.dart';
import '../../../domain/settings/usecases/get_app_language_usecase.dart';
import '../../../domain/settings/usecases/get_discover_content_type_usecase.dart';
import '../../../domain/settings/usecases/get_download_location_usecase.dart';
import '../../../domain/settings/usecases/get_downloading_format_usecase.dart';
import '../../../domain/settings/usecases/get_exported_location_usecase.dart';
import '../../../domain/settings/usecases/get_home_screen_content_number_usecase.dart';
import '../../../domain/settings/usecases/get_player_ui_usecase.dart';
import '../../../domain/settings/usecases/get_streaming_quality_usecase.dart';
import '../../../domain/settings/usecases/get_theme_mode_usecase.dart';
import '../../../domain/settings/usecases/is_auto_download_favorite_song_enabled_usecase.dart';
import '../../../domain/settings/usecases/is_background_play_enabled_usecase.dart';
import '../../../domain/settings/usecases/is_bottom_nav_bar_enabled_usecase.dart';
import '../../../domain/settings/usecases/is_cache_home_screen_data_enabled_usecase.dart';
import '../../../domain/settings/usecases/is_caching_songs_enabled_usecase.dart';
import '../../../domain/settings/usecases/is_ignoring_battery_optimizations_usecase.dart';
import '../../../domain/settings/usecases/is_loudness_normalization_enabled_usecase.dart';
import '../../../domain/settings/usecases/is_piped_linked_usecase.dart';
import '../../../domain/settings/usecases/is_skip_silence_enabled_usecase.dart';
import '../../../domain/settings/usecases/is_slidable_action_enabled_usecase.dart';
import '../../../domain/settings/usecases/is_transition_animation_disabled_usecase.dart';
import '../../../domain/settings/usecases/reset_app_settings_to_default_usecase.dart';
import '../../../domain/settings/usecases/reset_download_location_usecase.dart';
import '../../../domain/settings/usecases/set_app_language_usecase.dart';
import '../../../domain/settings/usecases/set_auto_download_favorite_song_enabled_usecase.dart';
import '../../../domain/settings/usecases/set_auto_open_player_usecase.dart';
import '../../../domain/settings/usecases/set_background_play_enabled_usecase.dart';
import '../../../domain/settings/usecases/set_bottom_nav_bar_enabled_usecase.dart';
import '../../../domain/settings/usecases/set_cache_home_screen_data_enabled_usecase.dart';
import '../../../domain/settings/usecases/set_caching_songs_enabled_usecase.dart';
import '../../../domain/settings/usecases/set_discover_content_type_usecase.dart';
import '../../../domain/settings/usecases/set_download_location_usecase.dart';
import '../../../domain/settings/usecases/set_downloading_format_usecase.dart';
import '../../../domain/settings/usecases/set_exported_location_usecase.dart';
import '../../../domain/settings/usecases/set_home_screen_content_number_usecase.dart';
import '../../../domain/settings/usecases/set_loudness_normalization_enabled_usecase.dart';
import '../../../domain/settings/usecases/set_player_ui_usecase.dart';
import '../../../domain/settings/usecases/set_restore_playback_session_usecase.dart';
import '../../../domain/settings/usecases/set_skip_silence_enabled_usecase.dart';
import '../../../domain/settings/usecases/set_slidable_action_enabled_usecase.dart';
import '../../../domain/settings/usecases/set_stop_playback_on_swipe_away_usecase.dart';
import '../../../domain/settings/usecases/set_streaming_quality_usecase.dart';
import '../../../domain/settings/usecases/set_theme_mode_usecase.dart';
import '../../../domain/settings/usecases/set_transition_animation_disabled_usecase.dart';
import '../../../domain/settings/usecases/should_auto_open_player_usecase.dart';
import '../../../domain/settings/usecases/should_restore_playback_session_usecase.dart';
import '../../../domain/settings/usecases/should_stop_playback_on_swipe_away_usecase.dart';
import '../../../domain/settings/usecases/unlink_piped_usecase.dart';
import '../../../services/music_service.dart';
import '../../../utils/helper.dart';
import '../../../utils/update_check_flag_file.dart';
import '../../../ui/player/player_controller.dart';
import '../../../ui/utils/theme_controller.dart';
import '../home/home_controller.dart';

class SettingsController extends GetxController {
  late String _supportDir;
  final cacheSongs = false.obs;
  final themeModetype = ThemeType.dynamic.obs;
  final skipSilenceEnabled = false.obs;
  final loudnessNormalizationEnabled = false.obs;
  final noOfHomeScreenContent = 3.obs;
  final streamingQuality = AudioQuality.High.obs;
  final playerUi = 0.obs;
  final slidableActionEnabled = true.obs;
  final isIgnoringBatteryOptimizations = false.obs;
  final autoOpenPlayer = false.obs;
  final discoverContentType = "QP".obs;
  final isNewVersionAvailable = false.obs;
  final isLinkedWithPiped = false.obs;
  final stopPlyabackOnSwipeAway = false.obs;
  final currentAppLanguageCode = "en".obs;
  final downloadLocationPath = "".obs;
  final exportLocationPath = "".obs;
  final downloadingFormat = "".obs;
  final hideDloc = true.obs;
  final autoDownloadFavoriteSongEnabled = false.obs;
  final isTransitionAnimationDisabled = false.obs;
  final isBottomNavBarEnabled = false.obs;
  final backgroundPlayEnabled = true.obs;
  final restorePlaybackSession = false.obs;
  final cacheHomeScreenData = true.obs;
  final currentVersion = "V1.12.1";

  // Use Cases
  final _getAppLanguageUseCase = Get.find<GetAppLanguageUseCase>();
  final _setAppLanguageUseCase = Get.find<SetAppLanguageUseCase>();
  final _getHomeScreenContentNumberUseCase =
      Get.find<GetHomeScreenContentNumberUseCase>();
  final _setHomeScreenContentNumberUseCase =
      Get.find<SetHomeScreenContentNumberUseCase>();
  final _getStreamingQualityUseCase = Get.find<GetStreamingQualityUseCase>();
  final _setStreamingQualityUseCase = Get.find<SetStreamingQualityUseCase>();
  final _getPlayerUiUseCase = Get.find<GetPlayerUiUseCase>();
  final _setPlayerUiUseCase = Get.find<SetPlayerUiUseCase>();
  final _isBottomNavBarEnabledUseCase =
      Get.find<IsBottomNavBarEnabledUseCase>();
  final _setBottomNavBarEnabledUseCase =
      Get.find<SetBottomNavBarEnabledUseCase>();
  final _isSlidableActionEnabledUseCase =
      Get.find<IsSlidableActionEnabledUseCase>();
  final _setSlidableActionEnabledUseCase =
      Get.find<SetSlidableActionEnabledUseCase>();
  final _getDownloadingFormatUseCase = Get.find<GetDownloadingFormatUseCase>();
  final _setDownloadingFormatUseCase = Get.find<SetDownloadingFormatUseCase>();
  final _getExportedLocationUseCase = Get.find<GetExportedLocationUseCase>();
  final _setExportedLocationUseCase = Get.find<SetExportedLocationUseCase>();
  final _getDownloadLocationUseCase = Get.find<GetDownloadLocationUseCase>();
  final _setDownloadLocationUseCase = Get.find<SetDownloadLocationUseCase>();
  final _resetDownloadLocationUseCase =
      Get.find<ResetDownloadLocationUseCase>();
  final _isTransitionAnimationDisabledUseCase =
      Get.find<IsTransitionAnimationDisabledUseCase>();
  final _setTransitionAnimationDisabledUseCase =
      Get.find<SetTransitionAnimationDisabledUseCase>();
  final _clearImagesCacheUseCase = Get.find<ClearImagesCacheUseCase>();
  final _getThemeModeUseCase = Get.find<GetThemeModeUseCase>();
  final _setThemeModeUseCase = Get.find<SetThemeModeUseCase>();
  final _getDiscoverContentTypeUseCase =
      Get.find<GetDiscoverContentTypeUseCase>();
  final _setDiscoverContentTypeUseCase =
      Get.find<SetDiscoverContentTypeUseCase>();
  final _isCachingSongsEnabledUseCase =
      Get.find<IsCachingSongsEnabledUseCase>();
  final _setCachingSongsEnabledUseCase =
      Get.find<SetCachingSongsEnabledUseCase>();
  final _isSkipSilenceEnabledUseCase = Get.find<IsSkipSilenceEnabledUseCase>();
  final _setSkipSilenceEnabledUseCase =
      Get.find<SetSkipSilenceEnabledUseCase>();
  final _isLoudnessNormalizationEnabledUseCase =
      Get.find<IsLoudnessNormalizationEnabledUseCase>();
  final _setLoudnessNormalizationEnabledUseCase =
      Get.find<SetLoudnessNormalizationEnabledUseCase>();
  final _shouldRestorePlaybackSessionUseCase =
      Get.find<ShouldRestorePlaybackSessionUseCase>();
  final _setRestorePlaybackSessionUseCase =
      Get.find<SetRestorePlaybackSessionUseCase>();
  final _isCacheHomeScreenDataEnabledUseCase =
      Get.find<IsCacheHomeScreenDataEnabledUseCase>();
  final _setCacheHomeScreenDataEnabledUseCase =
      Get.find<SetCacheHomeScreenDataEnabledUseCase>();
  final _isAutoDownloadFavoriteSongEnabledUseCase =
      Get.find<IsAutoDownloadFavoriteSongEnabledUseCase>();
  final _setAutoDownloadFavoriteSongEnabledUseCase =
      Get.find<SetAutoDownloadFavoriteSongEnabledUseCase>();
  final _isBackgroundPlayEnabledUseCase =
      Get.find<IsBackgroundPlayEnabledUseCase>();
  final _setBackgroundPlayEnabledUseCase =
      Get.find<SetBackgroundPlayEnabledUseCase>();
  final _isIgnoringBatteryOptimizationsUseCase =
      Get.find<IsIgnoringBatteryOptimizationsUseCase>();
  final _enableIgnoringBatteryOptimizationsUseCase =
      Get.find<EnableIgnoringBatteryOptimizationsUseCase>();
  final _shouldAutoOpenPlayerUseCase = Get.find<ShouldAutoOpenPlayerUseCase>();
  final _setAutoOpenPlayerUseCase = Get.find<SetAutoOpenPlayerUseCase>();
  final _isPipedLinkedUseCase = Get.find<IsPipedLinkedUseCase>();
  final _unlinkPipedUseCase = Get.find<UnlinkPipedUseCase>();
  final _resetAppSettingsToDefaultUseCase =
      Get.find<ResetAppSettingsToDefaultUseCase>();
  final _shouldStopPlaybackOnSwipeAwayUseCase =
      Get.find<ShouldStopPlaybackOnSwipeAwayUseCase>();
  final _setStopPlaybackOnSwipeAwayUseCase =
      Get.find<SetStopPlaybackOnSwipeAwayUseCase>();

  @override
  void onInit() {
    _setInitValue();
    if (updateCheckFlag) _checkNewVersion();
    _createInAppSongDownDir();
    super.onInit();
  }

  get currentVision => currentVersion;
  get isCurrentPathsupportDownDir =>
      "$_supportDir/Music" == downloadLocationPath.toString();
  String get supportDirPath => _supportDir;

  Future<String> get dbDir async {
    if (GetPlatform.isAndroid || GetPlatform.isIOS) {
      return (await getApplicationDocumentsDirectory()).path;
    } else {
      return (await getApplicationSupportDirectory()).path;
    }
  }

  Future<void> closeAllDatabases() async {
    await Hive.close();
  }

  _checkNewVersion() {
    newVersionCheck(currentVersion)
        .then((value) => isNewVersionAvailable.value = value);
  }

  Future<String> _createInAppSongDownDir() async {
    _supportDir = (await getApplicationSupportDirectory()).path;
    final directory = Directory("$_supportDir/Music/");
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return "$_supportDir/Music";
  }

  Future<void> _setInitValue() async {
    currentAppLanguageCode.value = _getAppLanguageUseCase();
    isBottomNavBarEnabled.value = _isBottomNavBarEnabledUseCase();
    noOfHomeScreenContent.value = _getHomeScreenContentNumberUseCase();
    isTransitionAnimationDisabled.value =
        _isTransitionAnimationDisabledUseCase();
    cacheSongs.value = _isCachingSongsEnabledUseCase();
    themeModetype.value = _getThemeModeUseCase();
    skipSilenceEnabled.value = _isSkipSilenceEnabledUseCase();
    loudnessNormalizationEnabled.value =
        _isLoudnessNormalizationEnabledUseCase();
    autoOpenPlayer.value = _shouldAutoOpenPlayerUseCase();
    restorePlaybackSession.value = _shouldRestorePlaybackSessionUseCase();
    cacheHomeScreenData.value = _isCacheHomeScreenDataEnabledUseCase();
    streamingQuality.value = _getStreamingQualityUseCase();
    playerUi.value = _getPlayerUiUseCase();
    backgroundPlayEnabled.value = _isBackgroundPlayEnabledUseCase();
    downloadLocationPath.value = await _getDownloadLocationUseCase();
    exportLocationPath.value = await _getExportedLocationUseCase();
    downloadingFormat.value = _getDownloadingFormatUseCase();
    discoverContentType.value = _getDiscoverContentTypeUseCase();
    slidableActionEnabled.value = _isSlidableActionEnabledUseCase();
    isLinkedWithPiped.value = await _isPipedLinkedUseCase();
    stopPlyabackOnSwipeAway.value = _shouldStopPlaybackOnSwipeAwayUseCase();
    isIgnoringBatteryOptimizations.value =
        await _isIgnoringBatteryOptimizationsUseCase();
    autoDownloadFavoriteSongEnabled.value =
        _isAutoDownloadFavoriteSongEnabledUseCase();
  }

  void setAppLanguage(String? val) {
    Get.updateLocale(Locale(val!));
    Get.find<MusicServices>().hlCode = val;
    Get.find<HomeController>().loadContentFromNetwork(silent: true);
    currentAppLanguageCode.value = val;
    _setAppLanguageUseCase(val);
  }

  void setContentNumber(int? no) {
    noOfHomeScreenContent.value = no!;
    _setHomeScreenContentNumberUseCase(no);
  }

  void setStreamingQuality(dynamic val) {
    _setStreamingQualityUseCase(val);
    streamingQuality.value = val;
  }

  void setPlayerUi(dynamic val) {
    final playerCon = Get.find<PlayerController>();
    _setPlayerUiUseCase(val);
    if (val == 1 && playerCon.gesturePlayerStateAnimationController == null) {
      playerCon.initGesturePlayerStateAnimationController();
    }
    playerUi.value = val;
  }

  void enableBottomNavBar(bool val) {
    final homeScrCon = Get.find<HomeController>();
    final playerCon = Get.find<PlayerController>();
    if (val) {
      homeScrCon.onSideBarTabSelected(3);
      isBottomNavBarEnabled.value = true;
    } else {
      isBottomNavBarEnabled.value = false;
      homeScrCon.onSideBarTabSelected(5);
    }
    if (!Get.find<PlayerController>().initFlagForPlayer) {
      playerCon.playerPanelMinHeight.value =
          val ? 75.0 : 75.0 + Get.mediaQuery.viewPadding.bottom;
    }
    _setBottomNavBarEnabledUseCase(val);
  }

  void toggleSlidableAction(bool val) {
    _setSlidableActionEnabledUseCase(val);
    slidableActionEnabled.value = val;
  }

  void changeDownloadingFormat(String? val) {
    _setDownloadingFormatUseCase(val!);
    downloadingFormat.value = val;
  }

  Future<void> setExportedLocation() async {
    await _setExportedLocationUseCase();
    exportLocationPath.value = await _getExportedLocationUseCase();
  }

  Future<void> setDownloadLocation() async {
    await _setDownloadLocationUseCase();
    downloadLocationPath.value = await _getDownloadLocationUseCase();
  }

  void showDownLoc() {
    hideDloc.value = false;
  }

  void disableTransitionAnimation(bool val) {
    _setTransitionAnimationDisabledUseCase(val);
    isTransitionAnimationDisabled.value = val;
  }

  Future<void> clearImagesCache() async {
    await _clearImagesCacheUseCase();
  }

  void resetDownloadLocation() {
    _resetDownloadLocationUseCase();
  }

  void onThemeChange(dynamic val) {
    _setThemeModeUseCase(val);
    themeModetype.value = val;
    Get.find<ThemeController>().changeThemeModeType(val);
  }

  void onContentChange(dynamic value) {
    _setDiscoverContentTypeUseCase(value);
    discoverContentType.value = value;
    Get.find<HomeController>().changeDiscoverContent(value);
  }

  void toggleCachingSongsValue(bool value) {
    _setCachingSongsEnabledUseCase(value);
    cacheSongs.value = value;
  }

  void toggleSkipSilence(bool val) {
    Get.find<PlayerController>().toggleSkipSilence(val);
    _setSkipSilenceEnabledUseCase(val);
    skipSilenceEnabled.value = val;
  }

  void toggleLoudnessNormalization(bool val) {
    Get.find<PlayerController>().toggleLoudnessNormalization(val);
    _setLoudnessNormalizationEnabledUseCase(val);
    loudnessNormalizationEnabled.value = val;
  }

  void toggleRestorePlaybackSession(bool val) {
    _setRestorePlaybackSessionUseCase(val);
    restorePlaybackSession.value = val;
  }

  Future<void> toggleCacheHomeScreenData(bool val) async {
    _setCacheHomeScreenDataEnabledUseCase(val);
    cacheHomeScreenData.value = val;
  }

  void toggleAutoDownloadFavoriteSong(bool val) {
    _setAutoDownloadFavoriteSongEnabledUseCase(val);
    autoDownloadFavoriteSongEnabled.value = val;
  }

  void toggleBackgroundPlay(bool val) {
    _setBackgroundPlayEnabledUseCase(val);
    backgroundPlayEnabled.value = val;
  }

  Future<void> enableIgnoringBatteryOptimizations() async {
    await _enableIgnoringBatteryOptimizationsUseCase();
    isIgnoringBatteryOptimizations.value =
        await _isIgnoringBatteryOptimizationsUseCase();
  }

  void toggleAutoOpenPlayer(bool val) {
    _setAutoOpenPlayerUseCase(val);
    autoOpenPlayer.value = val;
  }

  Future<void> unlinkPiped() async {
    await _unlinkPipedUseCase();
    isLinkedWithPiped.value = false;
  }

  Future<void> resetAppSettingsToDefault() async {
    await _resetAppSettingsToDefaultUseCase();
  }

  void toggleStopPlyabackOnSwipeAway(bool val) {
    _setStopPlaybackOnSwipeAwayUseCase(val);
    stopPlyabackOnSwipeAway.value = val;
  }
}
