import 'package:get/get.dart';
import 'package:harmonymusic/ui/utils/theme_controller.dart';
import '../repository/settings_repository.dart';

class GetThemeModeUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  ThemeType call() {
    return _settingsRepository.getThemeMode();
  }
}
