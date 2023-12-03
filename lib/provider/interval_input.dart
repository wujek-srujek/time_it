import 'package:riverpod/riverpod.dart';

import 'interval_definition.dart';

export 'interval_definition.dart';

class IntervalInputNotifier extends StateNotifier<IntervalDefinition> {
  final List<int> _input;
  int _digitCount;

  factory IntervalInputNotifier(IntervalDefinition? prototype) {
    if (prototype == null) {
      return IntervalInputNotifier._(
        List.filled(6, 0),
        0,
        const IntervalDefinition(),
      );
    }

    final (input, digitCount) = _decompose(prototype);

    return IntervalInputNotifier._(input, digitCount, prototype);
  }

  IntervalInputNotifier._(
    this._input,
    this._digitCount,
    IntervalDefinition prototype,
  ) : super(prototype);

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
      _update(() {
        // Traverse the input and reset the digits to reset. Only relevant parts
        // of the input are considered.
        for (var i = _input.length - _digitCount; i < _input.length; ++i) {
          _input[i] = 0;
        }

        _digitCount = 0;
      });
    }
  }

  void _update(void Function() operations) {
    operations();

    state = state.copyWith(
      newHours: _input[0] * 10 + _input[1],
      newMinutes: _input[2] * 10 + _input[3],
      newSeconds: _input[4] * 10 + _input[5],
    );
  }
}

(List<int>, int) _decompose(IntervalDefinition prototype) {
  final input = List.filled(6, 0);

  void decomposeUnit(int unit, int firstIndex) {
    if (unit > 0) {
      input[firstIndex] = unit ~/ 10;
      input[firstIndex + 1] = unit.remainder(10);
    }
  }

  decomposeUnit(prototype.hours, 0);
  decomposeUnit(prototype.minutes, 2);
  decomposeUnit(prototype.seconds, 4);

  var i = 0;
  while (i < input.length && input[i] == 0) {
    ++i;
  }
  final digitCount = input.length - i;

  return (input, digitCount);
}

final intervalInputNotifierProvider = StateNotifierProvider.autoDispose
    .family<IntervalInputNotifier, IntervalDefinition, IntervalDefinition?>(
  (ref, prototype) => IntervalInputNotifier(prototype),
);
