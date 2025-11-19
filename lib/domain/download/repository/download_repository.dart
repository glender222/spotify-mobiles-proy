import 'package:audio_service/audio_service.dart';

abstract class DownloadRepository {
  Future<void> downloadPlaylist(String playlistId, List<MediaItem> songList);
  Future<void> downloadSong(MediaItem song);
  Future<void> cancelPlaylistDownload(String playlistId);
  Stream<int> get songDownloadingProgress;
  Stream<int> get playlistDownloadingProgress;
  Stream<bool> get isJobRunning;
  Stream<String> get currentPlaylistId;
  Stream<List<MediaItem>> get songQueue;
}
