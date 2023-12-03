import 'package:riverpod/riverpod.dart';

import 'interval_group.dart';

export 'interval_definition.dart';

// This notifier is essentially storage where mode preparation logic saves the
// configured intervals which are later read by the workout logic. This is done
// so that the latter has only one place to get its data from and not have to
// expose any kind of setter which mode preparation would have to call. If any
// workout was started, it will use the latest interval group configuration, if
// any (for example, stopwatch has no intervals).
// Its provider is not automatically disposed.
class WorkoutIntervalsNotifier extends Notifier<List<IntervalGroup>> {
  WorkoutIntervalsNotifier._();

  @override
  List<IntervalGroup> build() => [];

  @override
  set state(List<IntervalGroup> newState) => super.state = newState;
}

final workoutIntervalsProvider =
    NotifierProvider<WorkoutIntervalsNotifier, List<IntervalGroup>>(
  WorkoutIntervalsNotifier._,
);
