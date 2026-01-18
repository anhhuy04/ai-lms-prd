import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';

/// Container that automatically adjusts padding and spacing based on device type
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final Alignment? alignment;
  final BoxConstraints? constraints;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.alignment,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    final defaultPadding = padding ?? EdgeInsets.all(config.screenPadding);
    final defaultMargin = margin;

    return Container(
      padding: defaultPadding,
      margin: defaultMargin,
      color: color,
      decoration: decoration,
      width: width,
      height: height,
      alignment: alignment,
      constraints: constraints,
      child: child,
    );
  }
}
