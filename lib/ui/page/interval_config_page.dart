import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/interval_config.dart';
import '../widget/common/common_button.dart';
import '../widget/common/common_features.dart';
import '../widget/common/fitted_text.dart';
import '../widget/common/page_scaffold.dart';
import '../widget/mode/countdown_timer_widget.dart';
import '../widget/mode/rounds_widget.dart';
import 'workout_page.dart';

// Design and behavior influenced by the standard Android Clock app.
class IntervalConfigPage extends StatelessWidget {
  const IntervalConfigPage();

  @override
  Widget build(BuildContext context) {
    // Use StatelessWidget + Consumer to have 'child' support.
    return Consumer(
      builder: (context, ref, child) {
        final intervalConfig = ref.watch(_neverNullIntervalConfigProvider);

        return PageScaffold(
          title: 'Define interval',
          floatingActionButton: intervalConfig.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const WorkoutPage(
                          topWidget: RoundsWidget(),
                          bottomWidget: CountdownTimerWidget(),
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.play_arrow_rounded),
                )
              : null,
          child: child!,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 24),
              child: const _IntervalTextWidget(),
            ),
          ),
          Divider(
            thickness: 2,
            color: textStyle(context).color,
          ),
          const Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.only(top: 24),
              child: _DialWidget(),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntervalTextWidget extends ConsumerWidget {
  const _IntervalTextWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervalConfig = ref.watch(_neverNullIntervalConfigProvider);

    final textColor = intervalConfig.isNotEmpty
        ? Theme.of(context).colorScheme.primary
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _UnitTile(
          intervalConfig.hours,
          textColor: textColor,
        ),
        _DotsTile(textColor: textColor),
        _UnitTile(
          intervalConfig.minutes,
          textColor: textColor,
        ),
        _DotsTile(textColor: textColor),
        _UnitTile(
          intervalConfig.seconds,
          textColor: textColor,
        ),
        GestureDetector(
          onLongPress: intervalConfig.isNotEmpty
              ? () => ref
                  .read(intervalConfigNotifierProvider.notifier)
                  .deleteAllDigits()
              : null,
          child: IconButton(
            onPressed: intervalConfig.isNotEmpty
                ? () => ref
                    .read(intervalConfigNotifierProvider.notifier)
                    .deleteLastDigit()
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
  final Color? textColor;

  const _UnitTile(this.amount, {this.textColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: FittedText(
        '$amount'.padLeft(2, '0'),
        color: textColor,
      ),
    );
  }
}

class _DotsTile extends StatelessWidget {
  final Color? textColor;

  const _DotsTile({this.textColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FittedText(
        ':',
        color: textColor,
      ),
    );
  }
}

class _DialWidget extends ConsumerWidget {
  const _DialWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget makeRow(List<int?> digits) {
      return Expanded(
        child: Row(
          children: digits.map((digit) {
            final body = digit == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: CommonButton(
                      onTap: () => ref
                          .read(intervalConfigNotifierProvider.notifier)
                          .addDigit(digit),
                      child: FittedText('$digit'),
                    ),
                  );

            return Expanded(child: body);
          }).toList(),
        ),
      );
    }

    return Column(
      children: [
        makeRow([1, 2, 3]),
        makeRow([4, 5, 6]),
        makeRow([7, 8, 9]),
        makeRow([null, 0, null]),
      ],
    );
  }
}

// [IntervalConfig] may be null in [intervalConfigNotifierProvider] so let's
// use a 'null object'. If not, `null` would need to be dealt with in many
// places in this library.

class _UnsetIntervalConfig implements IntervalConfig {
  const _UnsetIntervalConfig();

  @override
  Duration asDuration() => throw UnimplementedError('must not be called');

  @override
  bool get isNotEmpty => false;

  @override
  int get hours => 0;

  @override
  int get minutes => 0;

  @override
  int get seconds => 0;
}

final _neverNullIntervalConfigProvider =
    Provider.autoDispose<IntervalConfig>((ref) {
  return ref.watch(intervalConfigNotifierProvider) ??
      const _UnsetIntervalConfig();
});
