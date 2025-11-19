import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:harmonymusic/data/playlist/datasources/playlist_local_data_source.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:harmonymusic/data/playlist/datasources/playlist_export_data_source.dart';
import 'package:harmonymusic/domain/playlist/usecases/update_local_playlist_usecase.dart';
import 'package:harmonymusic/domain/playlist/usecases/export_playlist_usecase.dart';
import 'package:harmonymusic/data/playlist/datasources/playlist_remote_data_source.dart';
import 'package:harmonymusic/domain/playlist/usecases/get_online_playlist_details_usecase.dart';
import 'package:harmonymusic/data/playlist/repositories/playlist_repository_impl.dart';
import 'package:harmonymusic/domain/playlist/repositories/playlist_repository.dart';
import 'package:harmonymusic/domain/playlist/usecases/save_playlist_usecase.dart';
import 'package:harmonymusic/domain/playlist/usecases/remove_playlist_usecase.dart';

class PlaylistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlaylistLocalDataSource>(
      () => PlaylistLocalDataSourceImpl(Hive),
    );
    Get.lazyPut<PlaylistRemoteDataSource>(
      () => PlaylistRemoteDataSourceImpl(
          musicServices: Get.find<MusicServices>()),
    );
    Get.lazyPut<PlaylistExportDataSource>(
      () => PlaylistExportDataSourceImpl(hive: Hive),
    );

    Get.lazyPut<PlaylistRepository>(
      () => PlaylistRepositoryImpl(
        localDataSource: Get.find<PlaylistLocalDataSource>(),
        remoteDataSource: Get.find<PlaylistRemoteDataSource>(),
        exportDataSource: Get.find<PlaylistExportDataSource>(),
      ),
    );

    Get.lazyPut<SavePlaylistUseCase>(
      () => SavePlaylistUseCase(Get.find<PlaylistRepository>()),
    );

    Get.lazyPut<RemovePlaylistUseCase>(
      () => RemovePlaylistUseCase(Get.find<PlaylistRepository>()),
    );

    Get.lazyPut<GetOnlinePlaylistDetailsUseCase>(
      () => GetOnlinePlaylistDetailsUseCase(Get.find<PlaylistRepository>()),
    );

    Get.lazyPut<UpdateLocalPlaylistUseCase>(
      () => UpdateLocalPlaylistUseCase(Get.find<PlaylistRepository>()),
    );

    Get.lazyPut<ExportPlaylistUseCase>(
      () => ExportPlaylistUseCase(Get.find<PlaylistRepository>()),
    );
  }
}
