import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/profile.dart';
import 'package:flutter/material.dart';

/// Thanh tiêu đề thống nhất cho tất cả tab trong Teacher Dashboard.
///
/// - Mobile/tablet: hiển thị trong body phía trên, không dùng native AppBar
///   để tránh xung đột với extendBody.
/// - Wide/desktop: ẩn đi vì sidebar layout đã có thông tin profile.
///
/// [selectedIndex] xác định tab nào đang active để render đúng tiêu đề.
class DashboardTopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final Profile? profile;
  final List<Widget>? actions;
  final bool showAvatar;

  const DashboardTopBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.profile,
    this.actions,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = profile?.fullName ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: isDark ? const Color(0xFF1A2632) : Colors.white,
      padding: EdgeInsets.fromLTRB(
        DesignSpacing.lg,
        topPadding + DesignSpacing.sm,
        DesignSpacing.sm,
        DesignSpacing.sm,
      ),
      child: Row(
        children: [
          // ── Title block ─────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white54
                        : DesignColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // ── Actions ────────────────────────────────────────────────────
          if (actions != null) ...actions!,
          if (actions != null && showAvatar) const SizedBox(width: 8),

          // ── Avatar ─────────────────────────────────────────────────────
          if (showAvatar) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: DesignColors.primary.withValues(alpha: 0.12),
              backgroundImage: (profile?.avatarUrl?.isNotEmpty == true)
                  ? NetworkImage(profile!.avatarUrl!)
                  : null,
              child: (profile?.avatarUrl?.isNotEmpty == true)
                  ? null
                  : Text(
                      initial,
                      style: const TextStyle(
                        color: DesignColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
            const SizedBox(width: DesignSpacing.sm),
          ],
        ],
      ),
    );
  }
}
