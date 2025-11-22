import 'package:audio_service/audio_service.dart';
import '../repositories/album_repository.dart';
import '../entities/album_entity.dart';

/// UseCase to add an album to the user's library
///
/// Following Clean Architecture principles:
/// - Single Responsibility: Only handles adding albums to library
/// - Dependency Inversion: Depends on AlbumRepository abstraction
class AddAlbumToLibraryUseCase {
  final AlbumRepository _repository;

  AddAlbumToLibraryUseCase(this._repository);

  /// Executes the use case to add an album to library
  ///
  /// [album] - The album entity to add
  /// [tracks] - The tracks associated with this album
  /// Returns true if successfully added, false otherwise
  Future<bool> call(AlbumEntity album, List<MediaItem> tracks) async {
    return await _repository.addToLibrary(album, tracks);
  }
}
