import 'package:audio_service/audio_service.dart';
import '../repository/player_repository.dart';

class RemoveFromQueueUseCase {
  final PlayerRepository _repository;

  RemoveFromQueueUseCase(this._repository);

  Future<void> call(MediaItem song) {
    return _repository.removeFromQueue(song);
  }
}
