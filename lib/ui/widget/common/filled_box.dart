import 'package:flutter/material.dart';

import 'common_features.dart';

enum Corner {
  topLeft,
  topRight,
  bottomRight,
  bottomLeft,
}

extension _SetOfCorners on Set<Corner>? {
  Radius? operator [](Corner corner) =>
      this?.contains(corner) ?? true ? circularBorderRadius : null;
}

/// A simple container.
///
/// It draws a background using [color] below its [child], and a thin border
/// around it. By default all corners are rounded but this can be controlled
/// using [roundedCorners]. All changes to the background and corners are
/// animated.
class FilledBox extends StatelessWidget {
  final Color color;
  final Set<Corner>? roundedCorners;
  final Widget child;

  /// 'null' [roundedCorners] means 'all corners'.
  const FilledBox({
    required this.color,
    this.roundedCorners,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Decoration>(
      duration: animationDuration,
      tween: DecorationTween(
        end: BoxDecoration(
          borderRadius: BorderRadius.zero.copyWith(
            topLeft: roundedCorners[Corner.topLeft],
            topRight: roundedCorners[Corner.topRight],
            bottomLeft: roundedCorners[Corner.bottomLeft],
            bottomRight: roundedCorners[Corner.bottomRight],
          ),
          border: Border.all(
            color: textStyle(context).color!,
          ),
          color: color,
        ),
      ),
      builder: (context, decoration, child) {
        return DecoratedBox(
          decoration: decoration,
          child: child,
        );
      },
      child: child,
    );
  }
}
