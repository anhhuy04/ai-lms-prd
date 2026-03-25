import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/analytics/skill_mastery.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// DualRadarChart: Skill-by-skill comparison (REC-03).
/// Overlays student's mastery radar (teal, solid) over class average radar (gray, dashed).
/// Used in the peer comparison bottom sheet (tap PeerComparisonBadge).
class DualRadarChart extends StatelessWidget {
  final List<SkillMastery> studentSkills;
  final Map<String, double> classAverageSkills;
  final double height;

  const DualRadarChart({
    super.key,
    required this.studentSkills,
    required this.classAverageSkills,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    final displaySkills = studentSkills.take(8).toList();
    if (displaySkills.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Chua co du lieu ky nang',
            style: DesignTypography.bodyMedium.copyWith(color: Colors.grey),
          ),
        ),
      );
    }

    final classAvgEntries = displaySkills.map((s) {
      final avg = classAverageSkills[s.objectiveId] ?? 0.0;
      return RadarEntry(value: (avg * 100).clamp(0.0, 100.0));
    }).toList();

    return SizedBox(
      height: height,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          radarBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
          gridBorderData: BorderSide(color: Colors.grey.shade200, width: 1),
          tickBorderData: BorderSide(color: Colors.grey.shade200, width: 1),
          tickCount: 4,
          ticksTextStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 10,
          ),
          titlePositionPercentageOffset: 0.15,
          titleTextStyle: TextStyle(
            color: DesignColors.moonLight,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          getTitle: (index, angle) {
            final skillName = displaySkills[index].skillName;
            final truncated = skillName.length > 10
                ? '${skillName.substring(0, 8)}...'
                : skillName;
            return RadarChartTitle(
              text: truncated,
              angle: 0,
            );
          },
          dataSets: [
            // Student (foreground - teal, solid)
            RadarDataSet(
              fillColor: DesignColors.primary.withValues(alpha: 0.25),
              borderColor: DesignColors.primary,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: displaySkills.map((s) =>
                RadarEntry(value: (s.masteryLevel * 100).clamp(0.0, 100.0))
              ).toList(),
            ),
            // Class average (background - gray, solid thin)
            RadarDataSet(
              fillColor: Colors.grey.withValues(alpha: 0.1),
              borderColor: Colors.grey.shade400,
              borderWidth: 1,
              entryRadius: 2,
              dataEntries: classAvgEntries,
            ),
          ],
        ),
      ),
    );
  }
}
