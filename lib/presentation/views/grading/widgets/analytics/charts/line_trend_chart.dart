import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/constants/design_tokens.dart';
import '../../../../../../domain/entities/analytics/grade_trend.dart';

class LineTrendChart extends StatelessWidget {
  final List<GradeTrend> trends;
  final double height;

  /// Số bài tối đa hiển thị mà không cần scroll
  static const int _maxVisible = 10;

  /// Chiều rộng mỗi điểm dữ liệu khi cần scroll
  static const double _itemWidth = 58.0;

  /// Chiều cao dành cho nhãn trục X dưới cùng
  static const double _bottomTitlesHeight = 28.0;

  /// Padding trên để dot tại điểm max không bị cắt
  static const double _topPadding = 10.0;

  const LineTrendChart({
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
            'Chưa có dữ liệu xu hướng điểm',
            style: DesignTypography.bodyMedium.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final spots = trends.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.score);
    }).toList();

    final needsScroll = trends.length > _maxVisible;

    if (!needsScroll) {
      // Không cần scroll — chart bình thường có Y-axis
      return SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.only(top: _topPadding),
          child: _buildChart(spots, showYAxis: true),
        ),
      );
    }

    // Cần scroll: Y-axis cố định bên trái, phần data scroll ngang
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Cột Y-axis cố định ──
          _buildFixedYAxis(),
          // ── Vùng chart scroll ngang ──
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: trends.length * _itemWidth,
                child: Padding(
                  padding: const EdgeInsets.only(top: _topPadding),
                  child: _buildChart(spots, showYAxis: false),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Y-axis cố định — tự vẽ nhãn căn chỉnh với vùng chart
  Widget _buildFixedYAxis() {
    const labels = ['10', '8', '6', '4', '2', '0'];
    return SizedBox(
      width: 32,
      child: Padding(
        // top: _topPadding để căn với chart; bottom: _bottomTitlesHeight để tránh nhãn X
        padding: const EdgeInsets.only(
          top: _topPadding,
          bottom: _bottomTitlesHeight,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels
              .map(
                (l) => Text(
                  l,
                  style: DesignTypography.caption.copyWith(
                    color: DesignColors.textSecondary,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.right,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  /// Xây dựng LineChart, ẩn/hiện Y-axis theo [showYAxis]
  Widget _buildChart(List<FlSpot> spots, {required bool showYAxis}) {
    return LineChart(
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
              color: DesignColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: showYAxis,
              reservedSize: 32,
              interval: 2,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: DesignTypography.caption.copyWith(
                  color: DesignColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: _bottomTitlesHeight,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < trends.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _formatDate(trends[index].date),
                      style: DesignTypography.caption.copyWith(
                        color: DesignColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: DesignColors.dividerLight,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 10,
        clipData: const FlClipData.none(), // không cắt dot tại maxY
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) =>
                DesignColors.textPrimary.withValues(alpha: 0.85),
            tooltipRoundedRadius: DesignRadius.sm,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final trend = trends[spot.spotIndex];
                final classLine = trend.className != null
                    ? '\n${trend.className}'
                    : '';
                return LineTooltipItem(
                  '${trend.assignmentName}$classLine\n',
                  DesignTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: '${trend.score.toStringAsFixed(1)} điểm',
                      style: DesignTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
      duration: const Duration(milliseconds: 400),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}';
}
