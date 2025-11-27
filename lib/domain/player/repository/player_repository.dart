import 'package:audio_service/audio_service.dart';
import '../entities/player_state.dart';

abstract class PlayerRepository {
  Stream<PlayerState> get playerStateStream;
  Stream<MediaItem?> get currentSongStream;
  Stream<List<MediaItem>> get queueStream;

  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> skipToNext();
  Future<void> skipToPrevious();
  Future<void> skipToQueueItem(int index);

  Future<void> playSong(MediaItem song);
  Future<void> playPlaylist(List<MediaItem> songs, int index);
  Future<void> addToQueue(MediaItem song);
  Future<void> removeFromQueue(MediaItem song);
  Future<void> reorderQueue(int oldIndex, int newIndex);
  Future<void> clearQueue();

  Future<void> setShuffleMode(ShuffleMode mode);
  Future<void> setRepeatMode(RepeatMode mode);
  Future<void> setVolume(double volume);

  // Favorites
  Future<void> toggleFavorite(MediaItem song);
  Future<bool> isFavorite(String songId);

  // Equalizer
  Future<void> openEqualizer();
}
