import 'package:get/get.dart';
import '../repository/download_repository.dart';

class CancelPlaylistDownloadUseCase {
  final DownloadRepository _downloadRepository = Get.find<DownloadRepository>();

  Future<void> call(String playlistId) async {
    await _downloadRepository.cancelPlaylistDownload(playlistId);
  }
}
