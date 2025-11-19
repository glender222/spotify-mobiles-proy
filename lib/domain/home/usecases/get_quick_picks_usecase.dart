import 'package:harmonymusic/domain/home/entities/quick_picks_entity.dart';
import 'package:harmonymusic/domain/home/repositories/home_repository.dart';

class GetQuickPicksUseCase {
  final HomeRepository _repository;

  GetQuickPicksUseCase(this._repository);

  Future<QuickPicksEntity> call(String contentType, {String? songId}) {
    return _repository.getQuickPicks(contentType, songId: songId);
  }
}
