import 'package:hive/hive.dart';
import '../models/artist_model.dart';

/// Abstract interface for local artist data operations
abstract class ArtistLocalDataSource {
  Future<ArtistModel?> getArtist(String artistId);
  Future<void> saveArtist(ArtistModel artist);
  Future<void> deleteArtist(String artistId);
  Future<bool> isArtistInLibrary(String artistId);
}

/// Implementation of local data source using Hive
class ArtistLocalDataSourceImpl implements ArtistLocalDataSource {
  final HiveInterface _hive;
  static const String _boxName = 'LibraryArtists';

  ArtistLocalDataSourceImpl(this._hive);

  @override
  Future<ArtistModel?> getArtist(String artistId) async {
    try {
      final box = await _hive.openBox(_boxName);
      final data = box.get(artistId);
      await box.close();

      if (data == null) return null;

      return ArtistModel.fromJson(
        data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data),
        artistId,
      );
    } catch (e) {
      throw Exception('Failed to get artist from local storage: $e');
    }
  }

  @override
  Future<void> saveArtist(ArtistModel artist) async {
    try {
      final box = await _hive.openBox(_boxName);
      await box.put(artist.id, artist.toJson());
      await box.close();
    } catch (e) {
      throw Exception('Failed to save artist to local storage: $e');
    }
  }

  @override
  Future<void> deleteArtist(String artistId) async {
    try {
      final box = await _hive.openBox(_boxName);
      await box.delete(artistId);
      await box.close();
    } catch (e) {
      throw Exception('Failed to delete artist from local storage: $e');
    }
  }

  @override
  Future<bool> isArtistInLibrary(String artistId) async {
    try {
      final box = await _hive.openBox(_boxName);
      final exists = box.containsKey(artistId);
      await box.close();
      return exists;
    } catch (e) {
      return false;
    }
  }
}
