import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class IsIgnoringBatteryOptimizationsUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  Future<bool> call() {
    return _settingsRepository.isIgnoringBatteryOptimizations();
  }
}
