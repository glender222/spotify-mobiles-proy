import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class GetDownloadLocationUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  Future<String> call() {
    return _settingsRepository.getDownloadLocation();
  }
}
