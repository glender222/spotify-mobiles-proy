import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:harmonymusic/domain/home/entities/home_section_entity.dart';
import 'package:harmonymusic/domain/home/entities/quick_picks_entity.dart';

abstract class HomeRepository {
  Future<List<HomeSectionEntity>> getHomeContent();
  Future<List<MediaItem>> getRecentlyPlayed();
  Future<List<MediaItem>> getRecommendations();
  Future<List<HomeSectionEntity>> getCachedHomeContent();
  Future<void> cacheHomeContent(List<HomeSectionEntity> sections);
  Future<QuickPicksEntity> getQuickPicks(String contentType, {String? songId});
}
