import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';

/// Tile hành động trong drawer
/// Hiển thị một mục hành động với icon, tiêu đề, phụ đề và nút mở rộng
class DrawerActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool showChevron;
  final Widget? trailing;
  final bool showNotificationDot;
  final String? notificationCount;

  const DrawerActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.showChevron = false,
    this.trailing,
    this.showNotificationDot = false,
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignRadius.md),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        child: Row(
          children: [
            // Icon bên trái
            _buildIconContainer(context),
            SizedBox(width: spacing.md),

            // Nội dung chính
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DesignTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    // maxLines: 2,
                    // overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: spacing.xs),
                    Text(
                      subtitle!,
                      style: DesignTypography.bodySmall.copyWith(
                        color: DesignColors.textSecondary,
                      ),
                      // maxLines: 2,
                      // overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Phần bên phải (chevron hoặc custom trailing)
            if (trailing != null)
              trailing!
            else if (showChevron)
              Icon(
                Icons.chevron_right,
                size: DesignIcons.smSize,
                color: DesignColors.textTertiary,
              ),

            // Notification dot (nếu có)
            if (showNotificationDot)
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignColors.error,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Container chứa icon với nền và màu sắc
  Widget _buildIconContainer(BuildContext context) {
    return Container(
      width: DesignComponents.avatarSmall,
      height: DesignComponents.avatarSmall,
      decoration: BoxDecoration(
        color: iconColor?.withValues(alpha: 0.1) ?? DesignColors.moonMedium,
        borderRadius: BorderRadius.circular(DesignRadius.full),
      ),
      child: Icon(
        icon,
        size: DesignIcons.mdSize,
        color: iconColor ?? DesignColors.drawerIcon,
      ),
    );
  }
}
