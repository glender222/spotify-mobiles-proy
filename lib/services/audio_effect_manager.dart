import 'dart:io';
import 'package:harmonymusic/services/equalizer.dart';

class AudioEffectManager {
  static bool openEqualizer(int sessionId) {
    if (Platform.isAndroid) {
      try {
        return EqualizerService.openEqualizer(sessionId);
      } catch (e) {
        print("Error opening equalizer: $e");
        return false;
      }
    }
    return false;
  }

  static void initAudioEffect(int sessionId) {
    if (Platform.isAndroid) {
      try {
        EqualizerService.initAudioEffect(sessionId);
      } catch (e) {
        print("Error initializing audio effect: $e");
      }
    }
  }

  static void endAudioEffect(int sessionId) {
    if (Platform.isAndroid) {
      try {
        EqualizerService.endAudioEffect(sessionId);
      } catch (e) {
        print("Error ending audio effect: $e");
      }
    }
  }
}
