import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class IsBackgroundPlayEnabledUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  bool call() {
    return _settingsRepository.isBackgroundPlayEnabled();
  }
}
