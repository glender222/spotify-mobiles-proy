import '../repository/player_repository.dart';

class PlayUseCase {
  final PlayerRepository _repository;

  PlayUseCase(this._repository);

  Future<void> call() {
    return _repository.play();
  }
}
