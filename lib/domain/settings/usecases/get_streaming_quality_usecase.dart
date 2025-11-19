import 'package:get/get.dart';
import 'package:harmonymusic/services/music_service.dart';
import '../repository/settings_repository.dart';

class GetStreamingQualityUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  AudioQuality call() {
    return _settingsRepository.getStreamingQuality();
  }
}
