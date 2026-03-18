import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/analytics/class_analytics.dart';

class GradeDistributionChart extends StatelessWidget {
  final List<ClassDistribution> distribution;
  final double height;

  const GradeDistributionChart({
    super.key,
    required this.distribution,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (distribution.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No grade data available',
            style: DesignTypography.bodyMedium.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          barGroups: distribution.asMap().entries.map((entry) {
            final color = _getBarColor(entry.value.rangeStart);
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.count.toDouble(),
                  color: color,
                  width: 24,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) =>
                  Text('${value.toInt()}', style: DesignTypography.caption),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < distribution.length) {
                    final dist = distribution[index];
                    return Text(
                      '${dist.rangeStart}-${dist.rangeEnd}',
                      style: DesignTypography.caption,
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => DesignColors.white,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final dist = distribution[groupIndex];
                return BarTooltipItem(
                  '${dist.rangeStart}-${dist.rangeEnd}: ${dist.count} students',
                  DesignTypography.caption,
                );
              },
            ),
          ),
        ),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  Color _getBarColor(int rangeStart) {
    if (rangeStart >= 80) return DesignColors.success;
    if (rangeStart >= 60) return DesignColors.primary;
    if (rangeStart >= 40) return DesignColors.warning;
    return DesignColors.error;
  }
}
