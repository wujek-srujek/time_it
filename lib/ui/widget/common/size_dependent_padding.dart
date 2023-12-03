import 'dart:math';

import 'package:flutter/material.dart';

enum CalculationBase {
  width,
  height,

  /// Whatever the smaller side is.
  ///
  /// Changes depending on device rotation.
  smallerSide,
}

/// Padding based on current screen size.
///
/// It uses the [Padding] widget internally, after calculating pixel paddings
/// for each side based on [MediaQueryData.size].
class SizeDependentPadding extends StatelessWidget {
  final double left;
  final double top;
  final double right;
  final double bottom;
  final CalculationBase horizontalCalculationBase;
  final CalculationBase verticalCalculationBase;
  final Widget child;

  const SizeDependentPadding({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.horizontalCalculationBase,
    required this.verticalCalculationBase,
    required this.child,
  })  : assert(left >= 0),
        assert(top >= 0),
        assert(right >= 0),
        assert(bottom >= 0);

  const SizeDependentPadding.all(
    double value, {
    required CalculationBase calculationBase,
    required Widget child,
  }) : this(
          left: value,
          top: value,
          right: value,
          bottom: value,
          horizontalCalculationBase: calculationBase,
          verticalCalculationBase: calculationBase,
          child: child,
        );

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final horizontalBase = _pickBase(screenSize, horizontalCalculationBase);
    final verticalBase = _pickBase(screenSize, verticalCalculationBase);

    final leftPixel = horizontalBase * left;
    final topPixel = verticalBase * top;
    final rightPixel = horizontalBase * right;
    final bottomPixel = verticalBase * bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        leftPixel,
        topPixel,
        rightPixel,
        bottomPixel,
      ),
      child: child,
    );
  }

  double _pickBase(Size size, CalculationBase calculationBase) {
    return switch (calculationBase) {
      CalculationBase.width => size.width,
      CalculationBase.height => size.height,
      CalculationBase.smallerSide => min(size.width, size.height),
    };
  }
}
