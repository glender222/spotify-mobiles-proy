import '../repository/player_repository.dart';

class OpenEqualizerUseCase {
  final PlayerRepository _repository;

  OpenEqualizerUseCase(this._repository);

  Future<void> call() => _repository.openEqualizer();
}
