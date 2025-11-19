import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:harmonymusic/domain/home/repositories/home_repository.dart';

class GetRecentlyPlayedUseCase {
  final HomeRepository _repository;

  GetRecentlyPlayedUseCase(this._repository);

  Future<List<MediaItem>> call() {
    return _repository.getRecentlyPlayed();
  }
}
