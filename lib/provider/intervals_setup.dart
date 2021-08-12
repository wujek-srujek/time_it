import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import 'interval_definition.dart';
import 'interval_group.dart';

export 'interval_definition.dart';

@immutable
abstract class IntervalsSetupItem {
  int get repetitions;
}

class IntervalDefinitionItem extends IntervalsSetupItem {
  final IntervalDefinition intervalDefinition;

  IntervalDefinitionItem(this.intervalDefinition);

  @override
  int get repetitions => intervalDefinition.repetitions;
}

class IntervalsSetupNotifier extends StateNotifier<List<IntervalsSetupItem>> {
  IntervalsSetupNotifier() : super(const []);

  void add(IntervalsSetupItem item) {
    state = [
      ...state,
      item,
    ];
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
    required IntervalsSetupItem item,
  }) {
    final newIntervalDefinitions = [...state];
    newIntervalDefinitions[index] = item;

    state = newIntervalDefinitions;
  }

  void reset() {
    state = const [];
  }

  // For now all items are IntervalDefinitionItems (the UI doesn't know groups
  // yet) so wrap them in a single group. This will not be necessary once the UI
  // correctly supports groups and will be replaced by a method returning a list
  // of them.
  IntervalGroup intervalGroup(int repetitions) => IntervalGroup(
        intervalDefinitions: state
            .whereType<IntervalDefinitionItem>()
            .map((item) => item.intervalDefinition)
            .toList(),
        repetitions: repetitions,
      );
}

final intervalsSetupNotifierProvider = StateNotifierProvider.autoDispose<
    IntervalsSetupNotifier, List<IntervalsSetupItem>>(
  (ref) => IntervalsSetupNotifier(),
);
