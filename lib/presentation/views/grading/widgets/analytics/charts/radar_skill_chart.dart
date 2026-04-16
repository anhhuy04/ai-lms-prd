import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/constants/design_tokens.dart';
import '../../../../../../domain/entities/analytics/skill_mastery.dart';

class RadarSkillChart extends StatelessWidget {
  final List<SkillMastery> skills;
  final double height;

  const RadarSkillChart({super.key, required this.skills, this.height = 300});

  @override
  Widget build(BuildContext context) {
    // RadarChart requires at least 3 data points
    if (skills.length < 3) {
      return SizedBox(
        height: height,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.radar, size: 48, color: DesignColors.textSecondary.withValues(alpha: 0.4)),
              const SizedBox(height: DesignSpacing.sm),
              Text(
                skills.isEmpty
                    ? 'Chưa có dữ liệu kỹ năng'
                    : 'Cần ít nhất 3 kỹ năng để hiển thị biểu đồ\n(hiện có ${skills.length})',
                textAlign: TextAlign.center,
                style: DesignTypography.bodyMedium.copyWith(
                  color: DesignColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Limit to 8 skills for better visualization
    final displaySkills = skills.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: RadarChart(
            RadarChartData(
              dataSets: [
                RadarDataSet(
                  fillColor: DesignColors.primary.withValues(alpha: 0.2),
                  borderColor: DesignColors.primary,
                  borderWidth: 2,
                  entryRadius: 3,
                  dataEntries: displaySkills
                      .map((skill) => RadarEntry(value: skill.masteryLevel * 100))
                      .toList(),
                ),
              ],
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: const BorderSide(
                color: DesignColors.primary,
                width: 2,
              ),
              gridBorderData: const BorderSide(
                color: DesignColors.dividerLight,
                width: 1,
              ),
              titleTextStyle: DesignTypography.caption.copyWith(
                fontWeight: FontWeight.bold,
              ),
              getTitle: (index, angle) {
                if (index < displaySkills.length) {
                  return RadarChartTitle(
                    text: 'KN${index + 1}',
                    angle: 0, // Keep labels horizontal (no rotation)
                  );
                }
                return const RadarChartTitle(text: '');
              },
              tickCount: 5,
              ticksTextStyle: DesignTypography.caption.copyWith(
                color: DesignColors.textSecondary,
              ),
              tickBorderData: const BorderSide(color: DesignColors.dividerLight),
            ),
            duration: const Duration(milliseconds: 400),
          ),
        ),
        const SizedBox(height: DesignSpacing.md),
        // Legend below the chart
        Container(
          padding: const EdgeInsets.all(DesignSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DesignRadius.md),
            boxShadow: [DesignElevation.level1],
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
