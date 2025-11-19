import 'package:harmonymusic/domain/playlist/repositories/playlist_repository.dart';

class RemovePlaylistUseCase {
  final PlaylistRepository _repository;

  RemovePlaylistUseCase(this._repository);

  Future<void> call(String playlistId) async {
    if (playlistId.isEmpty) {
      throw ArgumentError('playlistId cannot be empty');
    }
    return _repository.removePlaylist(playlistId);
  }
}
