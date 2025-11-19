import 'package:harmonymusic/data/playlist/datasources/playlist_local_data_source.dart';
import 'package:harmonymusic/data/playlist/datasources/playlist_remote_data_source.dart';
import 'package:harmonymusic/data/playlist/datasources/playlist_export_data_source.dart';
import 'package:harmonymusic/data/playlist/models/playlist_model.dart';
import 'package:harmonymusic/domain/playlist/entities/playlist_entity.dart';
import 'package:harmonymusic/domain/playlist/entities/export_type.dart';
import 'package:harmonymusic/domain/playlist/repositories/playlist_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistLocalDataSource localDataSource;
  final PlaylistRemoteDataSource remoteDataSource;
  final PlaylistExportDataSource exportDataSource;

  PlaylistRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.exportDataSource,
  });

  @override
  Future<void> savePlaylist(PlaylistEntity playlist) async {
    try {
      final playlistModel = PlaylistModel.fromEntity(playlist);
      await localDataSource.savePlaylist(playlistModel);
    } catch (e) {
      throw Exception('Failed to save playlist.');
    }
  }

  @override
  Future<void> removePlaylist(String playlistId) async {
    try {
      await localDataSource.removePlaylist(playlistId);
    } catch (e) {
      throw Exception('Failed to remove playlist.');
    }
  }

  @override
  Future<PlaylistEntity> getOnlinePlaylistDetails(String playlistId) async {
    try {
      final playlistModel = await remoteDataSource.getOnlinePlaylistDetails(playlistId);
      return playlistModel;
    } catch (e) {
      throw Exception('Failed to get online playlist details.');
    }
  }

  @override
  Future<void> updateLocalPlaylist(PlaylistEntity playlist) async {
    try {
      final playlistModel = PlaylistModel.fromEntity(playlist);
      await localDataSource.updatePlaylist(playlistModel);
    } catch (e) {
      throw Exception('Failed to update local playlist.');
    }
  }

  @override
  Future<String> exportPlaylist({required String playlistId, required ExportType format}) async {
    try {
      return await exportDataSource.exportPlaylist(playlistId: playlistId, format: format);
    } catch (e) {
      throw Exception('Failed to export playlist.');
    }
  }
}
