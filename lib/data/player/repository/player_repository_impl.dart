import 'package:audio_service/audio_service.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';
import '/models/media_Item_builder.dart';

import '../../../domain/player/entities/player_state.dart';
import '../../../domain/player/repository/player_repository.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final AudioHandler _audioHandler;

  PlayerRepositoryImpl(this._audioHandler);

  @override
  Stream<PlayerState> get playerStateStream =>
      Rx.combineLatest2<PlaybackState, dynamic, PlayerState>(
        _audioHandler.playbackState,
        _audioHandler.customState,
        (playbackState, customState) {
          final volume =
              (customState is Map && customState.containsKey('volume'))
                  ? (customState['volume'] as num).toDouble()
                  : 1.0;
          return _mapPlaybackStateToPlayerState(playbackState, volume);
        },
      ).distinct((prev, next) =>
          prev.playing == next.playing &&
          prev.status == next.status &&
          prev.queueIndex == next.queueIndex);

  @override
  Stream<MediaItem?> get currentSongStream => _audioHandler.mediaItem;

  @override
  Stream<List<MediaItem>> get queueStream => _audioHandler.queue;

  PlayerState _mapPlaybackStateToPlayerState(PlaybackState state,
      [double volume = 1.0]) {
    return PlayerState(
      playing: state.playing,
      status: _mapProcessingState(state.processingState),
      position: state.position,
      bufferedPosition: state.bufferedPosition,
      speed: state.speed,
      queueIndex: state.queueIndex,
      shuffleMode: _mapShuffleMode(state.shuffleMode),
      repeatMode: _mapRepeatModeFromAudioService(state.repeatMode),
      volume: volume,
    );
  }

  ShuffleMode _mapShuffleMode(AudioServiceShuffleMode mode) {
    switch (mode) {
      case AudioServiceShuffleMode.none:
        return ShuffleMode.off;
      case AudioServiceShuffleMode.all:
      case AudioServiceShuffleMode.group:
        return ShuffleMode.all;
    }
  }

  RepeatMode _mapRepeatModeFromAudioService(AudioServiceRepeatMode mode) {
    switch (mode) {
      case AudioServiceRepeatMode.none:
        return RepeatMode.off;
      case AudioServiceRepeatMode.one:
        return RepeatMode.one;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        return RepeatMode.all;
    }
  }

  PlayerStatus _mapProcessingState(AudioProcessingState state) {
    switch (state) {
      case AudioProcessingState.idle:
        return PlayerStatus.idle;
      case AudioProcessingState.loading:
        return PlayerStatus.loading;
      case AudioProcessingState.buffering:
        return PlayerStatus.buffering;
      case AudioProcessingState.ready:
        return PlayerStatus.ready;
      case AudioProcessingState.completed:
        return PlayerStatus.completed;
      case AudioProcessingState.error:
        return PlayerStatus.error;
    }
  }

  @override
  Future<void> play() => _audioHandler.play();

  @override
  Future<void> pause() => _audioHandler.pause();

  @override
  Future<void> stop() => _audioHandler.stop();

  @override
  Future<void> seek(Duration position) => _audioHandler.seek(position);

  @override
  Future<void> skipToNext() => _audioHandler.skipToNext();

  @override
  Future<void> skipToPrevious() => _audioHandler.skipToPrevious();

  @override
  Future<void> skipToQueueItem(int index) =>
      _audioHandler.skipToQueueItem(index);

  @override
  Future<void> playSong(MediaItem song) async {
    // Logic from legacy: enqueue if empty, or add and play
    // For now, we use custom actions or standard methods if available
    // The legacy controller used 'setSourceNPlay' custom action
    await _audioHandler.customAction("setSourceNPlay", {'mediaItem': song});
  }

  @override
  Future<void> playPlaylist(List<MediaItem> songs, int index) async {
    // Legacy used updateQueue then playByIndex
    await _audioHandler.updateQueue(songs);
    await _audioHandler.customAction("playByIndex", {"index": index});
  }

  @override
  Future<void> addToQueue(MediaItem song) => _audioHandler.addQueueItem(song);

  @override
  Future<void> removeFromQueue(MediaItem song) =>
      _audioHandler.removeQueueItem(song);

  @override
  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    await _audioHandler.customAction(
        "reorderQueue", {"oldIndex": oldIndex, "newIndex": newIndex});
  }

  @override
  Future<void> clearQueue() async {
    await _audioHandler.customAction("clearQueue");
  }

  @override
  Future<void> setShuffleMode(ShuffleMode mode) {
    final audioServiceMode = mode == ShuffleMode.all
        ? AudioServiceShuffleMode.all
        : AudioServiceShuffleMode.none;
    return _audioHandler.setShuffleMode(audioServiceMode);
  }

  @override
  Future<void> setRepeatMode(RepeatMode mode) {
    final audioServiceMode = _mapRepeatMode(mode);
    return _audioHandler.setRepeatMode(audioServiceMode);
  }

  AudioServiceRepeatMode _mapRepeatMode(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.off:
        return AudioServiceRepeatMode.none;
      case RepeatMode.one:
        return AudioServiceRepeatMode.one;
      case RepeatMode.all:
        return AudioServiceRepeatMode.all;
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    // Legacy used custom action setVolume with int 0-100
    // But audio_service has setVolume(double)
    // We'll stick to custom action if that's what the handler expects,
    // or use the standard one if implemented.
    // Looking at AudioHandler code: case 'setVolume': _player.setVolume(extras!['value'] / 100);
    // So it expects 0-100.
    await _audioHandler
        .customAction("setVolume", {"value": (volume * 100).toInt()});
  }

  @override
  Future<void> toggleFavorite(MediaItem song) async {
    final box = await Hive.openBox("LIBFAV");
    if (box.containsKey(song.id)) {
      await box.delete(song.id);
    } else {
      await box.put(song.id, MediaItemBuilder.toJson(song));
    }
  }

  @override
  Future<bool> isFavorite(String songId) async {
    final box = await Hive.openBox("LIBFAV");
    return box.containsKey(songId);
  }

  @override
  Future<void> openEqualizer() async {
    await _audioHandler.customAction("openEqualizer");
  }
}
