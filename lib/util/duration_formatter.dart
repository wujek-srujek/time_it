import 'dart:math';

import '../util/duration_x.dart';

const maxDecimalPlaces = 3;

// Be careful changing order as it is relevant (see `includes`).
enum TimeComponent {
  hour,
  minute,
  second,
  none;

  bool includes(TimeComponent other) => index <= other.index;
}

extension _UnpackedDurationX on UnpackedDuration {
  bool includes(TimeComponent component) {
    return switch (component) {
      TimeComponent.hour => hours > 0,
      TimeComponent.minute => hours > 0 || minutes > 0,
      TimeComponent.second => hours > 0 || minutes > 0 || seconds > 0,
      TimeComponent.none => true,
    };
  }
}

/// Formats the specified [duration].
///
/// By default, only relevant [TimeComponent]s are printed, i.e. only components
/// which are present, or 'below'. For example, for the duration '3 min': hours
/// are not printed, but minutes (explicitly) and seconds (implicitly) are.
/// This can be changed by specifying [forceComponent]. For example, for the
/// duration '3 sec' and [forceComponent] set to [TimeComponent.hour], all of
/// hours, minutes and seconds are printed, with hours and minutes being all 0.
///
/// By default, the minimal necessary number of digits are printed for each
/// component. For example, for the duration '17 sec' '17' is printed for
/// seconds, but for '1 sec' only '1' is printed. This may not be desired, e.g.
/// when multiple times are shown in some kind of a table and should be
/// displayed consistently. This can be changed by using [forceComponentPadding]
/// which pads single digits with leading '0'. Similarly to [forceComponent],
/// this changes the way the forced component is printed, as well as all
/// components 'below'. For example, the duration '1 hour 1 min 1 sec' and
/// [forceComponentPadding] of [TimeComponent.hour] is printed as '01:01:01'.
///
/// [forceComponent] and [forceComponentPadding] are independent, which makes it
/// possible to achieve various printing effects. For example, for the default
/// [forceComponent] of [TimeComponent.none] and [forceComponentPadding] set to
/// [TimeComponent.minute], the duration '1 min 1 sec' is printed as '01:01',
/// but the duration '1 sec' is printed as '01' only - [forceComponentPadding]
/// does't influence which component is present in the formatted string; it just
/// influences its formatting if and only if it is already present (because it
/// exists or is forced with [forceComponent]).
///
/// Optionally, [decimalPlaces] can be specified to also print milliseconds.
/// This supports 0 (default, means milliseconds will not be printed) to 3
/// decimal places.
String formatDuration(
  Duration duration, {
  TimeComponent forceComponent = TimeComponent.none,
  TimeComponent forceComponentPadding = TimeComponent.none,
  int decimalPlaces = 0,
}) {
  assert(decimalPlaces >= 0);
  assert(decimalPlaces <= maxDecimalPlaces);

  final unpacked = duration.unpack();

  final sb = StringBuffer();

  void processComponent(TimeComponent component, int value) {
    if (unpacked.includes(component) || forceComponent.includes(component)) {
      var string = value.toString();
      if (forceComponentPadding.includes(component)) {
        string = string.padLeft(2, '0');
      }
      sb.write(string);
    }
  }

  processComponent(TimeComponent.hour, unpacked.hours);

  if (sb.isNotEmpty) {
    sb.write(':');
  }

  processComponent(TimeComponent.minute, unpacked.minutes);

  if (sb.isNotEmpty) {
    sb.write(':');
  }

  processComponent(TimeComponent.second, unpacked.seconds);

  if (decimalPlaces > 0) {
    if (sb.isNotEmpty) {
      sb.write('.');
    }

    final divider = pow(10, maxDecimalPlaces - decimalPlaces);
    final fraction = unpacked.millis ~/ divider;
    final fractionString = fraction.toString().padLeft(decimalPlaces, '0');

    sb.write(fractionString);
  }

  return sb.toString();
}
