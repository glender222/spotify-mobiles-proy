import 'package:audio_service/audio_service.dart';
import '../repository/player_repository.dart';

class GetCurrentSongStreamUseCase {
  final PlayerRepository _repository;

  GetCurrentSongStreamUseCase(this._repository);

  Stream<MediaItem?> call() {
    return _repository.currentSongStream;
  }
}
