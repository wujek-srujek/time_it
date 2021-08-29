import 'package:flutter/material.dart';

import 'common_features.dart';
import 'filled_box.dart';
import 'size_dependent_padding.dart';

enum CommonButtonVariant {
  /// A destructive button which supports long pressing only and uses
  /// [ColorScheme.error] for its background color.
  destructive,

  /// A primary button which supports tapping, long pressing and uses
  /// [ColorScheme.secondary] for its background color. There should most likely
  /// be at most one such botton per page.
  ///
  /// The 'primary' variant uses `ColorScheme.secondary` (I know, confusing) as
  /// this is what FABs use, and this button is king of a replacement for them.
  primary,

  /// A standard button which supports tapping, long pressing and uses
  /// [ColorScheme.primary] background color.
  ///
  /// The 'standard' variant uses `ColorScheme.primary` (I know, confusing) as
  /// this is what most buttons in this application should look like.
  standard,
}

/// A button used throughout this app.
///
/// It supports variants defined in [CommonButtonVariant].
///
/// If a `CommonButton` changes its variant (e.g. from destructive to standard),
/// it may be useful to use the [CommonButton.safetyCheck] factory and let it
/// decide dynamically which variant it should represent.
class CommonButton extends StatelessWidget {
  final CommonButtonVariant variant;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final Widget child;

  const CommonButton({
    this.onTap,
    this.onLongPress,
    required this.child,
  }) : variant = CommonButtonVariant.standard;

  const CommonButton.destructive({
    this.onLongPress,
    required this.child,
  })  : variant = CommonButtonVariant.destructive,
        onTap = null;

  const CommonButton.primary({
    this.onTap,
    required this.child,
  })  : variant = CommonButtonVariant.primary,
        onLongPress = null;

  factory CommonButton.safetyCheck({
    required bool Function() safetyCheck,
    CommonButtonVariant variantIfSafe = CommonButtonVariant.standard,
    void Function()? action,
    required Widget child,
  }) {
    assert(variantIfSafe != CommonButtonVariant.destructive);

    if (!safetyCheck()) {
      return CommonButton.destructive(
        onLongPress: action,
        child: child,
      );
    }

    if (variantIfSafe == CommonButtonVariant.primary) {
      return CommonButton.primary(
        onTap: action,
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
    final color = _resolveColor(Theme.of(context).colorScheme);

    return InkWell(
      highlightColor: color.withAlpha(75),
      borderRadius: allCircularBorderRadius,
      onTap: onTap,
      onLongPress: onLongPress,
      child: FilledBox(
        color: color.withAlpha(150),
        child: SizeDependentPadding.all(
          _paddingRatio,
          calculationBase: CalculationBase.smallerSide,
          child: child,
        ),
      ),
    );
  }

  Color _resolveColor(ColorScheme colorScheme) {
    switch (variant) {
      case CommonButtonVariant.destructive:
        return colorScheme.error;
      // The following two are a bit confusing, see [CommonButtonVariant] docs
      // for an explanation.
      case CommonButtonVariant.primary:
        return colorScheme.secondary;
      case CommonButtonVariant.standard:
        return colorScheme.primary;
    }
  }
}

const _paddingRatio = 0.075;
