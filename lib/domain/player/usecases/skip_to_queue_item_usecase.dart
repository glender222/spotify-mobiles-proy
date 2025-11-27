import '../repository/player_repository.dart';

class SkipToQueueItemUseCase {
  final PlayerRepository _repository;

  SkipToQueueItemUseCase(this._repository);

  Future<void> call(int index) {
    return _repository.skipToQueueItem(index);
  }
}
