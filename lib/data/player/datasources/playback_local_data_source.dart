import 'package:hive/hive.dart';

abstract class PlaybackLocalDataSource {
  Future<void> saveSession(Map<String, dynamic> sessionData);
  Future<Map<String, dynamic>?> getLastSession();
  bool getSkipSilenceEnabled();
  bool getLoudnessNormalizationEnabled();
}

class PlaybackLocalDataSourceImpl implements PlaybackLocalDataSource {
  final Box prevSessionBox;
  final Box appPrefsBox;

  PlaybackLocalDataSourceImpl({
    required this.prevSessionBox,
    required this.appPrefsBox,
  });

  @override
  Future<void> saveSession(Map<String, dynamic> sessionData) async {
    await prevSessionBox.clear();
    await prevSessionBox.putAll(sessionData);
  }

  @override
  Future<Map<String, dynamic>?> getLastSession() async {
    if (prevSessionBox.isEmpty) return null;
    return Map<String, dynamic>.from(prevSessionBox.toMap());
  }

  @override
  bool getSkipSilenceEnabled() {
    return appPrefsBox.get("skipSilenceEnabled") ?? false;
  }

  @override
  bool getLoudnessNormalizationEnabled() {
    return appPrefsBox.get("loudnessNormalizationEnabled") ?? false;
  }
}
