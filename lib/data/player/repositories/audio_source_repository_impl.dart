import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../domain/player/repositories/audio_source_repository.dart';
import '../../../../models/hm_streaming_data.dart';
import '../../../../services/background_task.dart';
import '../../../../services/permission_service.dart';
import '../../../../services/utils.dart';
import '../../../../services/stream_service.dart';
import '../../../../utils/helper.dart';
import '../../../../presentation/controllers/settings/settings_controller.dart';

class AudioSourceRepositoryImpl implements AudioSourceRepository {
  // We might want to inject these boxes or a DataSource in the future
  // For now, we access Hive directly as per the original implementation to minimize friction

  @override
  Future<HMStreamingData> getPlayableUrl(String songId,
      {bool generateNewUrl = false}) async {
    return _checkNGetUrl(songId, generateNewUrl: generateNewUrl);
  }

  // Logic moved from AudioHandler
  Future<HMStreamingData> _checkNGetUrl(String songId,
      {bool generateNewUrl = false, bool offlineReplacementUrl = false}) async {
    printINFO("Requested id : $songId");
    final songDownloadsBox = Hive.box("SongDownloads");
    final cacheDir = (await getTemporaryDirectory()).path;

    // 1. Check SongsCache (Cached Files)
    if (!offlineReplacementUrl &&
        (await Hive.openBox("SongsCache")).containsKey(songId)) {
      printINFO("Got Song from cachedbox ($songId)");
      final streamInfo = Hive.box("SongsCache").get(songId)["streamInfo"];
      Audio? cacheAudioPlaceholder;

      if (streamInfo != null && streamInfo.isNotEmpty) {
        // Create a copy to avoid modifying Hive object directly if it's not a primitive
        // But here we are constructing a new Audio object mostly
        // streamInfo[1] is likely a Map
        final audioMap = Map<String, dynamic>.from(streamInfo[1]);
        audioMap['url'] = "file://$cacheDir/cachedSongs/$songId.mp3";
        cacheAudioPlaceholder = Audio.fromJson(audioMap);
      } else {
        cacheAudioPlaceholder = Audio(
            audioCodec: Codec.mp4a, // Fixed: Use enum instead of string
            bitrate: 0,
            loudnessDb: 0,
            duration: 0,
            size: 0,
            url: "file://$cacheDir/cachedSongs/$songId.mp3",
            itag: 0);
      }

      return HMStreamingData(
          playable: true,
          statusMSG: "OK",
          lowQualityAudio: cacheAudioPlaceholder,
          highQualityAudio: cacheAudioPlaceholder);
    }
    // 2. Check SongDownloads (Downloaded Files)
    else if (!offlineReplacementUrl && songDownloadsBox.containsKey(songId)) {
      final song = songDownloadsBox.get(songId);
      final streamInfoJson = song["streamInfo"];
      Audio? audio;
      final path = song['url'];

      if (streamInfoJson != null && streamInfoJson.isNotEmpty) {
        audio = Audio.fromJson(streamInfoJson[1]);
      } else {
        audio = Audio(
            itag: 140,
            audioCodec: Codec.mp4a, // Fixed: Use enum instead of string
            bitrate: 0,
            duration: 0,
            loudnessDb: 0,
            url: path,
            size: 0);
      }

      final streamInfo = HMStreamingData(
          playable: true,
          statusMSG: "OK",
          highQualityAudio: audio,
          lowQualityAudio: audio);

      // Check if file exists
      // We use Get.find<SettingsController> as in original, or we could use Hive 'AppPrefs'
      final supportDirPath = Get.find<SettingsController>().supportDirPath;

      if (path.contains("$supportDirPath/Music")) {
        return streamInfo;
      }

      // Check file access and if file exist in storage
      final status = await PermissionService.getExtStoragePermission();
      if (status && await File(path).exists()) {
        return streamInfo;
      }

      // File not found, fallback to online
      return _checkNGetUrl(songId, offlineReplacementUrl: true);
    }
    // 3. Online / Cached URL
    else {
      final songsUrlCacheBox = Hive.box("SongsUrlCache");
      final qualityIndex = Hive.box('AppPrefs').get('streamingQuality') ?? 1;
      HMStreamingData? streamInfo;

      if (songsUrlCacheBox.containsKey(songId) && !generateNewUrl) {
        final streamInfoJson = songsUrlCacheBox.get(songId);
        if (streamInfoJson.runtimeType.toString().contains("Map") &&
            !isExpired(url: (streamInfoJson['lowQualityAudio']['url']))) {
          printINFO("Got cached Url ($songId)");
          streamInfo = HMStreamingData.fromJson(streamInfoJson);
        }
      }

      if (streamInfo == null) {
        final token = RootIsolateToken.instance;
        // Using background task to fetch URL
        final streamInfoJson =
            await Isolate.run(() => getStreamInfo(songId, token));
        streamInfo = HMStreamingData.fromJson(streamInfoJson);
        if (streamInfo.playable) songsUrlCacheBox.put(songId, streamInfoJson);
      }

      streamInfo.setQualityIndex(qualityIndex as int);
      return streamInfo;
    }
  }
}
