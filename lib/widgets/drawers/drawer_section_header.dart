import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';

/// Header cho các section trong drawer
/// Hiển thị tiêu đề section với kiểu dáng nhất quán
class DrawerSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;

  const DrawerSectionHeader({
    super.key,
    required this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.md,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: DesignIcons.smSize,
              color: DesignColors.textSecondary,
            ),
            SizedBox(width: DesignSpacing.sm),
          ],
          Text(
            title,
            style: DesignTypography.labelMedium.copyWith(
              color: DesignColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
