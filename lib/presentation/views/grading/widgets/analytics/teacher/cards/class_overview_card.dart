import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';

class ClassOverviewCard extends StatelessWidget {
  final double classAverage;
  final int totalStudents;
  final int totalSubmissions;
  final double? highestScore;
  final double? lowestScore;

  const ClassOverviewCard({
    super.key,
    required this.classAverage,
    required this.totalStudents,
    required this.totalSubmissions,
    this.highestScore,
    this.lowestScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignColors.primary,
            DesignColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Class Performance',
            style: DesignTypography.titleMedium.copyWith(
              color: DesignColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: DesignSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric(
                'Average',
                '${classAverage.toStringAsFixed(1)}%',
                Icons.analytics,
              ),
              _buildMetric(
                'Students',
                '$totalStudents',
                Icons.people,
              ),
              _buildMetric(
                'Submissions',
                '$totalSubmissions',
                Icons.assignment,
              ),
            ],
          ),
          if (highestScore != null && lowestScore != null) ...[
            SizedBox(height: DesignSpacing.md),
            Divider(color: DesignColors.white.withValues(alpha: 0.3)),
            SizedBox(height: DesignSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Highest: ${highestScore!.toStringAsFixed(1)}%',
                  style: DesignTypography.caption.copyWith(
                    color: DesignColors.white.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  'Lowest: ${lowestScore!.toStringAsFixed(1)}%',
                  style: DesignTypography.caption.copyWith(
                    color: DesignColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: DesignColors.white, size: DesignIcons.mdSize),
        SizedBox(height: DesignSpacing.xs),
        Text(
          value,
          style: TextStyle(
            fontSize: DesignTypography.headlineSmallSize,
            color: DesignColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: DesignTypography.caption.copyWith(
            color: DesignColors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
