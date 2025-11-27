import 'dart:core';
import 'dart:core' as core;
import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:harmonymusic/models/durationstate.dart';
import '../../../ui/widgets/sliding_up_panel.dart';
import '../../../models/playling_from.dart';
import '/services/music_service.dart';
import '/presentation/controllers/home/home_controller.dart';
import 'package:hive/hive.dart';

import '../../../domain/player/entities/player_state.dart';
import '../../../domain/player/usecases/play_usecase.dart';
import '../../../domain/player/usecases/pause_usecase.dart';
import '../../../domain/player/usecases/stop_usecase.dart';
import '../../../domain/player/usecases/seek_usecase.dart';
import '../../../domain/player/usecases/skip_to_next_usecase.dart';
import '../../../domain/player/usecases/skip_to_previous_usecase.dart';
import '../../../domain/player/usecases/play_song_usecase.dart';
import '../../../domain/player/usecases/play_playlist_usecase.dart';
import '../../../domain/player/usecases/add_to_queue_usecase.dart';
import '../../../domain/player/usecases/remove_from_queue_usecase.dart';
import '../../../domain/player/usecases/reorder_queue_usecase.dart';
import '../../../domain/player/usecases/clear_queue_usecase.dart';
import '../../../domain/player/usecases/set_shuffle_mode_usecase.dart';
import '../../../domain/player/usecases/set_repeat_mode_usecase.dart';
import '../../../domain/player/usecases/set_volume_usecase.dart';
import '../../../domain/player/usecases/get_player_state_stream_usecase.dart';
import '../../../domain/player/usecases/get_current_song_stream_usecase.dart';
import '../../../domain/player/usecases/get_queue_stream_usecase.dart';
import '../../../domain/player/usecases/skip_to_queue_item_usecase.dart';
import '../../../domain/player/usecases/toggle_favorite_usecase.dart';
import '../../../domain/player/usecases/is_favorite_usecase.dart';
import '../../../domain/player/usecases/open_equalizer_usecase.dart';

enum PlayButtonState { paused, playing, loading }

class PlayerController extends GetxController {
  // Use Cases
  final PlayUseCase _playUseCase;
  final PauseUseCase _pauseUseCase;
  final StopUseCase _stopUseCase;
  final SeekUseCase _seekUseCase;
  final SkipToNextUseCase _skipToNextUseCase;
  final SkipToPreviousUseCase _skipToPreviousUseCase;
  final PlaySongUseCase _playSongUseCase;
  final PlayPlaylistUseCase _playPlaylistUseCase;
  final AddToQueueUseCase _addToQueueUseCase;
  final RemoveFromQueueUseCase _removeFromQueueUseCase;
  final ReorderQueueUseCase _reorderQueueUseCase;
  final ClearQueueUseCase _clearQueueUseCase;
  final SetShuffleModeUseCase _setShuffleModeUseCase;
  final SetRepeatModeUseCase _setRepeatModeUseCase;
  final SetVolumeUseCase _setVolumeUseCase;
  final GetPlayerStateStreamUseCase _getPlayerStateStreamUseCase;
  final GetCurrentSongStreamUseCase _getCurrentSongStreamUseCase;
  final GetQueueStreamUseCase _getQueueStreamUseCase;
  final SkipToQueueItemUseCase _skipToQueueItemUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;
  final IsFavoriteUseCase _isFavoriteUseCase;
  final OpenEqualizerUseCase _openEqualizerUseCase;

  // State
  final playerState = const PlayerState().obs;
  final currentSong = Rxn<MediaItem>();
  final queue = <MediaItem>[].obs;
  final progressBarStatus = ProgressBarState(
    current: core.Duration.zero,
    buffered: core.Duration.zero,
    total: core.Duration.zero,
  ).obs;

  // UI State
  final isPlayerPanelVisible = false.obs;
  final playerPanelOpacity = 1.0.obs;
  final isPlayerpanelTopVisible = true.obs;
  final playerPaneOpacity = 1.0.obs;

  // Compatibility with legacy UI
  final GlobalKey<ScaffoldState> homeScaffoldkey = GlobalKey<ScaffoldState>();
  final PanelController playerPanelController = PanelController();
  final PanelController queuePanelController = PanelController();
  ScrollController scrollController = ScrollController();
  AnimationController? gesturePlayerStateAnimationController;

  // Compatibility State (Legacy)
  final isCurrentSongFav = false.obs;
  final isShuffleModeEnabled = false.obs;
  final currentSongDuration = core.Duration.zero.obs;
  final currentSongPosition = core.Duration.zero.obs;
  final isPanelGTHOpened = false.obs;
  final playinfrom = PlaylingFrom(type: PlaylingFromType.SELECTION).obs;
  Animation<double>? gesturePlayerStateAnimation;
  final gesturePlayerVisibleState = true.obs;
  final currentSongIndex = 0.obs;
  final buttonState = PlayButtonState.paused.obs;
  final playerPanelMinHeight = 70.0.obs;

  // Lyrics State
  final isDesktopLyricsDialogOpen = false.obs;
  final showLyricsflag = false.obs;

  // Sleep Timer
  final Rx<core.Duration> timerDurationLeft = core.Duration.zero.obs;
  final RxBool isSleepTimerActive = false.obs;

  List<MediaItem> get currentQueue => queue;

  PlayerController({
    required PlayUseCase playUseCase,
    required PauseUseCase pauseUseCase,
    required StopUseCase stopUseCase,
    required SeekUseCase seekUseCase,
    required SkipToNextUseCase skipToNextUseCase,
    required SkipToPreviousUseCase skipToPreviousUseCase,
    required PlaySongUseCase playSongUseCase,
    required PlayPlaylistUseCase playPlaylistUseCase,
    required AddToQueueUseCase addToQueueUseCase,
    required RemoveFromQueueUseCase removeFromQueueUseCase,
    required ReorderQueueUseCase reorderQueueUseCase,
    required ClearQueueUseCase clearQueueUseCase,
    required SetShuffleModeUseCase setShuffleModeUseCase,
    required SetRepeatModeUseCase setRepeatModeUseCase,
    required SetVolumeUseCase setVolumeUseCase,
    required GetPlayerStateStreamUseCase getPlayerStateStreamUseCase,
    required GetCurrentSongStreamUseCase getCurrentSongStreamUseCase,
    required GetQueueStreamUseCase getQueueStreamUseCase,
    required SkipToQueueItemUseCase skipToQueueItemUseCase,
    required ToggleFavoriteUseCase toggleFavoriteUseCase,
    required IsFavoriteUseCase isFavoriteUseCase,
    required OpenEqualizerUseCase openEqualizerUseCase,
  })  : _playUseCase = playUseCase,
        _pauseUseCase = pauseUseCase,
        _stopUseCase = stopUseCase,
        _seekUseCase = seekUseCase,
        _skipToNextUseCase = skipToNextUseCase,
        _skipToPreviousUseCase = skipToPreviousUseCase,
        _playSongUseCase = playSongUseCase,
        _playPlaylistUseCase = playPlaylistUseCase,
        _addToQueueUseCase = addToQueueUseCase,
        _removeFromQueueUseCase = removeFromQueueUseCase,
        _reorderQueueUseCase = reorderQueueUseCase,
        _clearQueueUseCase = clearQueueUseCase,
        _setShuffleModeUseCase = setShuffleModeUseCase,
        _setRepeatModeUseCase = setRepeatModeUseCase,
        _setVolumeUseCase = setVolumeUseCase,
        _getPlayerStateStreamUseCase = getPlayerStateStreamUseCase,
        _getCurrentSongStreamUseCase = getCurrentSongStreamUseCase,
        _getQueueStreamUseCase = getQueueStreamUseCase,
        _skipToQueueItemUseCase = skipToQueueItemUseCase,
        _toggleFavoriteUseCase = toggleFavoriteUseCase,
        _isFavoriteUseCase = isFavoriteUseCase,
        _openEqualizerUseCase = openEqualizerUseCase;

  // Settings & Home Compatibility
  @override
  void onInit() {
    super.onInit();
    _bindStreams();

    // Sync compatibility fields
    ever(playerState, (state) {
      isShuffleModeEnabled.value = state.shuffleMode != ShuffleMode.off;
      currentSongIndex.value = state.queueIndex ?? 0;

      if (state.processingState == PlayerStatus.loading ||
          state.processingState == PlayerStatus.buffering) {
        buttonState.value = PlayButtonState.loading;
      } else if (state.playing) {
        buttonState.value = PlayButtonState.playing;
      } else {
        buttonState.value = PlayButtonState.paused;
      }
    });
  }

  void _bindStreams() {
    playerState.bindStream(_getPlayerStateStreamUseCase());
    currentSong.bindStream(_getCurrentSongStreamUseCase());
    queue.bindStream(_getQueueStreamUseCase());

    // Update progress bar status
    final positionStream = AudioService.position;

    // Combine streams to update progress bar
    positionStream.listen((position) {
      final total = currentSong.value?.duration ?? core.Duration.zero;
      final buffered = playerState.value.bufferedPosition;
      progressBarStatus.value = ProgressBarState(
        current: position,
        total: total,
        buffered: buffered,
      );
    });

    // Also update when player state changes (for buffered) or song changes (for duration)
    ever(playerState, (state) {
      final position = progressBarStatus.value.current;
      final total = currentSong.value?.duration ?? core.Duration.zero;
      progressBarStatus.value = ProgressBarState(
        current: position,
        total: total,
        buffered: state.bufferedPosition,
      );
    });

    ever(currentSong, (song) {
      final position = progressBarStatus.value.current;
      final total = song?.duration ?? core.Duration.zero;
      progressBarStatus.value = ProgressBarState(
        current: position,
        total: total,
        buffered: progressBarStatus.value.buffered,
      );
      _checkFav();
    });
  }

  // Playback Controls
  void play() => _playUseCase();
  void pause() => _pauseUseCase();
  void stop() => _stopUseCase();
  void playPause() {
    if (playerState.value.playing) {
      pause();
    } else {
      play();
    }
  }

  void seek(core.Duration position) => _seekUseCase(position);
  void next() => _skipToNextUseCase();
  void previous() => _skipToPreviousUseCase();
  void prev() => previous(); // Alias

  // Queue Management
  void playSong(MediaItem song) => _playSongUseCase(song);

  void removeFromQueue(MediaItem song) => _removeFromQueueUseCase(song);
  void clearQueue() => _clearQueueUseCase();
  void playPlaylist(List<MediaItem> songs, {int index = 0}) =>
      _playPlaylistUseCase(songs, index: index);

  // Sleep Timer Compatibility
  bool get isSleepEndOfSongActive => false;
  void startSleepTimer(int minutes) {
    print("Start Sleep Timer not implemented yet");
  }

  void cancelSleepTimer() {
    print("Cancel Sleep Timer not implemented yet");
  }

  void addFiveMinutes() {
    print("Add Five Minutes not implemented yet");
  }

  void sleepEndOfSong() {
    print("Sleep End Of Song not implemented yet");
  }

  // Queue & Playback Compatibility
  bool get isQueueLoopModeEnabled =>
      playerState.value.repeatMode == RepeatMode.all;
  void toggleQueueLoopMode() => toggleRepeat();
  void shuffleQueue() => toggleShuffle();
  void toggleShuffleMode() => toggleShuffle();
  void toggleLoopMode() => toggleRepeat();
  bool get isLoopModeEnabled => playerState.value.repeatMode != RepeatMode.off;

  void showLyrics() {
    print("Show Lyrics not implemented yet");
  }

  double get volume => playerState.value.volume;
  bool get mute => volume == 0;
  void setVolume(double volume) => _setVolumeUseCase(volume);

  void toggleMute() {
    if (mute) {
      setVolume(1.0);
    } else {
      setVolume(0.0);
    }
  }

  void toggleShuffle() {
    final currentMode = playerState.value.shuffleMode;
    final newMode =
        currentMode == ShuffleMode.off ? ShuffleMode.all : ShuffleMode.off;
    _setShuffleModeUseCase(newMode);
  }

  void toggleRepeat() {
    final currentMode = playerState.value.repeatMode;
    RepeatMode newMode;
    switch (currentMode) {
      case RepeatMode.off:
        newMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        newMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        newMode = RepeatMode.off;
        break;
    }
    _setRepeatModeUseCase(newMode);
  }

  // Settings & Home Compatibility
  void initGesturePlayerStateAnimationController(TickerProvider vsync) {
    gesturePlayerStateAnimationController = AnimationController(
      vsync: vsync,
      duration: const core.Duration(milliseconds: 300),
    );
    gesturePlayerStateAnimation = CurvedAnimation(
        parent: gesturePlayerStateAnimationController!, curve: Curves.easeIn);
  }

  final RxBool initFlagForPlayer = false.obs;

  void panellistener(double x) {
    if (x >= 0 && x <= 0.2) {
      playerPanelOpacity.value = 1 - (x * 5);
      isPlayerpanelTopVisible.value = true;
    } else if (x > 0.2) {
      isPlayerpanelTopVisible.value = false;
    }

    if (x > 0.6) {
      isPanelGTHOpened.value = true;
    } else {
      isPanelGTHOpened.value = false;
    }
  }

  void toggleSkipSilence(bool value) {
    print("Toggle Skip Silence not implemented: $value");
  }

  void toggleLoudnessNormalization(bool value) {
    print("Toggle Loudness Normalization not implemented: $value");
  }

  // Audio Handler Compatibility

  void notifyPlayError(dynamic error) {
    print("Play Error: $error");
    // Show snackbar or handle error
  }

  // Missing Compatibility Methods
  void seekByIndex(int index) => _skipToQueueItemUseCase(index);
  Future<void> enqueueSong(MediaItem song) async => _addToQueueUseCase(song);

  void playNext(MediaItem song) {
    _addToQueueUseCase(song);
  }

  void startRadio(MediaItem? song, {String? playlistid}) async {
    try {
      final musicServices = Get.find<MusicServices>();
      final content = await musicServices.getWatchPlaylist(
          videoId: song?.id ?? "", radio: true, playlistId: playlistid);
      final tracks = List<MediaItem>.from(content['tracks']);
      playPlaylist(tracks, index: 0);

      // Update playing from
      playinfrom.value =
          PlaylingFrom(type: PlaylingFromType.SELECTION, name: "Radio");

      Get.snackbar("Radio Started",
          "Playing radio based on ${song?.title ?? 'selection'}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.contentTextStyle?.color);
    } catch (e) {
      print("Error starting radio: $e");
      Get.snackbar("Error", "Failed to start radio",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.contentTextStyle?.color);
    }
  }

  void onReorder(int oldIndex, int newIndex) =>
      _reorderQueueUseCase(oldIndex, newIndex);

  Future<void> _checkFav() async {
    if (currentSong.value != null) {
      isCurrentSongFav.value = await _isFavoriteUseCase(currentSong.value!.id);
    }
  }

  void toggleFavourite([MediaItem? song]) async {
    print("DEBUG: toggleFavourite called");
    final item = song ?? currentSong.value;
    if (item != null) {
      await _toggleFavoriteUseCase(item);
      await _checkFav();
      final isFav = isCurrentSongFav.value;
      Get.snackbar(
        isFav ? "Added to Favorites" : "Removed from Favorites",
        "${item.title} has been ${isFav ? 'added to' : 'removed from'} your favorites.",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
        backgroundColor: Get.theme.snackBarTheme.backgroundColor,
        colorText: Get.theme.snackBarTheme.contentTextStyle?.color,
      );
    }
  }

  Future<void> openEqualizer() async {
    await _openEqualizerUseCase();
  }

  // More Compatibility Methods
  void playPlayListSong(List<MediaItem> songs, int index, {dynamic playfrom}) {
    playPlaylist(songs, index: index);
  }

  Future<void> enqueueSongList(List<MediaItem> songs) async {
    for (var song in songs) {
      await _addToQueueUseCase(song);
    }
  }

  void pushSongToQueue(MediaItem song) {
    _addToQueueUseCase(song);
  }

  // Lyrics Compatibility
  final RxBool isLyricsLoading = false.obs;
  final RxInt lyricsMode = 0.obs; // 0: normal, 1: synced
  final RxMap<String, dynamic> lyrics =
      <String, dynamic>{"plainLyrics": "NA", "synced": "NA"}.obs;
  // We use dynamic to avoid importing flutter_lyric if not strictly necessary,
  // but if the UI expects a specific type we might need to cast.
  // Assuming the UI expects a LyricUI object.
  final lyricUi = Rxn<dynamic>();

  void changeLyricsMode(int? index) {
    if (index != null) {
      lyricsMode.value = index;
    } else {
      lyricsMode.value = (lyricsMode.value + 1) % 2;
    }
  }
}

extension DurationExtension on core.Duration {
  core.Duration operator %(core.Duration other) {
    return core.Duration(microseconds: inMicroseconds % other.inMicroseconds);
  }
}
