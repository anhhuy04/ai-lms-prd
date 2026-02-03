import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Base card widget với icon, label và số lượng
/// Tái sử dụng code chung giữa các card widgets
class BaseCard extends StatelessWidget {
  final String label;
  final int count;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? borderColor;

  const BaseCard({
    super.key,
    required this.label,
    required this.count,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.md,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                label,
                style: DesignTypography.bodySmall.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              SizedBox(width: DesignSpacing.xs),
              _buildIcon(context),
            ],
          ),
          SizedBox(height: DesignSpacing.xs),
          Text(
            count.toString(),
            style: DesignTypography.headlineMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardContent);
    }

    return cardContent;
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: DesignComponents.avatarSmall,
      height: DesignComponents.avatarSmall,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(DesignRadius.full),
        boxShadow: [DesignElevation.level1],
      ),
      child: Icon(icon, size: DesignIcons.smSize, color: iconColor),
    );
  }
}
