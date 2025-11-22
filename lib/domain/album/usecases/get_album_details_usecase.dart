import '../repositories/album_repository.dart';
import '../entities/album_entity.dart';

/// UseCase to fetch album details from the repository
///
/// Following Clean Architecture principles:
/// - Single Responsibility: Only fetches album details
/// - Dependency Inversion: Depends on AlbumRepository abstraction
class GetAlbumDetailsUseCase {
  final AlbumRepository _repository;

  GetAlbumDetailsUseCase(this._repository);

  /// Executes the use case to get album details
  ///
  /// [albumId] - The ID of the album to fetch
  /// Returns [AlbumEntity] with album information
  /// Throws an exception if the album is not found or network error occurs
  Future<AlbumEntity> call(String albumId) async {
    return await _repository.getAlbumDetails(albumId);
  }
}
