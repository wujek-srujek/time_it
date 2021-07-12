import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/round_data.dart';
import '../../provider/timer.dart';
import '../../util/duration_formatter.dart';
import '../widget/common_features.dart';
import '../widget/fitted_text.dart';
import '../widget/page_scaffold.dart';
import 'round_summary_page.dart';

class TimerPage extends StatelessWidget {
  const TimerPage();

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: const _BackButton(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Expanded(
            child: _RoundsWidget(),
          ),
          Expanded(
            child: _CountdownWidget(),
          ),
        ],
      ),
    );
  }
}

class _RoundsWidget extends ConsumerWidget {
  const _RoundsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerStatus = ref.watch(timerStatusProvider);
    final roundData = ref.watch(roundDataNotifierProvider);

    final void Function()? onTap;
    if (timerStatus != TimerStatus.completed) {
      onTap = () => ref
          .read(
            roundDataNotifierProvider.notifier,
          )
          .registerRound();
    } else if (roundData != null) {
      onTap = () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (context) => const RoundSummaryPage(),
            ),
          );
    } else {
      onTap = null;
    }

    return InkWell(
      borderRadius: borderRadius,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FittedText(
              roundData != null
                  ? formatRoundDuration(roundData.lastRoundDuration)
                  : '--',
            ),
          ),
          Expanded(
            flex: 3,
            child: FittedText(
              roundData != null ? '${roundData.roundDurations.length}' : '0',
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownWidget extends ConsumerWidget {
  const _CountdownWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerStatus = ref.watch(timerStatusProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color durationColor;
    switch (timerStatus) {
      case TimerStatus.running:
        durationColor = colorScheme.primary;
        break;
      case TimerStatus.stopped:
        durationColor = colorScheme.error;
        break;
      case TimerStatus.completed:
        durationColor = colorScheme.secondary;
        break;
    }

    return InkWell(
      borderRadius: borderRadius,
      onTap: timerStatus != TimerStatus.completed
          ? () {
              final timerNotifier = ref.read(timerNotifierProvider.notifier);

              if (timerStatus == TimerStatus.running) {
                timerNotifier.stop();
              } else {
                timerNotifier.start();
              }
            }
          : null,
      child: Consumer(
        builder: (context, watch, _) {
          final timerState = ref.watch(timerNotifierProvider);

          return FittedText(
            _formatRemainingDuration(timerState.remaining!),
            color: durationColor,
          );
        },
      ),
    );
  }
}

class _BackButton extends ConsumerWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerStatus = ref.watch(timerStatusProvider);

    return FloatingActionButton(
      backgroundColor: timerStatus == TimerStatus.completed
          ? null
          : Theme.of(context).colorScheme.error,
      onPressed: () {
        Navigator.of(context).pop();
      },
      mini: true,
      child: Icon(
        timerStatus == TimerStatus.completed
            ? Icons.arrow_back_ios_rounded
            : Icons.stop_rounded,
      ),
    );
  }
}

const _tenSeconds = Duration(seconds: 10);

String _formatRemainingDuration(Duration remainingDuration) {
  if (remainingDuration > _tenSeconds) {
    return formatDuration(
      remainingDuration,
      forceComponent: TimeComponent.second,
      forceComponentPadding: TimeComponent.second,
    );
  }

  return formatDuration(
    remainingDuration,
    forceComponent: TimeComponent.second,
    decimalPlaces: 1,
  );
}
