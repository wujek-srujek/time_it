import 'package:flutter/material.dart';

import 'common_features.dart';
import 'fitted_text.dart';
import 'size_dependent_padding.dart';

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
    final primaryColor = theme.colorScheme.primary;

    return InkWell(
      highlightColor: primaryColor.withAlpha(75),
      borderRadius: borderRadius,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(
            color: textStyle(context).color!,
          ),
          color: primaryColor.withAlpha(50),
        ),
        child: SizeDependentPadding.all(
          _paddingRatio,
          calculationBase: CalculationBase.smallerSide,
          child: FittedText(text),
        ),
      ),
    );
  }
}

const _paddingRatio = 0.075;