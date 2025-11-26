import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:audiotags/audiotags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../../domain/download/repository/download_repository.dart';
import '../../../domain/settings/repository/settings_repository.dart';
import '../../../services/downloader.dart';
import '../../../services/music_service.dart';
import '../../../services/permission_service.dart';
import '../../../services/stream_service.dart';
import '../../../presentation/controllers/library/library_songs_controller.dart';
import '../../../ui/widgets/snackbar.dart';
import '../../../utils/helper.dart';
import '../../../models/media_Item_builder.dart';

class DownloadRepositoryImpl implements DownloadRepository {
  final Downloader _downloader = Get.find<Downloader>();
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();
  final _dio = Dio();

  @override
  Stream<int> get songDownloadingProgress =>
      _downloader.songDownloadingProgress.stream;
  @override
  Stream<int> get playlistDownloadingProgress =>
      _downloader.playlistDownloadingProgress.stream;
  @override
  Stream<bool> get isJobRunning => _downloader.isJobRunning.stream;
  @override
  Stream<String> get currentPlaylistId => _downloader.currentPlaylistId.stream;
  @override
  Stream<List<MediaItem>> get songQueue => _downloader.songQueue.stream;

  @override
  Future<void> downloadPlaylist(
      String playlistId, List<MediaItem> songList) async {
    if (!(await _checkPermissionNDir())) return;

    if (_downloader.playlistQueue.containsKey(playlistId)) {
      _downloader.songQueue
          .removeWhere((element) => songList.contains(element));
      _downloader.playlistQueue.remove(playlistId);
      return;
    }

    _downloader.playlistQueue[playlistId] = songList;
    _downloader.songQueue.addAll(songList);

    if (_downloader.isJobRunning.isFalse) {
      await _triggerDownloadingJob();
    }
  }

  @override
  Future<void> downloadSong(MediaItem song) async {
    if (!(await _checkPermissionNDir())) return;
    _downloader.songQueue.add(song);
    if (_downloader.isJobRunning.isFalse) {
      await _triggerDownloadingJob();
    }
  }

  @override
  Future<void> cancelPlaylistDownload(String playlistId) async {
    final songList = _downloader.playlistQueue[playlistId];
    if (songList != null) {
      _downloader.songQueue
          .removeWhere((element) => songList.contains(element));
      _downloader.playlistQueue.remove(playlistId);
    }
  }

  Future<bool> _checkPermissionNDir() async {
    final downloadPath = await _settingsRepository.getDownloadLocation();
    final supportDir = (await getApplicationSupportDirectory()).path;
    final isCurrentPathSupportDir = "$supportDir/Music" == downloadPath;

    if (!isCurrentPathSupportDir &&
        !await PermissionService.getExtStoragePermission()) {
      return false;
    }

    final directory = Directory(downloadPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return true;
  }

  Future<void> _triggerDownloadingJob() async {
    if (_downloader.playlistQueue.isNotEmpty) {
      _downloader.isJobRunning.value = true;
      for (String playlistId in _downloader.playlistQueue.keys.toList()) {
        if (_downloader.playlistQueue.containsKey(playlistId)) {
          _downloader.currentPlaylistId.value = playlistId;
          await _downloadSongList(
              (_downloader.playlistQueue[playlistId]!).toList(),
              isPlaylist: true);
          _downloader.playlistQueue.remove(playlistId);
        }
        _downloader.currentPlaylistId.value = "";
        _downloader.playlistDownloadingProgress.value = 0;
      }
    } else {
      _downloader.isJobRunning.value = true;
      await _downloadSongList(_downloader.songQueue.toList());
    }

    if (_downloader.songQueue.isNotEmpty) {
      _triggerDownloadingJob();
    } else {
      _downloader.isJobRunning.value = false;
    }
  }

  Future<void> _downloadSongList(List<MediaItem> jobSongList,
      {bool isPlaylist = false}) async {
    for (MediaItem song in jobSongList) {
      if (isPlaylist &&
          !_downloader.playlistQueue
              .containsKey(_downloader.currentPlaylistId.value)) {
        _downloader.currentPlaylistId.value = "";
        _downloader.playlistDownloadingProgress.value = 0;
        return;
      }

      if (!Hive.box("SongDownloads").containsKey(song.id)) {
        _downloader.songDownloadingProgress.value = 0;
        await _writeFileStream(song);
      }
      _downloader.songQueue.remove(song);
      if (isPlaylist) {
        _downloader.playlistDownloadingProgress.value =
            jobSongList.indexOf(song) + 1;
      }
    }
  }

  Future<void> _writeFileStream(MediaItem song) async {
    Completer<void> complete = Completer();
    final downloadingFormat = _settingsRepository.getDownloadingFormat();
    final playerResponse = await StreamProvider.fetch(song.id);
    if (!playerResponse.playable) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
          Get.context!,
          playerResponse.statusMSG == "networkError"
              ? playerResponse.statusMSG.tr
              : playerResponse.statusMSG,
          size: SanckBarSize.BIG,
          duration: const Duration(seconds: 2),
          top: !GetPlatform.isDesktop));
      complete.complete();
      return complete.future;
    }
    Audio requiredAudioStream = downloadingFormat == "opus"
        ? playerResponse.highestBitrateOpusAudio!
        : playerResponse.highestBitrateMp4aAudio!;
    final dirPath = await _settingsRepository.getDownloadLocation();
    final actualDownformat =
        requiredAudioStream.audioCodec.name.contains("mp") ? "m4a" : "opus";
    final RegExp invalidChar =
        RegExp(r'Container.|\/|\\|\"|\<|\>|\*|\?|\:|\!|\[|\]|\¡|\||\%');
    final songTitle = "${song.title.trim()} (${song.artist?.trim()})"
        .replaceAll(invalidChar, "");
    String filePath = "$dirPath/$songTitle.$actualDownformat";
    final totalBytes = requiredAudioStream.size;
    _dio.download(
        requiredAudioStream.url,
        options: Options(headers: {"Range": 'bytes=0-$totalBytes'}),
        filePath, onReceiveProgress: (count, total) {
      if (total <= 0) return;
      _downloader.songDownloadingProgress.value =
          ((count / total) * 100).toInt();
    }).then(
      (value) async {
        String? year;
        try {
          if (song.extras?['year'] != null) {
            year = song.extras?['year'];
          } else {
            if (song.album != null) {
              final musicServ = Get.find<MusicServices>();
              year = await musicServ.getSongYear(song.id);
            }
          }
        } catch (_) {}
        try {
          final supportDir = (await getApplicationSupportDirectory()).path;
          final thumbnailPath = "$supportDir/thumbnails/${song.id}.png";
          await _dio.downloadUri(song.artUri!, thumbnailPath);
        } catch (e) {}
        song.extras?['url'] = filePath;
        final songJson = MediaItemBuilder.toJson(song);
        final streamInfoJson = requiredAudioStream.toJson();
        streamInfoJson['url'] = filePath;
        songJson["streamInfo"] = [true, streamInfoJson];
        Hive.box("SongDownloads").put(song.id, songJson);
        Get.find<LibrarySongsController>().librarySongsList.add(song);
        final trackDetails = (song.extras?['trackDetails'])?.split("/");
        final int? trackNumber = int.tryParse(trackDetails?[0] ?? "");
        final int? totalTracks = int.tryParse(trackDetails?[1] ?? "");
        try {
          final imageUrl = song.artUri!.toString();
          Tag tag = Tag(
              title: song.title,
              trackArtist: song.artist,
              album: song.album,
              year: int.tryParse(year ?? ""),
              trackNumber: trackNumber,
              trackTotal: totalTracks,
              albumArtist: song.artist,
              genre: song.genre,
              pictures: [
                Picture(
                    bytes: (await NetworkAssetBundle(Uri.parse((imageUrl)))
                            .load(imageUrl))
                        .buffer
                        .asUint8List(),
                    mimeType: MimeType.png,
                    pictureType: PictureType.coverFront)
              ]);
          await AudioTags.write(filePath, tag);
        } catch (e) {
          printERROR("$e");
        }
        complete.complete();
      },
    ).onError(
      (error, stackTrace) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
            Get.context!, "downloadError3".tr,
            size: SanckBarSize.BIG,
            duration: const Duration(seconds: 2),
            top: !GetPlatform.isDesktop));
        complete.complete();
      },
    );
    return complete.future;
  }
}
