import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';

class ClassOverviewCard extends StatelessWidget {
  final double classAverage;
  final int totalStudents;
  final int totalSubmissions;
  final int totalExpectedSubmissions;
  /// Số HS đã nộp ÍT NHẤT 1 bài (dedupe). Khác `totalSubmissions` (số lượt nộp).
  final int participatingStudents;
  final double? highestScore;
  final double? lowestScore;
  final double? submissionRate;
  final double? lateSubmissionRate;
  final int? lateSubmissionCount;
  final int? lateSubmissionTotal;
  final String? worstOffenderName;
  final int? worstOffenderCount;

  const ClassOverviewCard({
    super.key,
    required this.classAverage,
    required this.totalStudents,
    required this.totalSubmissions,
    required this.totalExpectedSubmissions,
    this.participatingStudents = 0,
    this.highestScore,
    this.lowestScore,
    this.submissionRate,
    this.lateSubmissionRate,
    this.lateSubmissionCount,
    this.lateSubmissionTotal,
    this.worstOffenderName,
    this.worstOffenderCount,
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
            'Tổng quan lớp học',
            style: DesignTypography.titleMedium.copyWith(
              color: DesignColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: DesignSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: Icons.analytics,
                  value: '${classAverage.toStringAsFixed(1)}/10',
                  label: 'Điểm TB',
                ),
              ),
              Expanded(
                child: _MetricTile(
                  icon: Icons.people_outline,
                  value: '$totalStudents',
                  label: 'Học sinh',
                ),
              ),
              Expanded(
                child: _MetricTile(
                  icon: Icons.assignment_turned_in_outlined,
                  value: '$totalSubmissions',
                  label: 'Lượt nộp',
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          Divider(color: DesignColors.white.withValues(alpha: 0.25), height: 1),
          SizedBox(height: DesignSpacing.sm),
          _buildDetails(),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    final onTimeStr = submissionRate != null
        ? '${(submissionRate! * 100).toStringAsFixed(0)}%'
        : '-';
    final lateStr = lateSubmissionRate != null
        ? '${(lateSubmissionRate! * 100).toStringAsFixed(0)}%'
        : '-';

    return Column(
      children: [
        // Row 1: Đã tham gia (HS) | Lượt nộp (events)
        // - "Đã tham gia": HS đã nộp ít nhất 1 bài / sĩ số. Trả lời "lớp có ai chưa làm bài không?"
        // - "Lượt nộp": tổng lượt nộp / tổng lượt mong đợi (HS × dist). Trả lời "tiến độ chung của lớp".
        Row(
          children: [
            Expanded(
              child: _DetailChip(
                icon: Icons.how_to_reg_outlined,
                label: 'Đã tham gia',
                value: '$participatingStudents/$totalStudents',
              ),
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: _DetailChip(
                icon: Icons.assignment_turned_in_outlined,
                label: 'Lượt nộp',
                value: '$totalSubmissions/$totalExpectedSubmissions',
              ),
            ),
          ],
        ),
        SizedBox(height: DesignSpacing.sm),
        // Row 1.5: Đúng hạn | (placeholder để cân layout)
        Row(
          children: [
            Expanded(
              child: _DetailChip(
                icon: Icons.check_circle_outline,
                label: 'Đúng hạn',
                value: onTimeStr,
              ),
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: _DetailChip(
                icon: Icons.schedule,
                label: 'Nộp muộn',
                value: lateStr,
              ),
            ),
          ],
        ),
        SizedBox(height: DesignSpacing.sm),
        // Row 2: Cao nhất | Thấp nhất
        Row(
          children: [
            Expanded(
              child: _DetailChip(
                icon: Icons.trending_up,
                label: 'Cao nhất',
                value: highestScore != null
                    ? '${highestScore!.toStringAsFixed(1)}/10'
                    : '-',
              ),
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: _DetailChip(
                icon: Icons.trending_down,
                label: 'Thấp nhất',
                value: lowestScore != null
                    ? '${lowestScore!.toStringAsFixed(1)}/10'
                    : '-',
              ),
            ),
          ],
        ),
        // Row 3: Worst offender (nếu có)
        if (worstOffenderName != null &&
            worstOffenderCount != null &&
            worstOffenderCount! > 0) ...[
          SizedBox(height: DesignSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _DetailChip(
                  icon: Icons.warning_amber,
                  label: worstOffenderName!.length > 10
                      ? '${worstOffenderName!.substring(0, 10)}...'
                      : worstOffenderName!,
                  value: '$worstOffenderCount muộn',
                ),
              ),
              SizedBox(width: DesignSpacing.sm),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: DesignColors.white.withValues(alpha: 0.9), size: 20.w),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: DesignColors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: DesignColors.white.withValues(alpha: 0.75)),
        ),
      ],
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: DesignColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.w, color: DesignColors.white.withValues(alpha: 0.8)),
          SizedBox(width: 4.w),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 10.sp, color: DesignColors.white.withValues(alpha: 0.8)),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: DesignColors.white),
          ),
        ],
      ),
    );
  }
}
