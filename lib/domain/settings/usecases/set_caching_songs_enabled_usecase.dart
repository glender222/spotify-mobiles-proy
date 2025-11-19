import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class SetCachingSongsEnabledUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  Future<void> call(bool enabled) {
    return _settingsRepository.setCachingSongsEnabled(enabled);
  }
}
