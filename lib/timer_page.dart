import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiver/async.dart';

class TimerPage extends StatefulWidget {
  final Duration interval;

  const TimerPage({required this.interval});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  @override
  void initState() {
    super.initState();

    context.read(_timerNotifierProvider(widget.interval).notifier).start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Consumer(
            builder: (context, watch, child) {
              final remaining = watch(
                _timerNotifierProvider(widget.interval),
              );

              return Text(
                _formatDuration(remaining),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline2!.copyWith(
                  fontFeatures: [
                    const FontFeature.tabularFigures(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.error,
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.stop_rounded),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inMilliseconds.remainder(60000) / 1000;

  final sb = StringBuffer();

  if (hours > 0) {
    // If 'hours' comes first, no '0' padding needed.
    sb..write(hours.toString())..write(':');
  }

  if (hours > 0 || minutes > 0) {
    // Even if 'minutes' is 0 but hours' exists, 'minutes' must be added.
    // If 'minutes' comes first, no '0' padding needed; if 'hours' comes
    // before, '0' padding needed.
    var minutesString = minutes.toString();
    if (hours > 0) {
      minutesString = minutesString.padLeft(2, '0');
    }
    sb..write(minutesString)..write(':');
  }

  // 'seconds' is added unconditionally, even if 0.
  final String b;
  if (hours == 0 && minutes == 0 && seconds < 10) {
    // If only total < 10 'seconds' remain, fraction second with 1 decimal place
    // is added. Any digits after the first decimal point are truncated.
    final secondsWithFirstDecimal = (seconds * 10).toInt() / 10;
    b = secondsWithFirstDecimal.toStringAsFixed(1);
  } else {
    // In all other cases only whole seconds are used (fractions truncated).
    b = seconds.toInt().toString().padLeft(2, '0');
  }
  sb.write(b);

  return sb.toString();
}

class _TimerNotifier extends StateNotifier<Duration> {
  final Duration interval;

  late final CountdownTimer _timer;
  late final StreamSubscription<CountdownTimer> _timerSubscription;

  _TimerNotifier(this.interval) : super(interval);

  void start() {
    _timer = CountdownTimer(
      interval,
      const Duration(milliseconds: 100),
    );
    _timerSubscription = _timer.listen(
      (timer) => state = timer.remaining,
      onDone: _cleanUp,
    );
  }

  void stop() {
    if (_timer.isRunning) {
      _timer.cancel();
    }
  }

  void _cleanUp() {
    _timerSubscription.cancel();
  }
}

final _timerNotifierProvider = StateNotifierProvider.autoDispose
    .family<_TimerNotifier, Duration, Duration>(
  (ref, interval) {
    final timerNotifier = _TimerNotifier(interval);
    ref.onDispose(timerNotifier.stop);

    return timerNotifier;
  },
);
