import 'package:hive/hive.dart';
import 'library_local_datasource.dart';

/// Implementation of LibraryLocalDataSource using Hive
class LibraryLocalDataSourceImpl implements LibraryLocalDataSource {
  final Box _songsDownloadBox;
  final Box _songsCacheBox;
  final Box _playlistsBox;
  final Box _albumsBox;
  final Box _artistsBox;

  LibraryLocalDataSourceImpl({
    required Box songsDownloadBox,
    required Box songsCacheBox,
    required Box playlistsBox,
    required Box albumsBox,
    required Box artistsBox,
  })  : _songsDownloadBox = songsDownloadBox,
        _songsCacheBox = songsCacheBox,
        _playlistsBox = playlistsBox,
        _albumsBox = albumsBox,
        _artistsBox = artistsBox;

  //========================
  // SONGS
  //========================

  @override
  Future<List<Map<String, dynamic>>> getLibrarySongs() async {
    try {
      final List<Map<String, dynamic>> allSongs = [];

      // Get downloaded songs
      for (var key in _songsDownloadBox.keys) {
        final value = _songsDownloadBox.get(key);
        if (value is Map) {
          allSongs.add(Map<String, dynamic>.from(value));
        }
      }

      // Get cached songs
      for (var key in _songsCacheBox.keys) {
        final value = _songsCacheBox.get(key);
        if (value is Map) {
          allSongs.add(Map<String, dynamic>.from(value));
        }
      }

      return allSongs;
    } catch (e) {
      throw Exception('Failed to get library songs: $e');
    }
  }

  @override
  Future<void> saveSong(
    String songId,
    Map<String, dynamic> songData, {
    bool isDownloaded = false,
  }) async {
    try {
      final box = isDownloaded ? _songsDownloadBox : _songsCacheBox;
      await box.put(songId, songData);
    } catch (e) {
      throw Exception('Failed to save song: $e');
    }
  }

  @override
  Future<void> deleteSong(String songId, {bool isDownloaded = false}) async {
    try {
      // Try both boxes to ensure deletion
      if (_songsDownloadBox.containsKey(songId)) {
        await _songsDownloadBox.delete(songId);
      }
      if (_songsCacheBox.containsKey(songId)) {
        await _songsCacheBox.delete(songId);
      }
    } catch (e) {
      throw Exception('Failed to delete song: $e');
    }
  }

  @override
  Future<bool> songExists(String songId) async {
    return _songsDownloadBox.containsKey(songId) ||
        _songsCacheBox.containsKey(songId);
  }

  //========================
  // PLAYLISTS
  //========================

  @override
  Future<List<Map<String, dynamic>>> getLibraryPlaylists() async {
    try {
      final List<Map<String, dynamic>> playlists = [];

      for (var key in _playlistsBox.keys) {
        final value = _playlistsBox.get(key);
        if (value is Map) {
          playlists.add(Map<String, dynamic>.from(value));
        }
      }

      return playlists;
    } catch (e) {
      throw Exception('Failed to get library playlists: $e');
    }
  }

  @override
  Future<void> savePlaylist(
    String playlistId,
    Map<String, dynamic> playlistData,
  ) async {
    try {
      await _playlistsBox.put(playlistId, playlistData);
    } catch (e) {
      throw Exception('Failed to save playlist: $e');
    }
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _playlistsBox.delete(playlistId);
    } catch (e) {
      throw Exception('Failed to delete playlist: $e');
    }
  }

  @override
  Future<bool> playlistExists(String playlistId) async {
    return _playlistsBox.containsKey(playlistId);
  }

  //========================
  // ALBUMS
  //========================

  @override
  Future<List<Map<String, dynamic>>> getLibraryAlbums() async {
    try {
      final List<Map<String, dynamic>> albums = [];

      for (var key in _albumsBox.keys) {
        final value = _albumsBox.get(key);
        if (value is Map) {
          albums.add(Map<String, dynamic>.from(value));
        }
      }

      return albums;
    } catch (e) {
      throw Exception('Failed to get library albums: $e');
    }
  }

  @override
  Future<void> saveAlbum(String albumId, Map<String, dynamic> albumData) async {
    try {
      await _albumsBox.put(albumId, albumData);
    } catch (e) {
      throw Exception('Failed to save album: $e');
    }
  }

  @override
  Future<void> deleteAlbum(String albumId) async {
    try {
      await _albumsBox.delete(albumId);
    } catch (e) {
      throw Exception('Failed to delete album: $e');
    }
  }

  //========================
  // ARTISTS
  //========================

  @override
  Future<List<Map<String, dynamic>>> getLibraryArtists() async {
    try {
      final List<Map<String, dynamic>> artists = [];

      for (var key in _artistsBox.keys) {
        final value = _artistsBox.get(key);
        if (value is Map) {
          artists.add(Map<String, dynamic>.from(value));
        }
      }

      return artists;
    } catch (e) {
      throw Exception('Failed to get library artists: $e');
    }
  }

  @override
  Future<void> saveArtist(
    String artistId,
    Map<String, dynamic> artistData,
  ) async {
    try {
      await _artistsBox.put(artistId, artistData);
    } catch (e) {
      throw Exception('Failed to save artist: $e');
    }
  }

  @override
  Future<void> deleteArtist(String artistId) async {
    try {
      await _artistsBox.delete(artistId);
    } catch (e) {
      throw Exception('Failed to delete artist: $e');
    }
  }

  //========================
  // GENERIC
  //========================

  @override
  Future<void> clearAllData() async {
    try {
      await _songsDownloadBox.clear();
      await _songsCacheBox.clear();
      await _playlistsBox.clear();
      await _albumsBox.clear();
      await _artistsBox.clear();
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }
}
