import '../entities/artist_entity.dart';

/// Abstract repository interface for artist operations
/// Following Clean Architecture principles - defines contracts for data operations
abstract class ArtistRepository {
  /// Fetches artist details by ID
  /// Returns [ArtistEntity] with artist information
  /// Throws exception if artist not found
  Future<ArtistEntity> getArtistDetails(String artistId);

  /// Fetches artist content (songs, albums, videos, etc.) by ID
  /// Returns [ArtistContentEntity] with all artist content
  Future<ArtistContentEntity> getArtistContent(String artistId);

  /// Fetches specific tab content (e.g., more albums, more singles)
  /// [params] - The params from artist data for the specific tab
  /// [tabName] - The name of the tab
  /// Returns map with results and additionalParams
  Future<Map<String, dynamic>> getArtistTabContent(
      Map<String, dynamic> params, String tabName);

  /// Adds artist to user's library
  /// [artist] - The artist entity to add
  /// Returns true if successful
  Future<bool> addToLibrary(ArtistEntity artist);

  /// Removes artist from user's library
  /// [artistId] - THID of the artist to remove
  /// Returns true if successful
  Future<bool> removeFromLibrary(String artistId);

  /// Checks if artist is in user's library
  /// [artistId] - The ID of the artist to check
  /// Returns true if in library
  Future<bool> isInLibrary(String artistId);
}
