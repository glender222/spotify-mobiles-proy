import 'package:audio_service/audio_service.dart';
import '../repository/player_repository.dart';

class AddToQueueUseCase {
  final PlayerRepository _repository;

  AddToQueueUseCase(this._repository);

  Future<void> call(MediaItem song) {
    return _repository.addToQueue(song);
  }
}
