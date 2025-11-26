import 'package:audio_service/audio_service.dart';
import 'library_item_entity.dart';

/// Entity representing a song in the library
class LibrarySongEntity extends LibraryItemEntity {
  final String artist;
  final String? album;
  final Duration? duration;
  final String thumbnailUrl;
  final bool isDownloaded;
  final bool isCached;
  final String? localPath;
  final Map<String, dynamic>? extras;

  LibrarySongEntity({
    required super.id,
    required super.title,
    required super.addedAt,
    required this.artist,
    this.album,
    this.duration,
    required this.thumbnailUrl,
    this.isDownloaded = false,
    this.isCached = false,
    this.localPath,
    this.extras,
  }) : super(itemType: LibraryItemType.song);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'addedAt': addedAt.toIso8601String(),
      'itemType': itemType.name,
      'artist': artist,
      'album': album,
      'duration': duration?.inMilliseconds,
      'thumbnailUrl': thumbnailUrl,
      'isDownloaded': isDownloaded,
      'isCached': isCached,
      'localPath': localPath,
      'extras': extras,
    };
  }

  factory LibrarySongEntity.fromJson(Map<String, dynamic> json) {
    return LibrarySongEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
      artist: json['artist'] as String,
      album: json['album'] as String?,
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      thumbnailUrl: json['thumbnailUrl'] as String,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      isCached: json['isCached'] as bool? ?? false,
      localPath: json['localPath'] as String?,
      extras: json['extras'] as Map<String, dynamic>?,
    );
  }

  /// Convert from MediaItem (for backward compatibility)
  factory LibrarySongEntity.fromMediaItem(MediaItem item) {
    return LibrarySongEntity(
      id: item.id,
      title: item.title,
      addedAt: DateTime.now(), // Will be overridden if loading from DB
      artist: item.artist ?? 'Unknown Artist',
      album: item.album,
      duration: item.duration,
      thumbnailUrl: item.artUri?.toString() ?? '',
      isDownloaded: item.extras?['isDownloaded'] as bool? ?? false,
      isCached:
          item.extras?['url'] == null && item.extras?['isDownloaded'] != true
              ? true
              : false,
      localPath: item.extras?['url'] as String?,
      extras: item.extras,
    );
  }

  /// Convert to MediaItem (for UI compatibility)
  MediaItem toMediaItem() {
    return MediaItem(
      id: id,
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      artUri: Uri.tryParse(thumbnailUrl),
      extras: {
        ...?extras,
        'isDownloaded': isDownloaded,
        'url': localPath,
      },
    );
  }

  /// Create copy with updated fields
  LibrarySongEntity copyWith({
    String? id,
    String? title,
    DateTime? addedAt,
    String? artist,
    String? album,
    Duration? duration,
    String? thumbnailUrl,
    bool? isDownloaded,
    bool? isCached,
    String? localPath,
    Map<String, dynamic>? extras,
  }) {
    return LibrarySongEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      addedAt: addedAt ?? this.addedAt,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isCached: isCached ?? this.isCached,
      localPath: localPath ?? this.localPath,
      extras: extras ?? this.extras,
    );
  }
}
