import 'dart:math' as math;

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/redo_eligibility.dart';
import 'package:ai_mls/data/datasources/assignment_datasource.dart';
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
  bool _autoSubmitDone = false;

  Future<void> _refresh() async {
    ref.invalidate(studentAssignmentDetailProvider(widget.distributionId));
    ref.invalidate(studentSubmissionProvider(widget.distributionId));
    // Đợi cả 2 provider load xong
    await Future.wait([
      ref.read(studentAssignmentDetailProvider(widget.distributionId).future),
      ref.read(studentSubmissionProvider(widget.distributionId).future),
    ]);
  }

  Future<void> _autoSubmit() async {
    try {
      await ref.read(submitAssignmentProvider(widget.distributionId).future);
      ref.invalidate(studentSubmissionProvider(widget.distributionId));
      ref.invalidate(studentAssignmentDetailProvider(widget.distributionId));
    } catch (e) {
      AppLogger.error('Auto-submit failed: $e');
      if (mounted) setState(() => _autoSubmitDone = false);
    }
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
    final maxAttempts = (settings['max_attempts'] as num?)?.toInt();

    final submission = submissionAsync.value;
    final status = submission?['status'] as String? ?? 'not_started';

    final isSubmitted = status == 'submitted' ||
        status == 'graded' ||
        status == 'ai_processing' ||
        status == 'pending_review';
    final isInProgress = status == 'in_progress';

    // Tự động nộp bài nếu quá hạn và giáo viên không cho nộp muộn
    if (isInProgress && !_autoSubmitDone) {
      final dueAt = distribution['due_at'] as String?;
      final allowLate = distribution['allow_late'] as bool? ?? true;
      if (dueAt != null && !allowLate) {
        final dueDateTime = DateTime.tryParse(dueAt)?.toLocal();
        if (dueDateTime != null && DateTime.now().isAfter(dueDateTime)) {
          _autoSubmitDone = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => _autoSubmit());
        }
      }
    }

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
    final allowLate = distribution['allow_late'] as bool? ?? true;
    final totalPoints = assignment['total_points'] as num?;
    final description = assignment['description'] as String?;
    final answeredCount = submission?['answered_count'] as int? ?? 0;
    final totalQuestions = questions.length;

    DateTime? dueDateTime;
    if (dueAt != null) dueDateTime = DateTime.tryParse(dueAt)?.toLocal();

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
          dueDateTime: dueDateTime,
          allowLate: allowLate,
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

    DateTime? examDeadline;
    if (isInProgress && sessionStartedAt != null && timeLimitMinutes != null) {
      examDeadline = sessionStartedAt!.add(Duration(minutes: timeLimitMinutes!));
    }
    final examExpired = examDeadline != null && now.isAfter(examDeadline);

    return Column(
      children: [
        // Thẻ 1: Thời gian — nội dung khác nhau giữa chưa làm / đang làm dở
        if (isInProgress)
          _CompactInfoCard(
            icon: Icons.schedule_outlined,
            iconColor: DesignColors.primary,
            header: 'Thời gian thực hiện',
            lines: [
              (label: 'Bắt đầu lúc: ', value: sessionStartedAt != null ? _fmtDate(sessionStartedAt!) : 'Không có', valueColor: null),
              (label: 'Hết giờ lúc: ', value: examDeadline != null ? _fmtDate(examDeadline) : 'Không có', valueColor: examExpired ? DesignColors.error : null),
              (label: 'Hạn nộp bài: ', value: dueDateTime != null ? _fmtDate(dueDateTime!) : 'Không có', valueColor: isExpired ? DesignColors.error : null),
              (label: 'Thời gian bài làm: ', value: timeLimitMinutes != null ? _fmtLimit(timeLimitMinutes!) : 'Không giới hạn', valueColor: null),
            ],
          )
        else
          _CompactInfoCard(
            icon: Icons.event_note_outlined,
            iconColor: Colors.red.shade400,
            header: 'Lịch kiểm tra',
            lines: [
              (label: 'Hạn nộp bài: ', value: dueDateTime != null ? _fmtDate(dueDateTime!) : 'Không có', valueColor: isExpired ? DesignColors.error : null),
              (label: 'Thời gian tối đa: ', value: timeLimitMinutes != null ? _fmtLimit(timeLimitMinutes!) : 'Không giới hạn', valueColor: null),
            ],
          ),

        // Thẻ 2: Nội dung bài tập
        const SizedBox(height: DesignSpacing.sm),
        _CompactInfoCard(
          icon: Icons.quiz_outlined,
          iconColor: DesignColors.tealPrimary,
          header: 'Thông tin bài tập',
          lines: [
            (label: 'Tổng điểm: ', value: totalPoints != null && totalPoints! > 0 ? '${totalPoints!.toStringAsFixed(0)} điểm' : 'Không có', valueColor: null),
            (label: 'Số câu hỏi: ', value: totalQuestions > 0 ? '$totalQuestions câu' : 'Không có', valueColor: null),
          ],
        ),
      ],
    );
  }

}

/// Thẻ gọn 1 icon: header UPPERCASE + các dòng "label: **value**"
/// Dùng chung cho tất cả các nhóm thông tin trong 3 trạng thái
class _CompactInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String header;
  final List<({String label, String value, Color? valueColor})> lines;

  const _CompactInfoCard({
    required this.icon,
    required this.iconColor,
    required this.header,
    required this.lines,
  });

  Widget _buildLine(String label, String value, Color? valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: DesignTypography.bodySmallSize,
            color: DesignColors.textSecondary,
          ),
          children: [
            TextSpan(text: label),
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: DesignTypography.semiBold,
                color: valueColor ?? DesignColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.08),
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
                  header.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: DesignTypography.bold,
                    color: DesignColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                ...lines.map((l) => _buildLine(l.label, l.value, l.valueColor)),
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
  final DateTime? dueDateTime;
  final bool allowLate;

  const _PendingFooter({
    required this.isInProgress,
    required this.distributionId,
    required this.dueDateTime,
    required this.allowLate,
  });

  @override
  Widget build(BuildContext context) {
    final isClosed = !allowLate &&
        dueDateTime != null &&
        DateTime.now().isAfter(dueDateTime!);

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
            child: isClosed
                ? _ClosedBanner()
                : ElevatedButton.icon(
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
            isClosed
                ? 'Bài tập đã đóng, không thể nộp bài'
                : 'Hệ thống sẽ tự động lưu tiến trình của bạn',
            style: TextStyle(fontSize: 10.sp, color: DesignColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _ClosedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignColors.moonLight,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 20, color: DesignColors.textTertiary),
          const SizedBox(width: DesignSpacing.sm),
          Text(
            'Đã quá hạn nộp bài',
            style: TextStyle(
              fontSize: DesignTypography.bodyLargeSize,
              fontWeight: DesignTypography.semiBold,
              color: DesignColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TRẠNG THÁI: ĐÃ NỘP
// ═══════════════════════════════════════════════════════════

class _SubmittedView extends ConsumerStatefulWidget {
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
  ConsumerState<_SubmittedView> createState() => _SubmittedViewState();
}

class _SubmittedViewState extends ConsumerState<_SubmittedView> {
  /// Lần làm được người dùng chọn rõ ràng; null = dùng mặc định theo rule
  Map<String, dynamic>? _selectedAttempt;

  void _onAttemptTapped(Map<String, dynamic> attempt) {
    setState(() {
      // Tap lại item đang chọn → quay về mặc định (theo rule)
      if (_selectedAttempt?['id'] == attempt['id']) {
        _selectedAttempt = null;
      } else {
        _selectedAttempt = attempt;
      }
    });
  }

  /// Tính attempt mặc định theo rule tính điểm
  Map<String, dynamic>? _pickDefault(
    List<Map<String, dynamic>> valid,
    String rule,
  ) {
    if (valid.isEmpty) return null;
    switch (rule) {
      case 'latest':
        return valid.last;
      case 'first':
        return valid.first;
      case 'max':
        Map<String, dynamic>? best;
        num bestScore = -1;
        for (final a in valid) {
          final s = _scoreOf(a) ?? -1;
          if (s > bestScore) {
            bestScore = s;
            best = a;
          }
        }
        return best;
      case 'average':
        // average: không pin lần nào → null (hiện điểm TB từ sub)
        return null;
      default:
        return valid.last;
    }
  }

  num? _scoreOf(Map<String, dynamic> a) {
    final subs = a['submissions'];
    if (subs is List && subs.isNotEmpty) {
      return subs[0]['total_score'] as num?;
    }
    final answers = a['submission_answers'];
    if (answers is List && answers.isNotEmpty) {
      num t = 0;
      for (final x in answers) {
        if (x is Map) t += (x['final_score'] as num? ?? 0);
      }
      return t;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final sub = widget.submission;
    final dist = widget.distribution;
    final asgn = widget.assignment;
    final settings = dist['settings'] as Map<String, dynamic>? ?? {};
    final scoreAggregationRule =
        settings['score_aggregation_rule'] as String? ?? 'latest';
    final allowRetake = settings['allow_retake'] as bool? ?? false;
    final timeLimitMinutes = dist['time_limit_minutes'] as int?;
    final totalPoints = (asgn['total_points'] as num?) ?? 10;
    final totalQuestions = widget.questions.length;
    final reviewMode = widget.reviewMode;
    final aiEnabled = widget.aiEnabled;

    // Watch attempts để tự chọn lần mặc định theo rule
    final attemptsAsync = ref.watch(
        studentDistributionAttemptsProvider(widget.distributionId));
    final validAttempts = attemptsAsync.valueOrNull
            ?.where((a) => a['status'] != 'in_progress')
            .toList() ??
        [];

    // Effective attempt được hiển thị: lựa chọn rõ ràng > mặc định theo rule.
    // Tính trực tiếp trong build() — không dùng postFrame setState (gây flicker).
    final defaultAttempt = validAttempts.length >= 2
        ? _pickDefault(validAttempts, scoreAggregationRule)
        : null;
    final sel = _selectedAttempt ?? defaultAttempt;
    final bool isViewing = sel != null;

    // ─── Dữ liệu hiển thị — lấy từ attempt được chọn hoặc submission hiện tại ───
    num? score;
    String status;
    num? timeTakenSec;
    int? correctCount;
    int? wrongCount;
    int totalAnswered;
    bool aiGraded;
    DateTime? startDt;
    DateTime? endDt;
    int? viewingAttemptNum;

    if (isViewing) {
      // Khi xem lần làm cũ: trích dữ liệu từ work_session được chọn
      final subs = sel['submissions'];
      final subMap = (subs is List && subs.isNotEmpty)
          ? subs[0] as Map<String, dynamic>
          : <String, dynamic>{};

      // Tính đúng/sai/đã trả lời từ submission_answers — submissions không lưu các
      // count này (submission_datasource tính động cho lần mới nhất, attempts query
      // không có), nên phải tự tính client-side từ answers.
      // Quy ước: final_score (hoặc ai_score fallback) > 0 → đúng, ngược lại → sai.
      final answersRaw = sel['submission_answers'];
      final hasAnswers = answersRaw is List && answersRaw.isNotEmpty;
      int correct = 0;
      int wrong = 0;
      num scoreSum = 0;
      if (hasAnswers) {
        for (final a in answersRaw) {
          if (a is! Map) continue;
          final eff = (a['final_score'] ?? a['ai_score'] ?? 0) as num;
          scoreSum += (a['final_score'] as num? ?? 0);
          if (eff > 0) {
            correct++;
          } else {
            wrong++;
          }
        }
      }

      score = subMap['total_score'] as num? ?? (hasAnswers ? scoreSum : null);
      status = sel['status'] as String? ?? 'graded';
      timeTakenSec = sel['time_spent_seconds'] as num?;
      correctCount = hasAnswers ? correct : (subMap['correct_count'] as int?);
      wrongCount = hasAnswers ? wrong : (subMap['wrong_count'] as int?);
      totalAnswered = hasAnswers
          ? answersRaw.length
          : (subMap['answered_count'] as int? ?? 0);
      aiGraded = subMap['ai_graded'] as bool? ?? false;
      final startedAtRaw = sel['started_at'] as String?;
      final submittedRaw = sel['submitted_at'] as String?;
      startDt = startedAtRaw != null
          ? DateTime.tryParse(startedAtRaw)?.toLocal()
          : null;
      endDt = submittedRaw != null
          ? DateTime.tryParse(submittedRaw)?.toLocal()
          : null;
      viewingAttemptNum = sel['attempt'] as int?;
    } else {
      // Khi xem lần làm mới nhất (mặc định)
      score = sub['score'] as num?;
      status = sub['status'] as String? ?? 'submitted';
      timeTakenSec = sub['time_taken_seconds'] as num?;
      correctCount = sub['correct_count'] as int?;
      wrongCount = sub['wrong_count'] as int?;
      totalAnswered = sub['answered_count'] as int? ?? 0;
      aiGraded = sub['ai_graded'] as bool? ?? false;
      final startedAtRaw = sub['started_at'] as String?;
      final submittedAtRaw =
          (sub['work_session_submitted_at'] ?? sub['submitted_at']) as String?;
      startDt = startedAtRaw != null
          ? DateTime.tryParse(startedAtRaw)?.toLocal()
          : null;
      endDt = submittedAtRaw != null
          ? DateTime.tryParse(submittedAtRaw)?.toLocal()
          : null;
      viewingAttemptNum = null;
    }

    String? timeTakenLabel;
    if (timeTakenSec != null) {
      final mins = (timeTakenSec / 60).floor();
      final secs = timeTakenSec.toInt() % 60;
      timeTakenLabel = mins > 0
          ? "$mins phút${secs > 0 ? ' $secs giây' : ''}"
          : '$secs giây';
    }

    final displayTotal = totalAnswered > 0 ? totalAnswered : totalQuestions;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            color: DesignColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Banner nhỏ gọn khi đang xem lần làm cũ
                  if (isViewing)
                    _ViewingBanner(
                      attemptNum: viewingAttemptNum ?? 1,
                      onClear: () => setState(() => _selectedAttempt = null),
                    ),

                  // Điểm số — luôn hiện, dữ liệu thay đổi theo lần được chọn
                  if (reviewMode != 'none')
                    _ScoreCard(
                      score: score,
                      totalPoints: totalPoints,
                      status: status,
                    )
                  else
                    _HiddenResultBanner(),

                  // Nhãn phương thức tính điểm — luôn hiện khi có làm lại
                  if (reviewMode != 'none' && allowRetake)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          DesignSpacing.md, DesignSpacing.xs, DesignSpacing.md, 0),
                      child: _ScoreRuleChip(rule: scoreAggregationRule),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: DesignSpacing.md),
                    child: Column(
                      children: [
                        const SizedBox(height: DesignSpacing.md),

                        // Card thời gian thực hiện — luôn hiện khi full_review.
                        // Dữ liệu thay đổi theo lần được chọn; các dòng thiếu data
                        // hiện "Không có" thay vì ẩn cả card (tránh giao diện flicker).
                        if (reviewMode == 'full_review') ...[
                          _CompactInfoCard(
                            icon: Icons.schedule_outlined,
                            iconColor: DesignColors.primary,
                            header: isViewing
                                ? 'Thời gian lần $viewingAttemptNum'
                                : 'Thời gian thực hiện',
                            lines: [
                              (
                                label: 'Bắt đầu: ',
                                value: startDt != null ? _fmtDate(startDt) : 'Không có',
                                valueColor: null,
                              ),
                              (
                                label: 'Kết thúc: ',
                                value: endDt != null ? _fmtDate(endDt) : 'Không có',
                                valueColor: null,
                              ),
                              (
                                label: 'Thời gian bài làm: ',
                                value: timeLimitMinutes != null
                                    ? _fmtLimit(timeLimitMinutes)
                                    : 'Không giới hạn',
                                valueColor: null,
                              ),
                            ],
                          ),
                          const SizedBox(height: DesignSpacing.md),
                        ],

                        // Thống kê đúng/sai — luôn hiện khi full_review
                        // (hiện dù correctCount null để timeTakenLabel vẫn show)
                        if (reviewMode == 'full_review') ...[
                          _StatsRow(
                            correctCount: correctCount,
                            wrongCount: wrongCount,
                            totalQuestions: displayTotal,
                            timeTakenLabel: timeTakenLabel,
                          ),
                          const SizedBox(height: DesignSpacing.md),
                        ],

                        // AI feedback — chỉ hiện ở lần mới nhất
                        if (reviewMode == 'full_review' &&
                            !isViewing &&
                            aiEnabled &&
                            (aiGraded || status == 'ai_processing')) ...[
                          const _AiFeedbackCard(),
                          const SizedBox(height: DesignSpacing.md),
                        ],

                        // Danh sách các lần làm bài (chỉ hiện khi ≥ 2 lần)
                        _AttemptsHistoryList(
                          distributionId: widget.distributionId,
                          currentSubmittedAt:
                              (sub['work_session_submitted_at'] ??
                                      sub['submitted_at'])
                                  as String?,
                          selectedAttemptId: sel?['id'] as String?,
                          reviewMode: reviewMode,
                          scoreAggregationRule: scoreAggregationRule,
                          allowRetake: allowRetake,
                          onAttemptTapped: _onAttemptTapped,
                        ),
                        const SizedBox(height: DesignSpacing.md),

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
          distributionId: widget.distributionId,
          reviewMode: reviewMode,
          attemptCount: sub['attempt_count'] as int? ?? 1,
          maxAttempts: widget.maxAttempts,
          allowRetake: allowRetake,
          scoreAggregationRule: scoreAggregationRule,
          selectedSessionId: sel?['id'] as String?,
          dueAt: () {
            final raw = dist['due_at'] as String?;
            return raw != null ? DateTime.tryParse(raw)?.toLocal() : null;
          }(),
        ),
      ],
    );
  }
}

// Banner hiển thị khi đang xem kết quả 1 lần cụ thể
class _ViewingBanner extends StatelessWidget {
  final int attemptNum;
  final VoidCallback onClear;

  const _ViewingBanner({required this.attemptNum, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.md, vertical: DesignSpacing.sm),
      color: DesignColors.primary.withValues(alpha: 0.07),
      child: Row(
        children: [
          Icon(Icons.history, size: 15, color: DesignColors.primary),
          const SizedBox(width: DesignSpacing.sm),
          Text(
            'Đang xem kết quả lần $attemptNum',
            style: TextStyle(
              fontSize: 12.sp,
              color: DesignColors.primary,
              fontWeight: DesignTypography.semiBold,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClear,
            child: Text(
              'Xem lần mới nhất',
              style: TextStyle(
                fontSize: 11.sp,
                color: DesignColors.primary,
                decoration: TextDecoration.underline,
                decorationColor: DesignColors.primary,
              ),
            ),
          ),
        ],
      ),
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
    // Luôn hiển thị cả 3 chip — "--" khi không có dữ liệu
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.check_circle_outline,
            iconColor: correctCount != null
                ? DesignColors.success
                : DesignColors.textTertiary,
            label: 'Đúng',
            value: correctCount != null
                ? '$correctCount/$totalQuestions'
                : '--',
            valueColor: correctCount != null
                ? DesignColors.success
                : DesignColors.textTertiary,
          ),
        ),
        const SizedBox(width: DesignSpacing.sm),
        Expanded(
          child: _StatChip(
            icon: Icons.cancel_outlined,
            iconColor: wrongCount != null
                ? DesignColors.error
                : DesignColors.textTertiary,
            label: 'Sai',
            value: wrongCount != null ? '$wrongCount' : '--',
            valueColor: wrongCount != null
                ? DesignColors.error
                : DesignColors.textTertiary,
          ),
        ),
        const SizedBox(width: DesignSpacing.sm),
        Expanded(
          child: _StatChip(
            icon: Icons.timer_outlined,
            iconColor: DesignColors.textSecondary,
            label: 'Thời gian',
            value: timeTakenLabel ?? '--',
            valueColor: DesignColors.textSecondary,
          ),
        ),
      ],
    );
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

class _SubmittedFooter extends ConsumerStatefulWidget {
  final String distributionId;
  final String reviewMode;
  final int attemptCount;
  final int? maxAttempts;
  final bool allowRetake;
  final String scoreAggregationRule;
  final String? selectedSessionId;
  /// Hạn nộp bài. Khi đã quá → block redo (mirror rule server).
  /// allow_late KHÔNG nới lỏng nhánh này: chỉ áp cho lần đầu.
  final DateTime? dueAt;

  const _SubmittedFooter({
    required this.distributionId,
    required this.reviewMode,
    required this.attemptCount,
    this.maxAttempts,
    this.allowRetake = false,
    this.scoreAggregationRule = 'latest',
    this.selectedSessionId,
    this.dueAt,
  });

  @override
  ConsumerState<_SubmittedFooter> createState() => _SubmittedFooterState();
}

class _SubmittedFooterState extends ConsumerState<_SubmittedFooter> {
  bool _isRedoing = false;

  // TODO 5.1.5 — Map exception → Vietnamese message
  String _redoErrorMessage(Object error) {
    if (error is RedoBlockedException) {
      switch (error.reason) {
        case RedoBlockReason.closed:
        case RedoBlockReason.pastDue:
          return 'Bài tập đã đóng, không thể làm lại.';
        case RedoBlockReason.notAllowed:
          return 'Giáo viên không cho phép làm lại bài này.';
        case RedoBlockReason.maxReached:
          return 'Bạn đã làm đủ số lần cho phép.';
        case RedoBlockReason.sessionInProgress:
          return 'Bạn đang có bài làm dở. Hãy nộp bài trước khi làm lại.';
        case RedoBlockReason.permission:
          return 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
      }
    }
    return 'Không thể làm lại. Vui lòng thử lại sau.';
  }

  String _disabledLabel(RedoBlockedClient reason) {
    switch (reason) {
      case RedoBlockedClient.notAllowed:
        return 'Không được làm lại';
      case RedoBlockedClient.maxReached:
        return 'Hết số lần làm';
      case RedoBlockedClient.pastDue:
        return 'Hết hạn làm lại';
    }
  }

  String _ruleLabel(String rule) {
    switch (rule) {
      case 'max':
        return 'Điểm cao nhất';
      case 'average':
        return 'Điểm trung bình';
      case 'first':
        return 'Điểm lần làm đầu tiên';
      default:
        return 'Điểm lần làm mới nhất';
    }
  }

  // TODO 5.1.2 — Confirm dialog + TODO 5.1.1 — Gọi RPC start_redo_session
  Future<void> _startRedo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Làm lại bài tập?'),
        content: Text(
          'Bài làm cũ vẫn được lưu.\n'
          'Điểm cuối cùng được tính theo quy tắc: ${_ruleLabel(widget.scoreAggregationRule)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              foregroundColor: DesignColors.white,
            ),
            child: const Text('Làm lại'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isRedoing = true);
    try {
      await ref
          .read(redoSessionProvider(widget.distributionId).notifier)
          .start();

      if (!mounted) return;
      // Workspace tự tìm session in_progress mới nhất qua getOrCreateSubmission
      context.pushNamed(
        AppRoute.studentAssignmentWorkspace,
        pathParameters: {'distributionId': widget.distributionId},
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_redoErrorMessage(e)),
          backgroundColor: DesignColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isRedoing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mirror rule của RPC start_redo_session — disable nút trước khi user
    // nhấn để khỏi nuốt 1 round-trip mạng + snackbar lỗi.
    final blockReason = whyCannotRedo(
      allowRetake: widget.allowRetake,
      attemptCount: widget.attemptCount,
      maxAttempts: widget.maxAttempts,
      dueAt: widget.dueAt,
    );
    final bool canRetry = blockReason == null;

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
          if (widget.reviewMode == 'full_review') ...[
            Expanded(
              child: SizedBox(
                height: 52.h,
                child: OutlinedButton.icon(
                  onPressed: () => context.pushNamed(
                    AppRoute.studentSubmissionReview,
                    pathParameters: {'distributionId': widget.distributionId},
                    extra: widget.selectedSessionId != null
                        ? {'sessionId': widget.selectedSessionId}
                        : null,
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

          // Làm lại — gọi RPC qua redoSessionProvider
          Expanded(
            child: SizedBox(
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: (canRetry && !_isRedoing) ? _startRedo : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canRetry ? DesignColors.primary : DesignColors.dividerMedium,
                  foregroundColor: canRetry ? DesignColors.white : DesignColors.textTertiary,
                  elevation: canRetry ? 2 : 0,
                  shadowColor: DesignColors.primary.withValues(alpha: 0.22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.lg),
                  ),
                  disabledBackgroundColor: DesignColors.dividerLight,
                  disabledForegroundColor: DesignColors.textSecondary,
                ),
                icon: _isRedoing
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: DesignColors.white,
                        ),
                      )
                    : const Icon(Icons.replay, size: 18),
                label: Text(
                  _isRedoing
                      ? 'Đang xử lý...'
                      : canRetry
                          ? 'Làm lại'
                          : _disabledLabel(blockReason),
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

String _fmtDate(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}'
    ' - ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String _fmtLimit(int m) => m >= 60
    ? '${m ~/ 60} giờ${m % 60 > 0 ? ' ${m % 60} phút' : ''}'
    : '$m phút';

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

class _AttemptsHistoryList extends ConsumerWidget {
  final String distributionId;
  /// submitted_at fallback cho lần làm mới nhất (khi work_session.submitted_at null)
  final String? currentSubmittedAt;
  final String? selectedAttemptId;
  final String reviewMode;
  final String scoreAggregationRule;
  final bool allowRetake;
  final void Function(Map<String, dynamic>)? onAttemptTapped;

  const _AttemptsHistoryList({
    required this.distributionId,
    this.currentSubmittedAt,
    this.selectedAttemptId,
    this.reviewMode = 'full_review',
    this.scoreAggregationRule = 'latest',
    this.allowRetake = false,
    this.onAttemptTapped,
  });

  /// Trả về id của attempt "được tính điểm" theo rule
  String? _countingId(List<Map<String, dynamic>> attempts) {
    if (attempts.isEmpty) return null;
    if (scoreAggregationRule == 'latest') {
      return attempts.last['id'] as String?;
    }
    if (scoreAggregationRule == 'first') {
      return attempts.first['id'] as String?;
    }
    if (scoreAggregationRule == 'max') {
      Map<String, dynamic>? best;
      num bestScore = -1;
      for (final a in attempts) {
        final s = _extractScore(a) ?? -1;
        if (s > bestScore) { bestScore = s; best = a; }
      }
      return best?['id'] as String?;
    }
    return null; // 'average' — không đánh dấu riêng lần nào
  }

  num? _extractScore(Map<String, dynamic> attemptData) {
    final subs = attemptData['submissions'];
    if (subs is List && subs.isNotEmpty) return subs[0]['total_score'] as num?;
    if (subs is Map) return subs['total_score'] as num?;
    // Fallback cho các lần cũ: tính tổng final_score từ submission_answers
    final answers = attemptData['submission_answers'];
    if (answers is List && answers.isNotEmpty) {
      num total = 0;
      for (final a in answers) {
        if (a is Map) total += (a['final_score'] as num? ?? 0);
      }
      return total;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attemptsAsync = ref.watch(studentDistributionAttemptsProvider(distributionId));

    return attemptsAsync.when(
      data: (attempts) {
        var valid = attempts
            .where((a) => a['status'] != 'in_progress')
            .toList();

        // Chỉ hiện khi có ≥ 2 lần làm (1 lần không cần danh sách)
        if (valid.length < 2) return const SizedBox.shrink();

        final counting = _countingId(valid);
        final showScore = reviewMode != 'none';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DesignSpacing.md),
          decoration: BoxDecoration(
            color: DesignColors.white,
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            border: Border.all(color: DesignColors.dividerLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'LỊCH SỬ LÀM BÀI',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: DesignTypography.bold,
                      color: DesignColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${valid.length} lần',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: DesignColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignSpacing.md),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: valid.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: DesignColors.dividerLight,
                ),
                itemBuilder: (context, index) {
                  final a = valid[index];
                  final attemptNum = a['attempt'] as int? ?? (index + 1);
                  // isSelected = lần này đang được xem trên UI (được chọn bởi parent)
                  final isSelected = a['id'] == selectedAttemptId;
                  // isCounting = lần được tính điểm theo rule
                  final isCounting = a['id'] == counting;
                  // Giải quyết submitted_at: fallback sang currentSubmittedAt nếu là lần mới nhất
                  final isLatest = index == valid.length - 1;
                  final rawSubmittedAt = a['submitted_at'] as String?;
                  final resolvedSubmittedAt = rawSubmittedAt ??
                      (isLatest ? currentSubmittedAt : null);
                  final submittedAt = resolvedSubmittedAt != null
                      ? DateTime.tryParse(resolvedSubmittedAt)?.toLocal()
                      : null;
                  final timeSec = a['time_spent_seconds'] as int?;
                  final score = _extractScore(a);

                  return GestureDetector(
                    onTap: () => onAttemptTapped?.call(Map<String, dynamic>.from(a)),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                    decoration: isSelected
                        ? BoxDecoration(
                            color: DesignColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(DesignRadius.sm),
                          )
                        : null,
                    child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    child: Row(
                      children: [
                        // Badge số thứ tự
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            // Nếu đang được xem (isSelected) → primary, còn nếu là lần tính điểm → viền
                            color: isSelected
                                ? DesignColors.primary
                                : DesignColors.moonLight,
                            shape: BoxShape.circle,
                            border: isCounting && !isSelected
                                ? Border.all(color: DesignColors.primary, width: 1.5)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '$attemptNum',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: DesignTypography.bold,
                                color: isSelected
                                    ? DesignColors.white
                                    : isCounting
                                        ? DesignColors.primary
                                        : DesignColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: DesignSpacing.md),
                        // Thông tin
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Lần $attemptNum',
                                    style: TextStyle(
                                      fontSize: DesignTypography.bodySmallSize,
                                      fontWeight: isSelected
                                          ? DesignTypography.bold
                                          : DesignTypography.semiBold,
                                      color: isSelected
                                          ? DesignColors.primary
                                          : DesignColors.textPrimary,
                                    ),
                                  ),
                                  // Badge "Hiện tại" = item đang được xem
                                  if (isSelected) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: DesignColors.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Xem',
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          fontWeight: DesignTypography.bold,
                                          color: DesignColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                  // ★ đánh dấu lần được tính điểm
                                  if (isCounting && scoreAggregationRule != 'average') ...[
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.star_rounded,
                                      size: 13,
                                      color: Colors.amber.shade600,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                submittedAt != null
                                    ? _fmtDate(submittedAt)
                                    : isLatest
                                        ? 'Vừa nộp'
                                        : 'Không rõ',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: DesignColors.textTertiary,
                                ),
                              ),
                              if (timeSec != null && timeSec > 0)
                                Text(
                                  'Thời gian: ${_fmtLimit(timeSec ~/ 60)}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: DesignColors.textTertiary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Điểm — ẩn nếu teacher chọn reviewMode = 'none'
                        if (showScore && score != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isCounting
                                  ? DesignColors.success.withValues(alpha: 0.12)
                                  : DesignColors.moonLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$score đ',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: DesignTypography.bold,
                                color: isCounting
                                    ? DesignColors.success
                                    : DesignColors.textSecondary,
                              ),
                            ),
                          )
                        else if (!showScore)
                          Icon(
                            Icons.visibility_off_outlined,
                            size: 16,
                            color: DesignColors.textTertiary,
                          ),
                      ],
                    ),   // Row
                    ),   // Padding
                    ),   // Container
                  );     // GestureDetector
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.md),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widget: nhãn phương thức tính điểm
// ─────────────────────────────────────────────────────────────

class _ScoreRuleChip extends StatelessWidget {
  final String rule;

  const _ScoreRuleChip({required this.rule});

  String get _label => switch (rule) {
        'max' => 'Điểm cao nhất',
        'average' => 'Trung bình các lần',
        'first' => 'Lần làm đầu tiên',
        _ => 'Bài nộp mới nhất',
      };

  IconData get _icon => switch (rule) {
        'max' => Icons.emoji_events_outlined,
        'average' => Icons.calculate_outlined,
        'first' => Icons.looks_one_outlined,
        _ => Icons.history_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.md, vertical: DesignSpacing.sm),
      decoration: BoxDecoration(
        color: DesignColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(
            color: DesignColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(_icon, size: 15, color: DesignColors.primary),
          const SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12.sp,
                  color: DesignColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'Điểm được tính theo: '),
                  TextSpan(
                    text: _label,
                    style: const TextStyle(
                      fontWeight: DesignTypography.bold,
                      color: DesignColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
