import 'package:riverpod/riverpod.dart';

import 'intervals_sequence.dart';

export 'interval_definition.dart';
export 'intervals_sequence.dart';

// This provider is essentially a buffer where mode preparation logic saves the
// configured intervals which are later read by the workout logic. This is done
// so that the latter has only one place to get its data from and not have to
// expose any kind of setter which mode preparation would have to call.
final workoutIntervalsProvider = StateProvider.autoDispose<IntervalsSequence>(
  (ref) => const IntervalsSequence(),
);
