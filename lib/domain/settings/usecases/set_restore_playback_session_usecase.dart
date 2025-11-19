import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class SetRestorePlaybackSessionUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  Future<void> call(bool restore) {
    return _settingsRepository.setRestorePlaybackSession(restore);
  }
}
