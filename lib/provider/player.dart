import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:riverpod/riverpod.dart';

/// A simple audio player.
///
/// It allows for playing different sounds simultaneously; playing the same
/// sound causes previous playback to be stopped.
///
/// It doesn't offer any control over the audio (seeking, stopping, etc.). All
/// its `playXXX` methods are of the 'fire-and-forget' variety.
class Player {
  static Future<void> init() async {
    // The context affects all players created afterwards so do this first.
    //
    // Applying any context on Android causes our sounds to either stop other
    // audio, or have ducking, so to actually have our sounds play on top of
    // other audio without ducking we must not apply any context, hence the
    // Platform check.
    //
    // Note to my future self: when testing this stuff, kill and redeploy the
    // application as hot reloading does strange and confusing things to the
    // states of the players, making it very hard to reasonably work with.
    if (Platform.isIOS) {
      await AudioPlayer.global.setAudioContext(
        const AudioContext(
          iOS: AudioContextIOS(
            // Use the value and ignore the lint. If this ever changes to some
            // other category, we want to keep this one. It was too hard to get
            // right to just risk that a change in the lib breaks our settings.
            // ignore: avoid_redundant_argument_values
            category: AVAudioSessionCategory.playback,
            options: [
              AVAudioSessionOptions.mixWithOthers,
            ],
          ),
        ),
      );
    }

    _intervalCompletedPlayer = AudioPlayer();
    _workoutCompletedPlayer = AudioPlayer();

    return Future.wait([
      _preparePlayer(_intervalCompletedPlayer, _intervalCompletedAsset),
      _preparePlayer(_workoutCompletedPlayer, _workoutCompletedAsset),
    ]).then((_) => null);
  }

  void playIntervalCompleted() {
    _play(_intervalCompletedPlayer);
  }

  void playWorkoutCompleted() {
    _play(_workoutCompletedPlayer);
  }
}

final playerProvider = Provider(
  (ref) => Player(),
);

Future<void> _preparePlayer(AudioPlayer player, String asset) {
  return Future.wait([
    // I want to but I can't, streams don't work in this mode so the
    // release mode setting doesn't work.
    // player.setPlayerMode(PlayerMode.lowLatency),
    player.setSourceAsset(asset),
    player.setReleaseMode(ReleaseMode.stop),
  ]);
}

void _play(AudioPlayer player) {
  unawaited(player.stop().then((_) => player.resume()));
}

late AudioPlayer _intervalCompletedPlayer;
late AudioPlayer _workoutCompletedPlayer;

const _audioAssets = 'audio';
const _intervalCompletedAsset = '$_audioAssets/interval_completed.mp3';
const _workoutCompletedAsset = '$_audioAssets/workout_completed.mp3';
