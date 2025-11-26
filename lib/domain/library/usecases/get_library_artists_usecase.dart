import 'package:get/get.dart';
import '../entities/library_artist_entity.dart';
import '../repository/library_repository.dart';

/// Use Case: Get all artists from library
class GetLibraryArtistsUseCase {
  final LibraryRepository _repository = Get.find<LibraryRepository>();

  Future<List<LibraryArtistEntity>> call() async {
    return await _repository.getLibraryArtists();
  }
}
