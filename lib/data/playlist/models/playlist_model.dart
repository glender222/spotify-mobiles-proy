// ignore_for_file: overridden_fields
import 'package:hive/hive.dart';
import 'package:harmonymusic/data/playlist/models/track_model.dart';
import 'package:harmonymusic/domain/playlist/entities/playlist_entity.dart';
import 'package:harmonymusic/models/playlist.dart' as legacy;

part 'playlist_model.g.dart';

@HiveType(typeId: 0)
class PlaylistModel extends PlaylistEntity {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String title;

  @HiveField(2)
  @override
  final String? description;

  @HiveField(3)
  @override
  final String thumbnailUrl;

  @HiveField(4)
  @override
  final List<TrackModel> tracks;

  PlaylistModel({
    required this.id,
    required this.title,
    this.description,
    required this.thumbnailUrl,
    required this.tracks,
  }) : super(
          id: id,
          title: title,
          description: description,
          thumbnailUrl: thumbnailUrl,
          tracks: tracks,
        );

  factory PlaylistModel.fromEntity(PlaylistEntity entity) {
    return PlaylistModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      thumbnailUrl: entity.thumbnailUrl,
      tracks: entity.tracks.map((e) => TrackModel.fromEntity(e)).toList(),
    );
  }

  factory PlaylistModel.fromLegacyPlaylist(legacy.Playlist legacyPlaylist,
      {List<TrackModel>? tracks}) {
    return PlaylistModel(
      id: legacyPlaylist.playlistId,
      title: legacyPlaylist.title,
      description: legacyPlaylist.description,
      thumbnailUrl: legacyPlaylist.thumbnailUrl,
      tracks: tracks ?? [],
    );
  }

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      tracks: (json['tracks'] as List)
          .map((item) => TrackModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'tracks': tracks.map((track) => track.toJson()).toList(),
      'modelType': 'PlaylistModel', // To help with deserialization
    };
  }
}
