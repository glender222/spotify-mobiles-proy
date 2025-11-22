import '../repositories/artist_repository.dart';

/// UseCase to check if an artist is in the user's library
class IsArtistInLibraryUseCase {
  final ArtistRepository _repository;

  IsArtistInLibraryUseCase(this._repository);

  /// Executes the use case to check library status
  /// [artistId] - The ID of the artist to check
  /// Returns true if in library
  Future<bool> call(String artistId) async {
    return await _repository.isInLibrary(artistId);
  }
}
