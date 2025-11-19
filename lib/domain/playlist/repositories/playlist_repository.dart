import 'package:harmonymusic/domain/playlist/entities/playlist_entity.dart';
import 'package:harmonymusic/domain/playlist/entities/export_type.dart';

abstract class PlaylistRepository {
  Future<void> savePlaylist(PlaylistEntity playlist);
  Future<void> removePlaylist(String playlistId);
  Future<PlaylistEntity> getOnlinePlaylistDetails(String playlistId);
  Future<void> updateLocalPlaylist(PlaylistEntity playlist);
  Future<String> exportPlaylist({required String playlistId, required ExportType format});
}
