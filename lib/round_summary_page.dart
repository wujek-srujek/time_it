import 'dart:ui';

import 'package:flutter/material.dart';

import 'orientation_x.dart';
import 'round_data.dart';
import 'round_duration_formatter.dart';

class RoundSummaryPage extends StatelessWidget {
  final RoundData roundData;

  const RoundSummaryPage({required this.roundData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final slowestRoundTextColor = colorScheme.error;
    final fastestRoundTextColor = colorScheme.primary;

    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    final roundStatisticsWidget = roundData.areAllRoundDurationsEqual
        ? null
        : Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: _RoundStatisticsWidget(
              roundData: roundData,
              slowestRoundTextColor: slowestRoundTextColor,
              fastestRoundTextColor: fastestRoundTextColor,
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Round summary'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Flex(
            direction: orientation.asAxis(),
            children: [
              if (roundStatisticsWidget != null)
                if (isPortrait)
                  roundStatisticsWidget
                else
                  Expanded(
                    child: roundStatisticsWidget,
                  ),
              Expanded(
                flex: isPortrait ? 4 : 1,
                child: ListView.builder(
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
                    final textStyle = theme.textTheme.headline4!.copyWith(
                      color: textColor,
                      fontFeatures: [
                        const FontFeature.tabularFigures(),
                      ],
                    );

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.onSurface,
                        child: Text('${index + 1}'),
                      ),
                      title: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: Text(
                          formatRoundDuration(roundDuration),
                          style: textStyle,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundStatisticsWidget extends StatelessWidget {
  final RoundData roundData;
  final Color slowestRoundTextColor;
  final Color fastestRoundTextColor;

  const _RoundStatisticsWidget({
    required this.roundData,
    required this.slowestRoundTextColor,
    required this.fastestRoundTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    final baseTextStyle = Theme.of(context).textTheme.headline5!.copyWith(
      fontFeatures: const [
        FontFeature.tabularFigures(),
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
          label,
          formatRoundDuration(duration),
        ]
            .map(
              (text) => Padding(
                padding: EdgeInsets.symmetric(vertical: isPortrait ? 0 : 16),
                child: Text(
                  text,
                  style: textStyle,
                ),
              ),
            )
            .toList(),
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
