import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/round_data.dart';
import '../../../provider/timer.dart';
import '../../page/round_summary_page.dart';
import '../../util/timer_widget_ref_x.dart';
import '../common/fitted_text.dart';
import 'mode_widget.dart';

class RoundsWidget extends ConsumerWidget {
  const RoundsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerStatus = ref.watchTimerStatus();

    return ModeWidget(
      onTap: timerStatus != TimerStatus.completed
          ? () => ref.read(roundDataNotifierProvider.notifier).registerRound()
          : null,
      child: Consumer(
        builder: (context, ref, child) {
          final roundData = ref.watch(roundDataNotifierProvider);

          return Column(
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
                  roundData != null
                      ? '${roundData.roundDurations.length}'
                      : '0',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
