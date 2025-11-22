import '../../../domain/artist/entities/artist_entity.dart';
import '../../../domain/artist/repositories/artist_repository.dart';
import '../datasources/artist_remote_data_source.dart';
import '../datasources/artist_local_data_source.dart';
import '../models/artist_model.dart';

/// Implementation of ArtistRepository
/// Coordinates between remote and local data sources
class ArtistRepositoryImpl implements ArtistRepository {
  final ArtistRemoteDataSource _remoteDataSource;
  final ArtistLocalDataSource _localDataSource;

  ArtistRepositoryImpl({
    required ArtistRemoteDataSource remoteDataSource,
    required ArtistLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<ArtistEntity> getArtistDetails(String artistId) async {
    try {
      // Try local first (for library artists)
      final localArtist = await _localDataSource.getArtist(artistId);
      if (localArtist != null) {
        return localArtist.toEntity();
      }

      // Fetch from API
      final artistData = await _remoteDataSource.fetchArtist(artistId);
      final artistModel = ArtistModel.fromJson(artistData, artistId);
      return artistModel.toEntity();
    } catch (e) {
      throw Exception('Failed to get artist details: $e');
    }
  }

  @override
  Future<ArtistContentEntity> getArtistContent(String artistId) async {
    try {
      final artistData = await _remoteDataSource.fetchArtist(artistId);
      final contentModel = ArtistContentModel.fromJson(artistData);
      return contentModel.toEntity();
    } catch (e) {
      throw Exception('Failed to get artist content: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getArtistTabContent(
      Map<String, dynamic> params, String tabName) async {
    try {
      return await _remoteDataSource.fetchArtistTabContent(params, tabName);
    } catch (e) {
      throw Exception('Failed to get artist tab content: $e');
    }
  }

  @override
  Future<bool> addToLibrary(ArtistEntity artist) async {
    try {
      final artistModel = ArtistModel.fromEntity(artist);
      await _localDataSource.saveArtist(artistModel);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> removeFromLibrary(String artistId) async {
    try {
      await _localDataSource.deleteArtist(artistId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isInLibrary(String artistId) async {
    return await _localDataSource.isArtistInLibrary(artistId);
  }
}
