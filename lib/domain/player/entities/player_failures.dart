abstract class PlayerFailure {
  final String message;
  const PlayerFailure(this.message);
}

class NetworkFailure extends PlayerFailure {
  const NetworkFailure(super.message);
}

class PlaybackFailure extends PlayerFailure {
  const PlaybackFailure(super.message);
}

class CacheFailure extends PlayerFailure {
  const CacheFailure(super.message);
}
