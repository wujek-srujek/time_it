import 'package:flutter/material.dart';

import '../provider/interval_group.dart';
import 'page/workout_page.dart';
import 'widget/mode/countdown_timer_widget.dart';
import 'widget/mode/intervals_widget.dart';
import 'widget/mode/menu_items.dart';
import 'widget/mode/rounds_widget.dart';
import 'widget/mode/stopwatch_widget.dart';

Future<void> launchAmrap(
  BuildContext context,
  IntervalDefinition intervalDefinition,
) {
  return _launchWorkout(
    context,
    WorkoutPage(
      intervalGroups: [IntervalGroup.single(intervalDefinition)],
      topWidget: const RoundsWidget(),
      bottomWidget: const CountdownTimerWidget(),
      menuItems: const [
        RestartMenuButton(),
        RoundSummaryMenuButton(),
      ],
    ),
  );
}

Future<void> launchStopwatch(BuildContext context) {
  return _launchWorkout(
    context,
    const WorkoutPage(
      intervalGroups: [],
      topWidget: RoundsWidget(),
      bottomWidget: StopwatchWidget(),
      menuItems: [
        RestartMenuButton(),
        RoundSummaryMenuButton(),
      ],
    ),
  );
}

Future<void> launchIntervals(
  BuildContext context,
  List<IntervalGroup> intervalGroups,
) {
  return _launchWorkout(
    context,
    WorkoutPage(
      intervalGroups: intervalGroups,
      topWidget: const IntervalsWidget(),
      bottomWidget: const CountdownTimerWidget(),
      menuItems: const [
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
