import 'dart:ui';

import 'package:flutter/material.dart';

const animationDuration = Duration(milliseconds: 200);

const _borderRadius = 16.0;
const circularBorderRadius = Radius.circular(_borderRadius);
final allCircularBorderRadius = BorderRadius.circular(_borderRadius);

TextStyle textStyle(BuildContext context, {Color? color}) {
  return Theme.of(context).textTheme.bodyText2!.copyWith(
    color: color,
    fontFeatures: [
      const FontFeature.tabularFigures(),
    ],
  );
}
