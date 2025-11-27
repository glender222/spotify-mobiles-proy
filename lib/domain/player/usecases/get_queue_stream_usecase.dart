import 'package:audio_service/audio_service.dart';
import '../repository/player_repository.dart';

class GetQueueStreamUseCase {
  final PlayerRepository _repository;

  GetQueueStreamUseCase(this._repository);

  Stream<List<MediaItem>> call() {
    return _repository.queueStream;
  }
}
