import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../util/ticker.dart';
import 'interval_group.dart';
import 'keep_awake.dart';
import 'player.dart';
import 'workout_intervals.dart';

part 'timer.g.dart';

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
  final Ticker _ticker;
  final IntervalInfo? intervalInfo;
  final TimerStatus status;

  const TimerState._(
    this._ticker, {
    required this.intervalInfo,
    required this.status,
  });

  /// Current remaining time.
  ///
  /// If [intervalInfo] is not specified, this will return `null`. Otherwise, it
  /// is computed by subtracting [elapsed] from [IntervalInfo.interval] of
  /// [intervalInfo].
  ///
  /// Note: it uses the live timer behind the scenes so in the case when it does
  /// compute the value (`intervalInfo != null`), the result will most likely be
  /// different (smaller) each time this method is called. It might be necessary
  /// to call this method only once per frame to avoid weird behavior.
  Duration? remaining() {
    if (intervalInfo == null) {
      return null;
    }

    final remaining = intervalInfo!.interval - elapsed();

    // Due to how the underlying timer works, 'elapsed' can be slightly greater
    // than 'intervalInfo.interval', so fix it here.
    return remaining < Duration.zero ? Duration.zero : remaining;
  }

  /// Current elapsed time.
  ///
  /// Note: it uses the live timer behind the scenes so the result will most
  /// likely be different (greater) each time this method is called. It might be
  /// necessary to call this method only once per frame to avoid weird behavior.
  Duration elapsed() => _ticker.elapsed;
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
@riverpod
class TimerNotifier extends _$TimerNotifier {
  static const _defaultRefreshInterval = Duration(milliseconds: 100);

  late Iterable<IntervalInfo> _intervalInfos;
  late Iterator<IntervalInfo> _iterator;

  late _TimerDelegate _delegate;

  late Ticker _ticker;
  late StreamSubscription<Ticker> _tickerSubscription;

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

    _intervalInfos = IntervalInfoIterable(
      ref.watch(workoutIntervalsNotifierProvider),
    );
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
      _ticker,
      intervalInfo: intervalInfo,
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
      _ticker,
      intervalInfo: intervalInfo,
      status: TimerStatus.running,
    );

    _setUp(intervalInfo?.interval);

    start();
  }

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
        _ticker,
        intervalInfo: intervalInfo,
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
    state = TimerState._(
      _ticker,
      intervalInfo: state.intervalInfo,
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
