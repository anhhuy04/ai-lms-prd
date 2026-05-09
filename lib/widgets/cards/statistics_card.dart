import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Widget hiển thị statistics card với icon, label và value
/// Khác với BaseCard: không có icon, có border, layout đơn giản hơn
class StatisticsCard extends StatelessWidget {
  final String label;
  final int value;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData? icon;
  final VoidCallback? onTap;

  const StatisticsCard({
    super.key,
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(DesignRadius.lg);

    final content = Column(
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
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 16, color: textColor.withValues(alpha: 0.6)),
          ],
        ),
        SizedBox(height: DesignSpacing.xs),
        Text(
          value.toString(),
          style: DesignTypography.headlineLarge.copyWith(
            color: isDark ? DesignColors.white : DesignColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return Material(
        color: backgroundColor,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            padding: EdgeInsets.all(DesignSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: borderColor, width: 1),
            ),
            child: content,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: content,
    );
  }
}
