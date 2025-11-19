import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class SetAppLanguageUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  Future<void> call(String languageCode) {
    return _settingsRepository.setAppLanguage(languageCode);
  }
}
