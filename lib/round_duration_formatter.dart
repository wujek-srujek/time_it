String formatRoundDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inMilliseconds.remainder(60000) / 1000;

  final sb = StringBuffer();

  if (hours > 0) {
    // If 'hours' comes first, no '0' padding needed.
    sb..write(hours.toString())..write(':');
  }

  // 'minutes' and 'seconds' are added unconditionally, even if 0, and are
  // padded with '0'.

  sb
    ..write(minutes.toString().padLeft(2, '0'))
    ..write(':')
    ..write(seconds.toStringAsFixed(2).padLeft(5, '0'));

  return sb.toString();
}
