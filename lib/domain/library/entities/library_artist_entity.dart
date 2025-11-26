import 'library_item_entity.dart';
import '/models/artist.dart';

/// Entity representing an artist in the library
class LibraryArtistEntity extends LibraryItemEntity {
  final String thumbnailUrl;
  final String? description;
  final int albumCount;

  LibraryArtistEntity({
    required super.id,
    required super.title, // Artist name
    required super.addedAt,
    required this.thumbnailUrl,
    this.description,
    this.albumCount = 0,
  }) : super(itemType: LibraryItemType.artist);

  @override
  Map<String, dynamic> toJson() {
    return {
      'artistId': id,
      'name': title,
      'addedAt': addedAt.toIso8601String(),
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'albumCount': albumCount,
    };
  }

  factory LibraryArtistEntity.fromJson(Map<String, dynamic> json) {
    return LibraryArtistEntity(
      id: json['artistId'] as String,
      title: json['name'] as String,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
      thumbnailUrl: json['thumbnailUrl'] as String,
      description: json['description'] as String?,
      albumCount: json['albumCount'] as int? ?? 0,
    );
  }

  /// Convert from Artist model (for backward compatibility)
  factory LibraryArtistEntity.fromArtist(Artist artist) {
    return LibraryArtistEntity(
      id: artist.browseId,
      title: artist.name,
      addedAt: DateTime.now(),
      thumbnailUrl: artist.thumbnailUrl,
      description: artist.subscribers, // Using subscribers as description
      albumCount: 0,
    );
  }

  /// Convert to Artist model (for UI compatibility)
  Artist toArtist() {
    return Artist(
      name: title,
      browseId: id,
      thumbnailUrl: thumbnailUrl,
      subscribers: description,
    );
  }

  LibraryArtistEntity copyWith({
    String? id,
    String? title,
    DateTime? addedAt,
    String? thumbnailUrl,
    String? description,
    int? albumCount,
  }) {
    return LibraryArtistEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      addedAt: addedAt ?? this.addedAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
      albumCount: albumCount ?? this.albumCount,
    );
  }
}
