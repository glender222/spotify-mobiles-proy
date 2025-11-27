import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:terminate_restart/terminate_restart.dart';

import '/utils/get_localization.dart';
import '/services/activity_service.dart';
import '/services/downloader.dart';
import '/services/piped_service.dart';
import 'utils/app_link_controller.dart';
import '/services/audio_handler.dart';
import '/services/music_service.dart';
import '/ui/home.dart';
import 'presentation/bindings/player_binding.dart';
import 'presentation/controllers/settings/settings_controller.dart';
import '/ui/utils/theme_controller.dart';
import 'presentation/controllers/home/home_controller.dart';
import '/presentation/controllers/search/search_controller.dart'
    as app_controllers;
import 'presentation/controllers/library/library_songs_controller.dart';
import 'presentation/controllers/library/library_playlists_controller.dart';
import 'presentation/controllers/library/library_albums_controller.dart';
import 'presentation/controllers/library/library_artists_controller.dart';
import 'utils/system_tray.dart';
import 'utils/update_check_flag_file.dart';
import 'domain/settings/usecases/get_app_language_usecase.dart';
import 'domain/settings/usecases/set_app_language_usecase.dart';
import 'domain/settings/usecases/get_theme_mode_usecase.dart';
import 'domain/settings/usecases/set_theme_mode_usecase.dart';
import 'domain/settings/usecases/get_streaming_quality_usecase.dart';
import 'domain/settings/usecases/set_streaming_quality_usecase.dart';
import 'domain/settings/usecases/get_download_location_usecase.dart';
import 'domain/settings/usecases/set_download_location_usecase.dart';
import 'domain/settings/usecases/get_downloading_format_usecase.dart';
import 'domain/settings/usecases/set_downloading_format_usecase.dart';
import 'domain/settings/usecases/is_skip_silence_enabled_usecase.dart';
import 'domain/settings/usecases/set_skip_silence_enabled_usecase.dart';
import 'domain/settings/usecases/clear_images_cache_usecase.dart';
import 'domain/settings/usecases/enable_ignoring_battery_optimizations_usecase.dart';
import 'domain/settings/usecases/get_discover_content_type_usecase.dart';
import 'domain/settings/usecases/get_exported_location_usecase.dart';
import 'domain/settings/usecases/get_home_screen_content_number_usecase.dart';
import 'domain/settings/usecases/get_player_ui_usecase.dart';
import 'domain/settings/usecases/is_auto_download_favorite_song_enabled_usecase.dart';
import 'domain/settings/usecases/is_background_play_enabled_usecase.dart';
import 'domain/settings/usecases/is_bottom_nav_bar_enabled_usecase.dart';
import 'domain/settings/usecases/is_cache_home_screen_data_enabled_usecase.dart';
import 'domain/settings/usecases/is_caching_songs_enabled_usecase.dart';
import 'domain/settings/usecases/is_ignoring_battery_optimizations_usecase.dart';
import 'domain/settings/usecases/is_loudness_normalization_enabled_usecase.dart';
import 'domain/settings/usecases/is_piped_linked_usecase.dart';
import 'domain/settings/usecases/is_slidable_action_enabled_usecase.dart';
import 'domain/settings/usecases/is_transition_animation_disabled_usecase.dart';
import 'domain/settings/usecases/reset_app_settings_to_default_usecase.dart';
import 'domain/settings/usecases/reset_download_location_usecase.dart';
import 'domain/settings/usecases/set_auto_download_favorite_song_enabled_usecase.dart';
import 'domain/settings/usecases/set_auto_open_player_usecase.dart';
import 'domain/settings/usecases/set_background_play_enabled_usecase.dart';
import 'domain/settings/usecases/set_bottom_nav_bar_enabled_usecase.dart';
import 'domain/settings/usecases/set_cache_home_screen_data_enabled_usecase.dart';
import 'domain/settings/usecases/set_caching_songs_enabled_usecase.dart';
import 'domain/settings/usecases/set_discover_content_type_usecase.dart';
import 'domain/settings/usecases/set_exported_location_usecase.dart';
import 'domain/settings/usecases/set_home_screen_content_number_usecase.dart';
import 'domain/settings/usecases/set_loudness_normalization_enabled_usecase.dart';
import 'domain/settings/usecases/set_player_ui_usecase.dart';
import 'domain/settings/usecases/set_restore_playback_session_usecase.dart';
import 'domain/settings/usecases/set_slidable_action_enabled_usecase.dart';
import 'domain/settings/usecases/set_stop_playback_on_swipe_away_usecase.dart';
import 'domain/settings/usecases/set_transition_animation_disabled_usecase.dart';
import 'domain/settings/usecases/should_auto_open_player_usecase.dart';
import 'domain/settings/usecases/should_restore_playback_session_usecase.dart';
import 'domain/settings/usecases/should_stop_playback_on_swipe_away_usecase.dart';
import 'domain/settings/usecases/unlink_piped_usecase.dart';

import 'domain/settings/repository/settings_repository.dart';
import 'data/settings/repository/settings_repository_impl.dart';
import 'domain/download/repository/download_repository.dart';
import 'data/download/repository/download_repository_impl.dart';
import 'domain/search/repository/search_repository.dart';
import 'data/search/repository/search_repository_impl.dart';
import 'domain/home/repositories/home_repository.dart';
import 'data/home/repositories/home_repository_impl.dart';
import 'data/home/datasources/home_local_data_source.dart';
import 'data/home/datasources/home_remote_data_source.dart';
import 'data/home/datasources/recommendation_data_source.dart';

import 'domain/search/usecases/get_search_suggestions_usecase.dart';
import 'domain/search/usecases/search_usecase.dart';
import 'domain/search/usecases/get_search_continuation_usecase.dart';

import 'domain/home/usecases/get_home_page_content_usecase.dart';
import 'domain/home/usecases/get_recently_played_usecase.dart';
import 'domain/home/usecases/get_recommendations_usecase.dart';
import 'domain/home/usecases/get_cached_home_content_usecase.dart';
import 'domain/home/usecases/cache_home_content_usecase.dart';
import 'domain/home/usecases/get_quick_picks_usecase.dart';

import 'domain/download/usecases/download_song_usecase.dart';
import 'domain/download/usecases/get_song_queue_usecase.dart';
import 'domain/download/usecases/get_current_song_usecase.dart';
import 'domain/download/usecases/get_song_downloading_progress_usecase.dart';
import 'domain/download/usecases/is_job_running_usecase.dart';
import 'domain/download/usecases/cancel_playlist_download_usecase.dart';
import 'domain/download/usecases/download_playlist_usecase.dart';
import 'domain/download/usecases/get_current_playlist_id_usecase.dart';
import 'domain/download/usecases/get_playlist_downloading_progress_usecase.dart';
import 'domain/download/usecases/get_completed_playlist_id_usecase.dart';

// Album module imports
import 'domain/album/repositories/album_repository.dart';
import 'data/album/repositories/album_repository_impl.dart';
import 'data/album/datasources/album_remote_data_source.dart';
import 'data/album/datasources/album_local_data_source.dart';
import 'domain/album/usecases/get_album_details_usecase.dart';
import 'domain/album/usecases/get_album_tracks_usecase.dart';
import 'domain/album/usecases/add_album_to_library_usecase.dart';
import 'domain/album/usecases/remove_album_from_library_usecase.dart';
import 'domain/album/usecases/is_album_in_library_usecase.dart';

// Library module imports
import 'domain/library/repository/library_repository.dart';
import 'data/library/repository/library_repository_impl.dart';
import 'data/library/datasources/library_local_datasource.dart';
import 'data/library/datasources/library_local_datasource_impl.dart';
import 'domain/library/usecases/get_library_songs_usecase.dart';
import 'domain/library/usecases/watch_library_songs_usecase.dart';
import 'domain/library/usecases/add_song_to_library_usecase.dart';
import 'domain/library/usecases/remove_song_from_library_usecase.dart';
import 'domain/library/usecases/get_library_playlists_usecase.dart';
import 'domain/library/usecases/create_playlist_usecase.dart';
import 'domain/library/usecases/rename_playlist_usecase.dart';
import 'domain/library/usecases/sync_piped_playlists_usecase.dart';
import 'domain/library/usecases/get_library_albums_usecase.dart';
import 'domain/library/usecases/get_library_artists_usecase.dart';

// Player Module imports
import 'domain/player/repositories/audio_source_repository.dart';
import 'data/player/repositories/audio_source_repository_impl.dart';
import 'domain/player/repositories/playback_session_repository.dart';
import 'data/player/repositories/playback_session_repository_impl.dart';
import 'data/player/datasources/playback_local_data_source.dart';
import 'domain/player/usecases/get_playable_url_usecase.dart';
import 'domain/player/usecases/save_playback_session_usecase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  _setAppInitPrefs();
  await startApplicationServices();
  Get.put<AudioHandler>(await initAudioService(), permanent: true);
  WidgetsBinding.instance.addObserver(LifecycleHandler());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  TerminateRestart.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (!GetPlatform.isDesktop) Get.put(AppLinksController());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return GetMaterialApp(
        title: 'Harmony Music',
        home: const Home(),
        debugShowCheckedModeBanner: false,
        translations: Languages(),
        locale:
            Locale(Hive.box("AppPrefs").get('currentAppLanguageCode') ?? "en"),
        fallbackLocale: const Locale("en"),
        builder: (context, child) {
          final mQuery = MediaQuery.of(context);
          final scale =
              mQuery.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.1);
          return Stack(
            children: [
              GetX<ThemeController>(
                builder: (controller) => MediaQuery(
                  data: mQuery.copyWith(textScaler: scale),
                  child: AnimatedTheme(
                      duration: const Duration(milliseconds: 700),
                      data: controller.themedata.value!,
                      child: child!),
                ),
              ),
              GestureDetector(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.transparent,
                    height: mQuery.padding.bottom,
                    width: mQuery.size.width,
                  ),
                ),
              )
            ],
          );
        });
  }
}

Future<void> startApplicationServices() async {
  // Repositories - MUST be injected FIRST
  Get.put<HiveInterface>(Hive, permanent: true);
  Get.put<SettingsRepository>(SettingsRepositoryImpl(), permanent: true);
  Get.lazyPut<DownloadRepository>(() => DownloadRepositoryImpl(), fenix: true);
  Get.lazyPut<SearchRepository>(() => SearchRepositoryImpl(), fenix: true);
  Get.lazyPut<HomeRepository>(
      () => HomeRepositoryImpl(
            remoteDataSource: HomeRemoteDataSourceImpl(
                musicServices: Get.find<MusicServices>()),
            localDataSource: HomeLocalDataSourceImpl(
                activityService: Get.find<ActivityService>(), hive: Hive),
            recommendationDataSource: RecommendationDataSourceImpl(
                activityService: Get.find<ActivityService>(),
                musicServices: Get.find<MusicServices>()),
          ),
      fenix: true);

  // Services
  Get.lazyPut(() => PipedServices(), fenix: true);
  Get.lazyPut(() => MusicServices(), fenix: true);
  Get.lazyPut(() => ActivityService(), fenix: true);
  Get.lazyPut(() => Downloader(), fenix: true);

  // UI Controllers
  Get.lazyPut(() => ThemeController(), fenix: true);
  PlayerBinding().dependencies();
  Get.lazyPut(() => HomeController(), fenix: true);
  Get.lazyPut(
      () => LibrarySongsController(
            getLibrarySongsUseCase: Get.find<GetLibrarySongsUseCase>(),
            watchLibrarySongsUseCase: Get.find<WatchLibrarySongsUseCase>(),
            removeSongFromLibraryUseCase:
                Get.find<RemoveSongFromLibraryUseCase>(),
          ),
      fenix: true);
  Get.lazyPut(
      () => LibraryPlaylistsController(
            getLibraryPlaylistsUseCase: Get.find<GetLibraryPlaylistsUseCase>(),
            createPlaylistUseCase: Get.find<CreatePlaylistUseCase>(),
            renamePlaylistUseCase: Get.find<RenamePlaylistUseCase>(),
            syncPipedPlaylistsUseCase: Get.find<SyncPipedPlaylistsUseCase>(),
          ),
      fenix: true);
  Get.lazyPut(
      () => LibraryAlbumsController(
            getLibraryAlbumsUseCase: Get.find<GetLibraryAlbumsUseCase>(),
          ),
      fenix: true);
  Get.lazyPut(
      () => LibraryArtistsController(
            getLibraryArtistsUseCase: Get.find<GetLibraryArtistsUseCase>(),
          ),
      fenix: true);

  // Settings UseCases
  Get.lazyPut(() => GetAppLanguageUseCase(), fenix: true);
  Get.lazyPut(() => SetAppLanguageUseCase(), fenix: true);
  Get.lazyPut(() => GetThemeModeUseCase(), fenix: true);
  Get.lazyPut(() => SetThemeModeUseCase(), fenix: true);
  Get.lazyPut(() => GetStreamingQualityUseCase(), fenix: true);
  Get.lazyPut(() => SetStreamingQualityUseCase(), fenix: true);
  Get.lazyPut(() => GetDownloadLocationUseCase(), fenix: true);
  Get.lazyPut(() => SetDownloadLocationUseCase(), fenix: true);
  Get.lazyPut(() => GetDownloadingFormatUseCase(), fenix: true);
  Get.lazyPut(() => SetDownloadingFormatUseCase(), fenix: true);
  Get.lazyPut(() => IsSkipSilenceEnabledUseCase(), fenix: true);
  Get.lazyPut(() => SetSkipSilenceEnabledUseCase(), fenix: true);
  Get.lazyPut(() => GetHomeScreenContentNumberUseCase(), fenix: true);
  Get.lazyPut(() => SetHomeScreenContentNumberUseCase(), fenix: true);
  Get.lazyPut(() => GetPlayerUiUseCase(), fenix: true);
  Get.lazyPut(() => SetPlayerUiUseCase(), fenix: true);
  Get.lazyPut(() => IsBottomNavBarEnabledUseCase(), fenix: true);
  Get.lazyPut(() => SetBottomNavBarEnabledUseCase(), fenix: true);
  Get.lazyPut(() => IsSlidableActionEnabledUseCase(), fenix: true);
  Get.lazyPut(() => SetSlidableActionEnabledUseCase(), fenix: true);
  Get.lazyPut(() => GetExportedLocationUseCase(), fenix: true);
  Get.lazyPut(() => SetExportedLocationUseCase(), fenix: true);
  Get.lazyPut(() => ResetDownloadLocationUseCase(), fenix: true);
  Get.lazyPut(() => IsTransitionAnimationDisabledUseCase(), fenix: true);
  Get.lazyPut(() => SetTransitionAnimationDisabledUseCase(), fenix: true);
  Get.lazyPut(() => ClearImagesCacheUseCase(), fenix: true);
  Get.lazyPut(() => GetDiscoverContentTypeUseCase(), fenix: true);
  Get.lazyPut(() => SetDiscoverContentTypeUseCase(), fenix: true);
  Get.lazyPut(() => IsCachingSongsEnabledUseCase(), fenix: true);
  Get.lazyPut(() => SetCachingSongsEnabledUseCase(), fenix: true);
  Get.lazyPut(() => IsLoudnessNormalizationEnabledUseCase(), fenix: true);
  Get.lazyPut(() => SetLoudnessNormalizationEnabledUseCase(), fenix: true);
  Get.lazyPut(() => ShouldRestorePlaybackSessionUseCase(), fenix: true);
  Get.lazyPut(() => SetRestorePlaybackSessionUseCase(), fenix: true);
  Get.lazyPut(() => IsCacheHomeScreenDataEnabledUseCase(), fenix: true);
  Get.lazyPut(() => SetCacheHomeScreenDataEnabledUseCase(), fenix: true);
  Get.lazyPut(() => IsAutoDownloadFavoriteSongEnabledUseCase(), fenix: true);
  Get.lazyPut(() => SetAutoDownloadFavoriteSongEnabledUseCase(), fenix: true);
  Get.lazyPut(() => IsBackgroundPlayEnabledUseCase(), fenix: true);
  Get.lazyPut(() => SetBackgroundPlayEnabledUseCase(), fenix: true);
  Get.lazyPut(() => IsIgnoringBatteryOptimizationsUseCase(), fenix: true);
  Get.lazyPut(() => EnableIgnoringBatteryOptimizationsUseCase(), fenix: true);
  Get.lazyPut(() => ShouldAutoOpenPlayerUseCase(), fenix: true);
  Get.lazyPut(() => SetAutoOpenPlayerUseCase(), fenix: true);
  Get.lazyPut(() => IsPipedLinkedUseCase(), fenix: true);
  Get.lazyPut(() => UnlinkPipedUseCase(), fenix: true);
  Get.lazyPut(() => ResetAppSettingsToDefaultUseCase(), fenix: true);
  Get.lazyPut(() => ShouldStopPlaybackOnSwipeAwayUseCase(), fenix: true);
  Get.lazyPut(() => SetStopPlaybackOnSwipeAwayUseCase(), fenix: true);

  // Search UseCases
  Get.lazyPut(() => GetSearchSuggestionsUseCase(), fenix: true);
  Get.lazyPut(() => SearchUseCase(), fenix: true);
  Get.lazyPut(() => GetSearchContinuationUseCase(), fenix: true);

  // Home UseCases
  Get.lazyPut(() => GetHomePageContentUseCase(Get.find<HomeRepository>()),
      fenix: true);
  Get.lazyPut(() => GetRecentlyPlayedUseCase(Get.find<HomeRepository>()),
      fenix: true);
  Get.lazyPut(() => GetRecommendationsUseCase(Get.find<HomeRepository>()),
      fenix: true);
  Get.lazyPut(() => GetCachedHomeContentUseCase(Get.find<HomeRepository>()),
      fenix: true);
  Get.lazyPut(() => CacheHomeContentUseCase(Get.find<HomeRepository>()),
      fenix: true);
  Get.lazyPut(() => GetQuickPicksUseCase(Get.find<HomeRepository>()),
      fenix: true);

  // Download UseCases
  Get.lazyPut(() => DownloadSongUseCase(), fenix: true);
  Get.lazyPut(() => GetSongQueueUseCase(), fenix: true);
  Get.lazyPut(() => GetCurrentSongUseCase(), fenix: true);
  Get.lazyPut(() => GetSongDownloadingProgressUseCase(), fenix: true);
  Get.lazyPut(() => IsJobRunningUseCase(), fenix: true);
  Get.lazyPut(() => CancelPlaylistDownloadUseCase(), fenix: true);
  Get.lazyPut(() => DownloadPlaylistUseCase(), fenix: true);
  Get.lazyPut(() => GetCurrentPlaylistIdUseCase(), fenix: true);
  Get.lazyPut(() => GetPlaylistDownloadingProgressUseCase(), fenix: true);
  Get.lazyPut(() => GetCompletedPlaylistIdUseCase(), fenix: true);

  // Player Module - Data Sources
  Get.lazyPut<PlaybackLocalDataSource>(
      () => PlaybackLocalDataSourceImpl(
          prevSessionBox: Hive.box("prevSessionData"),
          appPrefsBox: Hive.box("AppPrefs")),
      fenix: true);

  // Player Module - Repositories
  Get.lazyPut<AudioSourceRepository>(() => AudioSourceRepositoryImpl(),
      fenix: true);
  Get.lazyPut<PlaybackSessionRepository>(
      () => PlaybackSessionRepositoryImpl(Get.find<PlaybackLocalDataSource>()),
      fenix: true);

  // Player Module - UseCases
  Get.lazyPut(() => GetPlayableUrlUseCase(Get.find<AudioSourceRepository>()),
      fenix: true);
  Get.lazyPut(
      () => SavePlaybackSessionUseCase(Get.find<PlaybackSessionRepository>()),
      fenix: true);

  // Album Module - Data Sources
  Get.lazyPut<AlbumRemoteDataSource>(
      () => AlbumRemoteDataSourceImpl(Get.find<MusicServices>()),
      fenix: true);
  Get.lazyPut<AlbumLocalDataSource>(() => AlbumLocalDataSourceImpl(Hive),
      fenix: true);

  // Album Module - Repository
  Get.lazyPut<AlbumRepository>(
      () => AlbumRepositoryImpl(
            remoteDataSource: Get.find<AlbumRemoteDataSource>(),
            localDataSource: Get.find<AlbumLocalDataSource>(),
          ),
      fenix: true);

  // Album Module - UseCases
  Get.lazyPut(() => GetAlbumDetailsUseCase(Get.find<AlbumRepository>()),
      fenix: true);
  Get.lazyPut(() => GetAlbumTracksUseCase(Get.find<AlbumRepository>()),
      fenix: true);
  Get.lazyPut(() => AddAlbumToLibraryUseCase(Get.find<AlbumRepository>()),
      fenix: true);
  Get.lazyPut(() => RemoveAlbumFromLibraryUseCase(Get.find<AlbumRepository>()),
      fenix: true);
  Get.lazyPut(() => IsAlbumInLibraryUseCase(Get.find<AlbumRepository>()),
      fenix: true);

  // Library Module - Data Sources
  Get.lazyPut<LibraryLocalDataSource>(
      () => LibraryLocalDataSourceImpl(
            songsDownloadBox: Hive.box('SongDownloads'),
            songsCacheBox: Hive.box('SongsCache'),
            favoritesBox: Hive.box('LIBFAV'),
            playlistsBox: Hive.box('userPlaylists'),
            albumsBox: Hive.box('userAlbums'),
            artistsBox: Hive.box('userArtists'),
          ),
      fenix: true);

  // Library Module - Repository
  Get.lazyPut<LibraryRepository>(
      () => LibraryRepositoryImpl(
            localDataSource: Get.find<LibraryLocalDataSource>(),
          ),
      fenix: true);

  // Library Module - UseCases
  Get.lazyPut(() => GetLibrarySongsUseCase(), fenix: true);
  Get.lazyPut(() => WatchLibrarySongsUseCase(Get.find<LibraryRepository>()),
      fenix: true);
  Get.lazyPut(() => AddSongToLibraryUseCase(), fenix: true);
  Get.lazyPut(() => RemoveSongFromLibraryUseCase(), fenix: true);
  Get.lazyPut(() => GetLibraryPlaylistsUseCase(), fenix: true);
  Get.lazyPut(() => CreatePlaylistUseCase(), fenix: true);
  Get.lazyPut(() => RenamePlaylistUseCase(), fenix: true);
  Get.lazyPut(() => SyncPipedPlaylistsUseCase(), fenix: true);
  Get.lazyPut(() => GetLibraryAlbumsUseCase(), fenix: true);
  Get.lazyPut(() => GetLibraryArtistsUseCase(), fenix: true);

  // Settings Controller (depends on UseCases)
  Get.lazyPut(() => SettingsController(), fenix: true);

  if (GetPlatform.isDesktop) {
    Get.lazyPut(() => app_controllers.SearchController(), fenix: true);
    Get.put(DesktopSystemTray());
  }
}

initHive() async {
  String applicationDataDirectoryPath;
  if (GetPlatform.isDesktop) {
    applicationDataDirectoryPath =
        "${(await getApplicationSupportDirectory()).path}/db";
  } else {
    applicationDataDirectoryPath =
        (await getApplicationDocumentsDirectory()).path;
  }
  await Hive.initFlutter(applicationDataDirectoryPath);
  await Hive.openBox("SongsCache");
  await Hive.openBox("SongDownloads");
  await Hive.openBox('SongsUrlCache');
  await Hive.openBox("AppPrefs");
  await Hive.openBox("homeScreenData");
  await Hive.openBox('userHistory');
  await Hive.openBox('userPlaylists');
  await Hive.openBox('userArtists');
  await Hive.openBox('userAlbums');
  await Hive.openBox('LIBFAV');
  await Hive.openBox('prevSessionData'); // Added
}

void _setAppInitPrefs() {
  final appPrefs = Hive.box("AppPrefs");
  if (appPrefs.isEmpty) {
    appPrefs.putAll({
      'themeModeType': 0,
      "cacheSongs": false,
      "skipSilenceEnabled": false,
      'streamingQuality': 1,
      'themePrimaryColor': 4278199603,
      'discoverContentType': "QP",
      'newVersionVisibility': updateCheckFlag,
      "cacheHomeScreenData": true
    });
  }
}

class LifecycleHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else if (state == AppLifecycleState.detached) {
      await Get.find<AudioHandler>().customAction("saveSession");
    }
  }
}
