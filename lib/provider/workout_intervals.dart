import 'package:riverpod/riverpod.dart';

import 'interval_group.dart';

export 'interval_definition.dart';

// This provider is essentially a storage where mode preparation logic saves the
// configured intervals which are later read by the workout logic. This is done
// so that the latter has only one place to get its data from and not have to
// expose any kind of setter which mode preparation would have to call. If any
// workaout was started, it will use the latest interval group configuration, if
// any (for example, stopwatch has not intervals).
final workoutIntervalsProvider = StateProvider<List<IntervalGroup>>(
  (ref) => const [],
);
