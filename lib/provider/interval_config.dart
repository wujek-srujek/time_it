import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

@immutable
class IntervalConfig {
  static const IntervalConfig zero = IntervalConfig();

  final int hours;
  final int minutes;
  final int seconds;

  const IntervalConfig({
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
  })  : assert(hours >= 0),
        assert(hours <= 99),
        assert(minutes >= 0),
        assert(minutes <= 99),
        assert(seconds >= 0),
        assert(seconds <= 99);

  Duration asDuration() => Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
      );

  bool get isNotEmpty => asDuration() > Duration.zero;
}

class IntervalConfigNotifier extends StateNotifier<IntervalConfig> {
  final List<int> _input;
  int _digitCount;

  IntervalConfigNotifier()
      : _digitCount = 0,
        _input = List.filled(6, 0),
        super(IntervalConfig.zero);

  void addDigit(int digit) {
    if (_digitCount < _input.length) {
      _update(() {
        // Traverse the input and move the digits by one spot to the left to
        // make space for the new one. Only relevant parts of the input are
        // considered.
        for (var i = _input.length - _digitCount; i < _input.length; ++i) {
          _input[i - 1] = _input[i];
        }
        _input[_input.length - 1] = digit;

        ++_digitCount;
      });
    }
  }

  void deleteLastDigit() {
    if (_digitCount > 0) {
      _update(() {
        // Traverse the input in reverse and move the digits by one spot to the
        // right to delete the last one. Only relevant parts of the input are
        // considered.
        for (var i = _input.length - 2; i >= _input.length - _digitCount; --i) {
          _input[i + 1] = _input[i];
        }
        _input[_input.length - _digitCount] = 0;

        --_digitCount;
      });
    }
  }

  void deleteAllDigits() {
    if (_digitCount > 0) {
      _update(() {
        for (var i = _input.length - _digitCount; i < _input.length; ++i) {
          _input[i] = 0;
        }

        _digitCount = 0;
      });
    }
  }

  void _update(void Function() operations) {
    operations();

    state = IntervalConfig(
      hours: _input[0] * 10 + _input[1],
      minutes: _input[2] * 10 + _input[3],
      seconds: _input[4] * 10 + _input[5],
    );
  }
}

final intervalConfigNotifierProvider =
    StateNotifierProvider.autoDispose<IntervalConfigNotifier, IntervalConfig>(
  (ref) => IntervalConfigNotifier(),
);
