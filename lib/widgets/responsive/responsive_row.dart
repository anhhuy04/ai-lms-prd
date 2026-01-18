import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';

/// Row widget with responsive spacing and alignment
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final MainAxisSize? mainAxisSize;
  final double? spacing;
  final bool wrapOnMobile;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.mainAxisSize,
    this.spacing,
    this.wrapOnMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    final effectiveSpacing = spacing ?? config.itemSpacing;

    // On mobile, optionally wrap to column if wrapOnMobile is true
    if (isMobile && wrapOnMobile) {
      return Column(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        mainAxisSize: mainAxisSize ?? MainAxisSize.max,
        children: _buildSpacedChildren(effectiveSpacing, isVertical: true),
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      mainAxisSize: mainAxisSize ?? MainAxisSize.max,
      children: _buildSpacedChildren(effectiveSpacing, isVertical: false),
    );
  }

  List<Widget> _buildSpacedChildren(double spacing, {required bool isVertical}) {
    if (children.isEmpty) return [];
    if (children.length == 1) return children;

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        if (isVertical) {
          spacedChildren.add(SizedBox(height: spacing));
        } else {
          spacedChildren.add(SizedBox(width: spacing));
        }
      }
    }
    return spacedChildren;
  }
}

