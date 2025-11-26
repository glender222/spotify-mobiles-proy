import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../../domain/library/entities/library_song_entity.dart';
import '../../../domain/library/entities/library_playlist_entity.dart';
import '../../../domain/library/entities/library_album_entity.dart';
import '../../../domain/library/entities/library_artist_entity.dart';
import '../../../domain/library/entities/library_item_entity.dart';
import '../../../domain/library/repository/library_repository.dart';
import '../datasources/library_local_datasource.dart';
import '/services/piped_service.dart';
import 'package:hive/hive.dart';

/// Implementation of LibraryRepository
class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryLocalDataSource _localDataSource;

  LibraryRepositoryImpl({
    required LibraryLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  //========================
  // SONGS
  //========================

  @override
  Future<List<LibrarySongEntity>> getLibrarySongs() async {
    try {
      final songsJson = await _localDataSource.getLibrarySongs();
      return songsJson.map((json) => LibrarySongEntity.fromJson(json)).toList();
    } catch (e) {
      throw LibraryException('Failed to get library songs', e as Exception?);
    }
  }

  @override
  Future<void> addSongToLibrary(LibrarySongEntity song) async {
    try {
      await _localDataSource.saveSong(
        song.id,
        song.toJson(),
        isDownloaded: song.isDownloaded,
      );
    } catch (e) {
      throw LibraryException('Failed to add song to library', e as Exception?);
    }
  }

  @override
  Future<void> removeSongFromLibrary(
    String songId, {
    bool deleteFile = false,
  }) async {
    try {
      // Delete from database
      await _localDataSource.deleteSong(songId);

      if (deleteFile) {
        // Delete physical file
        final songs = await getLibrarySongs();
        final song = songs.firstWhereOrNull((s) => s.id == songId);

        if (song != null && song.localPath != null) {
          final file = File(song.localPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }

        // Delete thumbnail
        final supportDir = (await getApplicationSupportDirectory()).path;
        final thumbFile = File('$supportDir/thumbnails/$songId.png');
        if (await thumbFile.exists()) {
          await thumbFile.delete();
        }
      }
    } catch (e) {
      throw LibraryException(
        'Failed to remove song from library',
        e as Exception?,
      );
    }
  }

  @override
  Future<void> removeMultipleSongs(
    List<String> songIds, {
    bool deleteFiles = false,
  }) async {
    try {
      for (final songId in songIds) {
        await removeSongFromLibrary(songId, deleteFile: deleteFiles);
      }
    } catch (e) {
      throw LibraryException(
        'Failed to remove multiple songs',
        e as Exception?,
      );
    }
  }

  @override
  Stream<List<LibrarySongEntity>> watchLibrarySongs() async* {
    // For now, return a single emission
    // TODO: Implement proper stream with Hive watch
    yield await getLibrarySongs();
  }

  //========================
  // PLAYLISTS
  //========================

  @override
  Future<List<LibraryPlaylistEntity>> getLibraryPlaylists() async {
    try {
      final playlistsJson = await _localDataSource.getLibraryPlaylists();
      return playlistsJson
          .map((json) => LibraryPlaylistEntity.fromJson(json))
          .toList();
    } catch (e) {
      throw LibraryException(
        'Failed to get library playlists',
        e as Exception?,
      );
    }
  }

  @override
  Future<void> createPlaylist(
    LibraryPlaylistEntity playlist, {
    bool syncToPiped = false,
  }) async {
    try {
      if (syncToPiped && playlist.isPipedPlaylist) {
        // Create on Piped service
        final pipedService = Get.find<PipedServices>();
        final result = await pipedService.createPlaylist(playlist.title);

        if (result.code == 1) {
          // Update playlist with Piped ID
          final updatedPlaylist = playlist.copyWith(
            id: result.response['playlistId'].toString(),
          );
          await _localDataSource.savePlaylist(
            updatedPlaylist.id,
            updatedPlaylist.toJson(),
          );
        } else {
          throw Exception('Failed to create Piped playlist');
        }
      } else {
        // Create locally
        await _localDataSource.savePlaylist(
          playlist.id,
          playlist.toJson(),
        );
      }
    } catch (e) {
      throw LibraryException('Failed to create playlist', e as Exception?);
    }
  }

  @override
  Future<void> renamePlaylist(
    String playlistId,
    String newTitle, {
    bool syncToPiped = false,
  }) async {
    try {
      final playlists = await getLibraryPlaylists();
      final playlist = playlists.firstWhereOrNull((p) => p.id == playlistId);

      if (playlist == null) {
        throw Exception('Playlist not found');
      }

      if (syncToPiped && playlist.isPipedPlaylist) {
        // Rename on Piped service
        final pipedService = Get.find<PipedServices>();
        final result = await pipedService.renamePlaylist(playlistId, newTitle);

        if (result.code == 0) {
          throw Exception('Failed to rename Piped playlist');
        }
      }

      // Update locally
      final updatedPlaylist = playlist.copyWith(title: newTitle);
      await _localDataSource.savePlaylist(
        playlistId,
        updatedPlaylist.toJson(),
      );
    } catch (e) {
      throw LibraryException('Failed to rename playlist', e as Exception?);
    }
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _localDataSource.deletePlaylist(playlistId);
    } catch (e) {
      throw LibraryException('Failed to delete playlist', e as Exception?);
    }
  }

  @override
  Future<void> syncPipedPlaylists() async {
    try {
      final pipedService = Get.find<PipedServices>();
      final result = await pipedService.getAllPlaylists();

      if (result.code != 1) {
        return; // No playlists or error
      }

      // Get blacklisted playlists
      final blacklistBox = await Hive.openBox('blacklistedPlaylist');
      final blacklisted = blacklistBox.values.whereType<String>().toSet();
      await blacklistBox.close();

      // Get current library playlists
      final currentPlaylists = await getLibraryPlaylists();
      final currentPipedIds = currentPlaylists
          .where((p) => p.isPipedPlaylist)
          .map((p) => p.id)
          .toSet();

      // Get cloud playlist IDs
      final cloudPlaylistIds = result.response
          .map((p) => p['id'] as String?)
          .whereType<String>()
          .toSet();

      // Add new playlists from cloud
      for (final playlistData in result.response) {
        final id = playlistData['id'] as String?;
        if (id != null &&
            !currentPipedIds.contains(id) &&
            !blacklisted.contains(id)) {
          final playlist = LibraryPlaylistEntity(
            id: id,
            title: playlistData['name'] as String? ?? 'Unnamed',
            addedAt: DateTime.now(),
            thumbnailUrl: playlistData['thumbnail'] as String? ?? '',
            description: 'Piped Playlist',
            isPipedPlaylist: true,
            isCloudPlaylist: true,
          );
          await _localDataSource.savePlaylist(id, playlist.toJson());
        }
      }

      // Remove playlists deleted from cloud
      for (final playlist in currentPlaylists) {
        if (playlist.isPipedPlaylist &&
            !cloudPlaylistIds.contains(playlist.id)) {
          await _localDataSource.deletePlaylist(playlist.id);
        }
      }
    } catch (e) {
      throw LibraryException('Failed to sync Piped playlists', e as Exception?);
    }
  }

  @override
  Future<void> blacklistPipedPlaylist(String playlistId) async {
    try {
      final box = await Hive.openBox('blacklistedPlaylist');
      await box.add(playlistId);
      await box.close();

      // Remove from library
      await _localDataSource.deletePlaylist(playlistId);
    } catch (e) {
      throw LibraryException(
        'Failed to blacklist Piped playlist',
        e as Exception?,
      );
    }
  }

  @override
  Future<void> resetBlacklistedPlaylists() async {
    try {
      final box = await Hive.openBox('blacklistedPlaylist');
      await box.clear();
      await box.close();

      // Re-sync playlists
      await syncPipedPlaylists();
    } catch (e) {
      throw LibraryException(
        'Failed to reset blacklisted playlists',
        e as Exception?,
      );
    }
  }

  @override
  Future<void> importPlaylistFromJson(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found');
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString);

      // Validate structure
      if (!jsonData.containsKey('playlistInfo') ||
          !jsonData.containsKey('songs')) {
        throw Exception('Invalid playlist file format');
      }

      // Create new playlist
      final playlistInfo = jsonData['playlistInfo'];
      final newPlaylistId = 'LIB${DateTime.now().millisecondsSinceEpoch}';

      final playlist = LibraryPlaylistEntity(
        id: newPlaylistId,
        title: '${playlistInfo['title']} (Imported)',
        addedAt: DateTime.now(),
        thumbnailUrl: playlistInfo['thumbnailUrl'] ?? '',
        description: playlistInfo['description'] ?? 'Imported Playlist',
        isCloudPlaylist: false,
      );

      await _localDataSource.savePlaylist(newPlaylistId, playlist.toJson());

      // Save songs to playlist box
      final songsBox = await Hive.openBox(newPlaylistId);
      final songsList = jsonData['songs'] as List;
      for (int i = 0; i < songsList.length; i++) {
        await songsBox.put(i, songsList[i]);
      }
      await songsBox.close();
    } catch (e) {
      throw LibraryException(
        'Failed to import playlist from JSON',
        e as Exception?,
      );
    }
  }

  //========================
  // ALBUMS
  //========================

  @override
  Future<List<LibraryAlbumEntity>> getLibraryAlbums() async {
    try {
      final albumsJson = await _localDataSource.getLibraryAlbums();
      return albumsJson
          .map((json) => LibraryAlbumEntity.fromJson(json))
          .toList();
    } catch (e) {
      throw LibraryException('Failed to get library albums', e as Exception?);
    }
  }

  @override
  Future<void> addAlbumToLibrary(LibraryAlbumEntity album) async {
    try {
      await _localDataSource.saveAlbum(album.id, album.toJson());
    } catch (e) {
      throw LibraryException('Failed to add album to library', e as Exception?);
    }
  }

  @override
  Future<void> removeAlbumFromLibrary(String albumId) async {
    try {
      await _localDataSource.deleteAlbum(albumId);
    } catch (e) {
      throw LibraryException(
        'Failed to remove album from library',
        e as Exception?,
      );
    }
  }

  //========================
  // ARTISTS
  //========================

  @override
  Future<List<LibraryArtistEntity>> getLibraryArtists() async {
    try {
      final artistsJson = await _localDataSource.getLibraryArtists();
      return artistsJson
          .map((json) => LibraryArtistEntity.fromJson(json))
          .toList();
    } catch (e) {
      throw LibraryException('Failed to get library artists', e as Exception?);
    }
  }

  @override
  Future<void> addArtistToLibrary(LibraryArtistEntity artist) async {
    try {
      await _localDataSource.saveArtist(artist.id, artist.toJson());
    } catch (e) {
      throw LibraryException(
        'Failed to add artist to library',
        e as Exception?,
      );
    }
  }

  @override
  Future<void> removeArtistFromLibrary(String artistId) async {
    try {
      await _localDataSource.deleteArtist(artistId);
    } catch (e) {
      throw LibraryException(
        'Failed to remove artist from library',
        e as Exception?,
      );
    }
  }

  //========================
  // GENERIC
  //========================

  @override
  Future<bool> isInLibrary(String itemId, LibraryItemType type) async {
    try {
      switch (type) {
        case LibraryItemType.song:
          return await _localDataSource.songExists(itemId);
        case LibraryItemType.playlist:
          return await _localDataSource.playlistExists(itemId);
        case LibraryItemType.album:
          final albums = await getLibraryAlbums();
          return albums.any((a) => a.id == itemId);
        case LibraryItemType.artist:
          final artists = await getLibraryArtists();
          return artists.any((a) => a.id == itemId);
      }
    } catch (e) {
      throw LibraryException(
          'Failed to check if item is in library', e as Exception?);
    }
  }

  @override
  Future<void> syncLibrary() async {
    try {
      // Sync Piped playlists
      await syncPipedPlaylists();

      // Clean up deleted cached songs
      await _cleanupCachedSongs();
    } catch (e) {
      throw LibraryException('Failed to sync library', e as Exception?);
    }
  }

  @override
  Future<void> refreshLibrary(LibraryItemType type) async {
    try {
      switch (type) {
        case LibraryItemType.song:
          await _cleanupCachedSongs();
          break;
        case LibraryItemType.playlist:
          await syncPipedPlaylists();
          break;
        case LibraryItemType.album:
        case LibraryItemType.artist:
          // No remote sync for albums/artists
          break;
      }
    } catch (e) {
      throw LibraryException('Failed to refresh library', e as Exception?);
    }
  }

  //========================
  // PRIVATE HELPERS
  //========================

  /// Clean up cached songs that no longer exist on disk
  Future<void> _cleanupCachedSongs() async {
    try {
      final cacheDir = (await getTemporaryDirectory()).path;
      final cachedSongsDir = Directory('$cacheDir/cachedSongs/');

      if (!cachedSongsDir.existsSync()) {
        return;
      }

      // Get list of existing files
      final existingFiles = cachedSongsDir
          .listSync()
          .where((f) => f is File && f.path.endsWith('.mp3'))
          .map((f) {
            final match =
                RegExp(r'cachedSongs/([^#]*)?\.mp3').firstMatch(f.path);
            return match?[1];
          })
          .whereType<String>()
          .toSet();

      // Get all cached songs from database
      final allSongs = await getLibrarySongs();
      final cachedSongs = allSongs.where((s) => s.isCached);

      // Remove songs that don't exist on disk
      for (final song in cachedSongs) {
        if (!existingFiles.contains(song.id)) {
          await _localDataSource.deleteSong(song.id);
        }
      }
    } catch (e) {
      // Don't throw, just log the error
      print('Error cleaning up cached songs: $e');
    }
  }
}
