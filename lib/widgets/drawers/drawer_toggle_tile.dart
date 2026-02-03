import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

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
    final spacing = context.spacing;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(DesignRadius.md),
      child: Padding(
        padding: EdgeInsets.only(
          left: spacing.md,
          right: 0, // Sát lề phải cho switch
          top: spacing.sm,
          bottom: spacing.sm,
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
                  color: DesignColors.drawerIcon,
                ),
              ),
              SizedBox(width: spacing.md),
            ],

            // Nội dung chính
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: titleStyle ?? defaultTitleStyle,
                    // maxLines: 1,
                    // overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: spacing.xs),
                    Text(
                      subtitle!,
                      style: subtitleStyle ?? defaultSubtitleStyle,
                      //   maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ],
                ],
              ),
            ),

            // Switch bên phải với kích cỡ tùy chỉnh, sát lề phải
            Transform.scale(
              scale: switchScale ?? defaultSwitchScale,
              child: Switch(
                value: value,
                onChanged: onChanged,
                thumbColor: WidgetStateProperty.all(Colors.white),
                activeTrackColor: DesignColors.drawerSwitchActive,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: DesignColors.drawerSwitchInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
