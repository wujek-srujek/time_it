import 'package:flutter/material.dart';

import '../../../provider/timer.dart';
import '../../../util/duration_formatter.dart';
import 'timer_widget.dart';

class CountdownTimerWidget extends StatelessWidget {
  const CountdownTimerWidget();

  @override
  Widget build(BuildContext context) => const TimerWidget(
        timerStateFormatter: _formatRemainingDuration,
      );
}

const _tenSeconds = Duration(seconds: 10);

String _formatRemainingDuration(TimerState timerState) {
  final remainingDuration = timerState.remaining!;
  if (remainingDuration > _tenSeconds) {
    return formatDuration(
      remainingDuration,
      forceComponent: TimeComponent.second,
      forceComponentPadding: TimeComponent.second,
    );
  }

  return formatDuration(
    remainingDuration,
    forceComponent: TimeComponent.second,
    decimalPlaces: 1,
  );
}
