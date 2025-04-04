// Flutter imports:
import 'package:flutter/material.dart';

/// A custom TextButton widget with an icon placed above the label.
class FlatIconTextButton extends TextButton {
  /// Creates a [FlatIconTextButton] widget with the specified properties.
  ///
  /// The [icon] and [label] parameters are required, while the others are
  /// optional.
  FlatIconTextButton({
    super.key,
    super.onPressed,
    super.clipBehavior,
    super.focusNode,
    double spacing = 5.0,
    required Widget icon,
    required Widget label,
  }) : super(
          // style: TextButton.styleFrom(
          //   // padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
          //   maximumSize:
          //       const Size(double.infinity, kBottomNavigationBarHeight),
          // ),
          child: icon);
        //   Column(
        //     mainAxisSize: MainAxisSize.min,
        //     children: <Widget>[
        //       ,
        //       // SizedBox(height: spacing),
        //       // label,
        //     ],
        //   ),
        // );
}
