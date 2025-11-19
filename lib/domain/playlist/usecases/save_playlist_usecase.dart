import 'package:harmonymusic/domain/playlist/entities/playlist_entity.dart';
import 'package:harmonymusic/domain/playlist/repositories/playlist_repository.dart';

class SavePlaylistUseCase {
  final PlaylistRepository _repository;

  SavePlaylistUseCase(this._repository);

  Future<void> call(PlaylistEntity playlist) async {
    return _repository.savePlaylist(playlist);
  }
}
