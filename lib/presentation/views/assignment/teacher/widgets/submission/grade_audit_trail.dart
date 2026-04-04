import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/grade_override.dart';

/// Widget hiển thị lịch sử override điểm (audit trail).
class GradeAuditTrail extends StatelessWidget {
  final List<GradeOverride> history;

  const GradeAuditTrail({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.moonLight,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                size: 16,
                color: DesignColors.textSecondary,
              ),
              SizedBox(width: DesignSpacing.xs),
              Text(
                'Lịch sử chỉnh sửa điểm',
                style: DesignTypography.labelMedium.copyWith(
                  color: DesignColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.sm),
          ...history.map((entry) => _buildEntry(entry)),
        ],
      ),
    );
  }

  Widget _buildEntry(GradeOverride entry) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignSpacing.sm),
      child: Row(
        children: [
          Text(
            '${entry.oldScore.toStringAsFixed(1)} → ${entry.newScore.toStringAsFixed(1)}',
            style: DesignTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: entry.newScore > entry.oldScore
                  ? DesignColors.success
                  : DesignColors.error,
            ),
          ),
          if (entry.reason != null && entry.reason!.isNotEmpty) ...[
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Text(
                entry.reason!,
                style: DesignTypography.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
