import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';

class Downloader extends GetxService {
  MediaItem? currentSong;
  RxMap<String, List<MediaItem>> playlistQueue =
      <String, List<MediaItem>>{}.obs;
  final currentPlaylistId = "".obs;
  final songDownloadingProgress = 0.obs;
  final playlistDownloadingProgress = 0.obs;
  final isJobRunning = false.obs;
  final completedPlaylistId = "".obs;

  RxList<MediaItem> songQueue = <MediaItem>[].obs;
}
