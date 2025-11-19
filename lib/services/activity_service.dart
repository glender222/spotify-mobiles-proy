import 'package:audio_service/audio_service.dart';
import 'package:hive/hive.dart';

import '../models/serializable_video.dart';

class ActivityService {
  static const _historyBoxName = 'userHistory';
  static const _playlistsBoxName = 'userPlaylists';
  static const _artistsBoxName = 'userArtists';

  Future<void> init() async {
    await Hive.openBox(_historyBoxName);
    await Hive.openBox(_playlistsBoxName);
    await Hive.openBox(_artistsBoxName);
  }

  Future<void> addSongToHistory(MediaItem mediaItem) async {
    final box = Hive.box(_historyBoxName);
    final serializableVideo = SerializableVideo(
      id: mediaItem.id,
      title: mediaItem.title,
      artist: mediaItem.artist ?? '',
      thumbnailUrl: mediaItem.artUri.toString(),
    );
    await box.put(mediaItem.id, serializableVideo.toJson());
  }

  List<SerializableVideo> getSongHistory() {
    final box = Hive.box(_historyBoxName);
    return box.values
        .map((json) => SerializableVideo.fromJson(json.cast<String, dynamic>()))
        .toList();
  }

  Future<void> addPlaylist(String playlistName, List<MediaItem> songs) async {
    final box = Hive.box(_playlistsBoxName);
    final songsJson = songs
        .map((song) => SerializableVideo(
              id: song.id,
              title: song.title,
              artist: song.artist ?? '',
              thumbnailUrl: song.artUri.toString(),
            ).toJson())
        .toList();
    await box.put(playlistName, songsJson);
  }

  Map<String, List<SerializableVideo>> getPlaylists() {
    final box = Hive.box(_playlistsBoxName);
    final playlists = <String, List<SerializableVideo>>{};
    for (var key in box.keys) {
      final songsJson = box.get(key) as List;
      final songs = songsJson
          .map((json) =>
              SerializableVideo.fromJson(json.cast<String, dynamic>()))
          .toList();
      playlists[key] = songs;
    }
    return playlists;
  }

  Future<void> addArtist(String artistName) async {
    final box = Hive.box(_artistsBoxName);
    final currentCount = box.get(artistName, defaultValue: 0);
    await box.put(artistName, currentCount + 1);
  }

  Map<String, int> getArtistCounts() {
    final box = Hive.box(_artistsBoxName);
    return box.toMap().cast<String, int>();
  }
}
