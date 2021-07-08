import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/interval_config.dart';
import '../widget/fitted_text_button.dart';
import 'timer_page.dart';

// Design and behavior influenced by the standard Android Clock app.
class IntervalConfigPage extends StatelessWidget {
  const IntervalConfigPage();

  @override
  Widget build(BuildContext context) {
    // Use StatelessWidget + Consumer to have 'child' support.
    return Consumer(
      builder: (context, ref, child) {
        final intervalConfig = ref.watch(intervalConfigNotifierProvider);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Define interval'),
          ),
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
                color: Theme.of(context).textTheme.bodyText2!.color,
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
        ),
      ),
    );
  }
}

class _IntervalTextWidget extends ConsumerWidget {
  const _IntervalTextWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervalConfig = ref.watch(intervalConfigNotifierProvider);

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
      child: _TextTile(
        '$amount'.padLeft(2, '0'),
        textColor: textColor,
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
      child: _TextTile(
        ':',
        textColor: textColor,
      ),
    );
  }
}

class _TextTile extends StatelessWidget {
  final String text;
  final Color? textColor;

  const _TextTile(
    this.text, {
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyText2!.copyWith(
            color: textColor,
            fontFeatures: [
              const FontFeature.tabularFigures(),
            ],
          ),
        ),
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
                    child: FittedTextButton(
                      '$digit',
                      onTap: () => ref
                          .read(intervalConfigNotifierProvider.notifier)
                          .addDigit(digit),
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
