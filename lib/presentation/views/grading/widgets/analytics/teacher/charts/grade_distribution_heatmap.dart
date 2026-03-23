import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/constants/design_tokens.dart';

/// Heatmap showing grade distribution across score buckets for each subject/assignment.
/// Rows = subjects (max 5 visible, scrollable)
/// Columns = score buckets: 0-4, 4-6, 6-8, 8-10
/// Cell color intensity based on student count.
class GradeDistributionHeatmap extends StatelessWidget {
  /// List of subject distributions, each containing bucket counts.
  /// If null/empty, shows empty state.
  final List<SubjectDistribution>? subjects;
  final double height;

  const GradeDistributionHeatmap({
    super.key,
    this.subjects,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    final data = subjects ?? [];
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Khong co du lieu phan bo',
            style: DesignTypography.bodyMedium.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
        ),
      );
    }

    // Show max 5 rows, scroll if more
    final displayData = data.take(5).toList();

    return SizedBox(
      height: height,
      child: Column(
        children: [
          // Header row: bucket labels
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(DesignSpacing.sm),
                  child: Text('Mon hoc', style: DesignTypography.caption),
                ),
              ),
              ..._bucketLabels.map((label) => Expanded(
                child: Container(
                  padding: EdgeInsets.all(DesignSpacing.sm),
                  alignment: Alignment.center,
                  child: Text(label, style: DesignTypography.caption),
                ),
              )),
            ],
          ),
          const Divider(height: 1),
          // Data rows
          Expanded(
            child: ListView.separated(
              itemCount: displayData.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final sub = displayData[index];
                return _buildRow(sub);
              },
            ),
          ),
        ],
      ),
    );
  }

  static const _bucketLabels = ['0-4', '4-6', '6-8', '8-10'];

  Widget _buildRow(SubjectDistribution subject) {
    final buckets = [
      subject.below50Count,
      subject.below60Count,
      subject.below80Count,
      subject.above80Count,
    ];

    return Row(
      children: [
        // Subject name
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.all(DesignSpacing.sm),
            alignment: Alignment.centerLeft,
            child: Text(
              subject.subjectName,
              style: DesignTypography.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // Bucket cells
        ...buckets.asMap().entries.map((entry) => Expanded(
          child: _dataCell(entry.value, entry.key),
        )),
      ],
    );
  }

  Widget _dataCell(int count, int bucketIndex) {
    final color = _getBucketColor(bucketIndex);
    final bgColor = count > 0
        ? color.withValues(alpha: (0.2 + (count.clamp(1, 5) * 0.15)).clamp(0.2, 0.9))
        : DesignColors.moonLight.withValues(alpha: 0.3);
    final textColor = count > 0 ? color : DesignColors.textSecondary;

    return Container(
      margin: EdgeInsets.all(2.r),
      padding: EdgeInsets.symmetric(vertical: DesignSpacing.xs),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(DesignRadius.sm),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 0 ? '$count' : '-',
        style: DesignTypography.caption.copyWith(
          color: textColor,
          fontWeight: count > 0 ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Color _getBucketColor(int bucketIndex) {
    // 0-4=red, 4-6=amber, 6-8=orange, 8-10=green
    switch (bucketIndex) {
      case 0: return DesignColors.error;
      case 1: return const Color(0xFFFFB300); // amber-600
      case 2: return const Color(0xFFFF9800); // orange
      case 3: return DesignColors.success;
      default: return DesignColors.textSecondary;
    }
  }
}

/// Data model for a single subject's grade distribution across score buckets.
class SubjectDistribution {
  final String subjectName;
  final int below50Count; // 0-4 range
  final int below60Count; // 4-6 range
  final int below80Count; // 6-8 range
  final int above80Count;  // 8-10 range

  const SubjectDistribution({
    required this.subjectName,
    this.below50Count = 0,
    this.below60Count = 0,
    this.below80Count = 0,
    this.above80Count = 0,
  });
}
