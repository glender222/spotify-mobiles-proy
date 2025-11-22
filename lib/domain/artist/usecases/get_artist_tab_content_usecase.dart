import '../repositories/artist_repository.dart';

/// UseCase to fetch specific tab content for an artist
class GetArtistTabContentUseCase {
  final ArtistRepository _repository;

  GetArtistTabContentUseCase(this._repository);

  /// Executes the use case to get tab content
  /// [params] - The params from artist data
  /// [tabName] - The name of the tab
  /// Returns map with results and continuation params
  Future<Map<String, dynamic>> call(
      Map<String, dynamic> params, String tabName) async {
    return await _repository.getArtistTabContent(params, tabName);
  }
}
