import 'dart:convert';
import 'dart:io';
import 'package:harmonymusic/domain/playlist/entities/export_type.dart';
import 'package:harmonymusic/models/media_Item_builder.dart';
import 'package:harmonymusic/models/playlist.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:audio_service/audio_service.dart' show MediaItem;

abstract class PlaylistExportDataSource {
  Future<String> exportPlaylist({required String playlistId, required ExportType format});
}

class PlaylistExportDataSourceImpl implements PlaylistExportDataSource {
  final HiveInterface hive;

  PlaylistExportDataSourceImpl({required this.hive});

  @override
  Future<String> exportPlaylist({required String playlistId, required ExportType format}) async {
    final libraryBox = await hive.openBox('LibraryPlaylists');
    final playlistJson = libraryBox.get(playlistId);
    if (playlistJson == null) {
      throw Exception('Playlist not found in local library');
    }

    final playlist = Playlist.fromJson(playlistJson);
    final songsBox = await hive.openBox(playlistId);
    final songs = songsBox.values.map((songJson) => MediaItemBuilder.fromJson(songJson)).toList();

    final Directory exportDir = await _getExportDirectory();
    final sanitizedName = playlist.title.replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_');

    String fileContent;
    String fileExtension;

    switch (format) {
      case ExportType.json:
        fileContent = _generateJsonContent(playlist, songs);
        fileExtension = 'json';
        break;
      case ExportType.csv:
        fileContent = _generateCsvContent(playlist, songs);
        fileExtension = 'csv';
        break;
    }

    String filename = "$sanitizedName.$fileExtension";
    String filePath = "${exportDir.path}/$filename";
    File file = File(filePath);

    int counter = 1;
    while (await file.exists()) {
      filename = "${sanitizedName}_$counter.$fileExtension";
      filePath = "${exportDir.path}/$filename";
      file = File(filePath);
      counter++;
    }

    await file.writeAsString(fileContent);
    return filePath;
  }

  String _generateJsonContent(Playlist playlist, List<MediaItem> songs) {
    final playlistData = {
      "playlistInfo": playlist.toJson(),
      "songs": songs.map((song) => MediaItemBuilder.toJson(song)).toList(),
      "exportDate": DateTime.now().toIso8601String(),
    };
    return jsonEncode(playlistData);
  }

  String _generateCsvContent(Playlist playlist, List<MediaItem> songs) {
    final buffer = StringBuffer();
    buffer.writeln('PlaylistBrowseId,PlaylistName,MediaId,Title,Artists,Duration,ThumbnailUrl,AlbumId,AlbumTitle,ArtistIds');
    for (final song in songs) {
      final playlistBrowseId = (!playlist.isCloudPlaylist || playlist.isPipedPlaylist) ? '' : _escapeCsvField(playlist.playlistId);
      final playlistName = _escapeCsvField(playlist.title);
      final mediaId = _escapeCsvField(song.id);
      final title = _escapeCsvField(song.title);
      final artistsList = song.extras?['artists'] as List?;
      final artists = artistsList != null ? _escapeCsvField(artistsList.map((a) => a['name']).join(', ')) : '';
      final duration = song.duration != null ? _formatDuration(song.duration!) : '';
      final thumbnailUrl = _escapeCsvField(song.artUri.toString());
      final albumData = song.extras?['album'] as Map?;
      final albumId = albumData != null ? _escapeCsvField(albumData['id'] ?? '') : '';
      final albumTitle = albumData != null ? _escapeCsvField(albumData['name'] ?? '') : '';
      final artistIds = artistsList != null && artistsList.isNotEmpty ? _escapeCsvField(artistsList.map((a) => a['id'] ?? '').join(',')) : '';
      buffer.writeln('$playlistBrowseId,$playlistName,$mediaId,$title,$artists,$duration,$thumbnailUrl,$albumId,$albumTitle,$artistIds');
    }
    return buffer.toString();
  }

  String _escapeCsvField(String field) {
    String escaped = field.replaceAll('"', '""');
    if (escaped.contains(',') || escaped.contains('\n') || escaped.contains('"')) {
      escaped = '"$escaped"';
    }
    return escaped;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Future<Directory> _getExportDirectory() async {
    Directory directory;
    const appFolderName = "HarmonyMusic";
    try {
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download/$appFolderName');
      } else if (Platform.isIOS) {
        final docDir = await path_provider.getApplicationDocumentsDirectory();
        directory = Directory('${docDir.path}/$appFolderName');
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '.';
        directory = Directory('$homeDir/Downloads/$appFolderName');
      } else {
        final tempDir = await path_provider.getTemporaryDirectory();
        directory = Directory('${tempDir.path}/$appFolderName');
      }
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory;
    } catch (e) {
      final appDocDir = await path_provider.getApplicationDocumentsDirectory();
      directory = Directory('${appDocDir.path}/$appFolderName');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory;
    }
  }
}
