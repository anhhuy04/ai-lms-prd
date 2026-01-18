import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';

/// Padding widget that automatically adjusts based on device type
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? all;
  final double? horizontal;
  final double? vertical;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.padding,
    this.all,
    this.horizontal,
    this.vertical,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    final config = ResponsiveUtils.getLayoutConfig(context);

    EdgeInsets effectivePadding;
    if (padding != null) {
      effectivePadding = padding!;
    } else if (all != null) {
      effectivePadding = EdgeInsets.all(all!);
    } else {
      effectivePadding = EdgeInsets.only(
        top: top ?? vertical ?? config.screenPadding,
        bottom: bottom ?? vertical ?? config.screenPadding,
        left: left ?? horizontal ?? config.screenPadding,
        right: right ?? horizontal ?? config.screenPadding,
      );
    }

    return Padding(
      padding: effectivePadding,
      child: child,
    );
  }
}
