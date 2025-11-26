import '../entities/library_song_entity.dart';
import '../entities/library_playlist_entity.dart';
import '../entities/library_album_entity.dart';
import '../entities/library_artist_entity.dart';
import '../entities/library_item_entity.dart';

/// Repository interface for Library operations
/// All library data access goes through this abstraction
abstract class LibraryRepository {
  //========================
  // SONGS
  //========================

  /// Get all songs in library (both cached and downloaded)
  Future<List<LibrarySongEntity>> getLibrarySongs();

  /// Add a song to library
  Future<void> addSongToLibrary(LibrarySongEntity song);

  /// Remove song from library and optionally delete file
  Future<void> removeSongFromLibrary(
    String songId, {
    bool deleteFile = false,
  });

  /// Remove multiple songs from library
  Future<void> removeMultipleSongs(
    List<String> songIds, {
    bool deleteFiles = false,
  });

  /// Watch library songs for real-time updates
  Stream<List<LibrarySongEntity>> watchLibrarySongs();

  //========================
  // PLAYLISTS
  //========================

  /// Get all playlists in library
  Future<List<LibraryPlaylistEntity>> getLibraryPlaylists();

  /// Create a new playlist
  Future<void> createPlaylist(
    LibraryPlaylistEntity playlist, {
    bool syncToPiped = false,
  });

  /// Rename an existing playlist
  Future<void> renamePlaylist(
    String playlistId,
    String newTitle, {
    bool syncToPiped = false,
  });

  /// Delete a playlist
  Future<void> deletePlaylist(String playlistId);

  /// Sync playlists with Piped service
  Future<void> syncPipedPlaylists();

  /// Blacklist a Piped playlist (won't sync)
  Future<void> blacklistPipedPlaylist(String playlistId);

  /// Reset blacklisted playlists
  Future<void> resetBlacklistedPlaylists();

  /// Import playlist from JSON file
  Future<void> importPlaylistFromJson(String filePath);

  //========================
  // ALBUMS
  //========================

  /// Get all albums in library
  Future<List<LibraryAlbumEntity>> getLibraryAlbums();

  /// Add album to library
  Future<void> addAlbumToLibrary(LibraryAlbumEntity album);

  /// Remove album from library
  Future<void> removeAlbumFromLibrary(String albumId);

  //========================
  // ARTISTS
  //========================

  /// Get all artists in library
  Future<List<LibraryArtistEntity>> getLibraryArtists();

  /// Add artist to library
  Future<void> addArtistToLibrary(LibraryArtistEntity artist);

  /// Remove artist from library
  Future<void> removeArtistFromLibrary(String artistId);

  //========================
  // GENERIC
  //========================

  /// Check if item is in library
  Future<bool> isInLibrary(String itemId, LibraryItemType type);

  /// Sync entire library (all types)
  Future<void> syncLibrary();

  /// Refresh library data for specific type
  Future<void> refreshLibrary(LibraryItemType type);
}

/// Custom exception for library operations
class LibraryException implements Exception {
  final String message;
  final Exception? cause;

  LibraryException(this.message, [this.cause]);

  @override
  String toString() =>
      'LibraryException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}
