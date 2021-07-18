import 'dart:math';

import 'package:flutter/material.dart';

class ModeWidget extends StatelessWidget {
  final void Function()? onTap;
  final Widget child;

  const ModeWidget({
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Pick the smaller side for a consistent landscape mode
    // (if ever implemented).
    final screenSize = MediaQuery.of(context).size;
    final smallerSide = min(screenSize.width, screenSize.height);

    return InkResponse(
      radius: smallerSide * 0.75,
      onTap: onTap,
      child: child,
    );
  }
}
