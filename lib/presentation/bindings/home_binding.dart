import 'package:get/get.dart';
import 'package:harmonymusic/data/home/datasources/home_remote_data_source.dart';
import 'package:harmonymusic/data/home/repositories/home_repository_impl.dart';
import 'package:harmonymusic/domain/home/repositories/home_repository.dart';
import 'package:harmonymusic/domain/home/usecases/get_home_page_content_usecase.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:harmonymusic/services/activity_service.dart';
import 'package:harmonymusic/data/home/datasources/home_local_data_source.dart';
import 'package:harmonymusic/data/home/datasources/recommendation_data_source.dart';
import 'package:harmonymusic/domain/home/usecases/get_recently_played_usecase.dart';
import 'package:harmonymusic/domain/home/usecases/get_recommendations_usecase.dart';
import 'package:harmonymusic/domain/home/usecases/get_cached_home_content_usecase.dart';
import 'package:harmonymusic/domain/home/usecases/cache_home_content_usecase.dart';
import 'package:harmonymusic/domain/home/usecases/get_quick_picks_usecase.dart';
import 'package:hive/hive.dart';

import '../../../data/search/repository/search_repository_impl.dart';
import '../../../domain/search/repository/search_repository.dart';
import '../../../domain/search/usecases/get_search_continuation_usecase.dart';
import '../../../domain/search/usecases/get_search_suggestions_usecase.dart';
import '../../../domain/search/usecases/search_usecase.dart';
import 'download_binding.dart';
import 'settings_binding.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    DownloadBinding().dependencies();
    SettingsBinding().dependencies();
    Get.lazyPut<SearchRepository>(() => SearchRepositoryImpl());
    Get.lazyPut(() => GetSearchSuggestionsUseCase());
    Get.lazyPut(() => SearchUseCase());
    Get.lazyPut(() => GetSearchContinuationUseCase());
    Get.lazyPut<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(musicServices: Get.find<MusicServices>()),
    );
    Get.lazyPut<HomeLocalDataSource>(
      () => HomeLocalDataSourceImpl(
          activityService: Get.find<ActivityService>(), hive: Hive),
    );
    Get.lazyPut<RecommendationDataSource>(
      () => RecommendationDataSourceImpl(
        activityService: Get.find<ActivityService>(),
        musicServices: Get.find<MusicServices>(),
      ),
    );

    Get.lazyPut<HomeRepository>(
      () => HomeRepositoryImpl(
        remoteDataSource: Get.find<HomeRemoteDataSource>(),
        localDataSource: Get.find<HomeLocalDataSource>(),
        recommendationDataSource: Get.find<RecommendationDataSource>(),
      ),
    );

    Get.lazyPut<GetHomePageContentUseCase>(
        () => GetHomePageContentUseCase(Get.find<HomeRepository>()));
    Get.lazyPut<GetRecentlyPlayedUseCase>(
        () => GetRecentlyPlayedUseCase(Get.find<HomeRepository>()));
    Get.lazyPut<GetRecommendationsUseCase>(
        () => GetRecommendationsUseCase(Get.find<HomeRepository>()));
    Get.lazyPut<GetCachedHomeContentUseCase>(
        () => GetCachedHomeContentUseCase(Get.find<HomeRepository>()));
    Get.lazyPut<CacheHomeContentUseCase>(
        () => CacheHomeContentUseCase(Get.find<HomeRepository>()));
    Get.lazyPut<GetQuickPicksUseCase>(
        () => GetQuickPicksUseCase(Get.find<HomeRepository>()));
  }
}
