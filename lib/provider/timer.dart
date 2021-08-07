import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import '../util/ticker.dart';
import 'intervals_setup.dart';
import 'keep_awake.dart';
import 'player.dart';

enum TimerStatus {
  running,
  stopped,
  completed,
}

class IntervalInfo {
  final Duration interval;
  final int ordinal;
  final int totalCount;

  IntervalInfo({
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
class TimerNotifier extends StateNotifier<TimerState> {
  static const _defaultRefreshInterval = Duration(milliseconds: 100);

  final _IntervalsEngine _engine;
  final _TimerDelegate _delegate;

  late Ticker _ticker;
  late StreamSubscription<Ticker> _tickerSubscription;

  TimerNotifier(this._engine, this._delegate)
      : super(TimerState._(
          intervalInfo: _engine.next,
          elapsed: Duration.zero,
          status: TimerStatus.stopped,
        )) {
    _setUp();
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
    _tearDown();

    _engine.reset();
    state = TimerState._(
      intervalInfo: _engine.next,
      elapsed: Duration.zero,
      status: TimerStatus.running,
    );

    _setUp();

    start();
  }

  @override
  void dispose() {
    _tearDown();

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

  void _setUp() {
    _ticker = Ticker(limit: state.intervalInfo?.interval);
    _tickerSubscription = _ticker.stream.listen(
      _tick,
      onDone: _done,
    );
  }

  void _tearDown() {
    _tickerSubscription.cancel();
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
    // Depending on that the engine says, the timer either completes or goes on
    // to process the next interval.

    final movedNext = _engine.moveNext();
    if (movedNext) {
      _delegate.onIntervalComplete();

      _tearDown();

      state = TimerState._(
        intervalInfo: _engine.current,
        elapsed: Duration.zero,
        status: TimerStatus.running,
      );

      _setUp();

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
    StateNotifierProvider.autoDispose<TimerNotifier, TimerState>(
  (ref) {
    final intervalsSequence = ref.watch(intervalsSetupNotifierProvider);
    final keepAwake = ref.watch(keepAwakeProvider);
    final player = ref.watch(playerProvider);

    return TimerNotifier(
      _IntervalsEngine(intervalsSequence.intervalDefinitions),
      _TimerDelegate(
        onStart: keepAwake.enable,
        onStop: keepAwake.disable,
        onIntervalComplete: player.playIntervalCompleted,
        onComplete: player.playWorkoutCompleted,
      ),
    )..start();
  },
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

class _IntervalsEngine implements Iterator<IntervalInfo> {
  final Iterable<IntervalDefinition> _intervalDefinitions;
  final int _totalCount;

  late Iterator<IntervalDefinition> _iterator;
  late int _currentRepetitionsRemaining;
  late int _ordinal;

  _IntervalsEngine(this._intervalDefinitions)
      : _totalCount = _intervalDefinitions.fold(
          0,
          (previousValue, element) => previousValue + element.repetitions,
        ) {
    reset();
  }

  @override
  bool moveNext() {
    if (_currentRepetitionsRemaining > 0) {
      --_currentRepetitionsRemaining;
      ++_ordinal;

      return true;
    }

    final movedNext = _iterator.moveNext();
    if (movedNext) {
      _currentRepetitionsRemaining = _iterator.current.repetitions - 1;
      ++_ordinal;
    }

    return movedNext;
  }

  @override
  IntervalInfo get current => IntervalInfo(
        interval: _iterator.current.toDuration(),
        ordinal: _ordinal,
        totalCount: _totalCount,
      );

  IntervalInfo? get next => moveNext() ? current : null;

  void reset() {
    _iterator = _intervalDefinitions.iterator;
    _currentRepetitionsRemaining = 0;
    _ordinal = 0;
  }
}
