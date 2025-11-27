import '../repository/player_repository.dart';

class IsFavoriteUseCase {
  final PlayerRepository _repository;

  IsFavoriteUseCase(this._repository);

  Future<bool> call(String songId) {
    return _repository.isFavorite(songId);
  }
}
