import 'dart:collection';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import 'timer.dart';

@immutable
class RoundData {
  final List<Duration> roundDurations;
  final int slowestRoundIndex;
  final int fastestRoundIndex;
  final Duration averageRoundDuration;
  final Duration standardDeviation;

  const RoundData({
    required this.roundDurations,
    required this.slowestRoundIndex,
    required this.fastestRoundIndex,
    required this.averageRoundDuration,
    required this.standardDeviation,
  })  : assert(roundDurations.length > 0),
        assert(slowestRoundIndex >= 0),
        assert(slowestRoundIndex < roundDurations.length),
        assert(fastestRoundIndex >= 0),
        assert(fastestRoundIndex < roundDurations.length);

  Duration get slowestRoundDuration => roundDurations[slowestRoundIndex];

  Duration get fastestRoundDuration => roundDurations[fastestRoundIndex];

  Duration get lastRoundDuration => roundDurations.last;

  bool get areAllRoundDurationsEqual => slowestRoundIndex == fastestRoundIndex;
}

class RoundDataNotifier extends StateNotifier<RoundData?> {
  final Duration Function() _elapsed;

  final List<Duration> _roundDurations;

  Duration _previousElapsed;

  int? _slowestRoundIndex;
  int? _fastestRoundIndex;

  RoundDataNotifier(this._elapsed)
      : _roundDurations = [],
        _previousElapsed = Duration.zero,
        super(null);

  void registerRound() {
    final elapsed = _elapsed();
    final roundDuration = elapsed - _previousElapsed;

    if (_slowestRoundIndex == null ||
        _roundDurations[_slowestRoundIndex!] < roundDuration) {
      _slowestRoundIndex = _roundDurations.length;
    }
    if (_fastestRoundIndex == null ||
        _roundDurations[_fastestRoundIndex!] > roundDuration) {
      _fastestRoundIndex = _roundDurations.length;
    }

    _roundDurations.add(roundDuration);

    _previousElapsed = elapsed;

    final average = elapsed ~/ _roundDurations.length;

    state = RoundData(
      roundDurations: UnmodifiableListView(_roundDurations),
      slowestRoundIndex: _slowestRoundIndex!,
      fastestRoundIndex: _fastestRoundIndex!,
      averageRoundDuration: average,
      standardDeviation: standardDeviation(average),
    );
  }

  void reset() {
    _roundDurations.clear();
    _previousElapsed = Duration.zero;
    _slowestRoundIndex = null;
    _fastestRoundIndex = null;
    state = null;
  }

  // stdDev = sqrt(sum((xi - average)^2) / N)
  Duration standardDeviation(Duration average) {
    final averageMicroseconds = average.inMicroseconds;
    final sumOfSquares = _roundDurations
        // xi - average
        .map((duration) => duration.inMicroseconds - averageMicroseconds)
        // (xi - average)^2
        .map((diff) => diff * diff)
        // sum((xi - average)^2)
        .reduce((value, element) => value + element);
    // stdDev = sqrt(sum((xi - average)^2) / N)
    final stdDev = sqrt(sumOfSquares ~/ _roundDurations.length);

    return Duration(microseconds: stdDev.toInt());
  }
}

final roundDataNotifierProvider =
    StateNotifierProvider.autoDispose<RoundDataNotifier, RoundData?>(
  (ref) {
    final timerNotifier = ref.watch(timerNotifierProvider.notifier);

    return RoundDataNotifier(() => timerNotifier.accurateElapsed);
  },
);
