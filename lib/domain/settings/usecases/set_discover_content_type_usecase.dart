import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class SetDiscoverContentTypeUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  Future<void> call(String type) {
    return _settingsRepository.setDiscoverContentType(type);
  }
}
