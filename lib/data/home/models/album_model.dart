import 'package:harmonymusic/domain/home/entities/album_entity.dart';
import 'package:harmonymusic/models/album.dart' as legacy;

class AlbumModel extends AlbumEntity {
  AlbumModel({
    required super.id,
    required super.title,
    super.artist,
    required super.thumbnailUrl,
  });

  factory AlbumModel.fromLegacyAlbum(legacy.Album legacyAlbum) {
    return AlbumModel(
      id: legacyAlbum.browseId,
      title: legacyAlbum.title,
      artist: legacyAlbum.artists?.first['name'],
      thumbnailUrl: legacyAlbum.thumbnailUrl,
    );
  }

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'thumbnailUrl': thumbnailUrl,
      'modelType': 'AlbumModel', // To help with deserialization
    };
  }
}
