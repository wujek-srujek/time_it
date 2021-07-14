import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/timer.dart';
import '../../util/duration_formatter.dart';
import 'common_features.dart';
import 'fitted_text.dart';

class TimerWidget extends ConsumerWidget {
  const TimerWidget();

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
