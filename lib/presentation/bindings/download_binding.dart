import 'package:get/get.dart';

import '../../../data/download/repository/download_repository_impl.dart';
import '../../../domain/download/repository/download_repository.dart';
import '../../../domain/download/usecases/cancel_playlist_download_usecase.dart';
import '../../../domain/download/usecases/download_playlist_usecase.dart';
import '../../../domain/download/usecases/download_song_usecase.dart';
import '../../../domain/download/usecases/get_current_playlist_id_usecase.dart';
import '../../../domain/download/usecases/get_playlist_downloading_progress_usecase.dart';
import '../../../domain/download/usecases/get_song_downloading_progress_usecase.dart';
import '../../../domain/download/usecases/get_current_song_usecase.dart';
import '../../../domain/download/usecases/get_song_queue_usecase.dart';
import '../../../domain/download/usecases/is_job_running_usecase.dart';

class DownloadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DownloadRepository>(() => DownloadRepositoryImpl());
    Get.lazyPut(() => DownloadSongUseCase());
    Get.lazyPut(() => DownloadPlaylistUseCase());
    Get.lazyPut(() => CancelPlaylistDownloadUseCase());
    Get.lazyPut(() => GetSongDownloadingProgressUseCase());
    Get.lazyPut(() => GetPlaylistDownloadingProgressUseCase());
    Get.lazyPut(() => IsJobRunningUseCase());
    Get.lazyPut(() => GetCurrentPlaylistIdUseCase());
    Get.lazyPut(() => GetSongQueueUseCase());
    Get.lazyPut(() => GetCurrentSongUseCase());
  }
}
