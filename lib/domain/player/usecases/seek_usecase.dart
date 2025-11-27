import '../repository/player_repository.dart';

class SeekUseCase {
  final PlayerRepository _repository;

  SeekUseCase(this._repository);

  Future<void> call(Duration position) {
    return _repository.seek(position);
  }
}
