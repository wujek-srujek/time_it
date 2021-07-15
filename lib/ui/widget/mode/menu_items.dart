import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/round_data.dart';
import '../../../provider/timer.dart';
import '../../page/round_summary_page.dart';
import '../common/common_button.dart';

class RoundSummaryMenuButton extends ConsumerWidget {
  const RoundSummaryMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundData = ref.watch(roundDataNotifierProvider);
    final isActive = roundData != null;

    return Opacity(
      opacity: isActive ? 1 : _inactiveOpacity,
      child: CommonButton(
        onTap: isActive
            ? () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const RoundSummaryPage(),
                  ),
                )
            : null,
        child: const Icon(Icons.list_rounded),
      ),
    );
  }
}

class RestartMenuButton extends ConsumerWidget {
  const RestartMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonButton(
      onTap: () {
        ref.read(roundDataNotifierProvider.notifier).reset();
        ref.read(timerNotifierProvider.notifier).restart();
      },
      child: const Icon(Icons.replay_rounded),
    );
  }
}

const _inactiveOpacity = 0.25;
