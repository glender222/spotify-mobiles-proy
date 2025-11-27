import '../repository/player_repository.dart';

class SkipToPreviousUseCase {
  final PlayerRepository _repository;

  SkipToPreviousUseCase(this._repository);

  Future<void> call() {
    return _repository.skipToPrevious();
  }
}
