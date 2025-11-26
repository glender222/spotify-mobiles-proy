import 'package:get/get.dart';
import '../repository/library_repository.dart';

/// Use Case: Sync Piped playlists
class SyncPipedPlaylistsUseCase {
  final LibraryRepository _repository = Get.find<LibraryRepository>();

  Future<void> call() async {
    await _repository.syncPipedPlaylists();
  }
}
