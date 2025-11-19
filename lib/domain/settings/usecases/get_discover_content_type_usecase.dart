import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class GetDiscoverContentTypeUseCase {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  String call() {
    return _settingsRepository.getDiscoverContentType();
  }
}
