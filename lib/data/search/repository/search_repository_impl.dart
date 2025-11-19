import 'package:get/get.dart';
import '../../../domain/search/repository/search_repository.dart';
import '../../../services/music_service.dart';

class SearchRepositoryImpl implements SearchRepository {
  final MusicServices _musicServices = Get.find<MusicServices>();

  @override
  Future<List<String>> getSearchSuggestions(String query) async {
    return await _musicServices.getSearchSuggestion(query);
  }

  @override
  Future<Map<String, dynamic>> search(String query, {String? filter, int limit = 20, String? filterParams}) async {
    return await _musicServices.search(query, filter: filter, limit: limit, filterParams: filterParams);
  }

  @override
  Future<Map<String, dynamic>> getSearchContinuation(Map additionalParamsNext, {int limit = 10}) async {
    return await _musicServices.getSearchContinuation(additionalParamsNext, limit: limit);
  }
}
