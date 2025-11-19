import 'package:hive/hive.dart';
import 'package:harmonymusic/data/playlist/models/playlist_model.dart';
import 'package:harmonymusic/data/playlist/models/track_model.dart';

abstract class PlaylistLocalDataSource {
  Future<void> savePlaylist(PlaylistModel playlist);
  Future<void> removePlaylist(String playlistId);
  Future<void> updatePlaylist(PlaylistModel playlist);
}

class PlaylistLocalDataSourceImpl implements PlaylistLocalDataSource {
  final HiveInterface hive;

  PlaylistLocalDataSourceImpl(this.hive);

  static const String libraryPlaylistsBoxName = 'LibraryPlaylists';

  @override
  Future<void> savePlaylist(PlaylistModel playlist) async {
    _registerAdapters();

    final libraryBox = await hive.openBox(libraryPlaylistsBoxName);
    await libraryBox.put(playlist.id, playlist.toJson());

    final songsBox = await hive.openBox<Map<String, dynamic>>(playlist.id);
    await songsBox.clear();
    for (int i = 0; i < playlist.tracks.length; i++) {
      await songsBox.put(i, playlist.tracks[i].toJson());
    }
  }

  @override
  Future<void> removePlaylist(String playlistId) async {
    final libraryBox = await hive.openBox(libraryPlaylistsBoxName);
    await libraryBox.delete(playlistId);

    if (await hive.boxExists(playlistId)) {
      final songsBox = await hive.openBox(playlistId);
      await songsBox.deleteFromDisk();
    }
  }

  @override
  Future<void> updatePlaylist(PlaylistModel playlist) async {
    // For now, updating is the same as saving. It overwrites the existing data.
    return savePlaylist(playlist);
  }

  void _registerAdapters() {
    if (!hive.isAdapterRegistered(PlaylistModelAdapter().typeId)) {
      hive.registerAdapter(PlaylistModelAdapter());
    }
    if (!hive.isAdapterRegistered(TrackModelAdapter().typeId)) {
      hive.registerAdapter(TrackModelAdapter());
    }
  }
}
