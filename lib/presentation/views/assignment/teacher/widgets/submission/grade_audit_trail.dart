import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';

/// Widget hiển thị lịch sử override điểm (audit trail).
class GradeAuditTrail extends StatelessWidget {
  final List<Map<String, dynamic>> history;

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

  Widget _buildEntry(Map<String, dynamic> entry) {
    final oldScore = entry['old_score'] as num?;
    final newScore = entry['new_score'] as num?;
    final reason = entry['reason'] as String?;

    return Padding(
      padding: EdgeInsets.only(bottom: DesignSpacing.sm),
      child: Row(
        children: [
          if (oldScore != null && newScore != null) ...[
            Text(
              '${oldScore.toStringAsFixed(1)} → ${newScore.toStringAsFixed(1)}',
              style: DesignTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: newScore > oldScore
                    ? DesignColors.success
                    : DesignColors.error,
              ),
            ),
          ],
          if (reason != null && reason.isNotEmpty) ...[
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Text(
                reason,
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
