import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class GetExportedLocationUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  Future<String> call() {
    return _settingsRepository.getExportedLocation();
  }
}
