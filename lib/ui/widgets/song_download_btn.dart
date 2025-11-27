import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../domain/download/usecases/download_song_usecase.dart';
import '../../domain/download/usecases/get_current_song_usecase.dart';
import '../../domain/download/usecases/get_song_downloading_progress_usecase.dart';
import '../../domain/download/usecases/get_song_queue_usecase.dart';
import '../../domain/download/usecases/is_job_running_usecase.dart';
import '/presentation/controllers/player/player_controller.dart';
import 'loader.dart';
import 'snackbar.dart';

class SongDownloadButton extends StatelessWidget {
  const SongDownloadButton({
    super.key,
    this.calledFromPlayer = false,
    this.song_,
    this.isDownloadingDoneCallback,
  });

  final bool calledFromPlayer;
  final MediaItem? song_;
  final void Function(bool)? isDownloadingDoneCallback;

  @override
  Widget build(BuildContext context) {
    final downloadSongUseCase = Get.find<DownloadSongUseCase>();
    final getSongQueueUseCase = Get.find<GetSongQueueUseCase>();
    final getCurrentSongUseCase = Get.find<GetCurrentSongUseCase>();
    final getSongDownloadingProgressUseCase =
        Get.find<GetSongDownloadingProgressUseCase>();
    final isJobRunningUseCase = Get.find<IsJobRunningUseCase>();
    final playerController = Get.find<PlayerController>();

    final song = calledFromPlayer ? playerController.currentSong.value : song_;
    if (song == null) return const SizedBox.shrink();

    return StreamBuilder<List<MediaItem>>(
      stream: getSongQueueUseCase(),
      builder: (context, songQueueSnapshot) {
        final songQueue = songQueueSnapshot.data ?? [];
        return StreamBuilder<MediaItem?>(
          stream: getCurrentSongUseCase(),
          builder: (context, currentSongSnapshot) {
            final currentSong = currentSongSnapshot.data;
            return StreamBuilder<int>(
              stream: getSongDownloadingProgressUseCase(),
              builder: (context, progressSnapshot) {
                final progress = progressSnapshot.data ?? 0;
                return StreamBuilder<bool>(
                  stream: isJobRunningUseCase(),
                  builder: (context, isJobRunningSnapshot) {
                    final isJobRunning = isJobRunningSnapshot.data ?? false;

                    final isDownloadingDone = (songQueue.contains(song) &&
                        currentSong == song &&
                        progress == 100);

                    if (isDownloadingDoneCallback != null) {
                      isDownloadingDoneCallback!(isDownloadingDone);
                    }

                    if (isDownloadingDone ||
                        Hive.box("SongDownloads").containsKey(song.id)) {
                      return Icon(
                        Icons.download_done,
                        color: Theme.of(context).textTheme.titleMedium!.color,
                      );
                    }

                    if (songQueue.contains(song) &&
                        isJobRunning &&
                        currentSong == song) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "$progress%",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                          LoadingIndicator(
                            dimension: 30,
                            strokeWidth: 4,
                            value: progress / 100,
                          ),
                        ],
                      );
                    }

                    if (songQueue.contains(song)) {
                      return const LoadingIndicator();
                    }

                    return IconButton(
                      icon: Icon(
                        Icons.download,
                        color: Theme.of(context).textTheme.titleMedium!.color,
                      ),
                      onPressed: () {
                        (Hive.openBox("SongsCache").then((box) {
                          if (box.containsKey(song.id)) {
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(snackbar(
                                context, "songAlreadyOfflineAlert".tr,
                                size: SanckBarSize.BIG));
                          } else {
                            downloadSongUseCase(song);
                          }
                        }));
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
