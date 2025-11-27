import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart';
import '../../data/player/repository/player_repository_impl.dart';
import '../../domain/player/repository/player_repository.dart';
import '../../domain/player/usecases/play_usecase.dart';
import '../../domain/player/usecases/pause_usecase.dart';
import '../../domain/player/usecases/stop_usecase.dart';
import '../../domain/player/usecases/seek_usecase.dart';
import '../../domain/player/usecases/skip_to_next_usecase.dart';
import '../../domain/player/usecases/skip_to_previous_usecase.dart';
import '../../domain/player/usecases/play_song_usecase.dart';
import '../../domain/player/usecases/play_playlist_usecase.dart';
import '../../domain/player/usecases/add_to_queue_usecase.dart';
import '../../domain/player/usecases/remove_from_queue_usecase.dart';
import '../../domain/player/usecases/reorder_queue_usecase.dart';
import '../../domain/player/usecases/clear_queue_usecase.dart';
import '../../domain/player/usecases/set_shuffle_mode_usecase.dart';
import '../../domain/player/usecases/set_repeat_mode_usecase.dart';
import '../../domain/player/usecases/set_volume_usecase.dart';
import '../../domain/player/usecases/get_player_state_stream_usecase.dart';
import '../../domain/player/usecases/get_current_song_stream_usecase.dart';
import '../../domain/player/usecases/get_queue_stream_usecase.dart';
import '../../domain/player/usecases/skip_to_queue_item_usecase.dart';
import '../../domain/player/usecases/toggle_favorite_usecase.dart';
import '../../domain/player/usecases/is_favorite_usecase.dart';
import '../../domain/player/usecases/open_equalizer_usecase.dart';
import '../controllers/player/player_controller.dart';

class PlayerBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<PlayerRepository>(
      () => PlayerRepositoryImpl(Get.find<AudioHandler>()),
    );

    // Use Cases
    Get.lazyPut(() => PlayUseCase(Get.find()));
    Get.lazyPut(() => PauseUseCase(Get.find()));
    Get.lazyPut(() => StopUseCase(Get.find()));
    Get.lazyPut(() => SeekUseCase(Get.find()));
    Get.lazyPut(() => SkipToNextUseCase(Get.find()));
    Get.lazyPut(() => SkipToPreviousUseCase(Get.find()));
    Get.lazyPut(() => PlaySongUseCase(Get.find()));
    Get.lazyPut(() => PlayPlaylistUseCase(Get.find()));
    Get.lazyPut(() => AddToQueueUseCase(Get.find()));
    Get.lazyPut(() => RemoveFromQueueUseCase(Get.find()));
    Get.lazyPut(() => ReorderQueueUseCase(Get.find()));
    Get.lazyPut(() => ClearQueueUseCase(Get.find()));
    Get.lazyPut(() => SetShuffleModeUseCase(Get.find()));
    Get.lazyPut(() => SetRepeatModeUseCase(Get.find()));
    Get.lazyPut(() => SetVolumeUseCase(Get.find()));
    Get.lazyPut(() => GetPlayerStateStreamUseCase(Get.find()));
    Get.lazyPut(() => GetCurrentSongStreamUseCase(Get.find()));
    Get.lazyPut(() => GetQueueStreamUseCase(Get.find()));
    Get.lazyPut(() => SkipToQueueItemUseCase(Get.find()));
    Get.lazyPut(() => ToggleFavoriteUseCase(Get.find()));
    Get.lazyPut(() => IsFavoriteUseCase(Get.find()));
    Get.lazyPut(() => OpenEqualizerUseCase(Get.find()));

    // Controller
    Get.lazyPut(() => PlayerController(
          playUseCase: Get.find(),
          pauseUseCase: Get.find(),
          stopUseCase: Get.find(),
          seekUseCase: Get.find(),
          skipToNextUseCase: Get.find(),
          skipToPreviousUseCase: Get.find(),
          playSongUseCase: Get.find(),
          playPlaylistUseCase: Get.find(),
          addToQueueUseCase: Get.find(),
          removeFromQueueUseCase: Get.find(),
          reorderQueueUseCase: Get.find(),
          clearQueueUseCase: Get.find(),
          setShuffleModeUseCase: Get.find(),
          setRepeatModeUseCase: Get.find(),
          setVolumeUseCase: Get.find(),
          getPlayerStateStreamUseCase: Get.find(),
          getCurrentSongStreamUseCase: Get.find(),
          getQueueStreamUseCase: Get.find(),
          skipToQueueItemUseCase: Get.find(),
          toggleFavoriteUseCase: Get.find(),
          isFavoriteUseCase: Get.find(),
          openEqualizerUseCase: Get.find(),
        ));
  }
}
