import '../repository/player_repository.dart';

class PauseUseCase {
  final PlayerRepository _repository;

  PauseUseCase(this._repository);

  Future<void> call() {
    return _repository.pause();
  }
}
