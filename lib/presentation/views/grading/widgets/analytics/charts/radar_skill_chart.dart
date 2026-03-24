import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/constants/design_tokens.dart';
import '../../../../../../domain/entities/analytics/skill_mastery.dart';

class RadarSkillChart extends StatelessWidget {
  final List<SkillMastery> skills;
  final double height;

  const RadarSkillChart({
    super.key,
    required this.skills,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No skill data available',
            style: DesignTypography.bodyMedium.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
        ),
      );
    }

    // Limit to 8 skills for better visualization
    final displaySkills = skills.take(8).toList();

    return SizedBox(
      height: height,
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: DesignColors.primary.withValues(alpha: 0.2),
              borderColor: DesignColors.primary,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: displaySkills.map((skill) =>
                RadarEntry(value: skill.masteryLevel * 100)
              ).toList(),
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarBorderData: const BorderSide(color: DesignColors.primary, width: 2),
          gridBorderData: const BorderSide(color: DesignColors.dividerLight, width: 1),
          titleTextStyle: DesignTypography.caption,
          getTitle: (index, angle) {
            if (index < displaySkills.length) {
              return RadarChartTitle(
                text: displaySkills[index].skillName,
                angle: angle,
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
    );
  }
}
