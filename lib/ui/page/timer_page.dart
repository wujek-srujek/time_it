import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/round_data.dart';
import '../../provider/timer.dart';
import '../../util/duration_x.dart';
import 'round_summary_page.dart';

class TimerPage extends StatelessWidget {
  const TimerPage();

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
        final timerStatus = watch(timerStatusProvider);
        final roundData = watch(roundDataNotifierProvider);

        final void Function()? onTap;
        if (timerStatus != TimerStatus.completed) {
          onTap = () => context
              .read(
                roundDataNotifierProvider.notifier,
              )
              .registerRound();
        } else if (roundData != null) {
          onTap = () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (context) => const RoundSummaryPage(),
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
        final timerState = watch(timerNotifierProvider);
        final timerStatus = timerState.status;

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        final Color durationColor;
        switch (timerStatus) {
          case TimerStatus.running:
            durationColor = colorScheme.primary;
            break;
          case TimerStatus.paused:
            durationColor = colorScheme.error;
            break;
          case TimerStatus.completed:
          case TimerStatus.stopped:
            durationColor = colorScheme.secondary;
        }

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: !timerStatus.isFinished
              ? () {
                  final timerNotifier = context.read(
                    timerNotifierProvider.notifier,
                  );

                  if (timerStatus == TimerStatus.running) {
                    timerNotifier.pause();
                  } else {
                    timerNotifier.resume();
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
        final timerStatus = watch(timerStatusProvider);

        return FloatingActionButton(
          backgroundColor: timerStatus == TimerStatus.completed
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
