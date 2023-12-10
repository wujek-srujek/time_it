import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player.g.dart';

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
    // Note to my future self: when testing this stuff, kill and redeploy the
    // application as hot reloading does strange and confusing things to the
    // states of the players, making it very hard to sanely work with.
    await AudioPlayer.global.setAudioContext(
      const AudioContext(
        android: AudioContextAndroid(
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          options: [
            AVAudioSessionOptions.mixWithOthers,
          ],
        ),
      ),
    );

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

@Riverpod(keepAlive: true)
Player player(PlayerRef ref) => Player();

Future<void> _preparePlayer(AudioPlayer player, String asset) {
  return Future.wait([
    // I want to but I can't, streams don't work in this mode so the
    // release mode setting doesn't work correctly.
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
