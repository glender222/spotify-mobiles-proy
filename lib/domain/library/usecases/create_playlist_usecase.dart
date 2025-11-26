import 'package:get/get.dart';
import '../entities/library_playlist_entity.dart';
import '../repository/library_repository.dart';

/// Use Case: Create a new playlist
class CreatePlaylistUseCase {
  final LibraryRepository _repository = Get.find<LibraryRepository>();

  Future<void> call(
    LibraryPlaylistEntity playlist, {
    bool syncToPiped = false,
  }) async {
    await _repository.createPlaylist(playlist, syncToPiped: syncToPiped);
  }
}
