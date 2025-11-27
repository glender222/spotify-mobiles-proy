import '../entities/library_song_entity.dart';
import '../repository/library_repository.dart';

class WatchLibrarySongsUseCase {
  final LibraryRepository _repository;

  WatchLibrarySongsUseCase(this._repository);

  Stream<List<LibrarySongEntity>> call() {
    return _repository.watchLibrarySongs();
  }
}
