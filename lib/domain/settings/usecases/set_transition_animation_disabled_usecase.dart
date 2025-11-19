import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class SetTransitionAnimationDisabledUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  Future<void> call(bool disabled) {
    return _settingsRepository.setTransitionAnimationDisabled(disabled);
  }
}
