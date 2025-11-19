import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class SetExportedLocationUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  Future<void> call() {
    return _settingsRepository.setExportedLocation();
  }
}
