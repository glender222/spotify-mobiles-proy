import 'library_item_entity.dart';
import '/models/playlist.dart';

/// Entity representing a playlist in the library
class LibraryPlaylistEntity extends LibraryItemEntity {
  final String? description;
  final String thumbnailUrl;
  final bool isCloudPlaylist;
  final bool isPipedPlaylist;
  final int songCount;

  LibraryPlaylistEntity({
    required super.id,
    required super.title,
    required super.addedAt,
    this.description,
    required this.thumbnailUrl,
    this.isCloudPlaylist = false,
    this.isPipedPlaylist = false,
    this.songCount = 0,
  }) : super(itemType: LibraryItemType.playlist);

  @override
  Map<String, dynamic> toJson() {
    return {
      'playlistId': id,
      'title': title,
      'addedAt': addedAt.toIso8601String(),
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'isCloudPlaylist': isCloudPlaylist,
      'isPipedPlaylist': isPipedPlaylist,
      'songCount': songCount,
    };
  }

  factory LibraryPlaylistEntity.fromJson(Map<String, dynamic> json) {
    return LibraryPlaylistEntity(
      id: json['playlistId'] as String,
      title: json['title'] as String,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
      description: json['description'] as String?,
      thumbnailUrl:
          json['thumbnailUrl'] as String? ?? Playlist.thumbPlaceholderUrl,
      isCloudPlaylist: json['isCloudPlaylist'] as bool? ?? false,
      isPipedPlaylist: json['isPipedPlaylist'] as bool? ?? false,
      songCount: json['songCount'] as int? ?? 0,
    );
  }

  /// Convert from Playlist model (for backward compatibility)
  factory LibraryPlaylistEntity.fromPlaylist(Playlist playlist) {
    return LibraryPlaylistEntity(
      id: playlist.playlistId,
      title: playlist.title,
      addedAt: DateTime.now(),
      description: playlist.description,
      thumbnailUrl: playlist.thumbnailUrl,
      isCloudPlaylist: playlist.isCloudPlaylist,
      isPipedPlaylist: playlist.isPipedPlaylist,
      songCount: 0,
    );
  }

  /// Convert to Playlist model (for UI compatibility)
  Playlist toPlaylist() {
    return Playlist(
      title: title,
      playlistId: id,
      thumbnailUrl: thumbnailUrl,
      description: description,
      isCloudPlaylist: isCloudPlaylist,
      isPipedPlaylist: isPipedPlaylist,
    );
  }

  LibraryPlaylistEntity copyWith({
    String? id,
    String? title,
    DateTime? addedAt,
    String? description,
    String? thumbnailUrl,
    bool? isCloudPlaylist,
    bool? isPipedPlaylist,
    int? songCount,
  }) {
    return LibraryPlaylistEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      addedAt: addedAt ?? this.addedAt,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isCloudPlaylist: isCloudPlaylist ?? this.isCloudPlaylist,
      isPipedPlaylist: isPipedPlaylist ?? this.isPipedPlaylist,
      songCount: songCount ?? this.songCount,
    );
  }
}
