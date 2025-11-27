import 'package:harmonymusic/domain/home/entities/home_section_entity.dart';
import 'package:harmonymusic/data/home/models/album_model.dart';
import 'package:harmonymusic/data/playlist/models/playlist_model.dart';

class HomeSectionModel extends HomeSectionEntity {
  HomeSectionModel({
    required super.title,
    required super.items,
  });

  factory HomeSectionModel.fromLegacyContent(dynamic content) {
    final String title = content.title;
    final List<dynamic> items;

    if (content.runtimeType.toString() == 'AlbumContent') {
      items = content.albumList
          .map((album) => AlbumModel.fromLegacyAlbum(album))
          .toList();
    } else if (content.runtimeType.toString() == 'PlaylistContent') {
      items = content.playlistList
          .map((playlist) => PlaylistModel.fromLegacyPlaylist(playlist))
          .toList();
    } else {
      items = [];
    }

    return HomeSectionModel(title: title, items: items);
  }

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> items = (json['items'] as List)
        .map((itemJson) {
          final itemMap = Map<String, dynamic>.from(itemJson);
          if (itemMap['modelType'] == 'AlbumModel') {
            return AlbumModel.fromJson(itemMap);
          } else if (itemMap['modelType'] == 'PlaylistModel') {
            return PlaylistModel.fromJson(itemMap);
          }
          return null;
        })
        .where((item) => item != null)
        .toList();

    return HomeSectionModel(
      title: json['title'],
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> itemsJson =
        items.map<Map<String, dynamic>>((item) {
      if (item is AlbumModel) {
        return item.toJson();
      } else if (item is PlaylistModel) {
        return item.toJson();
      }
      return {}; // Should not happen
    }).toList();

    return {
      'title': title,
      'items': itemsJson,
    };
  }
}
