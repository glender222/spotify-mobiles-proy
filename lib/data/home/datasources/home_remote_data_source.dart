import 'package:harmonymusic/data/home/models/home_section_model.dart';
import 'package:harmonymusic/models/album.dart';
import 'package:harmonymusic/models/playlist.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:harmonymusic/data/home/models/quick_picks_model.dart';
import 'package:harmonymusic/data/playlist/models/track_model.dart';
import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:hive/hive.dart';

abstract class HomeRemoteDataSource {
  Future<List<HomeSectionModel>> getHomeContent();
  Future<QuickPicksModel> getQuickPicks(String contentType, {String? songId});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final MusicServices musicServices;

  HomeRemoteDataSourceImpl({required this.musicServices});

  @override
  Future<List<HomeSectionModel>> getHomeContent() async {
    try {
      final homeContentListMap = await musicServices.getHome();

      final List<HomeSectionModel> sections = [];

      for (var content in homeContentListMap) {
        if ((content["contents"][0]).runtimeType == Playlist) {
          final tmp = PlaylistContent(
              playlistList: (content["contents"]).whereType<Playlist>().toList(),
              title: content["title"]);
          if (tmp.playlistList.length >= 2) {
            sections.add(HomeSectionModel.fromLegacyContent(tmp));
          }
        } else if ((content["contents"][0]).runtimeType == Album) {
          final tmp = AlbumContent(
              albumList: (content["contents"]).whereType<Album>().toList(),
              title: content["title"]);
          if (tmp.albumList.length >= 2) {
            sections.add(HomeSectionModel.fromLegacyContent(tmp));
          }
        }
      }
      return sections;
    } catch (e) {
      throw Exception('Failed to fetch home content.');
    }
  }

  @override
  Future<QuickPicksModel> getQuickPicks(String contentType, {String? songId}) async {
    // This logic is complex and moved directly from the controller.
    // A future refactor could simplify this at the service layer.
    try {
      if (contentType == "TR") {
        List charts = await musicServices.getCharts();
        final con = charts.length == 4 ? charts.removeAt(3) : charts.removeAt(2);
        final tracks = (con["contents"] as List<dynamic>)
            .map((item) => TrackModel.fromMediaItem(item as MediaItem))
            .toList();
        return QuickPicksModel.fromTrackModels(title: con['title'], tracks: tracks);
      } else if (contentType == "TMV") {
        List charts = await musicServices.getCharts();
        final tracks = (charts[0]["contents"] as List<dynamic>)
            .map((item) => TrackModel.fromMediaItem(item as MediaItem))
            .toList();
        return QuickPicksModel.fromTrackModels(title: charts[0]["title"], tracks: tracks);
      } else if (contentType == "BOLI") {
        songId ??= Hive.box("AppPrefs").get("recentSongId");
        if (songId != null) {
          final rel = await musicServices.getContentRelatedToSong(songId, "en"); // Assuming 'en' for now
          final con = rel.removeAt(0);
          final tracks = (con["contents"] as List<dynamic>)
            .map((item) => TrackModel.fromMediaItem(item as MediaItem))
            .toList();
          return QuickPicksModel.fromTrackModels(title: "Based on your listening", tracks: tracks);
        }
      }

      // Default to QP (Quick Picks)
      final homeContentListMap = await musicServices.getHome(limit: 1);
      final con = homeContentListMap[0];
       final tracks = (con["contents"] as List<dynamic>)
            .map((item) => TrackModel.fromMediaItem(item as MediaItem))
            .toList();
      return QuickPicksModel.fromTrackModels(title: con['title'], tracks: tracks);

    } catch (e) {
      throw Exception('Failed to fetch quick picks.');
    }
  }
}
