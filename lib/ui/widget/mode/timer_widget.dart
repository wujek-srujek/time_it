import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/timer.dart';
import '../../util/timer_widget_ref_x.dart';
import '../common/common_features.dart';
import '../common/fitted_text.dart';
import 'mode_widget.dart';

typedef TimerStateFormatter = String Function(TimerState);

class TimerWidget extends ConsumerWidget {
  final TimerStateFormatter timerStateFormatter;

  const TimerWidget({required this.timerStateFormatter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerStatus = ref.watchTimerStatus();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final durationColor = switch (timerStatus) {
      TimerStatus.running => colorScheme.primary,
      TimerStatus.stopped => colorScheme.error,
      TimerStatus.completed => colorScheme.secondary,
    };

    return ModeWidget(
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
        builder: (context, watch, child) {
          final timerState = ref.watch(timerNotifierProvider);

          return TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: durationColor),
            duration: animationDuration,
            builder: (context, color, child) {
              return FittedText(
                timerStateFormatter(timerState),
                color: color,
              );
            },
          );
        },
      ),
    );
  }
}
