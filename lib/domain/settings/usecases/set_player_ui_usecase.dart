import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class SetPlayerUiUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  Future<void> call(int ui) {
    return _settingsRepository.setPlayerUi(ui);
  }
}
