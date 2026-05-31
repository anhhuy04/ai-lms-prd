import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/profile.dart';
import 'package:flutter/material.dart';

/// Chữ cái đại diện avatar: lấy chữ đầu của TÊN (từ cuối trong họ tên VN),
/// vd "Nguyễn Khánh Toàn" → "T". Rỗng → "?".
String avatarInitialFromName(String? fullName) {
  final parts = (fullName ?? '').trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.last.isEmpty) return '?';
  return parts.last[0].toUpperCase();
}

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
    final initial = avatarInitialFromName(profile?.fullName);
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

/// Header chào mừng cho tab Home (mobile): gộp avatar + lời chào + tên thành một
/// khối. Avatar dùng chữ đầu của TÊN. Thay cho [DashboardTopBar] ở tab Home để
/// hiển thị tên đẹp khi không có sidebar (mobile).
class HomeGreetingBar extends StatelessWidget {
  final Profile? profile;
  final List<Widget>? actions;

  const HomeGreetingBar({
    super.key,
    this.profile,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fullName = profile?.fullName?.trim() ?? '';
    final displayName = fullName.isNotEmpty ? fullName : 'bạn';
    final initial = avatarInitialFromName(profile?.fullName);
    final hasAvatar = profile?.avatarUrl?.isNotEmpty == true;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: isDark ? const Color(0xFF1A2632) : Colors.white,
      padding: EdgeInsets.fromLTRB(
        DesignSpacing.lg,
        topPadding + DesignSpacing.md,
        DesignSpacing.sm,
        DesignSpacing.md,
      ),
      child: Row(
        children: [
          // ── Avatar (viền tròn nhẹ) ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: DesignColors.primary.withValues(alpha: 0.25),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: DesignColors.primary.withValues(alpha: 0.12),
              backgroundImage:
                  hasAvatar ? NetworkImage(profile!.avatarUrl!) : null,
              child: hasAvatar
                  ? null
                  : Text(
                      initial,
                      style: const TextStyle(
                        color: DesignColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: DesignSpacing.md),

          // ── Lời chào + tên ──────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chào mừng trở lại,',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isDark ? Colors.white54 : DesignColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // ── Actions (chuông) ────────────────────────────────────────────
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
