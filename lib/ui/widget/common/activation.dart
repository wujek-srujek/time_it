import 'package:flutter/material.dart';

import 'common_features.dart';

/// A widget which can activate its [child].
///
/// In its active state, it simply shows the `child`. When inactive, the `child`
/// is wrapped in [AnimatedOpacity] and [IgnorePointer] to disappear completely
/// and ignore touches.
///
/// [animationDuration] is used for the opacity animation.
class Activation extends StatelessWidget {
  final bool isActive;
  final double inactiveOpacity;
  final Widget child;

  const Activation({
    required this.isActive,
    this.inactiveOpacity = 0,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isActive ? 1 : inactiveOpacity,
      duration: animationDuration,
      child: IgnorePointer(
        ignoring: !isActive,
        child: child,
      ),
    );
  }
}
