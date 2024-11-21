import 'package:flutter/material.dart';

/// A class representing a margin with specified left and top values.
///
/// The `[Margin]` class is used to define the space on the left and top sides.
///
/// Properties:
/// - `[left]`: The left margin value.
/// - `[top]`: The top margin value.
/// - `[right]`: The right margin value.
/// - `[bottom]`: The bottom margin value.
class Margin {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const Margin({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });

  /// Method to convert CardEngine's `[Margin]` to the `[EdgeInsets]` from `flutter/material.dart` package. 
  EdgeInsets toEdgeInsets() {
    return EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
  }
}
