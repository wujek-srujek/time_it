import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/round_data.dart';
import '../../../provider/timer.dart';
import '../../page/round_summary_page.dart';
import '../common/common_features.dart';
import '../common/fitted_text.dart';

class RoundsWidget extends ConsumerWidget {
  const RoundsWidget();

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
