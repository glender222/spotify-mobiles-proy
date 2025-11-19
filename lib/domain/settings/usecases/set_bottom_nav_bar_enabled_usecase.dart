import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class SetBottomNavBarEnabledUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  Future<void> call(bool enabled) {
    return _settingsRepository.setBottomNavBarEnabled(enabled);
  }
}
