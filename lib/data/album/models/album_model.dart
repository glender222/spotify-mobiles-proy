import '../../../domain/album/entities/album_entity.dart';
import '../../../models/thumbnail.dart';

/// Model class for Album that maps API responses to domain entities
/// This belongs to the data layer and handles JSON serialization/deserialization
class AlbumModel {
  final String browseId;
  final String? audioPlaylistId;
  final String title;
  final String? description;
  final List<Map<dynamic, dynamic>>? artists;
  final String? year;
  final String thumbnailUrl;
  final int? trackCount;

  AlbumModel({
    required this.browseId,
    this.audioPlaylistId,
    required this.title,
    this.description,
    this.artists,
    this.year,
    required this.thumbnailUrl,
    this.trackCount,
  });

  /// Creates AlbumModel from JSON (API response)
  factory AlbumModel.fromJson(Map<dynamic, dynamic> json) {
    return AlbumModel(
      browseId: json["browseId"] ?? json["id"] ?? "",
      audioPlaylistId: json['audioPlaylistId'],
      title: json["title"] ?? "",
      description: json['description'] ?? json["type"] ?? "Album",
      artists: json["artists"] != null
          ? List<Map<dynamic, dynamic>>.from(json["artists"])
          : [
              {'name': ''}
            ],
      year: json['year'],
      thumbnailUrl: json["thumbnails"] != null && json["thumbnails"].isNotEmpty
          ? Thumbnail(json["thumbnails"][0]["url"]).medium
          : "",
      trackCount: json['trackCount'],
    );
  }

  /// Converts AlbumModel to JSON (for storage)
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "browseId": browseId,
      'artists': artists,
      'year': year,
      'audioPlaylistId': audioPlaylistId,
      'description': description,
      'thumbnails': [
        {'url': thumbnailUrl}
      ],
      'trackCount': trackCount,
    };
  }

  /// Converts AlbumModel to domain AlbumEntity
  AlbumEntity toEntity() {
    return AlbumEntity(
      id: browseId,
      title: title,
      thumbnailUrl: thumbnailUrl,
      artists: artists
              ?.map((artistMap) => ArtistInfo(
                    name: artistMap['name'] ?? '',
                    id: artistMap['id'],
                  ))
              .toList() ??
          [],
      year: year,
      trackCount: trackCount,
      description: description,
      audioPlaylistId: audioPlaylistId,
    );
  }

  /// Creates AlbumModel from domain AlbumEntity
  factory AlbumModel.fromEntity(AlbumEntity entity) {
    return AlbumModel(
      browseId: entity.id,
      title: entity.title,
      thumbnailUrl: entity.thumbnailUrl ?? "",
      artists: entity.artists
          .map((artist) => {
                'name': artist.name,
                'id': artist.id,
              })
          .toList(),
      year: entity.year,
      trackCount: entity.trackCount,
      description: entity.description,
      audioPlaylistId: entity.audioPlaylistId,
    );
  }
}
