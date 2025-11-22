import '../../../services/music_service.dart';

/// Abstract interface for remote artist data operations
abstract class ArtistRemoteDataSource {
  Future<Map<String, dynamic>> fetchArtist(String artistId);
  Future<Map<String, dynamic>> fetchArtistTabContent(
      Map<String, dynamic> params, String tabName);
}

/// Implementation of remote data source using MusicServices
class ArtistRemoteDataSourceImpl implements ArtistRemoteDataSource {
  final MusicServices _musicServices;

  ArtistRemoteDataSourceImpl(this._musicServices);

  @override
  Future<Map<String, dynamic>> fetchArtist(String artistId) async {
    try {
      final data = await _musicServices.getArtist(artistId);
      // Normalize the data structure
      data["Singles"] = data["Singles & EPs"];
      data["Songs"] = data["Top songs"];
      return data;
    } catch (e) {
      throw Exception('Failed to fetch artist: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> fetchArtistTabContent(
      Map<String, dynamic> params, String tabName) async {
    try {
      final data =
          await _musicServices.getArtistRealtedContent(params, tabName);
      return data;
    } catch (e) {
      throw Exception('Failed to fetch artist tab content: $e');
    }
  }
}
