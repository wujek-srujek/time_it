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
  final Duration interval;

  /// Elapsed time.
  ///
  /// Due to how the underlying platform timer works it can be slightly bigger
  /// than [interval].
  final Duration elapsed;
  final TimerStatus status;

  const TimerState._({
    required this.interval,
    required this.elapsed,
    required this.status,
  });

  const TimerState.initial(Duration interval)
      : this._(
          interval: interval,
          elapsed: Duration.zero,
          status: TimerStatus.paused,
        );

  /// Remaining time.
  ///
  /// It is computed by subtracting [elapsed] from [interval]. Due to this, it
  /// can be negative.
  Duration get remaining => interval - elapsed;

  TimerState _elapse(Duration duration, TimerStatus newStatus) {
    return TimerState._(
      interval: interval,
      elapsed: elapsed + duration,
      status: newStatus,
    );
  }
}

// Wakelock integration: the OS must not lock the screen as long as there is a
// running timer. The wakelock is again disabled in the following scenarios:
// - The running timer finishes, even if the user stays on this page (all
//   activity is done so there is no point in preventing screen lock).
// - The user leaves this page and there is a running timer. (If there is no
//   running timer, the previous scenario will have taken care of the wakelock.)
class TimerNotifier extends StateNotifier<TimerState> {
  static const _defaultRefreshInterval = Duration(milliseconds: 100);

  final void Function() _onComplete;

  CountdownTimer? _timer;
  StreamSubscription<CountdownTimer>? _timerSubscription;

  // When set, means the timer has been interrupted preemptively. When unset,
  // the timer is still running of has completed naturally.
  TimerStatus? _preemptiveInterruptionStatus;

  // Used to calculate elapsed time between ticks. Calling
  // [CountdownTimer.remaining] immediately after [CountdownTimer.elapsed] would
  // still introduce a tiny discrepancy (`elapsed` + `remaining` < `interval` by
  // a tiny bit) due to time flowing between these two calls. Using this field
  // we calculate the increment since the last tick and use it to consistently
  // calculate [TimerState.elapsed] and [TimerState.remaining].
  Duration _previousElapsed;

  TimerNotifier(Duration interval, this._onComplete)
      : _previousElapsed = Duration.zero,
        super(TimerState.initial(interval));

  void start() => _start(state.interval);

  void stop() => _stop(true);

  // There is no concept of 'pausing' in CountdownTimer. We just stop it here,
  // and resume will start a new one with an interval being the current state.
  void pause() => _stop(false);

  void resume() => _start(state.remaining);

  /// Returns the current accurate elapsed time.
  ///
  /// [state] updates happen at 'ticks' at more or less fixed intervals and
  /// can't report times in between. This is often good enough and should be
  /// used for most cases, like UI updates with elapsed information; sometimes,
  /// however, it is necessary to get the accurate elapsed time even between
  /// 'ticks', which this method allows.
  ///
  /// Calling this method doesn't influence the state in any way.
  Duration accurateElapsed() {
    final currentElapsed = _timer?.elapsed ?? Duration.zero;
    final elapsedSinceLastUpdate = currentElapsed - _previousElapsed;

    return state.elapsed + elapsedSinceLastUpdate;
  }

  void _start(Duration remaining) {
    if (_isRunning) {
      return;
    }

    if (remaining < Duration.zero) {
      // Pausing and resuming like mad can cause 'remaining' to be negative,
      // so fix this.
      remaining = Duration.zero;
    }

    // The refresh interval will equal 'remaining' if it's low enough.
    final refreshInterval = remaining > _defaultRefreshInterval
        ? _defaultRefreshInterval
        : remaining;
    _timer = CountdownTimer(remaining, refreshInterval);

    _updateState(TimerStatus.running);

    _timerSubscription = _timer!.listen(
      _tick,
      onDone: _done,
    );

    Wakelock.enable();
  }

  void _stop(bool isStopped) {
    if (!_isRunning) {
      return;
    }

    _preemptiveInterruptionStatus =
        isStopped ? TimerStatus.stopped : TimerStatus.paused;

    // Cancelling will cause the subscription's 'onDone' handler to be invoked.
    _timer!.cancel();
  }

  void _tick(CountdownTimer _) {
    _updateState(TimerStatus.running);
  }

  void _done() {
    _updateState(_preemptiveInterruptionStatus ?? TimerStatus.completed);

    _timerSubscription?.cancel();

    _timer = null;
    _timerSubscription = null;
    _preemptiveInterruptionStatus = null;

    _previousElapsed = Duration.zero;

    if (state.status == TimerStatus.completed) {
      _onComplete();
    }

    Wakelock.disable();
  }

  void _updateState(TimerStatus status) {
    final currentElapsed = _timer!.elapsed;
    final elapsedSinceLastUpdate = currentElapsed - _previousElapsed;

    state = state._elapse(elapsedSinceLastUpdate, status);
    _previousElapsed = currentElapsed;
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
