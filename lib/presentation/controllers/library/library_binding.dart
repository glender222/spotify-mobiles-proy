import 'package:get/get.dart';
import 'package:hive/hive.dart';

// Domain
import '/domain/library/repository/library_repository.dart';

// Use Cases
import '/domain/library/usecases/get_library_songs_usecase.dart';
import '/domain/library/usecases/remove_song_from_library_usecase.dart';
import '/domain/library/usecases/get_library_playlists_usecase.dart';
import '/domain/library/usecases/create_playlist_usecase.dart';
import '/domain/library/usecases/rename_playlist_usecase.dart';
import '/domain/library/usecases/sync_piped_playlists_usecase.dart';
import '/domain/library/usecases/get_library_albums_usecase.dart';
import '/domain/library/usecases/get_library_artists_usecase.dart';

// Data
import '/data/library/datasources/library_local_datasource.dart';
import '/data/library/datasources/library_local_datasource_impl.dart';
import '/data/library/repository/library_repository_impl.dart';

// Presentation
import '/presentation/controllers/library/library_songs_controller.dart';
import '/presentation/controllers/library/library_playlists_controller.dart';
import '/presentation/controllers/library/library_albums_controller.dart';
import '/presentation/controllers/library/library_artists_controller.dart';

/// Binding for Library Module
/// Registers all dependencies for Clean Architecture
class LibraryBinding extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    Get.lazyPut<LibraryLocalDataSource>(
      () => LibraryLocalDataSourceImpl(
        songsDownloadBox: Hive.box('SongDownloads'),
        songsCacheBox: Hive.box('SongsCache'),
        playlistsBox: Hive.box('LibraryPlaylists'),
        albumsBox: Hive.box('LibraryAlbums'),
        artistsBox: Hive.box('LibraryArtists'),
      ),
    );

    // Repository
    Get.lazyPut<LibraryRepository>(
      () => LibraryRepositoryImpl(
        localDataSource: Get.find<LibraryLocalDataSource>(),
      ),
    );

    // Use Cases - Songs
    Get.lazyPut(() => GetLibrarySongsUseCase());
    Get.lazyPut(() => RemoveSongFromLibraryUseCase());

    // Use Cases - Playlists
    Get.lazyPut(() => GetLibraryPlaylistsUseCase());
    Get.lazyPut(() => CreatePlaylistUseCase());
    Get.lazyPut(() => RenamePlaylistUseCase());
    Get.lazyPut(() => SyncPipedPlaylistsUseCase());

    // Use Cases - Albums
    Get.lazyPut(() => GetLibraryAlbumsUseCase());

    // Use Cases - Artists
    Get.lazyPut(() => GetLibraryArtistsUseCase());

    // Controllers
    Get.lazyPut(
      () => LibrarySongsController(
        getLibrarySongsUseCase: Get.find<GetLibrarySongsUseCase>(),
        removeSongFromLibraryUseCase: Get.find<RemoveSongFromLibraryUseCase>(),
      ),
    );

    Get.lazyPut(
      () => LibraryPlaylistsController(
        getLibraryPlaylistsUseCase: Get.find<GetLibraryPlaylistsUseCase>(),
        createPlaylistUseCase: Get.find<CreatePlaylistUseCase>(),
        renamePlaylistUseCase: Get.find<RenamePlaylistUseCase>(),
        syncPipedPlaylistsUseCase: Get.find<SyncPipedPlaylistsUseCase>(),
      ),
    );

    Get.lazyPut(
      () => LibraryAlbumsController(
        getLibraryAlbumsUseCase: Get.find<GetLibraryAlbumsUseCase>(),
      ),
    );

    Get.lazyPut(
      () => LibraryArtistsController(
        getLibraryArtistsUseCase: Get.find<GetLibraryArtistsUseCase>(),
      ),
    );
  }
}
