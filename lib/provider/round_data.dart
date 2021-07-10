import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import '../util/duration_x.dart';
import 'timer.dart';

@immutable
class RoundData {
  final List<Duration> roundDurations;
  final int slowestRoundIndex;
  final int fastestRoundIndex;
  final Duration averageRoundDuration;

  const RoundData({
    required this.roundDurations,
    required this.slowestRoundIndex,
    required this.fastestRoundIndex,
    required this.averageRoundDuration,
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

    state = RoundData(
      roundDurations: UnmodifiableListView(_roundDurations),
      slowestRoundIndex: _slowestRoundIndex!,
      fastestRoundIndex: _fastestRoundIndex!,
      averageRoundDuration: elapsed ~/ _roundDurations.length,
    );
  }
}

final roundDataNotifierProvider =
    StateNotifierProvider.autoDispose<RoundDataNotifier, RoundData?>(
  (ref) {
    final timerNotifier = ref.watch(timerNotifierProvider.notifier);

    return RoundDataNotifier(() => timerNotifier.accurateElapsed);
  },
);

String formatRoundDuration(Duration duration) {
  final unpacked = duration.unpack();

  final sb = StringBuffer();

  if (unpacked.hours > 0) {
    // If 'hours' comes first, no '0' padding needed.
    sb..write(unpacked.hours.toString())..write(':');
  }

  // 'minutes' and 'seconds' are added unconditionally, even if 0, and are
  // padded with '0'.

  sb
    ..write(unpacked.minutes.toString().padLeft(2, '0'))
    ..write(':')
    ..write(unpacked.seconds.toStringAsFixed(2).padLeft(5, '0'));

  return sb.toString();
}