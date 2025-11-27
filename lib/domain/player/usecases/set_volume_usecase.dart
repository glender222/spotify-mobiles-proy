import '../repository/player_repository.dart';

class SetVolumeUseCase {
  final PlayerRepository _repository;

  SetVolumeUseCase(this._repository);

  Future<void> call(double volume) {
    return _repository.setVolume(volume);
  }
}
