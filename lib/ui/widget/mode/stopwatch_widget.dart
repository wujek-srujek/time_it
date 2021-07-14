import 'package:flutter/material.dart';

import '../../../provider/timer.dart';
import '../../../util/duration_formatter.dart';
import 'timer_widget.dart';

class StopwatchWidget extends StatelessWidget {
  const StopwatchWidget();

  @override
  Widget build(BuildContext context) => const TimerWidget(
        timerStateFormatter: _formatElapsedDuration,
      );
}

String _formatElapsedDuration(TimerState timerState) {
  final elapsedDuration = timerState.elapsed;
  return formatDuration(
    elapsedDuration,
    forceComponent: TimeComponent.minute,
    forceComponentPadding: TimeComponent.minute,
  );
}
