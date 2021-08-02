import 'package:riverpod/riverpod.dart';

import 'interval_definition.dart';

export 'interval_definition.dart';

class IntervalsSetupNotifier extends StateNotifier<List<IntervalDefinition>> {
  IntervalsSetupNotifier() : super(const []);

  void add(IntervalDefinition intervalDefinition) {
    state = [
      ...state,
      intervalDefinition,
    ];
  }

  void reset() {
    state = [];
  }

  void remove(int index) {
    state = [
      ...state..removeAt(index),
    ];
  }

  void move({
    required int oldIndex,
    required int newIndex,
  }) {
    final newIntervalDefinitions = [...state];
    final movedIntervalDefinition = newIntervalDefinitions.removeAt(oldIndex);
    final insertionIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    newIntervalDefinitions.insert(insertionIndex, movedIntervalDefinition);
    state = newIntervalDefinitions;
  }

  void update({
    required int index,
    required IntervalDefinition intervalDefinition,
  }) {
    final newIntervalDefinitions = [...state];
    newIntervalDefinitions[index] = intervalDefinition;
    state = newIntervalDefinitions;
  }
}

final intervalsSetupNotifierProvider = StateNotifierProvider.autoDispose<
    IntervalsSetupNotifier, List<IntervalDefinition>>(
  (ref) => IntervalsSetupNotifier(),
);
