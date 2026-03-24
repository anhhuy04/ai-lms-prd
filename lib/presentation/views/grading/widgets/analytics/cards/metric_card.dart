import 'package:flutter/material.dart';
import '../../../../../../core/constants/design_tokens.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? trendColor;
  final String? trendText;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.trendColor,
    this.trendText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: DesignColors.white,
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          border: Border.all(color: DesignColors.dividerLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: DesignIcons.smSize, color: DesignColors.textSecondary),
                  SizedBox(width: DesignSpacing.xs),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: DesignTypography.bodySmall.copyWith(
                      color: DesignColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              value,
              style: DesignTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (trendText != null) ...[
              SizedBox(height: DesignSpacing.xs),
              Row(
                children: [
                  if (trendColor != null)
                    Icon(
                      trendColor == DesignColors.success
                          ? Icons.trending_up
                          : trendColor == DesignColors.error
                              ? Icons.trending_down
                              : Icons.trending_flat,
                      size: DesignIcons.xsSize,
                      color: trendColor,
                    ),
                  SizedBox(width: DesignSpacing.xs),
                  Expanded(
                    child: Text(
                      trendText!,
                      style: DesignTypography.caption.copyWith(
                        color: trendColor ?? DesignColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
