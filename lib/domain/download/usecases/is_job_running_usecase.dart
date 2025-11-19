import 'package:get/get.dart';
import '../repository/download_repository.dart';

class IsJobRunningUseCase {
  final DownloadRepository _downloadRepository = Get.find<DownloadRepository>();

  Stream<bool> call() {
    return _downloadRepository.isJobRunning;
  }
}
