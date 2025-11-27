import '../repository/player_repository.dart';

class SkipToNextUseCase {
  final PlayerRepository _repository;

  SkipToNextUseCase(this._repository);

  Future<void> call() {
    return _repository.skipToNext();
  }
}
