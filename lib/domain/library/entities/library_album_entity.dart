import 'library_item_entity.dart';
import '/models/album.dart';

/// Entity representing an album in the library
class LibraryAlbumEntity extends LibraryItemEntity {
  final String artist;
  final String? year;
  final String thumbnailUrl;
  final int trackCount;

  LibraryAlbumEntity({
    required super.id,
    required super.title,
    required super.addedAt,
    required this.artist,
    this.year,
    required this.thumbnailUrl,
    this.trackCount = 0,
  }) : super(itemType: LibraryItemType.album);

  @override
  Map<String, dynamic> toJson() {
    return {
      'browseId': id,
      'title': title,
      'addedAt': addedAt.toIso8601String(),
      'artist': artist,
      'year': year,
      'thumbnailUrl': thumbnailUrl,
      'trackCount': trackCount,
    };
  }

  factory LibraryAlbumEntity.fromJson(Map<String, dynamic> json) {
    return LibraryAlbumEntity(
      id: json['browseId'] as String,
      title: json['title'] as String,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
      artist: json['artist'] as String,
      year: json['year'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String,
      trackCount: json['trackCount'] as int? ?? 0,
    );
  }

  /// Convert from Album model (for backward compatibility)
  factory LibraryAlbumEntity.fromAlbum(Album album) {
    // Extract artist name from artists list
    final artistName = album.artists != null && album.artists!.isNotEmpty
        ? album.artists![0]['name'] as String? ?? 'Unknown Artist'
        : 'Unknown Artist';

    return LibraryAlbumEntity(
      id: album.browseId,
      title: album.title,
      addedAt: DateTime.now(),
      artist: artistName,
      year: album.year,
      thumbnailUrl: album.thumbnailUrl,
      trackCount: 0,
    );
  }

  /// Convert to Album model (for UI compatibility)
  Album toAlbum() {
    return Album(
      title: title,
      browseId: id,
      artists: [
        {'name': artist}
      ],
      thumbnailUrl: thumbnailUrl,
      year: year,
    );
  }

  LibraryAlbumEntity copyWith({
    String? id,
    String? title,
    DateTime? addedAt,
    String? artist,
    String? year,
    String? thumbnailUrl,
    int? trackCount,
  }) {
    return LibraryAlbumEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      addedAt: addedAt ?? this.addedAt,
      artist: artist ?? this.artist,
      year: year ?? this.year,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      trackCount: trackCount ?? this.trackCount,
    );
  }
}
