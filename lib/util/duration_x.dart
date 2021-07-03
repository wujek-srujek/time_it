import 'package:meta/meta.dart';

@immutable
class UnpackedDuration {
  final int hours;
  final int minutes;
  final double seconds;

  const UnpackedDuration._(this.hours, this.minutes, this.seconds);
}

extension DurationX on Duration {
  UnpackedDuration unpack() => UnpackedDuration._(
        inHours,
        inMinutes.remainder(60),
        inMilliseconds.remainder(60000) / 1000,
      );
}
