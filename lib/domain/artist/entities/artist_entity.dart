class ArtistEntity {
  final String id;
  final String name;
  final String? thumbnailUrl;
  final String? subscribers;
  final String? description;
  final String? radioId;
  final String? shuffleId;

  ArtistEntity({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.subscribers,
    this.description,
    this.radioId,
    this.shuffleId,
  });

  ArtistEntity copyWith({
    String? id,
    String? name,
    String? thumbnailUrl,
    String? subscribers,
    String? description,
    String? radioId,
    String? shuffleId,
  }) {
    return ArtistEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      subscribers: subscribers ?? this.subscribers,
      description: description ?? this.description,
      radioId: radioId ?? this.radioId,
      shuffleId: shuffleId ?? this.shuffleId,
    );
  }
}

/// Artist content containing different types of media
class ArtistContentEntity {
  final List<dynamic>? topSongs; // MediaItems
  final List<dynamic>? albums; // Can be album entities or maps
  final List<dynamic>? singles; // Can be album entities or maps
  final List<dynamic>? videos; // MediaItems
  final List<dynamic>? playlists; // Can be playlist entities or maps

  ArtistContentEntity({
    this.topSongs,
    this.albums,
    this.singles,
    this.videos,
    this.playlists,
  });

  ArtistContentEntity copyWith({
    List<dynamic>? topSongs,
    List<dynamic>? albums,
    List<dynamic>? singles,
    List<dynamic>? videos,
    List<dynamic>? playlists,
  }) {
    return ArtistContentEntity(
      topSongs: topSongs ?? this.topSongs,
      albums: albums ?? this.albums,
      singles: singles ?? this.singles,
      videos: videos ?? this.videos,
      playlists: playlists ?? this.playlists,
    );
  }
}
