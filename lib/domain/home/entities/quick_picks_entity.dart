import 'package:harmonymusic/domain/playlist/entities/track_entity.dart';

class QuickPicksEntity {
  final String title;
  final List<TrackEntity> items;

  QuickPicksEntity({
    required this.title,
    required this.items,
  });
}
