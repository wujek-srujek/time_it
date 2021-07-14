import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/timer.dart';
import '../common/common_features.dart';
import '../common/fitted_text.dart';

typedef TimerStateFormatter = String Function(TimerState);

class TimerWidget extends ConsumerWidget {
  final TimerStateFormatter timerStateFormatter;

  const TimerWidget({required this.timerStateFormatter});

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
            timerStateFormatter(timerState),
            color: durationColor,
          );
        },
      ),
    );
  }
}
