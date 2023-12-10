import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'interval_group.dart';

export 'interval_definition.dart';

part 'workout_intervals.g.dart';

// This notifier is essentially storage where mode preparation logic saves the
// configured intervals which are later read by the workout logic. This is done
// so that the latter has only one place to get its data from and not have to
// expose any kind of setter which mode preparation would have to call. If any
// workout was started, it will use the latest interval group configuration, if
// any (for example, stopwatch has no intervals).
// Its provider is not automatically disposed.
@Riverpod(keepAlive: true)
class WorkoutIntervalsNotifier extends _$WorkoutIntervalsNotifier {
  @override
  List<IntervalGroup> build() => [];

  @override
  set state(List<IntervalGroup> newState) => super.state = newState;
}
