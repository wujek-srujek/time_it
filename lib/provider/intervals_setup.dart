import 'package:riverpod/riverpod.dart';

import 'interval_definition.dart';
import 'intervals_sequence.dart';

export 'interval_definition.dart';
export 'intervals_sequence.dart';

class IntervalsSetupNotifier extends StateNotifier<IntervalsSequence> {
  IntervalsSetupNotifier() : super(const IntervalsSequence());

  void add(IntervalDefinition intervalDefinition) {
    state = state.copyWith(
      newIntervalDefinitions: [
        ...state.intervalDefinitions,
        intervalDefinition,
      ],
    );
  }

  void remove(int index) {
    state = state.copyWith(
      newIntervalDefinitions: [
        ...state.intervalDefinitions..removeAt(index),
      ],
    );
  }

  void move({
    required int oldIndex,
    required int newIndex,
  }) {
    final newIntervalDefinitions = [...state.intervalDefinitions];
    final movedIntervalDefinition = newIntervalDefinitions.removeAt(oldIndex);
    final insertionIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    newIntervalDefinitions.insert(insertionIndex, movedIntervalDefinition);

    state = state.copyWith(
      newIntervalDefinitions: newIntervalDefinitions,
    );
  }

  void update({
    required int index,
    required IntervalDefinition intervalDefinition,
  }) {
    final newIntervalDefinitions = [...state.intervalDefinitions];
    newIntervalDefinitions[index] = intervalDefinition;

    state = state.copyWith(
      newIntervalDefinitions: newIntervalDefinitions,
    );
  }

  void repeat(int repetitions) {
    state = state.copyWith(
      newRepetitions: repetitions,
    );
  }

  void reset() {
    state = const IntervalsSequence();
  }
}

final intervalsSetupNotifierProvider = StateNotifierProvider.autoDispose<
    IntervalsSetupNotifier, IntervalsSequence>(
  (ref) => IntervalsSetupNotifier(),
);
