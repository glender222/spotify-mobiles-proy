import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import '../repository/download_repository.dart';

class DownloadPlaylistUseCase {
  final DownloadRepository _downloadRepository = Get.find<DownloadRepository>();

  Future<void> call(String playlistId, List<MediaItem> songList) async {
    await _downloadRepository.downloadPlaylist(playlistId, songList);
  }
}
