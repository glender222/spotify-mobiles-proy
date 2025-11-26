import 'package:get/get.dart';
import '../entities/library_playlist_entity.dart';
import '../repository/library_repository.dart';

/// Use Case: Get all playlists from library
class GetLibraryPlaylistsUseCase {
  final LibraryRepository _repository = Get.find<LibraryRepository>();

  Future<List<LibraryPlaylistEntity>> call() async {
    return await _repository.getLibraryPlaylists();
  }
}
