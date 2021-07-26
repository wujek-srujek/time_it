import 'package:riverpod/riverpod.dart';

class IntervalsSetupNotifier extends StateNotifier<List<Duration>> {
  IntervalsSetupNotifier() : super(const []);

  void addInterval(Duration interval) {
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

final intervalsSetupNotifierProvider =
    StateNotifierProvider.autoDispose<IntervalsSetupNotifier, List<Duration>>(
  (ref) => IntervalsSetupNotifier(),
);
