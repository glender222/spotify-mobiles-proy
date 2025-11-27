import 'package:audio_service/audio_service.dart';
import '../repositories/playback_session_repository.dart';

class SavePlaybackSessionUseCase {
  final PlaybackSessionRepository repository;

  SavePlaybackSessionUseCase(this.repository);

  Future<void> call(List<MediaItem> queue, int index, Duration position) {
    return repository.saveSession(queue, index, position);
  }
}
