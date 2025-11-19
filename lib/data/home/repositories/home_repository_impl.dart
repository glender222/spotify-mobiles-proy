import 'package:harmonymusic/data/home/datasources/home_local_data_source.dart';
import 'package:harmonymusic/data/home/datasources/recommendation_data_source.dart';
import 'package:harmonymusic/data/home/datasources/home_remote_data_source.dart';
import 'package:harmonymusic/domain/home/entities/home_section_entity.dart';
import 'package:harmonymusic/domain/home/entities/quick_picks_entity.dart';
import 'package:harmonymusic/domain/home/repositories/home_repository.dart';
import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:harmonymusic/data/home/models/home_section_model.dart';

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
      // The models returned by the data source are compatible with the entities.
      return homeSections;
    } catch (e) {
      throw Exception('Failed to get home content from repository.');
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
  Future<QuickPicksEntity> getQuickPicks(String contentType, {String? songId}) async {
    return remoteDataSource.getQuickPicks(contentType, songId: songId);
  }
}
