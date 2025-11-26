import 'package:get/get.dart';
import '../entities/library_album_entity.dart';
import '../repository/library_repository.dart';

/// Use Case: Get all albums from library
class GetLibraryAlbumsUseCase {
  final LibraryRepository _repository = Get.find<LibraryRepository>();

  Future<List<LibraryAlbumEntity>> call() async {
    return await _repository.getLibraryAlbums();
  }
}
