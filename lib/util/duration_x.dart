import 'package:meta/meta.dart';

@immutable
class UnpackedDuration {
  final int hours;
  final int minutes;
  final int seconds;
  final int millis;

  const UnpackedDuration._(
    this.hours,
    this.minutes,
    this.seconds,
    this.millis,
  )   : assert(hours >= 0),
        // The UI doesn't support days, 100 full hours is max.
        assert(hours <= 100),
        assert(minutes >= 0),
        assert(minutes <= 59),
        assert(seconds >= 0),
        assert(seconds <= 59),
        assert(millis >= 0),
        assert(millis <= 999);
}

extension DurationX on Duration {
  UnpackedDuration unpack() => UnpackedDuration._(
        inHours,
        inMinutes.remainder(60),
        inSeconds.remainder(60),
        inMilliseconds.remainder(1000),
      );
}
