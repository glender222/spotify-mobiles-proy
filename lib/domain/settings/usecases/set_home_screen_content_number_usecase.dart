import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class SetHomeScreenContentNumberUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  Future<void> call(int number) {
    return _settingsRepository.setHomeScreenContentNumber(number);
  }
}
