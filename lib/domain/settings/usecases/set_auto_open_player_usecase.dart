import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class SetAutoOpenPlayerUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  Future<void> call(bool open) {
    return _settingsRepository.setAutoOpenPlayer(open);
  }
}
