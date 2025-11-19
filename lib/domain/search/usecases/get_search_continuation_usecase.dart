import 'package:get/get.dart';
import '../repository/search_repository.dart';

class GetSearchContinuationUseCase {
  final SearchRepository _searchRepository = Get.find<SearchRepository>();

  Future<Map<String, dynamic>> call(Map additionalParamsNext, {int limit = 10}) async {
    return await _searchRepository.getSearchContinuation(additionalParamsNext, limit: limit);
  }
}
