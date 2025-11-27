import '../repository/player_repository.dart';

class ClearQueueUseCase {
  final PlayerRepository _repository;

  ClearQueueUseCase(this._repository);

  Future<void> call() {
    return _repository.clearQueue();
  }
}
