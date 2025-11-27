import '../repository/player_repository.dart';

class ReorderQueueUseCase {
  final PlayerRepository _repository;

  ReorderQueueUseCase(this._repository);

  Future<void> call(int oldIndex, int newIndex) {
    return _repository.reorderQueue(oldIndex, newIndex);
  }
}
