import 'package:audio_service/audio_service.dart' show MediaItem;
import '../../../services/activity_service.dart';
import '../../../services/music_service.dart';

abstract class RecommendationDataSource {
  Future<List<MediaItem>> getRecommendations();
}

class RecommendationDataSourceImpl implements RecommendationDataSource {
  final ActivityService _activityService;
  final MusicServices _musicServices;

  RecommendationDataSourceImpl({
    required ActivityService activityService,
    required MusicServices musicServices,
  })  : _activityService = activityService,
        _musicServices = musicServices;

  @override
  Future<List<MediaItem>> getRecommendations() async {
    final artistCounts = _activityService.getArtistCounts();
    if (artistCounts.isEmpty) {
      return [];
    }

    final sortedArtists = artistCounts.keys.toList(growable: false)
      ..sort((k1, k2) => artistCounts[k2]!.compareTo(artistCounts[k1]!));

    final topArtist = sortedArtists.first;

    final searchResults =
        await _musicServices.search(topArtist, filter: 'songs');
    if (searchResults.containsKey('Songs')) {
      return (searchResults['Songs'] as List)
          .map((song) => song as MediaItem)
          .toList();
    }
    return [];
  }
}
