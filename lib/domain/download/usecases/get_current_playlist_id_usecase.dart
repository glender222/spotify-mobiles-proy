import 'package:get/get.dart';
import '../repository/download_repository.dart';

class GetCurrentPlaylistIdUseCase {
  final DownloadRepository _downloadRepository = Get.find<DownloadRepository>();

  Stream<String> call() {
    return _downloadRepository.currentPlaylistId;
  }
}
