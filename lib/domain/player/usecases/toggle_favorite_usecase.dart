import 'package:audio_service/audio_service.dart';
import '../repository/player_repository.dart';

class ToggleFavoriteUseCase {
  final PlayerRepository _repository;

  ToggleFavoriteUseCase(this._repository);

  Future<void> call(MediaItem song) {
    return _repository.toggleFavorite(song);
  }
}
