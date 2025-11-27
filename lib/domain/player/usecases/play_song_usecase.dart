import 'package:audio_service/audio_service.dart';
import '../repository/player_repository.dart';

class PlaySongUseCase {
  final PlayerRepository _repository;

  PlaySongUseCase(this._repository);

  Future<void> call(MediaItem song) {
    return _repository.playSong(song);
  }
}
