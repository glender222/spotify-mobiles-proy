import 'package:get/get.dart';
import '../entities/library_song_entity.dart';
import '../repository/library_repository.dart';

/// Use Case: Add song to library
class AddSongToLibraryUseCase {
  final LibraryRepository _repository = Get.find<LibraryRepository>();

  Future<void> call(LibrarySongEntity song) async {
    await _repository.addSongToLibrary(song);
  }
}
