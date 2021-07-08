import 'dart:ui';

import 'package:flutter/material.dart';

class FittedTextButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const FittedTextButton(
    this.text, {
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyText2!;
    final primaryColor = theme.colorScheme.primary;
    final borderRadius = BorderRadius.circular(16);

    return InkWell(
      highlightColor: primaryColor.withAlpha(75),
      borderRadius: borderRadius,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(
            color: textStyle.color!,
          ),
          color: primaryColor.withAlpha(50),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: FittedBox(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                fontFeatures: [
                  const FontFeature.tabularFigures(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
