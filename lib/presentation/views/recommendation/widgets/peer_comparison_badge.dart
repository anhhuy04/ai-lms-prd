import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// PeerComparisonBadge: Anonymous percentile badge.
/// Shows "Thu top X%" for top performers (percentile <= 25) with trending_up icon.
/// Shows "Thu X% cua lop" for others.
/// Per REC-03: NO student names, only anonymous aggregates.
class PeerComparisonBadge extends StatelessWidget {
  final double percentile;
  final double? classAverage;

  const PeerComparisonBadge({
    super.key,
    required this.percentile,
    this.classAverage,
  });

  @override
  Widget build(BuildContext context) {
    final isTop = percentile <= 25;
    final color = isTop ? DesignColors.success : DesignColors.warning;

    final label = isTop
        ? 'Thu top ${percentile.toStringAsFixed(0)}%'
        : 'Thu ${percentile.toStringAsFixed(0)}% cua lop';

    return Tooltip(
      message: classAverage != null
          ? 'Trung binh lop: ${classAverage!.toStringAsFixed(1)}'
          : '',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.sm,
          vertical: DesignSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignRadius.full),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isTop ? Icons.trending_up : Icons.trending_flat,
              size: DesignIcons.xsSize,
              color: color,
            ),
            SizedBox(width: DesignSpacing.xs),
            Text(
              label,
              style: DesignTypography.labelSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
