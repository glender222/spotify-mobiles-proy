import 'package:get/get.dart';
import 'package:harmonymusic/ui/utils/theme_controller.dart';
import '../repository/settings_repository.dart';

class SetThemeModeUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  Future<void> call(ThemeType theme) {
    return _settingsRepository.setThemeMode(theme);
  }
}
