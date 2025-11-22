import '../repositories/artist_repository.dart';
import '../entities/artist_entity.dart';

/// UseCase to fetch artist details
class GetArtistDetailsUseCase {
  final ArtistRepository _repository;

  GetArtistDetailsUseCase(this._repository);

  /// Executes the use case to get artist details
  /// [artistId] - The ID of the artist
  /// Returns [ArtistEntity] with artist information
  Future<ArtistEntity> call(String artistId) async {
    return await _repository.getArtistDetails(artistId);
  }
}
