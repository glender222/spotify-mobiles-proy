import 'package:harmonymusic/models/hm_streaming_data.dart';
import '../repositories/audio_source_repository.dart';

class GetPlayableUrlUseCase {
  final AudioSourceRepository repository;

  GetPlayableUrlUseCase(this.repository);

  Future<HMStreamingData> call(String songId, {bool generateNewUrl = false}) {
    return repository.getPlayableUrl(songId, generateNewUrl: generateNewUrl);
  }
}
