import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';

/// Tile toggle với switch trong drawer
/// Hiển thị một mục với switch để bật/tắt tính năng
class DrawerToggleTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
  final double? iconSize;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final double? switchScale; // Kích cỡ switch (mặc định: 1.0)

  // Cài đặt mặc định cho tất cả các nút
  static double defaultIconSize = DesignIcons.mdSize;
  static double defaultSwitchScale = 0.6;
  static TextStyle defaultTitleStyle = DesignTypography.bodyMedium.copyWith(
    fontWeight: FontWeight.w500,
  );
  static TextStyle defaultSubtitleStyle = DesignTypography.bodySmall.copyWith(
    color: DesignColors.textSecondary,
  );

  const DrawerToggleTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
    this.iconSize,
    this.titleStyle,
    this.subtitleStyle,
    this.switchScale,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(DesignRadius.md),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.sm,
        ),
        child: Row(
          children: [
            // Icon bên trái (nếu có)
            if (icon != null) ...[
              Container(
                width: DesignComponents.avatarSmall,
                height: DesignComponents.avatarSmall,
                decoration: BoxDecoration(
                  color: DesignColors.moonMedium,
                  borderRadius: BorderRadius.circular(DesignRadius.full),
                ),
                child: Icon(
                  icon,
                  size: iconSize ?? defaultIconSize,
                  color: DesignColors.textSecondary,
                ),
              ),
              SizedBox(width: DesignSpacing.md),
            ],

            // Nội dung chính
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: titleStyle ?? defaultTitleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: DesignSpacing.xs),
                    Text(
                      subtitle!,
                      style: subtitleStyle ?? defaultSubtitleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Switch bên phải với kích cỡ tùy chỉnh
            Transform.scale(
              scale: switchScale ?? defaultSwitchScale,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: DesignColors.primary,
                inactiveThumbColor: DesignColors.textTertiary,
                inactiveTrackColor: DesignColors.moonMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
