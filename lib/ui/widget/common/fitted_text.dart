import 'package:flutter/material.dart';

import 'common_features.dart';

class FittedText extends StatelessWidget {
  final String text;
  final Alignment alignment;
  final TextStyle? style;
  final Color? color;

  const FittedText(
    this.text, {
    this.alignment = Alignment.center,
    this.style,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      alignment: alignment,
      child: Text(
        text,
        style: style ?? textStyle(context, color: color),
      ),
    );
  }
}
