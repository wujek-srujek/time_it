import 'duration_x.dart';

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
