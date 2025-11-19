import 'package:harmonymusic/domain/home/entities/home_section_entity.dart';
import 'package:harmonymusic/domain/home/repositories/home_repository.dart';

class GetCachedHomeContentUseCase {
  final HomeRepository _repository;

  GetCachedHomeContentUseCase(this._repository);

  Future<List<HomeSectionEntity>> call() {
    return _repository.getCachedHomeContent();
  }
}
