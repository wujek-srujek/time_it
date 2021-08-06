import 'package:meta/meta.dart';

@immutable
class IntervalDefinition {
  final int hours;
  final int minutes;
  final int seconds;
  final int repetitions;

  const IntervalDefinition({
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
    this.repetitions = 1,
  })  : assert(hours >= 0),
        assert(hours <= 99),
        assert(minutes >= 0),
        assert(minutes <= 99),
        assert(seconds >= 0),
        assert(seconds <= 99),
        assert(repetitions >= 1);

  IntervalDefinition copyWith({
    int? newHours,
    int? newMinutes,
    int? newSeconds,
    int? newRepetitions,
  }) =>
      IntervalDefinition(
        hours: newHours ?? hours,
        minutes: newMinutes ?? minutes,
        seconds: newSeconds ?? seconds,
        repetitions: newRepetitions ?? repetitions,
      );

  Duration toDuration() => Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
      );
}
