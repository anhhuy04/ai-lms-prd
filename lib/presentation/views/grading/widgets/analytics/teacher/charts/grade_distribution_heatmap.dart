import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/analytics/class_analytics.dart';

/// Heatmap showing grade distribution across score buckets for each subject/assignment.
/// Header row is STICKY (does not scroll with data rows).
/// Data rows scrollable vertically, max 5 visible at a time (scrollable when > 5).
class GradeDistributionHeatmap extends StatelessWidget {
  final List<SubjectDistribution>? subjects;
  final double height;
  static const int _maxVisibleRows = 5;
  static const _bucketLabels = ['0-4', '4-6', '6-8', '8-10'];

  const GradeDistributionHeatmap({
    super.key,
    this.subjects,
    this.height = 300,
  });

  /// Fixed height for the header row — used to constrain ListView properly.
  double get _headerHeight => 36.0;

  @override
  Widget build(BuildContext context) {
    final data = subjects ?? [];
    if (data.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: DesignColors.white,
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          border: Border.all(color: DesignColors.dividerLight),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Center(
          child: Text(
            'Không có dữ liệu phân bố',
            style: DesignTypography.bodyMedium.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.dividerLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header — always visible at top (fixed height)
          SizedBox(
            height: _headerHeight,
            child: _buildHeader(),
          ),
          // Data rows (tối đa 5 hàng hiển thị, quá thì scroll)
          _buildDataRows(data),
        ],
      ),
    );
  }

  double get _rowHeight => 52.0;

  double _rowsViewportHeight(int rowCount) {
    final visibleRows = rowCount > _maxVisibleRows ? _maxVisibleRows : rowCount;
    return visibleRows * _rowHeight;
  }

  /// Header row — always visible (sticky). Does not scroll.
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: DesignColors.moonLight,
        border: Border(
          bottom: BorderSide(color: DesignColors.dividerLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Subject name column
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Text(
                'Môn học',
                style: DesignTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Bucket label columns
          ..._bucketLabels.map((label) => Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 12,
                ),
                child: Text(
                  label,
                  style: DesignTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  /// Data rows — tối đa 5 hàng hiển thị, quá thì scroll
  Widget _buildDataRows(List<SubjectDistribution> data) {
    final rowCount = data.length;

    return SizedBox(
      height: _rowsViewportHeight(rowCount),
      child: ListView.separated(
        physics: rowCount > _maxVisibleRows
            ? const BouncingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: data.length,
        separatorBuilder: (_, __) =>
            Container(height: 1, color: DesignColors.dividerLight),
        itemBuilder: (context, index) => _buildRow(context, data[index]),
      ),
    );
  }

  Widget _buildRow(BuildContext context, SubjectDistribution subject) {
    final buckets = [
      subject.below50Count,
      subject.below60Count,
      subject.below80Count,
      subject.above80Count,
    ];
    final bucketStudents = [
      subject.below50Students,
      subject.below60Students,
      subject.below80Students,
      subject.above80Students,
    ];

    return SizedBox(
      height: _rowHeight,
      child: Row(
        children: [
          // Subject name
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  subject.subjectName,
                  style: DesignTypography.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // Bucket cells
          ...buckets.asMap().entries.map((e) => _dataCell(
            context,
            e.value,
            e.key,
            bucketStudents[e.key],
          )),
        ],
      ),
    );
  }

  void _showStudentsBottomSheet(
    BuildContext context,
    int bucketIndex,
    List<StudentScoreItem> students,
  ) {
    if (students.isEmpty) return;

    final labels = ['0-4', '4-6', '6-8', '8-10'];
    final colors = [
      DesignColors.error,
      DesignColors.warning,
      Colors.orange,
      DesignColors.success,
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DesignColors.dividerMedium,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.only(
              top: DesignSpacing.md,
              left: DesignSpacing.md,
              right: DesignSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[bucketIndex],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Học sinh điểm ${labels[bucketIndex]}',
                  style: DesignTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Student list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: DesignSpacing.md,
                  vertical: 4,
                ),
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: colors[bucketIndex].withValues(alpha: 0.15),
                  child: Text(
                    student.studentName.isNotEmpty
                        ? student.studentName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: colors[bucketIndex],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                title: Text(
                  student.studentName,
                  style: DesignTypography.bodyMedium,
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors[bucketIndex].withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(student.score / 10).toStringAsFixed(1)}',
                    style: TextStyle(
                      color: colors[bucketIndex],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _dataCell(
    BuildContext context,
    int count,
    int bucketIndex,
    List<StudentScoreItem> students,
  ) {
    final color = _getBucketColor(bucketIndex);
    final bgColor = count > 0
        ? color.withValues(alpha: 0.2 + (count.clamp(1, 5) * 0.15).clamp(0.2, 0.9))
        : DesignColors.moonLight.withValues(alpha: 0.3);
    final textColor = count > 0 ? color : DesignColors.textSecondary;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: GestureDetector(
          onTap: count > 0
              ? () => _showStudentsBottomSheet(context, bucketIndex, students)
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              count > 0 ? '$count' : '-',
              style: DesignTypography.bodySmall.copyWith(
                color: textColor,
                fontWeight: count > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBucketColor(int bucketIndex) {
    switch (bucketIndex) {
      case 0: return DesignColors.error;
      case 1: return DesignColors.warning;
      case 2: return Colors.orange;
      case 3: return DesignColors.success;
      default: return DesignColors.textSecondary;
    }
  }
}
