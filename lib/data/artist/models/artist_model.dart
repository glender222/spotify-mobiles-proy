import '../../../domain/artist/entities/artist_entity.dart';
import '../../../models/thumbnail.dart';

/// Model for mapping between API/Hive and domain entities
class ArtistModel {
  final String id;
  final String name;
  final String? thumbnailUrl;
  final String? subscribers;
  final String? description;
  final String? radioId;
  final String? shuffleId;

  ArtistModel({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.subscribers,
    this.description,
    this.radioId,
    this.shuffleId,
  });

  /// Creates model from API JSON response
  factory ArtistModel.fromJson(Map<String, dynamic> json, String? artistId) {
    return ArtistModel(
      id: artistId ?? json['browseId'] ?? '',
      name: json['name'] ?? json['artist'] ?? '',
      thumbnailUrl: json['thumbnails'] != null && json['thumbnails'].isNotEmpty
          ? Thumbnail(json['thumbnails'][0]['url']).high
          : null,
      subscribers: _parseSubscribers(json['subscribers']),
      description: json['description'],
      radioId: json['radioId'],
      shuffleId: json['shuffleId'],
    );
  }

  static String? _parseSubscribers(dynamic subscribers) {
    if (subscribers == null) return null;
    if (subscribers is String) return subscribers;
    if (subscribers is Map && subscribers['text'] != null) {
      return subscribers['text'].toString();
    }
    return null;
  }

  /// Converts to JSON for Hive storage
  Map<String, dynamic> toJson() => {
        'browseId': id,
        'artist': name,
        'name': name,
        'thumbnails': thumbnailUrl != null
            ? [
                {'url': thumbnailUrl}
              ]
            : [],
        'subscribers': subscribers,
        'description': description,
        'radioId': radioId,
        'shuffleId': shuffleId,
      };

  /// Converts to domain entity
  ArtistEntity toEntity() {
    return ArtistEntity(
      id: id,
      name: name,
      thumbnailUrl: thumbnailUrl,
      subscribers: subscribers,
      description: description,
      radioId: radioId,
      shuffleId: shuffleId,
    );
  }

  /// Creates model from domain entity
  factory ArtistModel.fromEntity(ArtistEntity entity) {
    return ArtistModel(
      id: entity.id,
      name: entity.name,
      thumbnailUrl: entity.thumbnailUrl,
      subscribers: entity.subscribers,
      description: entity.description,
      radioId: entity.radioId,
      shuffleId: entity.shuffleId,
    );
  }
}

/// Model for artist content
class ArtistContentModel {
  final List<dynamic>? topSongs;
  final List<dynamic>? albums;
  final List<dynamic>? singles;
  final List<dynamic>? videos;
  final List<dynamic>? playlists;

  ArtistContentModel({
    this.topSongs,
    this.albums,
    this.singles,
    this.videos,
    this.playlists,
  });

  /// Creates model from API response
  factory ArtistContentModel.fromJson(Map<String, dynamic> json) {
    return ArtistContentModel(
      topSongs: json['Top songs'] ?? json['Songs'],
      albums: json['Albums'],
      singles: json['Singles & EPs'] ?? json['Singles'],
      videos: json['Videos'],
      playlists: json['Featured on'] ?? json['Playlists'],
    );
  }

  /// Converts to domain entity
  ArtistContentEntity toEntity() {
    return ArtistContentEntity(
      topSongs: topSongs,
      albums: albums,
      singles: singles,
      videos: videos,
      playlists: playlists,
    );
  }
}
