import 'package:harmonymusic/models/hm_streaming_data.dart';

abstract class AudioSourceRepository {
  /// Decides whether to play from Cache, Local File, or Network.
  /// Returns [HMStreamingData] with the playable URL and metadata.
  Future<HMStreamingData> getPlayableUrl(String songId,
      {bool generateNewUrl = false});
}
