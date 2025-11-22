class AlbumEntity {
  final String id;
  final String title;
  final String? thumbnailUrl;
  final List<ArtistInfo> artists;
  final String? year;
  final int? trackCount;
  final String? description;
  final String? audioPlaylistId;

  AlbumEntity({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    required this.artists,
    this.year,
    this.trackCount,
    this.description,
    this.audioPlaylistId,
  });

  AlbumEntity copyWith({
    String? id,
    String? title,
    String? thumbnailUrl,
    List<ArtistInfo>? artists,
    String? year,
    int? trackCount,
    String? description,
    String? audioPlaylistId,
  }) {
    return AlbumEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      artists: artists ?? this.artists,
      year: year ?? this.year,
      trackCount: trackCount ?? this.trackCount,
      description: description ?? this.description,
      audioPlaylistId: audioPlaylistId ?? this.audioPlaylistId,
    );
  }
}

class ArtistInfo {
  final String name;
  final String? id;

  ArtistInfo({
    required this.name,
    this.id,
  });

  ArtistInfo copyWith({
    String? name,
    String? id,
  }) {
    return ArtistInfo(
      name: name ?? this.name,
      id: id ?? this.id,
    );
  }
}
