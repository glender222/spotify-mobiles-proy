import 'package:get/get.dart';
import '../repository/library_repository.dart';

/// Use Case: Rename an existing playlist
class RenamePlaylistUseCase {
  final LibraryRepository _repository = Get.find<LibraryRepository>();

  Future<void> call(
    String playlistId,
    String newTitle, {
    bool syncToPiped = false,
  }) async {
    await _repository.renamePlaylist(
      playlistId,
      newTitle,
      syncToPiped: syncToPiped,
    );
  }
}
