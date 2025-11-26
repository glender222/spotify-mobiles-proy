import 'package:get/get.dart';
import '../repository/library_repository.dart';

/// Use Case: Remove song from library
class RemoveSongFromLibraryUseCase {
  final LibraryRepository _repository = Get.find<LibraryRepository>();

  Future<void> call(String songId, {bool deleteFile = false}) async {
    await _repository.removeSongFromLibrary(songId, deleteFile: deleteFile);
  }
}
