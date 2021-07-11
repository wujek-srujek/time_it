import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import '../util/ticker.dart';
import 'interval_config.dart';
import 'keep_awake.dart';
import 'player.dart';

enum TimerStatus {
  running,
  stopped,
  completed,
}

@immutable
class TimerState {
  final Duration? interval;

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

  const TimerState.initial(Duration? interval)
      : this._(
          interval: interval,
          elapsed: Duration.zero,
          status: TimerStatus.stopped,
        );

  /// Remaining time.
  ///
  /// It is computed by subtracting [elapsed] from [interval]. Due to this, it
  /// can be negative.
  ///
  /// If [interval] is not specified, this will return `null`.
  Duration? get remaining => interval != null ? interval! - elapsed : null;

  TimerState _update(Duration elapsed, TimerStatus status) {
    return TimerState._(
      interval: interval,
      elapsed: elapsed,
      status: status,
    );
  }
}

class _TimerDelegate {
  final void Function() onStart;
  final void Function() onStop;
  final void Function() onComplete;

  _TimerDelegate({
    required this.onStart,
    required this.onStop,
    required this.onComplete,
  });
}

// Wakelock integration: the OS must not lock the screen as long as there is a
// running timer. The wakelock is again disabled in the following scenarios:
// - The running timer completes, even if the user stays on the page - the
//   workout is done.
// - The timer is stopped, even if the user stays on the page - the workout is
//   temporarily interrupted.
// - The user leaves this page in the middle of a workout - the workout is
//   cancelled.
// In all of the above cases, the user has terminated the workout in some way
// and can use the app normally to prevent locking.
class TimerNotifier extends StateNotifier<TimerState> {
  static const _defaultRefreshInterval = Duration(milliseconds: 100);

  final _TimerDelegate _delegate;

  final Ticker _ticker;
  late final StreamSubscription<Ticker> _tickerSubscription;

  TimerNotifier(Duration? interval, this._delegate)
      : _ticker = Ticker(limit: interval),
        super(TimerState.initial(interval)) {
    _tickerSubscription = _ticker.stream.listen(
      _tick,
      onDone: _done,
    );
  }

  void start() {
    _ticker.start(refreshInterval: _chooseRefreshInterval(_ticker.remaining));
    _updateState(TimerStatus.running);

    _delegate.onStart();
  }

  void stop() {
    _ticker.stop();
    _updateState(TimerStatus.stopped);

    _delegate.onStop();
  }

  @override
  void dispose() {
    _tickerSubscription.cancel();

    if (!_ticker.isDisposed) {
      final wasRunning = _ticker.isRunning;

      _ticker.dispose();

      if (wasRunning) {
        _delegate.onStop();
      }
    }

    super.dispose();
  }

  /// Returns the current accurate elapsed time.
  ///
  /// [state] updates happen at 'ticks' at more or less fixed intervals and
  /// can't report times in between. This is often good enough and should be
  /// used for most cases, like UI updates with elapsed information; sometimes,
  /// however, it is necessary to get the accurate elapsed time even between
  /// 'ticks', which this method allows.
  ///
  /// Calling this method doesn't influence the state in any way.
  Duration get accurateElapsed => _ticker.elapsed;

  void _tick(Ticker _) {
    _updateState(TimerStatus.running);
  }

  void _done() {
    _updateState(TimerStatus.completed);

    _delegate.onStop();
    _delegate.onComplete();
  }

  void _updateState(TimerStatus status) {
    state = state._update(_ticker.elapsed, status);
  }

  Duration _chooseRefreshInterval(Duration? remaining) {
    if (remaining == null) {
      return _defaultRefreshInterval;
    }

    // Pausing and resuming like mad can cause 'remaining' to be negative.
    if (remaining <= Duration.zero) {
      return Duration.zero;
    }

    return remaining > _defaultRefreshInterval
        ? _defaultRefreshInterval
        : remaining;
  }
}

final timerNotifierProvider =
    StateNotifierProvider.autoDispose<TimerNotifier, TimerState>(
  (ref) {
    final interval = ref.watch(intervalConfigNotifierProvider)?.asDuration();
    final keepAwake = ref.watch(keepAwakeProvider);
    final player = ref.watch(playerProvider);

    final timerNotifier = TimerNotifier(
      interval,
      _TimerDelegate(
        onStart: keepAwake.enable,
        onStop: keepAwake.disable,
        onComplete: player.playTimerAlarm,
      ),
    );

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
