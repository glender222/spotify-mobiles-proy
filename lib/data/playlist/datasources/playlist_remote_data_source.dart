import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:harmonymusic/data/playlist/models/playlist_model.dart';
import 'package:harmonymusic/data/playlist/models/track_model.dart';
import 'package:harmonymusic/models/playlist.dart' as legacy;
import 'package:harmonymusic/services/music_service.dart';

abstract class PlaylistRemoteDataSource {
  Future<PlaylistModel> getOnlinePlaylistDetails(String playlistId);
}

class PlaylistRemoteDataSourceImpl implements PlaylistRemoteDataSource {
  final MusicServices musicServices;

  PlaylistRemoteDataSourceImpl({required this.musicServices});

  @override
  Future<PlaylistModel> getOnlinePlaylistDetails(String playlistId) async {
    try {
      final content = await musicServices.getPlaylistOrAlbumSongs(playlistId: playlistId);

      content['playlistId'] = playlistId;
      final legacyPlaylist = legacy.Playlist.fromJson(content);

      final tracks = (content['tracks'] as List<dynamic>)
          .map((trackJson) => TrackModel.fromMediaItem(trackJson as MediaItem))
          .toList();

      final playlistModel = PlaylistModel.fromLegacyPlaylist(legacyPlaylist, tracks: tracks);

      return playlistModel;
    } catch (e) {
      throw Exception('Failed to fetch online playlist details.');
    }
  }
}
