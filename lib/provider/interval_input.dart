import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

@immutable
class OngoingIntervalDefinition {
  final int hours;
  final int minutes;
  final int seconds;

  const OngoingIntervalDefinition({
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
  })  : assert(hours >= 0),
        assert(hours <= 99),
        assert(minutes >= 0),
        assert(minutes <= 99),
        assert(seconds >= 0),
        assert(seconds <= 99),
        assert(hours > 0 || minutes > 0 || seconds > 0);

  Duration toDuration() => Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
      );
}

@immutable
class IntervalInputState {
  final OngoingIntervalDefinition? ongoingDefinition;
  final List<Duration> intervals;

  const IntervalInputState({
    required this.ongoingDefinition,
    required this.intervals,
  });

  const IntervalInputState._initial()
      : this(
          ongoingDefinition: null,
          intervals: const [],
        );

  List<Duration> get allIntervals => [
        ...intervals,
        if (ongoingDefinition != null) ongoingDefinition!.toDuration(),
      ];
}

class IntervalInputNotifier extends StateNotifier<IntervalInputState> {
  final List<int> _input;
  int _digitCount;

  IntervalInputNotifier()
      : _digitCount = 0,
        _input = List.filled(6, 0),
        super(const IntervalInputState._initial());

  void addDigit(int digit) {
    if (_digitCount == 0 && digit == 0) {
      // No use for leading zeros.
      return;
    }

    if (_digitCount < _input.length) {
      _updateInput(() {
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
      _updateInput(() {
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

  void resetOngoingDefinition() {
    if (_digitCount > 0) {
      _updateInput(_resetInput);
    }
  }

  void completeOngoingDefinition() {
    assert(state.ongoingDefinition != null);

    _resetInput();
    state = IntervalInputState(
      ongoingDefinition: null,
      intervals: [
        ...state.intervals,
        state.ongoingDefinition!.toDuration(),
      ],
    );
  }

  void _resetInput() {
    for (var i = _input.length - _digitCount; i < _input.length; ++i) {
      _input[i] = 0;
    }

    _digitCount = 0;
  }

  void _updateInput(void Function() operations) {
    operations();

    state = IntervalInputState(
      ongoingDefinition: _digitCount > 0
          ? OngoingIntervalDefinition(
              hours: _input[0] * 10 + _input[1],
              minutes: _input[2] * 10 + _input[3],
              seconds: _input[4] * 10 + _input[5],
            )
          : null,
      intervals: state.intervals,
    );
  }
}

final intervalInputNotifierProvider = StateNotifierProvider.autoDispose<
    IntervalInputNotifier, IntervalInputState>(
  (ref) => IntervalInputNotifier(),
);
