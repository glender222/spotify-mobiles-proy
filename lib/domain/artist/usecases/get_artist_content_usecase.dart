import '../repositories/artist_repository.dart';
import '../entities/artist_entity.dart';

/// UseCase to fetch artist content (songs, albums, videos, etc.)
class GetArtistContentUseCase {
  final ArtistRepository _repository;

  GetArtistContentUseCase(this._repository);

  /// Executes the use case to get artist content
  /// [artistId] - The ID of the artist
  /// Returns [ArtistContentEntity] with all content
  Future<ArtistContentEntity> call(String artistId) async {
    return await _repository.getArtistContent(artistId);
  }
}
