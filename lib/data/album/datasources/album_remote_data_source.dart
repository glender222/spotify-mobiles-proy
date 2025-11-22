import 'package:audio_service/audio_service.dart';
import '../../../domain/album/entities/album_entity.dart';
import '../../../services/music_service.dart';
import '../models/album_model.dart';

/// Remote data source for fetching album data from the API
/// Abstracts the MusicServices to follow Clean Architecture
abstract class AlbumRemoteDataSource {
  Future<AlbumEntity> getAlbumDetails(String albumId);
  Future<List<MediaItem>> getAlbumTracks(String albumId);
}

class AlbumRemoteDataSourceImpl implements AlbumRemoteDataSource {
  final MusicServices _musicServices;

  AlbumRemoteDataSourceImpl(this._musicServices);

  @override
  Future<AlbumEntity> getAlbumDetails(String albumId) async {
    try {
      // Fetch album data from MusicServices
      final albumData =
          await _musicServices.getPlaylistOrAlbumSongs(albumId: albumId);

      // Convert to model and then to entity
      final albumModel = AlbumModel.fromJson(albumData);
      return albumModel.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch album details: $e');
    }
  }

  @override
  Future<List<MediaItem>> getAlbumTracks(String albumId) async {
    try {
      // Fetch album data including tracks from MusicServices
      final albumData =
          await _musicServices.getPlaylistOrAlbumSongs(albumId: albumId);

      // Extract tracks from the response
      final tracks = albumData['tracks'] as List<dynamic>?;
      if (tracks == null) {
        return [];
      }

      return List<MediaItem>.from(tracks);
    } catch (e) {
      throw Exception('Failed to fetch album tracks: $e');
    }
  }
}
