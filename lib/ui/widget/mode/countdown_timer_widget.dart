import 'package:flutter/material.dart';

import '../../../provider/timer.dart';
import '../../../util/duration_formatter.dart';
import 'timer_widget.dart';

class CountdownTimerWidget extends StatelessWidget {
  const CountdownTimerWidget();

  @override
  Widget build(BuildContext context) => const TimerWidget(
        timerOperations: _TimerOperations(),
      );
}

// When the remaining time is this or below, the UI switches to sub-second
// rebuilds.
const _subSecondThreshold = Duration(seconds: 10);

class _TimerOperations implements TimerOperations {
  const _TimerOperations();

  @override
  Duration extractDuration(TimerState state) => state.remaining!;

  // Cause rebuilds only when second changes, but switch to 10 rebuilds per
  // second if there are _subSecondThreshold or less seconds left.
  @override
  Object selectRebuildKey(Duration duration) {
    if (duration > _subSecondThreshold) {
      return duration.inSeconds;
    }

    // We know the timer fires ~10x per second, which corresponds to what we
    // want to show, so there is no need for extra maths. If the timer changes
    // to fire more often, we will need to e.g. duration.inMilliseconds ~/ 100.
    return duration.inMicroseconds;
  }

  // Format to show full seconds only, but switch to tenths of seconds if there
  // are _subSecondThreshold or less seconds left.
  @override
  String format(Duration duration) {
    if (duration > _subSecondThreshold) {
      return formatDuration(
        duration,
        forceComponent: TimeComponent.second,
        forceComponentPadding: TimeComponent.second,
      );
    }

    return formatDuration(
      duration,
      forceComponent: TimeComponent.second,
      decimalPlaces: 1,
    );
  }
}
