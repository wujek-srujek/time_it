import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/interval_group.dart';
import '../provider/workout_intervals.dart';
import 'page/workout_page.dart';
import 'widget/mode/countdown_timer_widget.dart';
import 'widget/mode/intervals_widget.dart';
import 'widget/mode/menu_items.dart';
import 'widget/mode/rounds_widget.dart';
import 'widget/mode/stopwatch_widget.dart';

Future<void> launchAmrap(
  WidgetRef ref,
  IntervalDefinition intervalDefinition,
) {
  return _launchWorkout(
    ref,
    [IntervalGroup.single(intervalDefinition)],
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

Future<void> launchStopwatch(WidgetRef ref) {
  return _launchWorkout(
    ref,
    [],
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

Future<void> launchIntervals(
  WidgetRef ref,
  List<IntervalGroup> intervalGroups,
) {
  return _launchWorkout(
    ref,
    intervalGroups,
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
  WidgetRef ref,
  List<IntervalGroup> intervalGroups,
  WorkoutPage workoutPage,
) {
  ref.read(workoutIntervalsProvider.notifier).state = intervalGroups;

  return Navigator.of(ref.context).push(
    MaterialPageRoute<void>(
      builder: (context) => workoutPage,
    ),
  );
}
