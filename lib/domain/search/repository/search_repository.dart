abstract class SearchRepository {
  Future<List<String>> getSearchSuggestions(String query);
  Future<Map<String, dynamic>> search(String query, {String? filter, int limit = 20, String? filterParams});
  Future<Map<String, dynamic>> getSearchContinuation(Map additionalParamsNext, {int limit = 10});
}
