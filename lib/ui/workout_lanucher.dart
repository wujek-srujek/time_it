import 'package:flutter/material.dart';

import 'page/workout_page.dart';
import 'widget/mode/countdown_timer_widget.dart';
import 'widget/mode/intervals_widget.dart';
import 'widget/mode/menu_items.dart';
import 'widget/mode/rounds_widget.dart';
import 'widget/mode/stopwatch_widget.dart';

void launchAmrap(BuildContext context) {
  _launchWorkout(
    context,
    const WorkoutPage(
      topWidget: RoundsWidget(),
      bottomWidget: CountdownTimerWidget(),
      menuItems: [
        RestartMenuButton(),
        RoundSummaryMenuButton(),
      ],
    ),
  );
}

void launchStopwatch(BuildContext context) {
  _launchWorkout(
    context,
    const WorkoutPage(
      topWidget: RoundsWidget(),
      bottomWidget: StopwatchWidget(),
      menuItems: [
        RestartMenuButton(),
        RoundSummaryMenuButton(),
      ],
    ),
  );
}

Future<void> launchIntervals(BuildContext context) {
  return _launchWorkout(
    context,
    const WorkoutPage(
      topWidget: IntervalsWidget(),
      bottomWidget: CountdownTimerWidget(),
      menuItems: [
        RestartMenuButton(),
      ],
    ),
  );
}

Future<void> _launchWorkout(
  BuildContext context,
  WorkoutPage workoutPage,
) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => workoutPage,
    ),
  );
}
