// ignore_for_file: overridden_fields
import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:hive/hive.dart';
import 'package:harmonymusic/domain/playlist/entities/track_entity.dart';

part 'track_model.g.dart';

@HiveType(typeId: 1)
class TrackModel extends TrackEntity {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String title;

  @HiveField(2)
  @override
  final String artist;

  @HiveField(3)
  @override
  final String? album;

  @HiveField(4)
  @override
  final String? thumbnailUrl;

  @HiveField(5)
  @override
  final Duration? duration;

  TrackModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.thumbnailUrl,
    this.duration,
  }) : super(
          id: id,
          title: title,
          artist: artist,
          album: album,
          thumbnailUrl: thumbnailUrl,
          duration: duration,
        );

  factory TrackModel.fromEntity(TrackEntity entity) {
    return TrackModel(
      id: entity.id,
      title: entity.title,
      artist: entity.artist,
      album: entity.album,
      thumbnailUrl: entity.thumbnailUrl,
      duration: entity.duration,
    );
  }

  factory TrackModel.fromMediaItem(MediaItem mediaItem) {
    return TrackModel(
      id: mediaItem.id,
      title: mediaItem.title,
      artist: mediaItem.artist ?? 'Unknown Artist',
      album: mediaItem.album,
      thumbnailUrl: mediaItem.artUri?.toString(),
      duration: mediaItem.duration,
    );
  }

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      thumbnailUrl: json['thumbnailUrl'],
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration?.inMilliseconds,
    };
  }
}
