import 'package:meta/meta.dart';

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
