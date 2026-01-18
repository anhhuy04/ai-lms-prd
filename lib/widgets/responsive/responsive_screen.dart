import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/constants/device_types.dart';

/// Screen wrapper that automatically applies responsive layout
class ResponsiveScreen extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final bool useMaxWidth;
  final double? maxContentWidth;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const ResponsiveScreen({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.useMaxWidth = true,
    this.maxContentWidth,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    final deviceType = ResponsiveUtils.getDeviceType(context);

    // Select appropriate widget based on device type
    Widget content;
    switch (deviceType) {
      case DeviceType.mobile:
        content = mobile;
        break;
      case DeviceType.tablet:
        content = tablet ?? mobile;
        break;
      case DeviceType.desktop:
        content = desktop ?? tablet ?? mobile;
        break;
    }

    // Apply max width constraint if needed
    if (useMaxWidth) {
      final effectiveMaxWidth = maxContentWidth ?? config.maxContentWidth;
      
      if (effectiveMaxWidth != double.infinity && effectiveMaxWidth > 0) {
        content = Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: effectiveMaxWidth,
            ),
            child: content,
          ),
        );
      }
    }

    // Apply padding
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: config.screenPadding,
    );

    return Container(
      color: backgroundColor ?? DesignColors.moonLight,
      padding: effectivePadding,
      child: content,
    );
  }
}
