import '../repository/player_repository.dart';

class StopUseCase {
  final PlayerRepository _repository;

  StopUseCase(this._repository);

  Future<void> call() {
    return _repository.stop();
  }
}
