import 'package:riverpod/riverpod.dart';

import 'interval_definition.dart';

export 'interval_definition.dart';

class IntervalInputNotifier extends StateNotifier<IntervalDefinition?> {
  final List<int> _input;
  int _digitCount;

  IntervalInputNotifier()
      : _digitCount = 0,
        _input = List.filled(6, 0),
        super(null);

  void addDigit(int digit) {
    if (_digitCount == 0 && digit == 0) {
      // No use for leading zeros.
      return;
    }

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

  void reset() {
    if (_digitCount > 0) {
      _update(_resetInput);
    }
  }

  void _resetInput() {
    for (var i = _input.length - _digitCount; i < _input.length; ++i) {
      _input[i] = 0;
    }

    _digitCount = 0;
  }

  void _update(void Function() operations) {
    operations();

    state = _digitCount > 0
        ? IntervalDefinition(
            hours: _input[0] * 10 + _input[1],
            minutes: _input[2] * 10 + _input[3],
            seconds: _input[4] * 10 + _input[5],
          )
        : null;
  }
}

final intervalInputNotifierProvider = StateNotifierProvider.autoDispose<
    IntervalInputNotifier, IntervalDefinition?>(
  (ref) => IntervalInputNotifier(),
);
