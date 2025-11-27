import '../entities/player_state.dart';
import '../repository/player_repository.dart';

class GetPlayerStateStreamUseCase {
  final PlayerRepository _repository;

  GetPlayerStateStreamUseCase(this._repository);

  Stream<PlayerState> call() {
    return _repository.playerStateStream;
  }
}
