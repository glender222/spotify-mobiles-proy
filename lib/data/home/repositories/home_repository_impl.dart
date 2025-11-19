import 'package:harmonymusic/data/home/datasources/home_local_data_source.dart';
import 'package:harmonymusic/data/home/datasources/recommendation_data_source.dart';
import 'package:harmonymusic/data/home/datasources/home_remote_data_source.dart';
import 'package:harmonymusic/domain/home/entities/home_section_entity.dart';
import 'package:harmonymusic/domain/home/entities/quick_picks_entity.dart';
import 'package:harmonymusic/domain/home/repositories/home_repository.dart';
import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:harmonymusic/data/home/models/home_section_model.dart';
import 'package:harmonymusic/utils/helper.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  final RecommendationDataSource recommendationDataSource;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.recommendationDataSource,
  });

  @override
  Future<List<HomeSectionEntity>> getHomeContent() async {
    try {
      final homeSections = await remoteDataSource.getHomeContent();
      // Cache successful fetch for offline use
      try {
        await localDataSource.cacheHomeContent(homeSections);
      } catch (cacheError) {
        // Cache failure shouldn't prevent returning data
        printERROR('Failed to cache home content: $cacheError');
      }
      return homeSections;
    } catch (e) {
      // Network failed - try to return cached content
      printERROR('Failed to fetch home content from network: $e');
      printINFO('Attempting to load cached home content...');
      try {
        final cachedContent = await localDataSource.getCachedHomeContent();
        if (cachedContent.isNotEmpty) {
          printINFO('Loaded ${cachedContent.length} sections from cache');
          return cachedContent;
        }
      } catch (cacheError) {
        printERROR('Failed to load cached content: $cacheError');
      }
      // Both network and cache failed - rethrow for controller to handle
      throw Exception(
          'Unable to load home content. Please check your internet connection and try again.');
    }
  }

  @override
  Future<List<MediaItem>> getRecentlyPlayed() async {
    return localDataSource.getSongHistory();
  }

  @override
  Future<List<MediaItem>> getRecommendations() async {
    return recommendationDataSource.getRecommendations();
  }

  @override
  Future<List<HomeSectionEntity>> getCachedHomeContent() async {
    final models = await localDataSource.getCachedHomeContent();
    return models; // Models are compatible with entities
  }

  @override
  Future<void> cacheHomeContent(List<HomeSectionEntity> sections) async {
    // We assume the sections are already HomeSectionModels from the data layer
    await localDataSource.cacheHomeContent(sections as List<HomeSectionModel>);
  }

  @override
  Future<QuickPicksEntity> getQuickPicks(String contentType,
      {String? songId}) async {
    return remoteDataSource.getQuickPicks(contentType, songId: songId);
  }
}
