import 'package:riverpod/riverpod.dart';

import 'interval_definition.dart';

export 'interval_definition.dart';

class IntervalInputNotifier extends StateNotifier<IntervalDefinition?> {
  final List<int> _input;
  int _digitCount;
  IntervalDefinition _prototype;

  IntervalInputNotifier()
      : _digitCount = 0,
        _input = List.filled(6, 0),
        _prototype = const IntervalDefinition(),
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

  void override(IntervalDefinition prototype) {
    _update(() {
      void decompose(int unit, int firstIndex) {
        if (unit > 0) {
          _input[firstIndex] = unit ~/ 10;
          _input[firstIndex + 1] = unit.remainder(10);
        }
      }

      decompose(prototype.hours, 0);
      decompose(prototype.minutes, 2);
      decompose(prototype.seconds, 4);

      var i = 0;
      while (i < _input.length && _input[i] == 0) {
        ++i;
      }
      _digitCount = _input.length - i;

      _prototype = prototype;
    });
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
        ? _prototype.copyWith(
            newHours: _input[0] * 10 + _input[1],
            newMinutes: _input[2] * 10 + _input[3],
            newSeconds: _input[4] * 10 + _input[5],
          )
        : null;
  }
}

final intervalInputNotifierProvider = StateNotifierProvider.autoDispose<
    IntervalInputNotifier, IntervalDefinition?>(
  (ref) => IntervalInputNotifier(),
);
