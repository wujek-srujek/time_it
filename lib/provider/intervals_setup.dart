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
}

final intervalsSetupNotifierProvider =
    StateNotifierProvider.autoDispose<IntervalsSetupNotifier, List<Duration>>(
  (ref) => IntervalsSetupNotifier(),
);
