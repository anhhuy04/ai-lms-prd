import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/analytics/class_analytics.dart';

class BottomPerformersList extends StatelessWidget {
  final List<StudentPerformance> performers;
  final Function(String studentId)? onTap;

  const BottomPerformersList({
    super.key,
    required this.performers,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(DesignSpacing.md),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: DesignColors.error,
                  size: DesignIcons.mdSize,
                ),
                SizedBox(width: DesignSpacing.sm),
                Text(
                  'Cần chú ý',
                  style: DesignTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: performers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final performer = performers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: DesignColors.error.withValues(alpha: 0.2),
                  child: Text(
                    '${index + 1}',
                    style: DesignTypography.labelMedium.copyWith(
                      color: DesignColors.error,
                    ),
                  ),
                ),
                title: Text(
                  performer.studentName,
                  style: DesignTypography.bodyMedium,
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignSpacing.sm,
                    vertical: DesignSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: DesignColors.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DesignRadius.md),
                  ),
                  child: Text(
                    '${performer.score.toStringAsFixed(1)}/10',
                    style: DesignTypography.labelMedium.copyWith(
                      color: DesignColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                onTap: () => onTap?.call(performer.studentId),
              );
            },
          ),
        ],
      ),
    );
  }
}
