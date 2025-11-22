import 'package:audio_service/audio_service.dart';
import '../repositories/album_repository.dart';

/// UseCase to fetch album tracks from the repository
///
/// Following Clean Architecture principles:
/// - Single Responsibility: Only fetches album tracks
/// - Dependency Inversion: Depends on AlbumRepository abstraction
class GetAlbumTracksUseCase {
  final AlbumRepository _repository;

  GetAlbumTracksUseCase(this._repository);

  /// Executes the use case to get album tracks
  ///
  /// [albumId] - The ID of the album whose tracks to fetch
  /// Returns a list of [MediaItem] representing the album's tracks
  /// Throws an exception if the album is not found or network error occurs
  Future<List<MediaItem>> call(String albumId) async {
    return await _repository.getAlbumTracks(albumId);
  }
}
