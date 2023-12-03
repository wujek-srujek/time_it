import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import '../util/iterable_x.dart';
import 'interval_group.dart';

export 'interval_definition.dart';

@immutable
sealed class IntervalsSetupItem with EquatableMixin {
  int get repetitions;

  const IntervalsSetupItem();

  IntervalsSetupItem withRepetitions(int repetitions);
}

final class IntervalGroupItem extends IntervalsSetupItem {
  @override
  final int repetitions;

  const IntervalGroupItem({
    this.repetitions = 1,
  }) : assert(repetitions >= 1);

  @override
  IntervalGroupItem withRepetitions(int repetitions) =>
      IntervalGroupItem(repetitions: repetitions);

  @override
  List<Object?> get props => [repetitions];
}

final class IntervalDefinitionItem extends IntervalsSetupItem {
  final IntervalDefinition intervalDefinition;

  const IntervalDefinitionItem(this.intervalDefinition);

  @override
  int get repetitions => intervalDefinition.repetitions;

  @override
  IntervalDefinitionItem withRepetitions(int repetitions) =>
      IntervalDefinitionItem(
        intervalDefinition.copyWith(newRepetitions: repetitions),
      );

  @override
  List<Object?> get props => [repetitions, intervalDefinition];
}

@immutable
class GroupedIntervalsSetupItem with EquatableMixin {
  final IntervalsSetupItem item;
  final int group;
  final bool isFirst;
  final bool isLast;

  const GroupedIntervalsSetupItem(
    this.item, {
    required this.group,
    required this.isFirst,
    required this.isLast,
  });

  GroupedIntervalsSetupItem _copyWith({
    IntervalsSetupItem? newItem,
    int? newGroup,
    bool? newIsFirst,
    bool? newIsLast,
  }) {
    // If changing the item, it must be of the same type.
    assert(newItem == null || newItem.runtimeType == item.runtimeType);

    return GroupedIntervalsSetupItem(
      newItem ?? item,
      group: newGroup ?? group,
      isFirst: newIsFirst ?? isFirst,
      isLast: newIsLast ?? isLast,
    );
  }

  @override
  List<Object?> get props => [item, group, isFirst, isLast];
}

@immutable
class IntervalsSetup with EquatableMixin {
  final List<GroupedIntervalsSetupItem> groupedItems;
  final bool hasIntervals;

  IntervalsSetup(
    this.groupedItems, {
    required this.hasIntervals,
  }) :
        // Make a sanity consistency check in debug only, no need to incur the
        // performance penalty in release builds.
        assert(
          hasIntervals ==
              groupedItems.any(
                (groupedItem) => groupedItem.item is IntervalDefinitionItem,
              ),
        );

  IntervalsSetup.initial() : this(const [], hasIntervals: false);

  @override
  List<Object?> get props => [groupedItems, hasIntervals];

  List<IntervalGroup> toIntervalGroups() {
    final intervalGroups = <IntervalGroup>[];

    // Initialize with the 'virtual' group in there is no explicit one.
    var currentGroupItem = const IntervalGroupItem();
    var groupedIntervalDefinitions = <IntervalDefinition>[];

    void terminateIntervalGroup() {
      if (groupedIntervalDefinitions.isNotEmpty) {
        intervalGroups.add(
          IntervalGroup(
            intervalDefinitions: groupedIntervalDefinitions,
            repetitions: currentGroupItem.repetitions,
          ),
        );

        groupedIntervalDefinitions = [];
      }
    }

    for (final groupedItem in groupedItems) {
      final item = groupedItem.item;

      switch (item) {
        case IntervalGroupItem _:
          terminateIntervalGroup();
          currentGroupItem = item;
        case IntervalDefinitionItem _:
          groupedIntervalDefinitions.add(item.intervalDefinition);
      }
    }

    // Terminate the last group.
    terminateIntervalGroup();

    return intervalGroups;
  }
}

// Modification operations work with [Iterable]s for performance - this way
// creating a new state and collecting all the necessary information along the
// way is done using a single iteration only.
class IntervalsSetupNotifier extends AutoDisposeNotifier<IntervalsSetup> {
  final IntervalsSetup? _testSeed;

  @visibleForTesting
  IntervalsSetupNotifier([this._testSeed]);

  @override
  IntervalsSetup build() => _testSeed ?? IntervalsSetup.initial();

  void add(IntervalsSetupItem item) {
    _recalculateState(
      state.groupedItems.unwrapped.followedBy([item]),
    );
  }

  void remove(int index) {
    final groupedItems = state.groupedItems;
    _recalculateState(
      groupedItems
          .getRange(0, index)
          .followedBy(groupedItems.getRange(index + 1, groupedItems.length))
          .unwrapped,
    );
  }

  /// Moves the item from one place in the list to another.
  ///
  /// While this operation is performed the list isn't modified, i.e. [newIndex]
  /// is the insertion point into the current list, without first removing the
  /// item at [oldIndex] (imagine the moved item to be 'cloned' for a short
  /// period of time). Due to this, moving the item down / further in the list
  /// requires [newIndex] to take this into account.
  void move({required int oldIndex, required int newIndex}) {
    if (newIndex == oldIndex || newIndex == oldIndex + 1) {
      // Moving to right before or right after itself is a no-op, see method
      // docs for more info about why indices might seem counter-intuitive.
      return;
    }

    final groupedItems = state.groupedItems;
    final Iterable<GroupedIntervalsSetupItem> iterable;
    if (oldIndex < newIndex) {
      // Moving down the list.
      iterable = groupedItems
          .getRange(0, oldIndex)
          .followedBy(groupedItems.getRange(oldIndex + 1, newIndex))
          .followedBy(groupedItems.getRange(oldIndex, oldIndex + 1))
          .followedBy(groupedItems.getRange(newIndex, groupedItems.length));
    } else {
      // Moving up the list.
      iterable = groupedItems
          .getRange(0, newIndex)
          .followedBy(groupedItems.getRange(oldIndex, oldIndex + 1))
          .followedBy(groupedItems.getRange(newIndex, oldIndex))
          .followedBy(groupedItems.getRange(oldIndex + 1, groupedItems.length));
    }

    _recalculateState(iterable.unwrapped);
  }

  void update({
    required int index,
    required IntervalsSetupItem item,
  }) {
    final groupedItems = state.groupedItems;
    _recalculateState(
      groupedItems
          .getRange(0, index)
          .followedBy([groupedItems[index]._copyWith(newItem: item)])
          .followedBy(groupedItems.getRange(index + 1, groupedItems.length))
          .unwrapped,
    );
  }

  void reset() {
    state = IntervalsSetup.initial();
  }

  void _recalculateState(Iterable<IntervalsSetupItem> items) {
    final recalculated = <GroupedIntervalsSetupItem>[];
    var hasIntervals = false;
    if (items.isNotEmpty) {
      var group = -1;
      for (final (index, (item, nextItem)) in items.withNext().indexed) {
        // If not a group at items[0] a 'virtual' first group is implied. This
        // makes the UI less cluttered for simplest use cases.
        final isFirst = item is IntervalGroupItem || index == 0;
        final isLast = nextItem == null || nextItem is IntervalGroupItem;
        if (isFirst) {
          ++group;
        }

        if (!hasIntervals && item is IntervalDefinitionItem) {
          hasIntervals = true;
        }

        recalculated.add(
          GroupedIntervalsSetupItem(
            item,
            group: group,
            isFirst: isFirst,
            isLast: isLast,
          ),
        );
      }
    }

    state = IntervalsSetup(
      recalculated,
      hasIntervals: hasIntervals,
    );
  }
}

final intervalsSetupNotifierProvider =
    NotifierProvider.autoDispose<IntervalsSetupNotifier, IntervalsSetup>(
  IntervalsSetupNotifier.new,
);

extension _IterableOfGroupedItemX on Iterable<GroupedIntervalsSetupItem> {
  Iterable<IntervalsSetupItem> get unwrapped => map((gi) => gi.item);
}
