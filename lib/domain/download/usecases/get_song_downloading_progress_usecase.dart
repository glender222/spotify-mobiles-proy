import 'package:get/get.dart';
import '../repository/download_repository.dart';

class GetSongDownloadingProgressUseCase {
  final DownloadRepository _downloadRepository = Get.find<DownloadRepository>();

  Stream<int> call() {
    return _downloadRepository.songDownloadingProgress;
  }
}
