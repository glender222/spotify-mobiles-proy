import '../repositories/artist_repository.dart';

/// UseCase to remove an artist from the user's library
class RemoveArtistFromLibraryUseCase {
  final ArtistRepository _repository;

  RemoveArtistFromLibraryUseCase(this._repository);

  /// Executes the use case to remove artist from library
  /// [artistId] - The ID of the artist to remove
  /// Returns true if successful
  Future<bool> call(String artistId) async {
    return await _repository.removeFromLibrary(artistId);
  }
}
