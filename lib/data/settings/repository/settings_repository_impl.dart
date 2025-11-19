import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/services/permission_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../domain/settings/repository/settings_repository.dart';
import '../../../services/music_service.dart';
import '../../../ui/utils/theme_controller.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final Box _appPrefsBox = Hive.box("AppPrefs");
  late String _supportDir;

  SettingsRepositoryImpl() {
    _initSupportDir();
  }

  Future<void> _initSupportDir() async {
    _supportDir = (await getApplicationSupportDirectory()).path;
  }

  @override
  String getAppLanguage() {
    final appLang = _appPrefsBox.get('currentAppLanguageCode') ?? "en";
    return appLang == "zh_Hant"
        ? "zh-TW"
        : appLang == "zh_Hans"
            ? "zh-CN"
            : appLang;
  }

  @override
  Future<void> setAppLanguage(String languageCode) async {
    await _appPrefsBox.put('currentAppLanguageCode', languageCode);
  }

  @override
  int getHomeScreenContentNumber() {
    return _appPrefsBox.get("noOfHomeScreenContent") ?? 3;
  }

  @override
  Future<void> setHomeScreenContentNumber(int number) async {
    await _appPrefsBox.put("noOfHomeScreenContent", number);
  }

  @override
  AudioQuality getStreamingQuality() {
    return AudioQuality.values[_appPrefsBox.get('streamingQuality') ?? 1];
  }

  @override
  Future<void> setStreamingQuality(AudioQuality quality) async {
    await _appPrefsBox.put("streamingQuality", quality.index);
  }

  @override
  int getPlayerUi() {
    return GetPlatform.isDesktop ? 0 : (_appPrefsBox.get('playerUi') ?? 0);
  }

  @override
  Future<void> setPlayerUi(int ui) async {
    await _appPrefsBox.put("playerUi", ui);
  }

  @override
  bool isBottomNavBarEnabled() {
    return GetPlatform.isDesktop
        ? false
        : (_appPrefsBox.get("isBottomNavBarEnabled") ?? false);
  }

  @override
  Future<void> setBottomNavBarEnabled(bool enabled) async {
    await _appPrefsBox.put("isBottomNavBarEnabled", enabled);
  }

  @override
  bool isSlidableActionEnabled() {
    return _appPrefsBox.get('slidableActionEnabled') ?? true;
  }

  @override
  Future<void> setSlidableActionEnabled(bool enabled) async {
    await _appPrefsBox.put("slidableActionEnabled", enabled);
  }

  @override
  String getDownloadingFormat() {
    return _appPrefsBox.get('downloadingFormat') ?? "m4a";
  }

  @override
  Future<void> setDownloadingFormat(String format) async {
    await _appPrefsBox.put("downloadingFormat", format);
  }

  @override
  Future<String> getExportedLocation() async {
    return _appPrefsBox.get("exportLocationPath") ??
        "/storage/emulated/0/Music";
  }

  @override
  Future<void> setExportedLocation() async {
    if (!await PermissionService.getExtStoragePermission()) {
      return;
    }
    final String? pickedFolderPath = await FilePicker.platform
        .getDirectoryPath(dialogTitle: "Select export file folder");
    if (pickedFolderPath != null && pickedFolderPath != '/') {
      await _appPrefsBox.put("exportLocationPath", pickedFolderPath);
    }
  }

  @override
  Future<String> getDownloadLocation() async {
    final downloadPath = _appPrefsBox.get('downloadLocationPath') ??
        await _createInAppSongDownDir();
    return (GetPlatform.isDesktop && downloadPath.contains("emulated"))
        ? await _createInAppSongDownDir()
        : downloadPath;
  }

  @override
  Future<void> setDownloadLocation() async {
    if (!await PermissionService.getExtStoragePermission()) {
      return;
    }
    final String? pickedFolderPath = await FilePicker.platform
        .getDirectoryPath(dialogTitle: "Select downloads folder");
    if (pickedFolderPath != null && pickedFolderPath != '/') {
      await _appPrefsBox.put("downloadLocationPath", pickedFolderPath);
    }
  }

  @override
  Future<void> resetDownloadLocation() async {
    final defaultPath = "$_supportDir/Music";
    await _appPrefsBox.put("downloadLocationPath", defaultPath);
  }

  @override
  bool isTransitionAnimationDisabled() {
    return _appPrefsBox.get('isTransitionAnimationDisabled') ?? false;
  }

  @override
  Future<void> setTransitionAnimationDisabled(bool disabled) async {
    await _appPrefsBox.put('isTransitionAnimationDisabled', disabled);
  }

  @override
  Future<void> clearImagesCache() async {
    final tempImgDirPath =
        "${(await getApplicationCacheDirectory()).path}/libCachedImageData";
    final tempImgDir = Directory(tempImgDirPath);
    if (await tempImgDir.exists()) {
      await tempImgDir.delete(recursive: true);
    }
  }

  @override
  ThemeType getThemeMode() {
    return ThemeType.values[_appPrefsBox.get('themeModeType') ?? 0];
  }

  @override
  Future<void> setThemeMode(ThemeType theme) async {
    await _appPrefsBox.put('themeModeType', theme.index);
  }

  @override
  String getDiscoverContentType() {
    return _appPrefsBox.get('discoverContentType') ?? "QP";
  }

  @override
  Future<void> setDiscoverContentType(String type) async {
    await _appPrefsBox.put('discoverContentType', type);
  }

  @override
  bool isCachingSongsEnabled() {
    return _appPrefsBox.get('cacheSongs') ?? false;
  }

  @override
  Future<void> setCachingSongsEnabled(bool enabled) async {
    await _appPrefsBox.put("cacheSongs", enabled);
  }

  @override
  bool isSkipSilenceEnabled() {
    return GetPlatform.isDesktop
        ? false
        : _appPrefsBox.get("skipSilenceEnabled") ?? false;
  }

  @override
  Future<void> setSkipSilenceEnabled(bool enabled) async {
    await _appPrefsBox.put('skipSilenceEnabled', enabled);
  }

  @override
  bool isLoudnessNormalizationEnabled() {
    return GetPlatform.isDesktop
        ? false
        : (_appPrefsBox.get("loudnessNormalizationEnabled") ?? false);
  }

  @override
  Future<void> setLoudnessNormalizationEnabled(bool enabled) async {
    await _appPrefsBox.put("loudnessNormalizationEnabled", enabled);
  }

  @override
  bool shouldRestorePlaybackSession() {
    return _appPrefsBox.get("restrorePlaybackSession") ?? false;
  }

  @override
  Future<void> setRestorePlaybackSession(bool restore) async {
    await _appPrefsBox.put("restrorePlaybackSession", restore);
  }

  @override
  bool isCacheHomeScreenDataEnabled() {
    return _appPrefsBox.get("cacheHomeScreenData") ?? true;
  }

  @override
  Future<void> setCacheHomeScreenDataEnabled(bool enabled) async {
    await _appPrefsBox.put("cacheHomeScreenData", enabled);
    if (!enabled) {
      Hive.openBox("homeScreenData").then((box) async {
        await box.clear();
        await box.close();
      });
    }
  }

  @override
  bool isAutoDownloadFavoriteSongEnabled() {
    return _appPrefsBox.get("autoDownloadFavoriteSongEnabled") ?? false;
  }

  @override
  Future<void> setAutoDownloadFavoriteSongEnabled(bool enabled) async {
    await _appPrefsBox.put("autoDownloadFavoriteSongEnabled", enabled);
  }

  @override
  bool isBackgroundPlayEnabled() {
    return _appPrefsBox.get("backgroundPlayEnabled") ?? true;
  }

  @override
  Future<void> setBackgroundPlayEnabled(bool enabled) async {
    await _appPrefsBox.put('backgroundPlayEnabled', enabled);
  }

  @override
  Future<bool> isIgnoringBatteryOptimizations() async {
    if (GetPlatform.isAndroid) {
      return await Permission.ignoreBatteryOptimizations.isGranted;
    }
    return true;
  }

  @override
  Future<void> enableIgnoringBatteryOptimizations() async {
    if (GetPlatform.isAndroid) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  @override
  bool shouldAutoOpenPlayer() {
    return _appPrefsBox.get('autoOpenPlayer') ?? true;
  }

  @override
  Future<void> setAutoOpenPlayer(bool open) async {
    await _appPrefsBox.put('autoOpenPlayer', open);
  }

  @override
  Future<bool> isPipedLinked() async {
    if (_appPrefsBox.containsKey("piped")) {
      return _appPrefsBox.get("piped")['isLoggedIn'];
    }
    return false;
  }

  @override
  Future<void> unlinkPiped() async {
    // This method has side effects beyond just settings.
    // It's a candidate for a separate use case.
    // For now, we keep it here to match the existing logic.
    if (_appPrefsBox.containsKey("piped")) {
      final pipedData = _appPrefsBox.get("piped");
      pipedData['isLoggedIn'] = false;
      await _appPrefsBox.put("piped", pipedData);
    }
  }

  @override
  Future<void> resetAppSettingsToDefault() async {
    await _appPrefsBox.clear();
  }

  @override
  bool shouldStopPlaybackOnSwipeAway() {
    return _appPrefsBox.get('stopPlyabackOnSwipeAway') ?? false;
  }

  @override
  Future<void> setStopPlaybackOnSwipeAway(bool stop) async {
    await _appPrefsBox.put('stopPlyabackOnSwipeAway', stop);
  }

  Future<String> _createInAppSongDownDir() async {
    _supportDir = (await getApplicationSupportDirectory()).path;
    final directory = Directory("$_supportDir/Music/");
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return "$_supportDir/Music";
  }
}
