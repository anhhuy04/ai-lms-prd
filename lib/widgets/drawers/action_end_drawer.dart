import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';

/// Khung chung cho tất cả các drawer bên phải
/// Sử dụng Scaffold.endDrawer để hiển thị menu tùy chọn
class ActionEndDrawer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const ActionEndDrawer({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Bọc nội dung drawer trong RepaintBoundary để tránh vẽ lại toàn màn khi mở
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85, // ~85% màn hình
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: DesignElevation.level3.blurRadius,
      child: RepaintBoundary(
        child: SafeArea(
          child: Column(
            children: [
              // HEADER với title, subtitle và nút đóng
              _buildHeader(context),
              const Divider(height: 1, color: DesignColors.dividerLight),

              // BODY - nội dung chính
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }

  /// Header drawer với thông tin
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        DesignSpacing.lg,
        DesignSpacing.md,
        DesignSpacing.lg,
        DesignSpacing.sm, // Giảm padding bottom cho hợp lý hơn
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: DesignTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            SizedBox(height: DesignSpacing.xs),
            Text(
              subtitle!,
              style: DesignTypography.bodySmall.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
