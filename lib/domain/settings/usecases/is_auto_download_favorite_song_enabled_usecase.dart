import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class IsAutoDownloadFavoriteSongEnabledUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  bool call() {
    return _settingsRepository.isAutoDownloadFavoriteSongEnabled();
  }
}
