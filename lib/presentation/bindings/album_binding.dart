import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../domain/album/repositories/album_repository.dart';
import '../../domain/album/usecases/get_album_details_usecase.dart';
import '../../domain/album/usecases/get_album_tracks_usecase.dart';
import '../../domain/album/usecases/add_album_to_library_usecase.dart';
import '../../domain/album/usecases/remove_album_from_library_usecase.dart';
import '../../domain/album/usecases/is_album_in_library_usecase.dart';
import '../../data/album/repositories/album_repository_impl.dart';
import '../../data/album/datasources/album_remote_data_source.dart';
import '../../data/album/datasources/album_local_data_source.dart';
import '../../services/music_service.dart';
import '../controllers/album/album_controller.dart';

import '../../domain/download/usecases/get_completed_playlist_id_usecase.dart';

/// Binding for Album module
/// Handles dependency injection for Album screen
class AlbumBinding extends Bindings {
  final String? tag;
  AlbumBinding({this.tag});

  @override
  void dependencies() {
    // Data Sources
    Get.lazyPut<AlbumRemoteDataSource>(
      () => AlbumRemoteDataSourceImpl(Get.find<MusicServices>()),
      fenix: true,
    );

    Get.lazyPut<AlbumLocalDataSource>(
      () => AlbumLocalDataSourceImpl(Hive),
      fenix: true,
    );

    // Repository
    Get.lazyPut<AlbumRepository>(
      () => AlbumRepositoryImpl(
        remoteDataSource: Get.find<AlbumRemoteDataSource>(),
        localDataSource: Get.find<AlbumLocalDataSource>(),
      ),
      fenix: true,
    );

    // Use Cases
    Get.lazyPut(
      () => GetAlbumDetailsUseCase(Get.find<AlbumRepository>()),
      fenix: true,
    );

    Get.lazyPut(
      () => GetAlbumTracksUseCase(Get.find<AlbumRepository>()),
      fenix: true,
    );

    Get.lazyPut(
      () => AddAlbumToLibraryUseCase(Get.find<AlbumRepository>()),
      fenix: true,
    );

    Get.lazyPut(
      () => RemoveAlbumFromLibraryUseCase(Get.find<AlbumRepository>()),
      fenix: true,
    );

    Get.lazyPut(
      () => IsAlbumInLibraryUseCase(Get.find<AlbumRepository>()),
      fenix: true,
    );

    // Controller
    Get.lazyPut(
      () => AlbumController(
        getAlbumDetails: Get.find<GetAlbumDetailsUseCase>(),
        getAlbumTracks: Get.find<GetAlbumTracksUseCase>(),
        addToLibrary: Get.find<AddAlbumToLibraryUseCase>(),
        removeFromLibrary: Get.find<RemoveAlbumFromLibraryUseCase>(),
        isInLibrary: Get.find<IsAlbumInLibraryUseCase>(),
        getCompletedPlaylistIdUseCase:
            Get.find<GetCompletedPlaylistIdUseCase>(),
      ),
      tag: tag,
      fenix: true,
    );
  }
}
