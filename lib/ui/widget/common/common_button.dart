import 'package:flutter/material.dart';

import 'common_features.dart';
import 'size_dependent_padding.dart';

/// A button used throughout this app.
///
/// It has two variants: default and 'destructive'.
///
/// In the default variant, it is possible to specify all the properties; if
/// [backgroundColor] is not specified, [ColorScheme.primary] is used.
///
/// In the destructive variant, only the [onLongPress] action is allowed, and
/// the background color is always fixed to [ColorScheme.error], without the
/// possibility of overriding it.
///
/// If a `CommonButton` changes its variant (e.g. from destructive to defuault),
/// it may be useful to use the [CommonButton.safetyCheck] factory and it decide
/// dynamically which variant it should represent.
class CommonButton extends StatelessWidget {
  final bool isDestructive;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final Color? backgroundColor;
  final Widget child;

  const CommonButton({
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    required this.child,
  }) : isDestructive = false;

  const CommonButton.destructive({
    this.onLongPress,
    required this.child,
  })  : isDestructive = true,
        onTap = null,
        backgroundColor = null;

  factory CommonButton.safetyCheck({
    required bool Function() safetyCheck,
    void Function()? action,
    required Widget child,
  }) {
    if (!safetyCheck()) {
      return CommonButton.destructive(
        onLongPress: action,
        child: child,
      );
    }

    return CommonButton(
      onTap: action,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor(context);

    return InkWell(
      highlightColor: color.withAlpha(75),
      borderRadius: borderRadius,
      onTap: onTap,
      onLongPress: onLongPress,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(
            color: textStyle(context).color!,
          ),
          color: color.withAlpha(150),
        ),
        child: SizeDependentPadding.all(
          _paddingRatio,
          calculationBase: CalculationBase.smallerSide,
          child: child,
        ),
      ),
    );
  }

  Color _resolveColor(BuildContext context) {
    if (backgroundColor != null) {
      return backgroundColor!;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return isDestructive ? colorScheme.error : colorScheme.primary;
  }
}

const _paddingRatio = 0.075;
