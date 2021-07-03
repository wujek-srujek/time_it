import 'dart:async';

import 'package:meta/meta.dart';
import 'package:quiver/async.dart';
import 'package:riverpod/riverpod.dart';
import 'package:wakelock/wakelock.dart';

import 'interval_config.dart';
import 'player.dart';

enum TimerStatus {
  running,
  paused,

  /// Stopped preemptively by the user.
  stopped,

  /// Stopped naturally, i.e. it run to the end.
  completed,
}

extension TimerStatusX on TimerStatus {
  bool get isFinished =>
      this == TimerStatus.stopped || this == TimerStatus.completed;
}

@immutable
class TimerState {
  final Duration remaining;
  final TimerStatus status;

  const TimerState(
    this.remaining,
    this.status,
  );
}

// Wakelock integration: the OS must not lock the screen as long as there is a
// running timer. The wakelock is again disabled in the following scenarios:
// - The running timer finishes, even if the user stays on this page (all
//   activity is done so there is no point in preventing screen lock).
// - The user leaves this page and there is a running timer. (If there is no
//   running timer, the previous scenario will have taken care of the wakelock.)
class TimerNotifier extends StateNotifier<TimerState> {
  final Duration _interval;
  final void Function() _onComplete;

  CountdownTimer? _timer;
  StreamSubscription<CountdownTimer>? _timerSubscription;
  // When set, means the timer has been interrupted preemptively. When unset,
  // the timer is still running of has completed naturally.
  TimerStatus? _preemptiveInterruptionStatus;

  // When a timer is paused and resumed, in reality a new timer is created and
  // started, so the 'elapsed' of the previous one would be lost. To fix this,
  // it is updated here and taken into account.
  Duration _elapsedSinceBeginning;

  TimerNotifier(this._interval, this._onComplete)
      : _elapsedSinceBeginning = Duration.zero,
        super(TimerState(_interval, TimerStatus.paused));

  void start() => _start(_interval);

  void stop() => _stop(true);

  // There is no concept of 'pausing' in CountdownTimer. We just stop it here,
  // and resume will start a new one with an interval being the current state.
  void pause() => _stop(false);

  void resume() => _start(state.remaining);

  Duration get elapsed {
    final currentElapsed = _timer?.elapsed ?? Duration.zero;

    return _elapsedSinceBeginning + currentElapsed;
  }

  void _start(Duration remaining) {
    if (_isRunning) {
      return;
    }

    _timer = CountdownTimer(
      remaining,
      const Duration(milliseconds: 100),
    );
    _timerSubscription = _timer!.listen(
      _tick,
      onDone: _done,
    );
    state = TimerState(state.remaining, TimerStatus.running);

    Wakelock.enable();
  }

  void _stop(bool isStopped) {
    if (!_isRunning) {
      return;
    }

    _preemptiveInterruptionStatus =
        isStopped ? TimerStatus.stopped : TimerStatus.paused;

    // Cancelling will cause the subscription's 'onDone' handler to be invoked.
    final timer = _timer!..cancel();
    _elapsedSinceBeginning += timer.elapsed;
  }

  void _tick(CountdownTimer timer) {
    state = TimerState(
      timer.remaining < Duration.zero ? Duration.zero : timer.remaining,
      TimerStatus.running,
    );
  }

  void _done() {
    Wakelock.disable();

    _timerSubscription?.cancel();
    _timerSubscription = null;
    _timer = null;

    state = TimerState(
      state.remaining,
      _preemptiveInterruptionStatus ?? TimerStatus.completed,
    );
    _preemptiveInterruptionStatus = null;

    if (state.status == TimerStatus.completed) {
      _elapsedSinceBeginning = _interval;
      _onComplete();
    }
  }

  bool get _isRunning => _timer?.isRunning ?? false;
}

final timerNotifierProvider =
    StateNotifierProvider.autoDispose<TimerNotifier, TimerState>(
  (ref) {
    final interval = ref.watch(intervalConfigNotifierProvider).asDuration();
    final player = ref.watch(playerProvider);

    final timerNotifier = TimerNotifier(
      interval,
      player.playTimerAlarm,
    );
    ref.onDispose(timerNotifier.stop);

    return timerNotifier..start();
  },
);

/// Use this provider if only [TimerState.status] changes are of interest.
///
/// [timerNotifierProvider] provides the whole state which includes
/// [TimerState.remaining], meaning its updates are very frequent. Using
/// [timerStatusProvider] will result in fewer dependent `Provider` and
/// `Widget` rebuilds.
///
/// While it is possible to use [timerNotifierProvider] together with
/// [ProviderBase.select], requesting `status` only happens to be used pretty
/// often so it is implemented here to avoid duplication.
final timerStatusProvider = Provider.autoDispose<TimerStatus>(
  (ref) => ref.watch(
    timerNotifierProvider.select((timerState) => timerState.status),
  ),
);
