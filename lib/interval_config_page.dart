import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'timer_page.dart';

// Design and behavior blatantly copied from the standard Android Clock app.
class IntervalConfigPage extends StatelessWidget {
  const IntervalConfigPage();

  @override
  Widget build(BuildContext context) {
    // Use StatelessWidget + Consumer to have 'child' support.
    return Consumer(
      builder: (context, watch, child) {
        final intervalConfig = watch(_intervalConfigNotifierProvider);

        return Scaffold(
          body: child,
          floatingActionButton: intervalConfig.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) {
                          return TimerPage(
                            interval: intervalConfig.asDuration(),
                          );
                        },
                      ),
                    );
                  },
                  child: const Icon(Icons.play_arrow_rounded),
                )
              : null,
        );
      },
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 24),
                  child: const _IntervalTextWidget(),
                ),
              ),
              const Divider(
                thickness: 2,
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _DialWidget(
                    onDigitPressed: (digit) {
                      context
                          .read(_intervalConfigNotifierProvider.notifier)
                          .addDigit(digit);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntervalTextWidget extends ConsumerWidget {
  const _IntervalTextWidget();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final intervalConfig = watch(_intervalConfigNotifierProvider);
    final textColor = intervalConfig.isNotEmpty
        ? Theme.of(context).colorScheme.primary
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _UnitTile(
          intervalConfig.hours,
          unitLabel: 'h',
          customTextColor: textColor,
        ),
        _UnitTile(
          intervalConfig.minutes,
          unitLabel: 'm',
          customTextColor: textColor,
        ),
        _UnitTile(
          intervalConfig.seconds,
          unitLabel: 's',
          customTextColor: textColor,
        ),
        GestureDetector(
          onLongPress: intervalConfig.isNotEmpty
              ? () {
                  context
                      .read(_intervalConfigNotifierProvider.notifier)
                      .deleteAllDigits();
                }
              : null,
          child: IconButton(
            onPressed: intervalConfig.isNotEmpty
                ? () {
                    context
                        .read(_intervalConfigNotifierProvider.notifier)
                        .deleteLastDigit();
                  }
                : null,
            icon: const Icon(
              Icons.backspace_outlined,
            ),
          ),
        ),
      ],
    );
  }
}

class _UnitTile extends StatelessWidget {
  final int amount;
  final String unitLabel;
  final Color? customTextColor;

  const _UnitTile(
    this.amount, {
    required this.unitLabel,
    this.customTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return RichText(
      text: TextSpan(
        text: '$amount'.padLeft(2, '0'),
        style: textTheme.headline2!.copyWith(
          color: customTextColor,
          fontFeatures: [
            const FontFeature.tabularFigures(),
          ],
        ),
        children: [
          TextSpan(
            text: unitLabel,
            style: textTheme.headline6!.copyWith(
              color: customTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialWidget extends StatelessWidget {
  final void Function(int digit) onDigitPressed;

  const _DialWidget({required this.onDigitPressed});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline3!.copyWith(
      fontFeatures: [
        const FontFeature.tabularFigures(),
      ],
    );

    TableRow makeRow(List<int?> digits) {
      return TableRow(
        children: digits.map((digit) {
          if (digit == null) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: TextButton(
              onPressed: () => onDigitPressed(digit),
              style: TextButton.styleFrom(
                shape: const CircleBorder(),
              ),
              child: Text(
                '$digit',
                style: textStyle,
              ),
            ),
          );
        }).toList(),
      );
    }

    return Table(
      children: [
        makeRow([1, 2, 3]),
        makeRow([4, 5, 6]),
        makeRow([7, 8, 9]),
        makeRow([null, 0, null]),
      ],
    );
  }
}

@immutable
class _IntervalConfig {
  static const _IntervalConfig zero = _IntervalConfig();

  final int hours;
  final int minutes;
  final int seconds;

  const _IntervalConfig({
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

class _IntervalConfigNotifier extends StateNotifier<_IntervalConfig> {
  final List<int> input;
  int digitCount;

  _IntervalConfigNotifier()
      : digitCount = 0,
        input = List.filled(6, 0),
        super(_IntervalConfig.zero);

  void addDigit(int digit) {
    if (digitCount < input.length) {
      _update(() {
        // Traverse the input and move the digits by one spot to the left to
        // make space for the new one. Only relevant parts of the input are
        // considered.
        for (var i = input.length - digitCount; i < input.length; ++i) {
          input[i - 1] = input[i];
        }
        input[input.length - 1] = digit;

        ++digitCount;
      });
    }
  }

  void deleteLastDigit() {
    if (digitCount > 0) {
      _update(() {
        // Traverse the input in reverse and move the digits by one spot to the
        // right to delete the last one. Only relevant parts of the input are
        // considered.
        for (var i = input.length - 2; i >= input.length - digitCount; --i) {
          input[i + 1] = input[i];
        }
        input[input.length - digitCount] = 0;

        --digitCount;
      });
    }
  }

  void deleteAllDigits() {
    if (digitCount > 0) {
      _update(() {
        for (var i = input.length - digitCount; i < input.length; ++i) {
          input[i] = 0;
        }

        digitCount = 0;
      });
    }
  }

  void _update(void Function() operations) {
    operations();

    state = _IntervalConfig(
      hours: input[0] * 10 + input[1],
      minutes: input[2] * 10 + input[3],
      seconds: input[4] * 10 + input[5],
    );
  }
}

final _intervalConfigNotifierProvider =
    StateNotifierProvider<_IntervalConfigNotifier, _IntervalConfig>(
  (ref) => _IntervalConfigNotifier(),
);
