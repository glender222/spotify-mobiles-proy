import 'package:audio_service/audio_service.dart';

abstract class PlaybackSessionRepository {
  Future<void> saveSession(List<MediaItem> queue, int index, Duration position);
  Future<Map<String, dynamic>?> restoreSession();
  bool getSkipSilenceEnabled();
  bool getLoudnessNormalizationEnabled();
}
