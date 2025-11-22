import '../repositories/artist_repository.dart';
import '../entities/artist_entity.dart';

/// UseCase to add an artist to the user's library
class AddArtistToLibraryUseCase {
  final ArtistRepository _repository;

  AddArtistToLibraryUseCase(this._repository);

  /// Executes the use case to add artist to library
  /// [artist] - The artist entity to add
  /// Returns true if successful
  Future<bool> call(ArtistEntity artist) async {
    return await _repository.addToLibrary(artist);
  }
}
