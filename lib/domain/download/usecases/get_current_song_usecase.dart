import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import '../repository/download_repository.dart';

class GetCurrentSongUseCase {
  final DownloadRepository _downloadRepository = Get.find<DownloadRepository>();

  Stream<MediaItem?> call() {
    // Combine the songQueue and isJobRunning streams to determine the current song
    return combineLatest2(
        _downloadRepository.songQueue, _downloadRepository.isJobRunning,
        (List<MediaItem> queue, bool isRunning) {
      if (queue.isNotEmpty && isRunning) {
        return queue.first;
      }
      return null;
    });
  }
}

// Helper function to combine two streams
Stream<R> combineLatest2<A, B, R>(
  Stream<A> streamA,
  Stream<B> streamB,
  R Function(A a, B b) combiner,
) {
  final controller = StreamController<R>(sync: true);
  A? valueA;
  B? valueB;
  bool hasValueA = false;
  bool hasValueB = false;

  StreamSubscription<A>? subscriptionA;
  StreamSubscription<B>? subscriptionB;

  void update() {
    if (hasValueA && hasValueB) {
      try {
        controller.add(combiner(valueA as A, valueB as B));
      } catch (e, s) {
        controller.addError(e, s);
      }
    }
  }

  controller.onListen = () {
    subscriptionA = streamA.listen(
      (a) {
        valueA = a;
        hasValueA = true;
        update();
      },
      onError: controller.addError,
    );
    subscriptionB = streamB.listen(
      (b) {
        valueB = b;
        hasValueB = true;
        update();
      },
      onError: controller.addError,
    );
  };

  controller.onCancel = () async {
    await Future.wait([
      subscriptionA?.cancel() ?? Future.value(),
      subscriptionB?.cancel() ?? Future.value(),
    ]);
  };

  return controller.stream;
}
