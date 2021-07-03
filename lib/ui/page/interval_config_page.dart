import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/interval_config.dart';
import 'timer_page.dart';

// Design and behavior blatantly copied from the standard Android Clock app.
class IntervalConfigPage extends StatelessWidget {
  const IntervalConfigPage();

  @override
  Widget build(BuildContext context) {
    // Use StatelessWidget + Consumer to have 'child' support.
    return Consumer(
      builder: (context, watch, child) {
        final intervalConfig = watch(intervalConfigNotifierProvider);

        return Scaffold(
          body: child,
          floatingActionButton: intervalConfig.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const TimerPage(),
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
              const Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: _DialWidget(),
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
    final intervalConfig = watch(intervalConfigNotifierProvider);

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
                      .read(intervalConfigNotifierProvider.notifier)
                      .deleteAllDigits();
                }
              : null,
          child: IconButton(
            onPressed: intervalConfig.isNotEmpty
                ? () {
                    context
                        .read(intervalConfigNotifierProvider.notifier)
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
  const _DialWidget();

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
              onPressed: () => context
                  .read(intervalConfigNotifierProvider.notifier)
                  .addDigit(digit),
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
