import 'package:get/get.dart';
import '../entities/library_song_entity.dart';
import '../repository/library_repository.dart';

/// Use Case: Get all songs from library
class GetLibrarySongsUseCase {
  final LibraryRepository _repository = Get.find<LibraryRepository>();

  Future<List<LibrarySongEntity>> call() async {
    return await _repository.getLibrarySongs();
  }
}
