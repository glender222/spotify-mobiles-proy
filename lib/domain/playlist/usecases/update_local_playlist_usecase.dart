import 'package:harmonymusic/domain/playlist/entities/playlist_entity.dart';
import 'package:harmonymusic/domain/playlist/repositories/playlist_repository.dart';

class UpdateLocalPlaylistUseCase {
  final PlaylistRepository _repository;

  UpdateLocalPlaylistUseCase(this._repository);

  Future<void> call(PlaylistEntity playlist) async {
    // Business logic could be added here, e.g., validating the playlist.
    return _repository.updateLocalPlaylist(playlist);
  }
}
