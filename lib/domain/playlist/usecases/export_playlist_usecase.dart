import 'package:harmonymusic/domain/playlist/entities/export_type.dart';
import 'package:harmonymusic/domain/playlist/repositories/playlist_repository.dart';

class ExportPlaylistUseCase {
  final PlaylistRepository _repository;

  ExportPlaylistUseCase(this._repository);

  Future<String> call({required String playlistId, required ExportType format}) async {
    if (playlistId.isEmpty) {
      throw ArgumentError('playlistId cannot be empty');
    }
    return _repository.exportPlaylist(playlistId: playlistId, format: format);
  }
}
