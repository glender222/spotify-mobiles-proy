import 'package:harmonymusic/domain/home/entities/home_section_entity.dart';
import 'package:harmonymusic/domain/home/repositories/home_repository.dart';

class GetHomePageContentUseCase {
  final HomeRepository _repository;

  GetHomePageContentUseCase(this._repository);

  Future<List<HomeSectionEntity>> call() async {
    return _repository.getHomeContent();
  }
}
