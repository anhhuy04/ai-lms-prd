import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/constants/design_tokens.dart';
import '../../../../../../domain/entities/analytics/grade_trend.dart';

class LineTrendChart extends StatelessWidget {
  final List<GradeTrend> trends;
  final double height;

  LineTrendChart({
    super.key,
    required this.trends,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No trend data available',
            style: DesignTypography.bodyMedium.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final spots = trends.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.score,
      );
    }).toList();

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: DesignColors.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: DesignColors.primary.withOpacity(0.1),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) =>
                  Text('${value.toInt()}', style: DesignTypography.caption),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < trends.length) {
                    return Text(
                      _formatDate(trends[index].date),
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
          minY: 0,
          maxY: 100,
        ),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}
