import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/round_data.dart';

class RoundSummaryPage extends ConsumerWidget {
  const RoundSummaryPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundData = ref.watch(roundDataNotifierProvider)!;

    final colorScheme = Theme.of(context).colorScheme;
    final slowestRoundTextColor = colorScheme.error;
    final fastestRoundTextColor = colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Round summary'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              if (!roundData.areAllRoundDurationsEqual)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: _RoundStatisticsWidget(
                    slowestRoundTextColor: slowestRoundTextColor,
                    fastestRoundTextColor: fastestRoundTextColor,
                  ),
                ),
              Expanded(
                child: _RoundsList(
                  slowestRoundTextColor: slowestRoundTextColor,
                  fastestRoundTextColor: fastestRoundTextColor,
                ),
              ),
            ],
          ),
        ),
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

    final baseTextStyle = Theme.of(context).textTheme.headline5!.copyWith(
      fontFeatures: [
        const FontFeature.tabularFigures(),
      ],
    );

    TableRow makeRow(
      String label,
      Duration duration,
      Color? textColor,
    ) {
      final textStyle = baseTextStyle.copyWith(color: textColor);

      return TableRow(
        children: [
          Text(
            label,
            style: textStyle,
          ),
          Text(
            formatRoundDuration(duration),
            style: textStyle,
          ),
        ],
      );
    }

    return Table(
      children: [
        makeRow(
          'Slowest:',
          roundData.slowestRoundDuration,
          slowestRoundTextColor,
        ),
        makeRow(
          'Fastest:',
          roundData.fastestRoundDuration,
          fastestRoundTextColor,
        ),
        makeRow(
          'Average:',
          roundData.averageRoundDuration,
          null,
        ),
      ],
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

    final theme = Theme.of(context);

    final onSurfaceColor = theme.colorScheme.onSurface;
    final baseTextStyle = theme.textTheme.headline4!.copyWith(
      fontFeatures: [
        const FontFeature.tabularFigures(),
      ],
    );

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
          leading: CircleAvatar(
            backgroundColor: onSurfaceColor,
            child: Text('${index + 1}'),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Text(
              formatRoundDuration(roundDuration),
              style: baseTextStyle.copyWith(color: textColor),
            ),
          ),
        );
      },
    );
  }
}
