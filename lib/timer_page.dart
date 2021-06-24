import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiver/async.dart';
import 'package:wakelock/wakelock.dart';

import 'duration_x.dart';
import 'round_data.dart';
import 'round_duration_formatter.dart';
import 'round_summary_page.dart';

class TimerPage extends StatefulWidget {
  final Duration interval;

  const TimerPage({required this.interval});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  late final _TimerNotifier _timerNotifier;
  late final _RoundDataNotifier _roundDataNotifier;

  @override
  void initState() {
    super.initState();

    _timerNotifier = context.read(
      _timerNotifierProvider(widget.interval).notifier,
    )..start();

    _roundDataNotifier = context.read(
      _roundDataNotifierProvider.notifier,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _roundsWidget(),
              ),
              Expanded(
                child: _countdownWidget(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _backButton(),
    );
  }

  Widget _roundsWidget() {
    return Consumer(
      builder: (context, watch, child) {
        final timerStatus = watch(
          _timerNotifierProvider(widget.interval),
        ).status;

        final roundData = watch(_roundDataNotifierProvider);

        final void Function()? onTap;
        if (timerStatus != _TimerStatus.completed) {
          onTap = () => _roundDataNotifier.registerRound(
                _timerNotifier.elapsed,
              );
        } else if (roundData != null) {
          onTap = () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (context) {
                    return RoundSummaryPage(roundData: roundData);
                  },
                ),
              );
        } else {
          onTap = null;
        }

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: FittedBox(
                  child: Text(
                    roundData != null
                        ? formatRoundDuration(roundData.lastRoundDuration)
                        : '--',
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      fontFeatures: [
                        const FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: FittedBox(
                  child: Text(
                    roundData != null
                        ? '${roundData.roundDurations.length}'
                        : '0',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _countdownWidget() {
    return Consumer(
      builder: (context, watch, child) {
        final timerState = watch(
          _timerNotifierProvider(widget.interval),
        );
        final timerStatus = timerState.status;

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        final Color durationColor;
        switch (timerStatus) {
          case _TimerStatus.running:
            durationColor = colorScheme.primary;
            break;
          case _TimerStatus.paused:
            durationColor = colorScheme.error;
            break;
          case _TimerStatus.completed:
          case _TimerStatus.stopped:
            durationColor = colorScheme.secondary;
        }

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: !timerStatus.isFinished
              ? () {
                  if (timerStatus == _TimerStatus.running) {
                    _timerNotifier.pause();
                  } else {
                    _timerNotifier.resume();
                  }
                }
              : null,
          child: FittedBox(
            child: Text(
              _formatRemaining(timerState.remaining),
              textAlign: TextAlign.center,
              style: theme.textTheme.headline2!.copyWith(
                color: durationColor,
                fontFeatures: [
                  const FontFeature.tabularFigures(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _backButton() {
    return Consumer(
      builder: (context, watch, child) {
        final timerStatus = watch(
          _timerNotifierProvider(widget.interval),
        ).status;

        return FloatingActionButton(
          backgroundColor: timerStatus == _TimerStatus.completed
              ? null
              : Theme.of(context).colorScheme.error,
          onPressed: () {
            Navigator.of(context).pop();
          },
          mini: true,
          child: Icon(
            timerStatus.isFinished
                ? Icons.arrow_back_ios_rounded
                : Icons.stop_rounded,
          ),
        );
      },
    );
  }
}

String _formatRemaining(Duration duration) {
  final unpacked = duration.unpack();

  final sb = StringBuffer();

  if (unpacked.hours > 0) {
    // If 'hours' comes first, no '0' padding needed.
    sb..write(unpacked.hours.toString())..write(':');
  }

  if (unpacked.hours > 0 || unpacked.minutes > 0) {
    // Even if 'minutes' is 0 but hours' exists, 'minutes' must be added.
    // If 'minutes' comes first, no '0' padding needed; if 'hours' comes
    // before, '0' padding needed.
    var minutesString = unpacked.minutes.toString();
    if (unpacked.hours > 0) {
      minutesString = minutesString.padLeft(2, '0');
    }
    sb..write(minutesString)..write(':');
  }

  // 'seconds' is added unconditionally, even if 0.
  final String b;
  if (unpacked.hours == 0 && unpacked.minutes == 0 && unpacked.seconds < 10) {
    // If only total < 10 'seconds' remain, fraction second with 1 decimal place
    // is added. Any digits after the first decimal point are truncated.
    final secondsWithFirstDecimal = (unpacked.seconds * 10).toInt() / 10;
    b = secondsWithFirstDecimal.toStringAsFixed(1);
  } else {
    // In all other cases only whole seconds are used (fractions truncated).
    b = unpacked.seconds.toInt().toString().padLeft(2, '0');
  }
  sb.write(b);

  return sb.toString();
}

enum _TimerStatus {
  running,
  paused,
  // Stopped preemptively by the user.
  stopped,
  // Stopped naturally, i.e. it run to the end.
  completed,
}

extension _TimerStatusX on _TimerStatus {
  bool get isFinished =>
      this == _TimerStatus.stopped || this == _TimerStatus.completed;
}

@immutable
class _TimerState {
  final Duration remaining;
  final _TimerStatus status;

  const _TimerState(
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
class _TimerNotifier extends StateNotifier<_TimerState> {
  final Duration interval;

  CountdownTimer? _timer;
  StreamSubscription<CountdownTimer>? _timerSubscription;
  // When set, means the timer has been interrupted preemptively. When unset, it
  // means the timer is running of has completed naturally.
  _TimerStatus? _preemptiveInterruptionStatus;

  // When a timer is paused and resumed, in reality a new timer is created and
  // started, so the 'elapsed' of the previous one would be lost. To fix this,
  // it is updated here and taken into account.
  Duration _elapsedSinceBeginning;

  _TimerNotifier(this.interval)
      : _elapsedSinceBeginning = Duration.zero,
        super(_TimerState(interval, _TimerStatus.paused));

  void start() => _start(interval);

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
    state = _TimerState(state.remaining, _TimerStatus.running);

    Wakelock.enable();
  }

  void _stop(bool isStopped) {
    if (!_isRunning) {
      return;
    }

    _preemptiveInterruptionStatus =
        isStopped ? _TimerStatus.stopped : _TimerStatus.paused;

    // Cancelling will cause the subscription's 'onDone' handler to be invoked.
    final timer = _timer!..cancel();
    _elapsedSinceBeginning += timer.elapsed;
  }

  void _tick(CountdownTimer timer) {
    state = _TimerState(
      timer.remaining < Duration.zero ? Duration.zero : timer.remaining,
      _TimerStatus.running,
    );
  }

  void _done() {
    Wakelock.disable();

    _timerSubscription?.cancel();
    _timerSubscription = null;
    _timer = null;

    state = _TimerState(
      state.remaining,
      _preemptiveInterruptionStatus ?? _TimerStatus.completed,
    );
    _preemptiveInterruptionStatus = null;

    if (state.status == _TimerStatus.completed) {
      _elapsedSinceBeginning = interval;
    }
  }

  bool get _isRunning => _timer?.isRunning ?? false;
}

final _timerNotifierProvider = StateNotifierProvider.autoDispose
    .family<_TimerNotifier, _TimerState, Duration>(
  (ref, interval) {
    final timerNotifier = _TimerNotifier(interval);
    ref.onDispose(timerNotifier.stop);

    return timerNotifier;
  },
);

class _RoundDataNotifier extends StateNotifier<RoundData?> {
  final List<Duration> _roundDurations;

  Duration _previousElapsed;

  int? _slowestRoundIndex;
  int? _fastestRoundIndex;

  _RoundDataNotifier()
      : _roundDurations = [],
        _previousElapsed = Duration.zero,
        super(null);

  void registerRound(Duration elapsed) {
    final roundDuration = elapsed - _previousElapsed;

    if (_slowestRoundIndex == null ||
        _roundDurations[_slowestRoundIndex!] < roundDuration) {
      _slowestRoundIndex = _roundDurations.length;
    }
    if (_fastestRoundIndex == null ||
        _roundDurations[_fastestRoundIndex!] > roundDuration) {
      _fastestRoundIndex = _roundDurations.length;
    }

    _roundDurations.add(roundDuration);

    _previousElapsed = elapsed;

    state = RoundData(
      roundDurations: UnmodifiableListView(_roundDurations),
      slowestRoundIndex: _slowestRoundIndex!,
      fastestRoundIndex: _fastestRoundIndex!,
      averageRoundDuration: elapsed ~/ _roundDurations.length,
    );
  }
}

final _roundDataNotifierProvider =
    StateNotifierProvider.autoDispose<_RoundDataNotifier, RoundData?>(
  (ref) => _RoundDataNotifier(),
);
