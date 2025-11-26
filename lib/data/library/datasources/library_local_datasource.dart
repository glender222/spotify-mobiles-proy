/// Local data source interface for Library operations
/// Abstracts Hive database operations
abstract class LibraryLocalDataSource {
  //========================
  // SONGS
  //========================

  /// Get all songs from cache and downloads
  Future<List<Map<String, dynamic>>> getLibrarySongs();

  /// Save song to library
  Future<void> saveSong(String songId, Map<String, dynamic> songData,
      {bool isDownloaded = false});

  /// Delete song from library
  Future<void> deleteSong(String songId, {bool isDownloaded = false});

  /// Check if song exists in library
  Future<bool> songExists(String songId);

  //========================
  // PLAYLISTS
  //========================

  /// Get all playlists from library
  Future<List<Map<String, dynamic>>> getLibraryPlaylists();

  /// Save playlist to library
  Future<void> savePlaylist(
      String playlistId, Map<String, dynamic> playlistData);

  /// Delete playlist from library
  Future<void> deletePlaylist(String playlistId);

  /// Check if playlist exists
  Future<bool> playlistExists(String playlistId);

  //========================
  // ALBUMS
  //========================

  /// Get all albums from library
  Future<List<Map<String, dynamic>>> getLibraryAlbums();

  /// Save album to library
  Future<void> saveAlbum(String albumId, Map<String, dynamic> albumData);

  /// Delete album from library
  Future<void> deleteAlbum(String albumId);

  //========================
  // ARTISTS
  //========================

  /// Get all artists from library
  Future<List<Map<String, dynamic>>> getLibraryArtists();

  /// Save artist to library
  Future<void> saveArtist(String artistId, Map<String, dynamic> artistData);

  /// Delete artist from library
  Future<void> deleteArtist(String artistId);

  //========================
  // GENERIC
  //========================

  /// Clear all data (for testing)
  Future<void> clearAllData();
}
