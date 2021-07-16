import 'dart:ui';

import 'package:flutter/material.dart';

const opacityAnimationDuration = Duration(milliseconds: 200);

final borderRadius = BorderRadius.circular(16);

TextStyle textStyle(BuildContext context, {Color? color}) {
  return Theme.of(context).textTheme.bodyText2!.copyWith(
    color: color,
    fontFeatures: [
      const FontFeature.tabularFigures(),
    ],
  );
}
