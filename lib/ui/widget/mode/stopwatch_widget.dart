import 'package:flutter/material.dart';

import '../../../provider/timer.dart';
import '../../../util/duration_formatter.dart';
import 'timer_widget.dart';

class StopwatchWidget extends StatelessWidget {
  const StopwatchWidget();

  @override
  Widget build(BuildContext context) => const TimerWidget(
        timerOperations: _TimerOperations(),
      );
}

class _TimerOperations implements TimerOperations {
  const _TimerOperations();

  @override
  Duration extractDuration(TimerState state) => state.elapsed;

  // Cause rebuilds only when second changes.
  @override
  Object selectRebuildKey(Duration duration) => duration.inSeconds;

  @override
  String format(Duration duration) => formatDuration(
        duration,
        forceComponent: TimeComponent.minute,
        forceComponentPadding: TimeComponent.minute,
      );
}
