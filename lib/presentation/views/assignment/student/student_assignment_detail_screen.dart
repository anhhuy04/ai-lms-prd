import 'dart:math' as math;

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/presentation/providers/student_assignment_providers.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Màn hình chi tiết bài tập dành cho học sinh.
///
/// 3 trạng thái chính:
///   • Chưa làm      (submission == null)
///   • Đang làm dở   (status == 'in_progress')
///   • Đã nộp        (submitted / graded / ai_processing / pending_review)
///
/// Sau khi nộp, hiển thị theo settings.student_review_mode:
///   • 'none'        → chỉ thông báo đã nộp thành công, ẩn hết điểm
///   • 'score_only'  → score card + trạng thái
///   • 'full_review' → đầy đủ: điểm, thời gian, thống kê, AI feedback
class StudentAssignmentDetailScreen extends ConsumerStatefulWidget {
  final String distributionId;

  const StudentAssignmentDetailScreen({
    super.key,
    required this.distributionId,
  });

  @override
  ConsumerState<StudentAssignmentDetailScreen> createState() =>
      _StudentAssignmentDetailScreenState();
}

class _StudentAssignmentDetailScreenState
    extends ConsumerState<StudentAssignmentDetailScreen> {
  Future<void> _refresh() async {
    ref.invalidate(studentAssignmentDetailProvider(widget.distributionId));
    ref.invalidate(studentSubmissionProvider(widget.distributionId));
    // Đợi cả 2 provider load xong
    await Future.wait([
      ref.read(studentAssignmentDetailProvider(widget.distributionId).future),
      ref.read(studentSubmissionProvider(widget.distributionId).future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug(
      '🔵 [DetailScreen] distributionId=${widget.distributionId}',
    );
    final detailAsync =
        ref.watch(studentAssignmentDetailProvider(widget.distributionId));
    final submissionAsync =
        ref.watch(studentSubmissionProvider(widget.distributionId));

    if (detailAsync.isLoading || submissionAsync.isLoading) {
      return const _LoadingScaffold();
    }
    if (detailAsync.hasError) {
      return _ErrorScaffold(error: detailAsync.error!);
    }

    final detail = detailAsync.value!;
    final assignment = detail['assignment'] as Map<String, dynamic>? ?? {};
    final distribution =
        detail['distribution'] as Map<String, dynamic>? ?? {};
    final questions = detail['questions'] as List<dynamic>? ?? [];
    final settings =
        distribution['settings'] as Map<String, dynamic>? ?? {};

    final title = assignment['title'] as String? ?? 'Bài tập';
    final reviewMode =
        settings['student_review_mode'] as String? ?? 'full_review';
    final aiEnabled = settings['ai_feedback_enabled'] as bool? ?? false;
    final maxAttempts = settings['max_attempts'] as int?;

    final submission = submissionAsync.value;
    final status = submission?['status'] as String? ?? 'not_started';

    final isSubmitted = status == 'submitted' ||
        status == 'graded' ||
        status == 'ai_processing' ||
        status == 'pending_review';
    final isInProgress = status == 'in_progress';

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      body: Column(
        children: [
          _AppBar(title: title, isSubmitted: isSubmitted),
          Expanded(
            child: isSubmitted
                ? _SubmittedView(
                    assignment: assignment,
                    distribution: distribution,
                    questions: questions,
                    submission: submission!,
                    distributionId: widget.distributionId,
                    reviewMode: reviewMode,
                    aiEnabled: aiEnabled,
                    maxAttempts: maxAttempts,
                    onRefresh: _refresh,
                  )
                : _PendingView(
                    assignment: assignment,
                    distribution: distribution,
                    questions: questions,
                    submission: submission,
                    isInProgress: isInProgress,
                    distributionId: widget.distributionId,
                    onRefresh: _refresh,
                  ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// AppBar
// ═══════════════════════════════════════════════════════════

class _AppBar extends StatelessWidget {
  final String title;
  final bool isSubmitted;

  const _AppBar({required this.title, required this.isSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DesignColors.white,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56.h,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                iconSize: DesignIcons.smSize,
                color: DesignColors.textPrimary,
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: DesignTypography.bodyMediumSize,
                    fontWeight: DesignTypography.bold,
                    color: DesignColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSubmitted)
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  iconSize: DesignIcons.smSize,
                  color: DesignColors.textSecondary,
                  onPressed: () {},
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Loading / Error
// ═══════════════════════════════════════════════════════════

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: DesignColors.moonLight,
      body: ShimmerDashboardLoading(),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final Object error;
  const _ErrorScaffold({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.w, color: DesignColors.error),
              const SizedBox(height: DesignSpacing.md),
              Text(
                'Không tải được thông tin bài tập',
                style: DesignTypography.bodyLarge
                    .copyWith(color: DesignColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TRẠNG THÁI: CHƯA LÀM / ĐANG LÀM DỞ
// ═══════════════════════════════════════════════════════════

class _PendingView extends StatelessWidget {
  final Map<String, dynamic> assignment;
  final Map<String, dynamic> distribution;
  final List<dynamic> questions;
  final Map<String, dynamic>? submission;
  final bool isInProgress;
  final String distributionId;
  final Future<void> Function() onRefresh;

  const _PendingView({
    required this.assignment,
    required this.distribution,
    required this.questions,
    required this.submission,
    required this.isInProgress,
    required this.distributionId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final dueAt = distribution['due_at'] as String?;
    final timeLimitMinutes = distribution['time_limit_minutes'] as int?;
    final totalPoints = assignment['total_points'] as num?;
    final description = assignment['description'] as String?;
    final answeredCount = submission?['answered_count'] as int? ?? 0;
    final totalQuestions = questions.length;

    DateTime? dueDateTime;
    if (dueAt != null) dueDateTime = DateTime.tryParse(dueAt);

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            color: DesignColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              DesignSpacing.md,
              DesignSpacing.lg,
              DesignSpacing.md,
              DesignSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isInProgress && totalQuestions > 0) ...[
                  _ProgressCard(
                    answeredCount: answeredCount,
                    totalQuestions: totalQuestions,
                  ),
                  const SizedBox(height: DesignSpacing.xl),
                ],
                const _SectionLabel(label: 'Thông tin bài tập'),
                const SizedBox(height: DesignSpacing.sm),
                _AssignmentInfoCard(
                  dueDateTime: dueDateTime,
                  timeLimitMinutes: timeLimitMinutes,
                  totalPoints: totalPoints,
                  totalQuestions: totalQuestions,
                  isInProgress: isInProgress,
                  sessionStartedAt: isInProgress
                      ? (() {
                          final raw = submission?['started_at'] as String?;
                          return raw != null ? DateTime.tryParse(raw) : null;
                        })()
                      : null,
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: DesignSpacing.xl),
                  const _SectionLabel(label: 'Hướng dẫn làm bài'),
                  const SizedBox(height: DesignSpacing.sm),
                  _InstructionsCard(description: description),
                ],
                SizedBox(height: 88.h),
              ],
            ),
          ),
          ), // RefreshIndicator
        ),
        _PendingFooter(
          isInProgress: isInProgress,
          distributionId: distributionId,
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int answeredCount;
  final int totalQuestions;

  const _ProgressCard({
    required this.answeredCount,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final percent =
        totalQuestions > 0 ? answeredCount / totalQuestions : 0.0;

    return Container(
      padding: const EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: DesignColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border:
            Border.all(color: DesignColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64.w,
            height: 64.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(64.w, 64.w),
                  painter: _CircularProgressPainter(
                    progress: percent,
                    trackColor: DesignColors.primary.withValues(alpha: 0.14),
                    progressColor: DesignColors.primary,
                    strokeWidth: 5,
                  ),
                ),
                Text(
                  '${(percent * 100).round()}%',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: DesignTypography.bold,
                    color: DesignColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DesignSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Đang làm dở',
                      style: TextStyle(
                        fontSize: DesignTypography.bodyMediumSize,
                        fontWeight: DesignTypography.bold,
                        color: DesignColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: DesignColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DesignRadius.sm),
                      ),
                      child: Text(
                        'TIẾP TỤC',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: DesignTypography.bold,
                          color: DesignColors.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Đã hoàn thành $answeredCount/$totalQuestions câu hỏi.',
                  style: TextStyle(
                    fontSize: DesignTypography.bodySmallSize,
                    color: DesignColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentInfoCard extends StatelessWidget {
  final DateTime? dueDateTime;
  final int? timeLimitMinutes;
  final num? totalPoints;
  final int totalQuestions;
  final bool isInProgress;
  final DateTime? sessionStartedAt;

  const _AssignmentInfoCard({
    this.dueDateTime,
    this.timeLimitMinutes,
    this.totalPoints,
    required this.totalQuestions,
    this.isInProgress = false,
    this.sessionStartedAt,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isExpired = dueDateTime != null && now.isAfter(dueDateTime!);

    // Tính thời điểm hết giờ làm bài (chỉ khi đang làm dở + có limit + có started_at)
    DateTime? examDeadline;
    if (isInProgress && sessionStartedAt != null && timeLimitMinutes != null) {
      examDeadline = sessionStartedAt!.add(Duration(minutes: timeLimitMinutes!));
    }
    final examDeadlineExpired = examDeadline != null && now.isAfter(examDeadline);

    return Column(
      children: [
        if (dueDateTime != null)
          _InfoTile(
            icon: Icons.event_busy_outlined,
            iconColor: isExpired ? DesignColors.error : Colors.red.shade400,
            label: 'Hạn nộp bài',
            value: _fmtDate(dueDateTime!),
            valueColor: isExpired ? DesignColors.error : null,
          ),

        // Khi đang làm dở + có giới hạn thời gian → hiển thị bắt đầu & hết giờ
        if (isInProgress && sessionStartedAt != null) ...[
          _InfoTile(
            icon: Icons.play_circle_outline,
            iconColor: DesignColors.primary,
            label: 'Bắt đầu lúc',
            value: _fmtDate(sessionStartedAt!),
          ),
          if (examDeadline != null)
            _InfoTile(
              icon: Icons.timer_off_outlined,
              iconColor: examDeadlineExpired ? DesignColors.error : Colors.orange.shade600,
              label: 'Hết giờ lúc',
              value: _fmtDate(examDeadline),
              valueColor: examDeadlineExpired ? DesignColors.error : null,
            ),
        ] else ...[
          // Khi chưa bắt đầu → hiển thị thời gian tối đa được phép
          Row(
            children: [
              if (timeLimitMinutes != null) ...[
                Expanded(
                  child: _InfoTile(
                    icon: Icons.timer_outlined,
                    iconColor: DesignColors.primary,
                    label: 'Thời gian tối đa',
                    value: '$timeLimitMinutes phút',
                  ),
                ),
                const SizedBox(width: DesignSpacing.sm),
              ],
              if (totalPoints != null && totalPoints! > 0)
                Expanded(
                  child: _InfoTile(
                    icon: Icons.workspace_premium_outlined,
                    iconColor: Colors.amber.shade600,
                    label: 'Tổng điểm',
                    value: '${totalPoints!.toStringAsFixed(0)}đ',
                  ),
                ),
            ],
          ),
        ],

        // Tổng điểm hàng riêng khi đang làm dở (vì row trên bị thay bởi 2 dòng thời gian)
        if (isInProgress && totalPoints != null && totalPoints! > 0)
          _InfoTile(
            icon: Icons.workspace_premium_outlined,
            iconColor: Colors.amber.shade600,
            label: 'Tổng điểm',
            value: '${totalPoints!.toStringAsFixed(0)}đ',
          ),

        if (totalQuestions > 0)
          _InfoTile(
            icon: Icons.quiz_outlined,
            iconColor: DesignColors.tealPrimary,
            label: 'Số câu hỏi',
            value: '$totalQuestions câu',
          ),
      ],
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}'
      ' - ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.sm),
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DesignColors.moonLight,
              borderRadius: BorderRadius.circular(DesignRadius.md),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: DesignTypography.bold,
                    color: DesignColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: DesignTypography.bodySmallSize,
                    fontWeight: DesignTypography.semiBold,
                    color: valueColor ?? DesignColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  final String description;
  const _InstructionsCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: Text(
        description,
        style: TextStyle(
          fontSize: DesignTypography.bodySmallSize,
          color: DesignColors.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }
}

class _PendingFooter extends StatelessWidget {
  final bool isInProgress;
  final String distributionId;

  const _PendingFooter({
    required this.isInProgress,
    required this.distributionId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        DesignSpacing.lg,
        DesignSpacing.md,
        DesignSpacing.lg,
        DesignSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: DesignColors.white,
        border: Border(top: BorderSide(color: DesignColors.dividerLight)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton.icon(
              onPressed: () => context.pushNamed(
                AppRoute.studentAssignmentWorkspace,
                pathParameters: {'distributionId': distributionId},
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.primary,
                foregroundColor: DesignColors.white,
                elevation: 3,
                shadowColor: DesignColors.primary.withValues(alpha: 0.28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.lg),
                ),
              ),
              icon: const Icon(Icons.play_circle_outlined, size: 22),
              label: Text(
                isInProgress ? 'Tiếp tục làm bài' : 'Bắt đầu làm bài',
                style: const TextStyle(
                  fontSize: DesignTypography.bodyLargeSize,
                  fontWeight: DesignTypography.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Hệ thống sẽ tự động lưu tiến trình của bạn',
            style: TextStyle(fontSize: 10.sp, color: DesignColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TRẠNG THÁI: ĐÃ NỘP
// ═══════════════════════════════════════════════════════════

class _SubmittedView extends StatelessWidget {
  final Map<String, dynamic> assignment;
  final Map<String, dynamic> distribution;
  final List<dynamic> questions;
  final Map<String, dynamic> submission;
  final String distributionId;
  final String reviewMode;
  final bool aiEnabled;
  final int? maxAttempts;
  final Future<void> Function() onRefresh;

  const _SubmittedView({
    required this.assignment,
    required this.distribution,
    required this.questions,
    required this.submission,
    required this.distributionId,
    required this.reviewMode,
    required this.aiEnabled,
    this.maxAttempts,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final score = submission['score'] as num?;
    final totalPoints = (assignment['total_points'] as num?) ?? 10;
    final status = submission['status'] as String? ?? 'submitted';
    final timeTakenSec = submission['time_taken_seconds'] as num?;
    final correctCount = submission['correct_count'] as int?;
    final wrongCount = submission['wrong_count'] as int?;
    final totalAnswered = submission['answered_count'] as int? ?? 0;
    final aiGraded = submission['ai_graded'] as bool? ?? false;

    final startedAtRaw = submission['started_at'] as String?;
    final submittedAtRaw =
        (submission['work_session_submitted_at'] ?? submission['submitted_at'])
            as String?;
    final startDt =
        startedAtRaw != null ? DateTime.tryParse(startedAtRaw) : null;
    final endDt =
        submittedAtRaw != null ? DateTime.tryParse(submittedAtRaw) : null;

    String? timeTakenLabel;
    if (timeTakenSec != null) {
      final mins = (timeTakenSec / 60).floor();
      final secs = timeTakenSec.toInt() % 60;
      timeTakenLabel = mins > 0
          ? "$mins phút${secs > 0 ? ' $secs giây' : ''}"
          : '$secs giây';
    }

    final totalQuestions = questions.length;
    final displayTotal =
        totalAnswered > 0 ? totalAnswered : totalQuestions;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            color: DesignColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Điểm số hoặc banner ẩn
                  if (reviewMode != 'none')
                  _ScoreCard(
                    score: score,
                    totalPoints: totalPoints,
                    status: status,
                  )
                else
                  _HiddenResultBanner(),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DesignSpacing.md),
                  child: Column(
                    children: [
                      const SizedBox(height: DesignSpacing.md),

                      // Thời gian (chỉ full_review)
                      if (reviewMode == 'full_review') ...[
                        _TimeInfoCard(startDt: startDt, endDt: endDt),
                        const SizedBox(height: DesignSpacing.md),
                      ],

                      // Thống kê đúng/sai/thời gian (chỉ full_review)
                      if (reviewMode == 'full_review' &&
                          (correctCount != null ||
                              timeTakenLabel != null)) ...[
                        _StatsRow(
                          correctCount: correctCount,
                          wrongCount: wrongCount,
                          totalQuestions: displayTotal,
                          timeTakenLabel: timeTakenLabel,
                        ),
                        const SizedBox(height: DesignSpacing.md),
                      ],

                      // AI feedback (full_review + ai enabled + graded)
                      if (reviewMode == 'full_review' &&
                          aiEnabled &&
                          (aiGraded ||
                              status == 'ai_processing')) ...[
                        const _AiFeedbackCard(),
                        const SizedBox(height: DesignSpacing.md),
                      ],

                      SizedBox(height: 88.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ), // RefreshIndicator
        ),
        _SubmittedFooter(
          distributionId: distributionId,
          reviewMode: reviewMode,
        ),
      ],
    );
  }
}

class _HiddenResultBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(DesignSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: DesignColors.success.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border:
            Border.all(color: DesignColors.success.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 56.w,
            color: DesignColors.success,
          ),
          const SizedBox(height: DesignSpacing.md),
          const Text(
            'Nộp bài thành công!',
            style: TextStyle(
              fontSize: DesignTypography.bodyLargeSize,
              fontWeight: DesignTypography.bold,
              color: DesignColors.textPrimary,
            ),
          ),
          const SizedBox(height: DesignSpacing.sm),
          Text(
            'Giáo viên đã ẩn kết quả bài làm.\nVui lòng chờ thông báo từ giáo viên.',
            style: TextStyle(
              fontSize: DesignTypography.bodySmallSize,
              color: DesignColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final num? score;
  final num totalPoints;
  final String status;

  const _ScoreCard({
    required this.score,
    required this.totalPoints,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final String statusLabel;
    switch (status) {
      case 'graded':
        statusLabel = 'Đã chấm điểm';
        break;
      case 'ai_processing':
        statusLabel = 'AI đang phân tích';
        break;
      case 'pending_review':
        statusLabel = 'Chờ giáo viên duyệt';
        break;
      default:
        statusLabel = 'Đã hoàn thành';
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [DesignColors.white, DesignColors.moonLight],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        DesignSpacing.lg,
        DesignSpacing.xl,
        DesignSpacing.lg,
        DesignSpacing.xl,
      ),
      child: Container(
        padding: const EdgeInsets.all(DesignSpacing.xl),
        decoration: BoxDecoration(
          color: DesignColors.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: DesignColors.primary.withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -8,
              right: -8,
              child: Icon(
                Icons.assignment_turned_in_outlined,
                size: 96.w,
                color: DesignColors.white.withValues(alpha: 0.08),
              ),
            ),
            Column(
              children: [
                Text(
                  'KẾT QUẢ BÀI LÀM',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: DesignTypography.bold,
                    color: DesignColors.white.withValues(alpha: 0.75),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: DesignSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      score != null
                          ? score!.toStringAsFixed(score! % 1 == 0 ? 0 : 1)
                          : '--',
                      style: TextStyle(
                        fontSize: 52.sp,
                        fontWeight: FontWeight.w800,
                        color: DesignColors.white,
                        fontStyle: FontStyle.italic,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/ ${totalPoints.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: DesignTypography.medium,
                        color: DesignColors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSpacing.md,
                    vertical: DesignSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: DesignColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DesignRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          size: 14, color: DesignColors.white),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: DesignTypography.semiBold,
                          color: DesignColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeInfoCard extends StatelessWidget {
  final DateTime? startDt;
  final DateTime? endDt;

  const _TimeInfoCard({this.startDt, this.endDt});

  String _fmt(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}'
      ' - ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DesignColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.md),
            ),
            child: const Icon(Icons.schedule_outlined,
                size: 20, color: DesignColors.primary),
          ),
          const SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THỜI GIAN THỰC HIỆN',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: DesignTypography.bold,
                    color: DesignColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                _TimeRow(
                  label: 'Bắt đầu:',
                  value: startDt != null ? _fmt(startDt!) : '--',
                ),
                _TimeRow(
                  label: 'Kết thúc:',
                  value: endDt != null ? _fmt(endDt!) : '--',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String label;
  final String value;

  const _TimeRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: DesignTypography.bodySmallSize,
            color: DesignColors.textSecondary,
          ),
          children: [
            TextSpan(text: '$label '),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: DesignTypography.semiBold,
                color: DesignColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int? correctCount;
  final int? wrongCount;
  final int totalQuestions;
  final String? timeTakenLabel;

  const _StatsRow({
    this.correctCount,
    this.wrongCount,
    required this.totalQuestions,
    this.timeTakenLabel,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    if (correctCount != null) {
      items.add(Expanded(
        child: _StatChip(
          icon: Icons.check_circle_outline,
          iconColor: DesignColors.success,
          label: 'Đúng',
          value: '$correctCount/$totalQuestions',
          valueColor: DesignColors.success,
        ),
      ));
    }

    if (wrongCount != null) {
      if (items.isNotEmpty) {
        items.add(const SizedBox(width: DesignSpacing.sm));
      }
      items.add(Expanded(
        child: _StatChip(
          icon: Icons.cancel_outlined,
          iconColor: DesignColors.error,
          label: 'Sai',
          value: '$wrongCount',
          valueColor: DesignColors.error,
        ),
      ));
    }

    if (timeTakenLabel != null) {
      if (items.isNotEmpty) {
        items.add(const SizedBox(width: DesignSpacing.sm));
      }
      items.add(Expanded(
        child: _StatChip(
          icon: Icons.timer_outlined,
          iconColor: DesignColors.textSecondary,
          label: 'Thời gian',
          value: timeTakenLabel!,
          valueColor: DesignColors.textSecondary,
        ),
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();
    return Row(children: items);
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.md,
      ),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: DesignTypography.bodyMediumSize,
                    fontWeight: DesignTypography.bold,
                    color: valueColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: DesignTypography.bold,
              color: DesignColors.textTertiary,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiFeedbackCard extends StatelessWidget {
  const _AiFeedbackCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignColors.primary.withValues(alpha: 0.06),
            DesignColors.tealPrimary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border:
            Border.all(color: DesignColors.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(DesignSpacing.xs),
            decoration: BoxDecoration(
              color: DesignColors.primary,
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            child: const Icon(Icons.auto_awesome,
                size: 16, color: DesignColors.white),
          ),
          const SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phản hồi AI',
                  style: TextStyle(
                    fontSize: DesignTypography.bodySmallSize,
                    fontWeight: DesignTypography.bold,
                    color: DesignColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI đã phân tích bài làm của bạn. '
                  'Xem chi tiết trong màn hình xem lại bài làm.',
                  style: TextStyle(
                    fontSize: DesignTypography.bodySmallSize,
                    color: DesignColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmittedFooter extends StatelessWidget {
  final String distributionId;
  final String reviewMode;

  const _SubmittedFooter({
    required this.distributionId,
    required this.reviewMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        DesignSpacing.md,
        DesignSpacing.md,
        DesignSpacing.md,
        DesignSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: DesignColors.white,
        border: Border(top: BorderSide(color: DesignColors.dividerLight)),
      ),
      child: Row(
        children: [
          // Xem lại bài làm — chỉ khi full_review
          if (reviewMode == 'full_review') ...[
            Expanded(
              child: SizedBox(
                height: 52.h,
                child: OutlinedButton.icon(
                  onPressed: () => context.pushNamed(
                    AppRoute.studentSubmissionReview,
                    pathParameters: {'distributionId': distributionId},
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignColors.textSecondary,
                    side: const BorderSide(color: DesignColors.dividerLight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignRadius.lg),
                    ),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: Text(
                    'Xem lại bài làm',
                    style: TextStyle(
                      fontSize: DesignTypography.bodySmallSize,
                      fontWeight: DesignTypography.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: DesignSpacing.sm),
          ],

          // Làm lại — luôn hiện
          Expanded(
            child: SizedBox(
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: () => context.pushNamed(
                  AppRoute.studentAssignmentWorkspace,
                  pathParameters: {'distributionId': distributionId},
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.primary,
                  foregroundColor: DesignColors.white,
                  elevation: 2,
                  shadowColor: DesignColors.primary.withValues(alpha: 0.22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.lg),
                  ),
                ),
                icon: const Icon(Icons.replay, size: 18),
                label: Text(
                  'Làm lại',
                  style: TextStyle(
                    fontSize: DesignTypography.bodySmallSize,
                    fontWeight: DesignTypography.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Shared helpers
// ═══════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: DesignTypography.bold,
        color: DesignColors.textTertiary,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Circular progress painter
// ═══════════════════════════════════════════════════════════

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  const _CircularProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter old) =>
      old.progress != progress;
}
