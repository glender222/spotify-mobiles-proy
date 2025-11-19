import 'package:get/get.dart';
import '../repository/search_repository.dart';

class GetSearchSuggestionsUseCase {
  final SearchRepository _searchRepository = Get.find<SearchRepository>();

  Future<List<String>> call(String query) async {
    return await _searchRepository.getSearchSuggestions(query);
  }
}
