import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/timer.dart';
import '../../util/timer_widget_ref_x.dart';
import '../common/common_features.dart';
import '../common/fitted_text.dart';
import 'mode_widget.dart';

/// Defines a contract to guide the [TimerWidget] when to rebuild and how to
/// format the time.
///
/// The following steps are executed in a sequence:
/// 1. Duration is extracted (e.g. [TimerState.elapsed]) ([extractDuration]).
/// 2. The duration is converted into a rebuild key ([selectRebuildKey]). If the
///    value is the same as the last time the UI was rebuilt, no rebuild will
///    happen. For example, if the timer should only show full seconds, there is
///    no need to rebuild each time the underlying sub-second timer fires, and
///    considering the rebuild key will take care of it.
///    Note: [TimerState.status] changes always cause a rebuild.
/// 3. If the UI is to be rebuilt, the duration extracted in #1 is formatted
///    ([format]).
abstract interface class TimerOperations {
  Duration extractDuration(TimerState state);
  Object selectRebuildKey(Duration duration);
  String format(Duration duration);
}

class TimerWidget extends ConsumerWidget {
  final TimerOperations timerOperations;

  const TimerWidget({required this.timerOperations});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerStatus = ref.watchTimerStatus();

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
        builder: (context, ref, child) {
          final rebuildData = ref.watch(
            timerNotifierProvider.select(
              (state) {
                final duration = timerOperations.extractDuration(state);

                return _RebuildData(
                  state.status,
                  timerOperations.selectRebuildKey(duration),
                  duration,
                );
              },
            ),
          );

          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          final durationColor = switch (timerStatus) {
            TimerStatus.running => colorScheme.primary,
            TimerStatus.stopped => colorScheme.error,
            TimerStatus.completed => colorScheme.secondary,
          };

          return TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: durationColor),
            duration: animationDuration,
            builder: (context, color, child) {
              return FittedText(
                timerOperations.format(rebuildData.duration),
                color: color,
              );
            },
          );
        },
      ),
    );
  }
}

class _RebuildData with EquatableMixin {
  final TimerStatus status;
  final Object rebuildKey;
  final Duration duration;

  _RebuildData(this.status, this.rebuildKey, this.duration);

  @override
  // 'duration' is intentionally 'transient'. 'status' and 'rebuildKey' cause
  // rebuilds, 'duration' is only for getting time if a rebuild is necessary.
  List<Object> get props => [status, rebuildKey];
}
