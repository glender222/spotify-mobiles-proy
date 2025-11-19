import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import '../repository/download_repository.dart';

class GetSongQueueUseCase {
  final DownloadRepository _downloadRepository = Get.find<DownloadRepository>();

  Stream<List<MediaItem>> call() {
    return _downloadRepository.songQueue;
  }
}
