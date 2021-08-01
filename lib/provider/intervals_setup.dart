import 'package:riverpod/riverpod.dart';

import 'interval_definition.dart';

export 'interval_definition.dart';

class IntervalsSetupNotifier extends StateNotifier<List<IntervalDefinition>> {
  IntervalsSetupNotifier() : super(const []);

  void addInterval(IntervalDefinition interval) {
    state = [
      ...state,
      interval,
    ];
  }

  void reset() {
    state = [];
  }

  void removeInterval(int index) {
    state = [
      ...state..removeAt(index),
    ];
  }

  void moveInterval({
    required int oldIndex,
    required int newIndex,
  }) {
    final newIntervals = [...state];
    final movedInterval = newIntervals.removeAt(oldIndex);
    final insertionIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    newIntervals.insert(insertionIndex, movedInterval);
    state = newIntervals;
  }
}

final intervalsSetupNotifierProvider = StateNotifierProvider.autoDispose<
    IntervalsSetupNotifier, List<IntervalDefinition>>(
  (ref) => IntervalsSetupNotifier(),
);
