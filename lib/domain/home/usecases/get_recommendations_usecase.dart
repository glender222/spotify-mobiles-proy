import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:harmonymusic/domain/home/repositories/home_repository.dart';

class GetRecommendationsUseCase {
  final HomeRepository _repository;

  GetRecommendationsUseCase(this._repository);

  Future<List<MediaItem>> call() {
    return _repository.getRecommendations();
  }
}
