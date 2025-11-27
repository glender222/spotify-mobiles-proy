import '../entities/player_state.dart';
import '../repository/player_repository.dart';

class SetRepeatModeUseCase {
  final PlayerRepository _repository;

  SetRepeatModeUseCase(this._repository);

  Future<void> call(RepeatMode mode) {
    return _repository.setRepeatMode(mode);
  }
}
