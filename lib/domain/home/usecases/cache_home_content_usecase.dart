import 'package:harmonymusic/domain/home/entities/home_section_entity.dart';
import 'package:harmonymusic/domain/home/repositories/home_repository.dart';

class CacheHomeContentUseCase {
  final HomeRepository _repository;

  CacheHomeContentUseCase(this._repository);

  Future<void> call(List<HomeSectionEntity> sections) {
    return _repository.cacheHomeContent(sections);
  }
}
