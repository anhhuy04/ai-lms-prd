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
            'Chưa có dữ liệu kỹ năng',
            style: DesignTypography.bodyMedium.copyWith(color: Colors.grey),
          ),
        ),
      );
    }

    final classAvgEntries = displaySkills.map((s) {
      final avg = classAverageSkills[s.objectiveId] ?? 0.0;
      return RadarEntry(value: (avg * 100).clamp(0.0, 100.0));
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: RadarChart(
            RadarChartData(
              radarShape: RadarShape.polygon,
              radarBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
              gridBorderData: BorderSide(color: Colors.grey.shade200, width: 1),
              tickBorderData: BorderSide(color: Colors.grey.shade200, width: 1),
              tickCount: 4,
              ticksTextStyle: TextStyle(color: Colors.grey.shade400, fontSize: 10),
              titlePositionPercentageOffset: 0.15,
              titleTextStyle: TextStyle(
                color: DesignColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              getTitle: (index, angle) {
                if (index < displaySkills.length) {
                  return RadarChartTitle(text: 'KN${index + 1}', angle: 0);
                }
                return const RadarChartTitle(text: '');
              },
              dataSets: [
                // Student (foreground - teal, solid)
                RadarDataSet(
                  fillColor: DesignColors.primary.withValues(alpha: 0.25),
                  borderColor: DesignColors.primary,
                  borderWidth: 2,
                  entryRadius: 3,
                  dataEntries: displaySkills
                      .map(
                        (s) => RadarEntry(
                          value: (s.masteryLevel * 100).clamp(0.0, 100.0),
                        ),
                      )
                      .toList(),
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
        ),
        const SizedBox(height: DesignSpacing.md),
        // Legend below the chart
        Container(
          padding: const EdgeInsets.all(DesignSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DesignRadius.md),
            border: Border.all(color: DesignColors.dividerLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chú giải kỹ năng:',
                style: DesignTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: DesignSpacing.sm),
              ...List.generate(displaySkills.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: DesignSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: DesignColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'KN${index + 1}',
                          style: DesignTypography.caption.copyWith(
                            color: DesignColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignSpacing.sm),
                      Expanded(
                        child: Text(
                          displaySkills[index].uiLabel,
                          style: DesignTypography.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
