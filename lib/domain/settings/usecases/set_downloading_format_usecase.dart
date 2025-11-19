import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class SetDownloadingFormatUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  Future<void> call(String format) {
    return _settingsRepository.setDownloadingFormat(format);
  }
}
