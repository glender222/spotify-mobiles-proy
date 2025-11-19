import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class GetDownloadingFormatUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  String call() {
    return _settingsRepository.getDownloadingFormat();
  }
}
