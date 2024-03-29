import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/round_data.dart';
import '../../util/duration_formatter.dart';
import '../widget/common/fitted_text.dart';
import '../widget/common/number_avatar.dart';
import '../widget/common/page_scaffold.dart';

class RoundSummaryPage extends ConsumerWidget {
  const RoundSummaryPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundData = ref.watch(roundDataNotifierProvider)!;

    final colorScheme = Theme.of(context).colorScheme;
    final slowestRoundTextColor = colorScheme.error;
    final fastestRoundTextColor = colorScheme.primary;

    return PageScaffold(
      title: 'Round summary',
      child: Column(
        children: [
          if (!roundData.areAllRoundDurationsEqual)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: _RoundStatisticsWidget(
                  slowestRoundTextColor: slowestRoundTextColor,
                  fastestRoundTextColor: fastestRoundTextColor,
                ),
              ),
            ),
          Expanded(
            flex: 4,
            child: _RoundsList(
              slowestRoundTextColor: slowestRoundTextColor,
              fastestRoundTextColor: fastestRoundTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundStatisticsWidget extends ConsumerWidget {
  final Color slowestRoundTextColor;
  final Color fastestRoundTextColor;

  const _RoundStatisticsWidget({
    required this.slowestRoundTextColor,
    required this.fastestRoundTextColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundData = ref.watch(roundDataNotifierProvider)!;

    return Column(
      children: [
        _makeRow(
          'Slowest:',
          roundData.slowestRoundDuration,
          slowestRoundTextColor,
        ),
        _makeRow(
          'Fastest:',
          roundData.fastestRoundDuration,
          fastestRoundTextColor,
        ),
        _makeRow(
          'Average:',
          roundData.averageRoundDuration,
          null,
        ),
        _makeRow(
          'Std. deviation:',
          roundData.standardDeviation,
          null,
        ),
      ],
    );
  }

  Widget _makeRow(String label, Duration roundDuration, Color? textColor) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: FittedText(
              label,
              alignment: Alignment.centerLeft,
              color: textColor,
            ),
          ),
          Expanded(
            child: FittedText(
              formatRoundDuration(roundDuration),
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundsList extends ConsumerWidget {
  const _RoundsList({
    required this.slowestRoundTextColor,
    required this.fastestRoundTextColor,
  });

  final Color slowestRoundTextColor;
  final Color fastestRoundTextColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundData = ref.watch(roundDataNotifierProvider)!;

    return ListView.builder(
      itemCount: roundData.roundDurations.length,
      itemBuilder: (context, index) {
        final roundDuration = roundData.roundDurations[index];

        final Color? textColor;
        if (roundData.areAllRoundDurationsEqual) {
          textColor = null;
        } else if (index == roundData.slowestRoundIndex) {
          textColor = slowestRoundTextColor;
        } else if (index == roundData.fastestRoundIndex) {
          textColor = fastestRoundTextColor;
        } else {
          textColor = null;
        }

        return ListTile(
          leading: NumberAvatar(
            number: index + 1,
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: FittedText(
              formatRoundDuration(roundDuration),
              color: textColor,
            ),
          ),
        );
      },
    );
  }
}

String formatRoundDuration(Duration duration) => formatDuration(
      duration,
      forceComponent: TimeComponent.minute,
      forceComponentPadding: TimeComponent.minute,
      decimalPlaces: 2,
    );
