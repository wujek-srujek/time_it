import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import '../util/ticker.dart';
import 'interval_group.dart';
import 'keep_awake.dart';
import 'player.dart';
import 'workout_intervals.dart';

enum TimerStatus {
  running,
  stopped,
  completed,
}

@immutable
class IntervalInfo {
  final Duration interval;
  final int ordinal;
  final int totalCount;

  const IntervalInfo({
    required this.interval,
    required this.ordinal,
    required this.totalCount,
  })  : assert(ordinal >= 1),
        assert(totalCount >= 1),
        assert(ordinal <= totalCount);
}

@immutable
class TimerState {
  final IntervalInfo? intervalInfo;
  final Duration elapsed;
  final TimerStatus status;

  const TimerState._({
    required this.intervalInfo,
    required this.elapsed,
    required this.status,
  });

  /// Remaining time.
  ///
  /// It is computed by subtracting [elapsed] from [IntervalInfo.interval] of
  /// [intervalInfo].
  ///
  /// If [intervalInfo] is not specified, this will return `null`.
  Duration? get remaining =>
      intervalInfo != null ? intervalInfo!.interval - elapsed : null;
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
class TimerNotifier extends AutoDisposeNotifier<TimerState> {
  static const _defaultRefreshInterval = Duration(milliseconds: 100);

  late Iterable<IntervalInfo> _intervalInfos;
  late Iterator<IntervalInfo> _iterator;

  late _TimerDelegate _delegate;

  late Ticker _ticker;
  late StreamSubscription<Ticker> _tickerSubscription;

  TimerNotifier._();

  @override
  TimerState build() {
    ref.onDispose(() {
      unawaited(_tearDown());

      if (!_ticker.isDisposed) {
        final wasRunning = _ticker.isRunning;

        _ticker.dispose();

        if (wasRunning) {
          _delegate.onStop();
        }
      }
    });

    _intervalInfos = IntervalInfoIterable(ref.watch(workoutIntervalsProvider));
    _iterator = _intervalInfos.iterator;

    final keepAwake = ref.read(keepAwakeProvider);
    final player = ref.read(playerProvider);

    _delegate = _TimerDelegate(
      onStart: keepAwake.enable,
      onStop: keepAwake.disable,
      onIntervalComplete: player.playIntervalCompleted,
      onComplete: player.playWorkoutCompleted,
    );

    final intervalInfo = _iterator.nextOrNull;
    _setUp(intervalInfo?.interval);

    return TimerState._(
      intervalInfo: intervalInfo,
      elapsed: Duration.zero,
      status: TimerStatus.stopped,
    );
  }

  void start() {
    _start();

    _delegate.onStart();
  }

  void stop() {
    _stop();

    _delegate.onStop();
  }

  void restart() {
    unawaited(_tearDown());

    _iterator = _intervalInfos.iterator;

    final intervalInfo = _iterator.nextOrNull;
    state = TimerState._(
      intervalInfo: intervalInfo,
      elapsed: Duration.zero,
      status: TimerStatus.running,
    );

    _setUp(intervalInfo?.interval);

    start();
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

  void _setUp(Duration? limit) {
    _ticker = Ticker(limit: limit);
    _tickerSubscription = _ticker.stream.listen(
      _tick,
      onDone: _done,
    );
  }

  Future<void> _tearDown() {
    return _tickerSubscription.cancel();
  }

  void _start() {
    _ticker.start(refreshInterval: _chooseRefreshInterval(_ticker.remaining));
    _updateState(TimerStatus.running);
  }

  void _stop() {
    _ticker.stop();
    _updateState(TimerStatus.stopped);
  }

  void _tick(Ticker _) {
    _updateState(TimerStatus.running);
  }

  void _done() {
    // Depending on what the engine says, the timer either completes or goes on
    // to process the next interval.

    final movedNext = _iterator.moveNext();
    if (movedNext) {
      _delegate.onIntervalComplete();

      unawaited(_tearDown());

      final intervalInfo = _iterator.current;
      state = TimerState._(
        intervalInfo: intervalInfo,
        elapsed: Duration.zero,
        status: TimerStatus.running,
      );
      _setUp(intervalInfo.interval);

      _start();
    } else {
      _delegate.onStop();
      _delegate.onComplete();

      _updateState(TimerStatus.completed);
    }
  }

  void _updateState(TimerStatus status) {
    var elapsed = _ticker.elapsed;

    // Due to how the underlying platform timer works, 'elapsed' can be greater
    // than 'intervalInfo.interval' but we don't want to deal with it so fix it.
    if (state.intervalInfo != null && elapsed > state.intervalInfo!.interval) {
      elapsed = state.intervalInfo!.interval;
    }

    state = TimerState._(
      intervalInfo: state.intervalInfo,
      elapsed: elapsed,
      status: status,
    );
  }

  Duration _chooseRefreshInterval(Duration? remaining) {
    if (remaining == null) {
      return _defaultRefreshInterval;
    }

    // Pausing and resuming like mad can cause 'remaining' to be negative due to
    // how the underlying platform timer works, so fix this.
    if (remaining <= Duration.zero) {
      return Duration.zero;
    }

    return remaining > _defaultRefreshInterval
        ? _defaultRefreshInterval
        : remaining;
  }
}

final timerNotifierProvider =
    NotifierProvider.autoDispose<TimerNotifier, TimerState>(
  TimerNotifier._,
);

class _TimerDelegate {
  final void Function() onStart;
  final void Function() onStop;
  final void Function() onIntervalComplete;
  final void Function() onComplete;

  _TimerDelegate({
    required this.onStart,
    required this.onStop,
    required this.onIntervalComplete,
    required this.onComplete,
  });
}

extension _IteratorX<T> on Iterator<T> {
  T? get nextOrNull => moveNext() ? current : null;
}

@visibleForTesting
class IntervalInfoIterable extends Iterable<IntervalInfo> {
  final Iterable<IntervalGroup> _intervalGroups;
  final int _length;

  IntervalInfoIterable(this._intervalGroups)
      : _length = _intervalGroups.fold<int>(
          0,
          (accumulator, group) => accumulator + group.intervalCount,
        );

  @override
  int get length => _length;

  @override
  Iterator<IntervalInfo> get iterator => _inflated.iterator;

  Iterable<IntervalInfo> get _inflated sync* {
    var ordinal = 0;
    for (final group in _intervalGroups) {
      for (var g = 1; g <= group.repetitions; ++g) {
        for (final intervalDefinition in group.intervalDefinitions) {
          final interval = intervalDefinition.toDuration();
          for (var i = 1; i <= intervalDefinition.repetitions; ++i) {
            yield IntervalInfo(
              interval: interval,
              ordinal: ++ordinal,
              totalCount: length,
            );
          }
        }
      }
    }
  }
}
