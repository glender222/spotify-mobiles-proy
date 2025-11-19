import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class SetStopPlaybackOnSwipeAwayUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  Future<void> call(bool stop) {
    return _settingsRepository.setStopPlaybackOnSwipeAway(stop);
  }
}
