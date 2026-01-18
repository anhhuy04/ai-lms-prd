import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/constants/design_tokens.dart';

/// Card widget with responsive sizing and padding
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;
  final Border? border;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final BoxDecoration? decoration;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.shape,
    this.border,
    this.gradient,
    this.boxShadow,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    final effectivePadding = padding ?? EdgeInsets.all(config.cardPadding);
    final effectiveMargin = margin;
    final effectiveElevation = elevation ?? 0.0;
    final effectiveShape = shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.cardRadius),
        );

    // Use provided decoration or build one from individual properties
    final effectiveDecoration = decoration ??
        BoxDecoration(
          color: gradient == null ? (color ?? Colors.white) : null,
          gradient: gradient,
          borderRadius: _getBorderRadius(effectiveShape),
          border: border,
          boxShadow: boxShadow ??
              (effectiveElevation > 0 ? [DesignElevation.cardShadow] : null),
        );

    Widget cardContent = Container(
      padding: effectivePadding,
      decoration: effectiveDecoration,
      child: child,
    );

    if (effectiveMargin != null) {
      cardContent = Container(
        margin: effectiveMargin,
        child: cardContent,
      );
    }

    return cardContent;
  }

  /// Extract border radius from shape or use default
  BorderRadius? _getBorderRadius(ShapeBorder shape) {
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius as BorderRadius?;
    }
    return BorderRadius.circular(DesignRadius.cardRadius);
  }
}
