import 'package:harmonymusic/domain/home/entities/quick_picks_entity.dart';
import 'package:harmonymusic/data/playlist/models/track_model.dart';

class QuickPicksModel extends QuickPicksEntity {
  QuickPicksModel({
    required super.title,
    required super.items,
  });

  factory QuickPicksModel.fromEntity(QuickPicksEntity entity) {
    return QuickPicksModel(
      title: entity.title,
      items: entity.items,
    );
  }

  factory QuickPicksModel.fromTrackModels({required String title, required List<TrackModel> tracks}) {
    return QuickPicksModel(
      title: title,
      items: tracks,
    );
  }
}
