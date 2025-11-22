import 'package:audio_service/audio_service.dart';
import '../entities/album_entity.dart';

/// Abstract repository interface for album operations
/// Following Clean Architecture principles - this interface belongs to the domain layer
/// and will be implemented in the data layer
abstract class AlbumRepository {
  /// Fetches album details by album ID
  ///
  /// Returns an [AlbumEntity] with album information
  /// Throws an exception if the album is not found or network error occurs
  Future<AlbumEntity> getAlbumDetails(String albumId);

  /// Fetches all tracks for a specific album
  ///
  /// Returns a list of [MediaItem] representing the album's tracks
  /// Throws an exception if the album is not found or network error occurs
  Future<List<MediaItem>> getAlbumTracks(String albumId);

  /// Adds an album to the user's library
  ///
  /// [album] - The album entity to add
  /// [tracks] - The tracks associated with this album
  /// Returns true if successfully added, false otherwise
  Future<bool> addToLibrary(AlbumEntity album, List<MediaItem> tracks);

  /// Removes an album from the user's library
  ///
  /// [albumId] - The ID of the album to remove
  /// Returns true if successfully removed, false otherwise
  Future<bool> removeFromLibrary(String albumId);

  /// Checks if an album is in the user's library
  ///
  /// [albumId] - The ID of the album to check
  /// Returns true if the album is in library, false otherwise
  Future<bool> isInLibrary(String albumId);

  /// Gets the album entity from library storage
  ///
  /// [albumId] - The ID of the album to retrieve
  /// Returns [AlbumEntity] if found in library, null otherwise
  Future<AlbumEntity?> getAlbumFromLibrary(String albumId);
}
