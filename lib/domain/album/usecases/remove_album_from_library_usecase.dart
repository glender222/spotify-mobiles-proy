import '../repositories/album_repository.dart';

/// UseCase to remove an album from the user's library
///
/// Following Clean Architecture principles:
/// - Single Responsibility: Only handles removing albums from library
/// - Dependency Inversion: Depends on AlbumRepository abstraction
class RemoveAlbumFromLibraryUseCase {
  final AlbumRepository _repository;

  RemoveAlbumFromLibraryUseCase(this._repository);

  /// Executes the use case to remove an album from library
  ///
  /// [albumId] - The ID of the album to remove
  /// Returns true if successfully removed, false otherwise
  Future<bool> call(String albumId) async {
    return await _repository.removeFromLibrary(albumId);
  }
}
