import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:riverpod/riverpod.dart';

/// A simple audio player.
///
/// It doesn't allow playing multiple sounds simultaneously, neither does it
/// offer any control over the audio (seeking, stopping, etc.). All its
/// `playXXX` methods are of the 'fire-and-forget' variety.
class Player {
  static Future<void> init() {
    return _audioCache.loadAll([
      _intervalCompletedFileName,
      _workoutCompletedFileName,
    ]);
  }

  void playIntervalCompleted() {
    _play(_intervalCompletedFileName);
  }

  void playWorkoutCompleted() {
    _play(_workoutCompletedFileName);
  }

  void _play(String fileName) {
    _audioCache.play(fileName, mode: PlayerMode.LOW_LATENCY);
  }
}

final playerProvider = Provider((ref) => Player());

const _intervalCompletedFileName = 'interval_completed.mp3';
const _workoutCompletedFileName = 'workout_completed.mp3';

final _audioCache = AudioCache(
  prefix: 'assets/audio/',
  fixedPlayer: AudioPlayer(),
  // 'duckAudio' is broken for Android so can't be used unconditionally. But it
  // is necessary for iOS because otherwise any background music is paused.
  // See https://github.com/luanpotter/audioplayers/issues/934.
  duckAudio: Platform.isIOS,
);
