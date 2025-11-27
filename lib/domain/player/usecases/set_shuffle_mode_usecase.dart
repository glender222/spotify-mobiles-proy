import '../entities/player_state.dart';
import '../repository/player_repository.dart';

class SetShuffleModeUseCase {
  final PlayerRepository _repository;

  SetShuffleModeUseCase(this._repository);

  Future<void> call(ShuffleMode mode) {
    return _repository.setShuffleMode(mode);
  }
}
