import 'dart:ui';

import 'package:flutter/material.dart';

import 'interval_config_page.dart';

class ModeSelectionPage extends StatelessWidget {
  const ModeSelectionPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose mode'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              _ModeButton(
                modeName: 'AMRAP',
                targetPage: IntervalConfigPage(),
              ),
              Expanded(
                flex: 3,
                child: SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String modeName;
  final Widget targetPage;

  const _ModeButton({
    required this.modeName,
    required this.targetPage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final textStyle = theme.textTheme.bodyText2!;
    final borderRadius = BorderRadius.circular(16);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: InkWell(
          highlightColor: primaryColor.withAlpha(75),
          borderRadius: borderRadius,
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (context) => targetPage,
              ),
            );
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(
                color: textStyle.color!,
              ),
              color: primaryColor.withAlpha(50),
            ),
            child: FittedBox(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  modeName,
                  style: textStyle.copyWith(
                    fontFeatures: [
                      const FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
