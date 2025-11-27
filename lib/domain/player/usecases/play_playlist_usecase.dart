import 'package:audio_service/audio_service.dart';
import '../repository/player_repository.dart';

class PlayPlaylistUseCase {
  final PlayerRepository _repository;

  PlayPlaylistUseCase(this._repository);

  Future<void> call(List<MediaItem> songs, {int index = 0}) {
    return _repository.playPlaylist(songs, index);
  }
}
