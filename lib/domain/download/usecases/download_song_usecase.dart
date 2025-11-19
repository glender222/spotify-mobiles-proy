import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import '../repository/download_repository.dart';

class DownloadSongUseCase {
  final DownloadRepository _downloadRepository = Get.find<DownloadRepository>();

  Future<void> call(MediaItem song) async {
    await _downloadRepository.downloadSong(song);
  }
}
