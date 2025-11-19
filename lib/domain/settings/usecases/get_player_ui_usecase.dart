import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class GetPlayerUiUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  int call() {
    return _settingsRepository.getPlayerUi();
  }
}
