import 'package:riverpod/riverpod.dart';

import 'interval_group.dart';

export 'interval_definition.dart';

// This provider is essentially a buffer where mode preparation logic saves the
// configured intervals which are later read by the workout logic. This is done
// so that the latter has only one place to get its data from and not have to
// expose any kind of setter which mode preparation would have to call.
final workoutIntervalsProvider = StateProvider.autoDispose<List<IntervalGroup>>(
  (ref) => const [],
);
