import 'package:audio_service/audio_service.dart';
import '../../../domain/album/repositories/album_repository.dart';
import '../../../domain/album/entities/album_entity.dart';
import '../datasources/album_remote_data_source.dart';
import '../datasources/album_local_data_source.dart';

/// Implementation of AlbumRepository
/// Orchestrates between remote and local data sources
class AlbumRepositoryImpl implements AlbumRepository {
  final AlbumRemoteDataSource _remoteDataSource;
  final AlbumLocalDataSource _localDataSource;

  AlbumRepositoryImpl({
    required AlbumRemoteDataSource remoteDataSource,
    required AlbumLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<AlbumEntity> getAlbumDetails(String albumId) async {
    // First check if album is in library (offline)
    final isInLib = await _localDataSource.isInLibrary(albumId);

    if (isInLib) {
      // Get from local storage if available
      final localAlbum = await _localDataSource.getAlbumFromLibrary(albumId);
      if (localAlbum != null) {
        return localAlbum;
      }
    }

    // Otherwise fetch from remote
    return await _remoteDataSource.getAlbumDetails(albumId);
  }

  @override
  Future<List<MediaItem>> getAlbumTracks(String albumId) async {
    // First check if album is in library (offline)
    final isInLib = await _localDataSource.isInLibrary(albumId);

    if (isInLib) {
      // Get tracks from local storage if available
      try {
        // Note: This would require adding a method to AlbumLocalDataSource
        // For now, we'll fall through to remote
      } catch (e) {
        // Fall through to remote
      }
    }

    // Fetch from remote
    return await _remoteDataSource.getAlbumTracks(albumId);
  }

  @override
  Future<bool> addToLibrary(AlbumEntity album, List<MediaItem> tracks) async {
    return await _localDataSource.addToLibrary(album, tracks);
  }

  @override
  Future<bool> removeFromLibrary(String albumId) async {
    return await _localDataSource.removeFromLibrary(albumId);
  }

  @override
  Future<bool> isInLibrary(String albumId) async {
    return await _localDataSource.isInLibrary(albumId);
  }

  @override
  Future<AlbumEntity?> getAlbumFromLibrary(String albumId) async {
    return await _localDataSource.getAlbumFromLibrary(albumId);
  }
}
