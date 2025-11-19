import 'package:harmonymusic/domain/playlist/entities/track_entity.dart';

class PlaylistEntity {
  final String id;
  final String title;
  final String? description;
  final String thumbnailUrl;
  final List<TrackEntity> tracks;

  PlaylistEntity({
    required this.id,
    required this.title,
    this.description,
    required this.thumbnailUrl,
    this.tracks = const [],
  });
}
