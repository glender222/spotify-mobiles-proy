import '../repositories/album_repository.dart';

/// UseCase to check if an album is in the user's library
///
/// Following Clean Architecture principles:
/// - Single Responsibility: Only checks album library status
/// - Dependency Inversion: Depends on AlbumRepository abstraction
class IsAlbumInLibraryUseCase {
  final AlbumRepository _repository;

  IsAlbumInLibraryUseCase(this._repository);

  /// Executes the use case to check if an album is in library
  ///
  /// [albumId] - The ID of the album to check
  /// Returns true if the album is in library, false otherwise
  Future<bool> call(String albumId) async {
    return await _repository.isInLibrary(albumId);
  }
}
