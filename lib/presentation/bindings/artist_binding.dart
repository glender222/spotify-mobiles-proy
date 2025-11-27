import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../domain/artist/repositories/artist_repository.dart';
import '../../domain/artist/usecases/get_artist_details_usecase.dart';
import '../../domain/artist/usecases/get_artist_content_usecase.dart';
import '../../domain/artist/usecases/get_artist_tab_content_usecase.dart';
import '../../domain/artist/usecases/add_artist_to_library_usecase.dart';
import '../../domain/artist/usecases/remove_artist_from_library_usecase.dart';
import '../../domain/artist/usecases/is_artist_in_library_usecase.dart';
import '../../data/artist/repositories/artist_repository_impl.dart';
import '../../data/artist/datasources/artist_remote_data_source.dart';
import '../../data/artist/datasources/artist_local_data_source.dart';
import '../../services/music_service.dart';
import '../controllers/artist/artist_controller.dart';

/// Binding for Artist module
/// Handles dependency injection for Artist screen
class ArtistBinding extends Bindings {
  final String? tag;
  ArtistBinding({this.tag});

  @override
  void dependencies() {
    // Data Sources
    Get.lazyPut<ArtistRemoteDataSource>(
      () => ArtistRemoteDataSourceImpl(Get.find<MusicServices>()),
      fenix: true,
    );

    Get.lazyPut<ArtistLocalDataSource>(
      () => ArtistLocalDataSourceImpl(Hive),
      fenix: true,
    );

    // Repository
    Get.lazyPut<ArtistRepository>(
      () => ArtistRepositoryImpl(
        remoteDataSource: Get.find<ArtistRemoteDataSource>(),
        localDataSource: Get.find<ArtistLocalDataSource>(),
      ),
      fenix: true,
    );

    // Use Cases
    Get.lazyPut(
      () => GetArtistDetailsUseCase(Get.find<ArtistRepository>()),
      fenix: true,
    );

    Get.lazyPut(
      () => GetArtistContentUseCase(Get.find<ArtistRepository>()),
      fenix: true,
    );

    Get.lazyPut(
      () => GetArtistTabContentUseCase(Get.find<ArtistRepository>()),
      fenix: true,
    );

    Get.lazyPut(
      () => AddArtistToLibraryUseCase(Get.find<ArtistRepository>()),
      fenix: true,
    );

    Get.lazyPut(
      () => RemoveArtistFromLibraryUseCase(Get.find<ArtistRepository>()),
      fenix: true,
    );

    Get.lazyPut(
      () => IsArtistInLibraryUseCase(Get.find<ArtistRepository>()),
      fenix: true,
    );

    // Controller
    Get.lazyPut(
      () => ArtistController(
        getArtistDetails: Get.find<GetArtistDetailsUseCase>(),
        getArtistContent: Get.find<GetArtistContentUseCase>(),
        getTabContent: Get.find<GetArtistTabContentUseCase>(),
        addToLibrary: Get.find<AddArtistToLibraryUseCase>(),
        removeFromLibrary: Get.find<RemoveArtistFromLibraryUseCase>(),
        isInLibrary: Get.find<IsArtistInLibraryUseCase>(),
      ),
      tag: tag,
      fenix: true,
    );
  }
}
