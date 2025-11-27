enum PlayerStatus { idle, loading, buffering, ready, completed, error }

enum RepeatMode { off, one, all }

enum ShuffleMode { off, all }

class PlayerState {
  final bool playing;
  final PlayerStatus status;
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  final double speed;
  final int? queueIndex;
  final ShuffleMode shuffleMode;
  final RepeatMode repeatMode;
  final double volume;

  const PlayerState({
    this.playing = false,
    this.status = PlayerStatus.idle,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.queueIndex,
    this.shuffleMode = ShuffleMode.off,
    this.repeatMode = RepeatMode.off,
    this.volume = 1.0,
  });

  PlayerStatus get processingState => status;

  PlayerState copyWith({
    bool? playing,
    PlayerStatus? status,
    Duration? position,
    Duration? bufferedPosition,
    Duration? duration,
    double? speed,
    int? queueIndex,
    ShuffleMode? shuffleMode,
    RepeatMode? repeatMode,
    double? volume,
  }) {
    return PlayerState(
      playing: playing ?? this.playing,
      status: status ?? this.status,
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      queueIndex: queueIndex ?? this.queueIndex,
      shuffleMode: shuffleMode ?? this.shuffleMode,
      repeatMode: repeatMode ?? this.repeatMode,
      volume: volume ?? this.volume,
    );
  }
}
