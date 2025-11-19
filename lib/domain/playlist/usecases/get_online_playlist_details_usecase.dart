import 'package:harmonymusic/domain/playlist/entities/playlist_entity.dart';
import 'package:harmonymusic/domain/playlist/repositories/playlist_repository.dart';

class GetOnlinePlaylistDetailsUseCase {
  final PlaylistRepository _repository;

  GetOnlinePlaylistDetailsUseCase(this._repository);

  Future<PlaylistEntity> call(String playlistId) async {
    if (playlistId.isEmpty) {
      throw ArgumentError('playlistId cannot be empty');
    }
    return _repository.getOnlinePlaylistDetails(playlistId);
  }
}
