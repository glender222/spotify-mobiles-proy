import 'package:audio_service/audio_service.dart';
import '../../../../domain/player/repositories/playback_session_repository.dart';
import '../datasources/playback_local_data_source.dart';
import '../../../../models/media_Item_builder.dart';

class PlaybackSessionRepositoryImpl implements PlaybackSessionRepository {
  final PlaybackLocalDataSource localDataSource;

  PlaybackSessionRepositoryImpl(this.localDataSource);

  @override
  Future<void> saveSession(
      List<MediaItem> queue, int index, Duration position) async {
    if (queue.isEmpty) return;

    final queueData = queue.map((e) => MediaItemBuilder.toJson(e)).toList();
    final sessionData = {
      "queue": queueData,
      "position": position.inMilliseconds,
      "index": index
    };

    await localDataSource.saveSession(sessionData);
  }

  @override
  Future<Map<String, dynamic>?> restoreSession() async {
    return await localDataSource.getLastSession();
  }

  @override
  bool getSkipSilenceEnabled() {
    return localDataSource.getSkipSilenceEnabled();
  }

  @override
  bool getLoudnessNormalizationEnabled() {
    return localDataSource.getLoudnessNormalizationEnabled();
  }
}
