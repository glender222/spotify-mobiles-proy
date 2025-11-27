import 'package:harmonymusic/models/media_Item_builder.dart';
import 'package:harmonymusic/services/activity_service.dart';
import 'package:hive/hive.dart';
import 'package:audio_service/audio_service.dart' show MediaItem;

import 'package:harmonymusic/data/home/models/home_section_model.dart';

abstract class HomeLocalDataSource {
  Future<List<MediaItem>> getSongHistory();
  Future<List<HomeSectionModel>> getCachedHomeContent();
  Future<void> cacheHomeContent(List<HomeSectionModel> sections);
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final ActivityService activityService;
  final HiveInterface hive;

  HomeLocalDataSourceImpl({required this.activityService, required this.hive});

  @override
  Future<List<MediaItem>> getSongHistory() async {
    final history = activityService.getSongHistory();
    return history
        .map((video) => MediaItemBuilder.fromSerializableVideo(video))
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<List<HomeSectionModel>> getCachedHomeContent() async {
    final box = await hive.openBox('homeScreenData');
    if (box.isEmpty) {
      return [];
    }
    final contentData = box.get('content') as List<dynamic>?;
    if (contentData == null) {
      return [];
    }
    return contentData
        .map((json) =>
            HomeSectionModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<void> cacheHomeContent(List<HomeSectionModel> sections) async {
    final box = await hive.openBox('homeScreenData');
    final contentJson = sections.map((section) => section.toJson()).toList();
    await box.put('content', contentJson);
  }
}
