import 'package:get/get.dart';
import '../repository/search_repository.dart';

class SearchUseCase {
  final SearchRepository _searchRepository = Get.find<SearchRepository>();

  Future<Map<String, dynamic>> call(String query, {String? filter, int limit = 20, String? filterParams}) async {
    return await _searchRepository.search(query, filter: filter, limit: limit, filterParams: filterParams);
  }
}
