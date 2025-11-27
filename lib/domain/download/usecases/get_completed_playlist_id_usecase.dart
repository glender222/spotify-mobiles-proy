import 'package:get/get.dart';
import '../repository/download_repository.dart';

class GetCompletedPlaylistIdUseCase {
  final DownloadRepository _downloadRepository = Get.find<DownloadRepository>();

  Stream<String> call() {
    return _downloadRepository.completedPlaylistId;
  }
}
