import 'package:flutter/material.dart';

extension OrientationX on Orientation {
  Axis asAxis() =>
      this == Orientation.portrait ? Axis.vertical : Axis.horizontal;
}
