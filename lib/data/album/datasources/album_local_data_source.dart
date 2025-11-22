import 'package:audio_service/audio_service.dart';
import 'package:hive/hive.dart';
import '../../../domain/album/entities/album_entity.dart';
import '../../../models/media_Item_builder.dart';
import '../models/album_model.dart';

/// Local data source for album library operations using Hive
/// Abstracts Hive access to follow Clean Architecture
abstract class AlbumLocalDataSource {
  Future<bool> addToLibrary(AlbumEntity album, List<MediaItem> tracks);
  Future<bool> removeFromLibrary(String albumId);
  Future<bool> isInLibrary(String albumId);
  Future<AlbumEntity?> getAlbumFromLibrary(String albumId);
}

class AlbumLocalDataSourceImpl implements AlbumLocalDataSource {
  final HiveInterface _hive;

  AlbumLocalDataSourceImpl(this._hive);

  @override
  Future<bool> addToLibrary(AlbumEntity album, List<MediaItem> tracks) async {
    try {
      // Save album metadata to LibraryAlbums box
      final albumsBox = await _hive.openBox("LibraryAlbums");
      final albumModel = AlbumModel.fromEntity(album);
      await albumsBox.put(album.id, albumModel.toJson());

      // Save album tracks to a dedicated box
      final tracksBox = await _hive.openBox(album.id);
      await tracksBox.clear();
      for (int i = 0; i < tracks.length; i++) {
        await tracksBox.put(i, MediaItemBuilder.toJson(tracks[i]));
      }

      await tracksBox.close();
      await albumsBox.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> removeFromLibrary(String albumId) async {
    try {
      // Remove album metadata
      final albumsBox = await _hive.openBox("LibraryAlbums");
      await albumsBox.delete(albumId);
      await albumsBox.close();

      // Remove album tracks box
      final tracksBox = await _hive.openBox(albumId);
      await tracksBox.deleteFromDisk();

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isInLibrary(String albumId) async {
    try {
      final box = await _hive.openBox("LibraryAlbums");
      final exists = box.containsKey(albumId);
      await box.close();
      return exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AlbumEntity?> getAlbumFromLibrary(String albumId) async {
    try {
      final box = await _hive.openBox("LibraryAlbums");
      final albumJson = box.get(albumId);
      await box.close();

      if (albumJson == null) {
        return null;
      }

      final albumModel = AlbumModel.fromJson(albumJson);
      return albumModel.toEntity();
    } catch (e) {
      return null;
    }
  }
}
