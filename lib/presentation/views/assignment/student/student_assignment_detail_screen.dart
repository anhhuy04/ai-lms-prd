import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/presentation/providers/student_assignment_providers.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StudentAssignmentDetailScreen extends ConsumerWidget {
  final String assignmentId;

  const StudentAssignmentDetailScreen({
    super.key,
    required this.assignmentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(studentAssignmentDetailProvider(assignmentId));
    final submissionAsync = ref.watch(studentSubmissionProvider(assignmentId));

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      body: detailAsync.when(
        loading: () => const ShimmerLoading(),
        error: (e, _) => _ErrorView(error: e),
        data: (detail) {
          final assignment = detail['assignment'] as Map<String, dynamic>? ?? {};
          final questions = detail['questions'] as List<dynamic>? ?? [];
          final distribution = detail['distribution'] as Map<String, dynamic>? ?? {};
          final settings = distribution['settings'] as Map<String, dynamic>? ?? {};

          final title = assignment['title'] as String? ?? 'Bài tập';
          final description = assignment['description'] as String?;
          final dueAt = distribution['due_at'] as String?;
          final totalPoints = assignment['total_points'] as num?;
          final timeLimitMinutes = distribution['time_limit_minutes'] as int?;
          final showScoreImmediately = settings['show_score_immediately'] as bool? ?? true;
          final studentReviewMode = settings['student_review_mode'] as String? ?? 'full_review';
          final maxAttempts = settings['max_attempts'] as int?;
          final dueDateTime = dueAt != null ? DateTime.tryParse(dueAt) : null;

          return submissionAsync.when(
            loading: () => const ShimmerLoading(),
            error: (e, _) => _InProgressView(
              assignmentId: assignmentId,
              title: title,
              description: description,
              dueDateTime: dueDateTime,
              totalPoints: totalPoints,
              timeLimitMinutes: timeLimitMinutes,
              questionCount: questions.length,
              submission: null,
            ),
            data: (submission) {
              final status = submission?['status'] as String? ?? 'draft';
              final isSubmitted = status == 'submitted' || status == 'graded';

              if (isSubmitted) {
                return _SubmittedView(
                  assignmentId: assignmentId,
                  title: title,
                  submission: submission!,
                  totalPoints: totalPoints,
                  showScore: showScoreImmediately,
                  studentReviewMode: studentReviewMode,
                  maxAttempts: maxAttempts,
                  questionCount: questions.length,
                  onRefresh: () {
                    ref.invalidate(studentAssignmentDetailProvider(assignmentId));
                    ref.invalidate(studentSubmissionProvider(assignmentId));
                  },
                );
              }
              return _InProgressView(
                assignmentId: assignmentId,
                title: title,
                description: description,
                dueDateTime: dueDateTime,
                totalPoints: totalPoints,
                timeLimitMinutes: timeLimitMinutes,
                questionCount: questions.length,
                submission: submission,
              );
            },
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// SUBMITTED VIEW
// ──────────────────────────────────────────────────────────────────────────────

class _SubmittedView extends StatelessWidget {
  final String assignmentId;
  final String title;
  final Map<String, dynamic> submission;
  final num? totalPoints;
  final bool showScore;
  final String studentReviewMode;
  final int? maxAttempts;
  final int questionCount;
  final VoidCallback onRefresh;

  const _SubmittedView({
    required this.assignmentId,
    required this.title,
    required this.submission,
    this.totalPoints,
    required this.showScore,
    required this.studentReviewMode,
    this.maxAttempts,
    required this.questionCount,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final score = submission['score'] as num?;
    final correctCount = submission['correct_count'] as int?;
    final wrongCount = submission['wrong_count'] as int?;
    final timeTakenSeconds = submission['time_taken_seconds'] as int?;
    final startedAt = submission['started_at'] as String?;
    final submittedAt = submission['submitted_at'] as String?;
    final aiFeedback = submission['ai_feedback'] as String?;
    final teacherComment = submission['teacher_comment'] as String?;
    final teacherName = submission['teacher_name'] as String?;

    final startDt = startedAt != null ? DateTime.tryParse(startedAt) : null;
    final endDt = submittedAt != null ? DateTime.tryParse(submittedAt) : null;
    final timeTakenMin = timeTakenSeconds != null ? timeTakenSeconds ~/ 60 : null;

    return Column(children: [
      _AppBarRow(context: context, title: title, trailing: IconButton(
        icon: const Icon(Icons.share_outlined, size: 22),
        onPressed: () {},
      )),
      Expanded(
        child: RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(children: [
            _ScoreHeroCard(score: score, totalPoints: totalPoints, showScore: showScore),
            const SizedBox(height: 12),
            // Timing & stats chỉ hiện khi không ở chế độ 'none'
            if (studentReviewMode != 'none') ...[
              if (startDt != null || endDt != null) ...[
                _TimingCard(startDt: startDt, endDt: endDt),
                const SizedBox(height: 12),
              ],
              if (correctCount != null || wrongCount != null || timeTakenMin != null) ...[
                _StatsRow(correct: correctCount, wrong: wrongCount, timeMin: timeTakenMin, total: questionCount),
                const SizedBox(height: 12),
              ],
            ],
            // AI feedback & teacher comments chỉ hiện ở chế độ 'full_review'
            if (studentReviewMode == 'full_review') ...[
              if (aiFeedback != null && aiFeedback.isNotEmpty) ...[
                _AiFeedbackCard(feedback: aiFeedback),
                const SizedBox(height: 12),
              ],
              if (teacherComment != null && teacherComment.isNotEmpty)
                _TeacherCommentCard(comment: teacherComment, name: teacherName),
            ],
          ]),
          ),
        ),
      ),
      _SubmittedFooter(
        assignmentId: assignmentId,
        studentReviewMode: studentReviewMode,
        maxAttempts: maxAttempts,
        attemptCount: submission['attempt_count'] as int? ?? 0,
      ),
    ]);
  }
}

class _ScoreHeroCard extends StatelessWidget {
  final num? score;
  final num? totalPoints;
  final bool showScore;

  const _ScoreHeroCard({this.score, this.totalPoints, required this.showScore});

  @override
  Widget build(BuildContext context) {
    final maxScore = totalPoints ?? 10;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [DesignColors.primary, const Color(0xFF0D6FCC)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: DesignColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Stack(children: [
        Positioned(top: -8, right: -8,
          child: Icon(Icons.assignment_turned_in, size: 100, color: Colors.white.withValues(alpha: 0.08))),
        Column(children: [
          Text('KẾT QUẢ BÀI LÀM',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 10),
          if (!showScore)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.lock_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Điểm đang được ẩn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ]),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(score != null ? score!.toStringAsFixed(1) : '--',
                  style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                Text(' / ${maxScore.toStringAsFixed(0)}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 22, fontWeight: FontWeight.w500)),
              ],
            ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.check_circle, color: Colors.white, size: 15),
              SizedBox(width: 6),
              Text('Đã hoàn thành', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
      ]),
    );
  }
}

class _TimingCard extends StatelessWidget {
  final DateTime? startDt;
  final DateTime? endDt;

  const _TimingCard({this.startDt, this.endDt});

  String _fmt(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} - ${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecor(),
      child: Row(children: [
        _iconBox(Icons.schedule_outlined, const Color(0xFFEFF6FF), DesignColors.primary),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Thời gian thực hiện', style: _labelStyle()),
          const SizedBox(height: 3),
          if (startDt != null) Text('Bắt đầu: ${_fmt(startDt!)}', style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
          if (endDt != null) Text('Kết thúc: ${_fmt(endDt!)}', style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
        ]),
      ]),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int? correct;
  final int? wrong;
  final int? timeMin;
  final int total;

  const _StatsRow({this.correct, this.wrong, this.timeMin, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _StatItem(icon: Icons.check_circle_outline, value: correct != null ? '$correct${total > 0 ? "/$total" : ""}' : '--', label: 'Đúng', color: const Color(0xFF22C55E))),
      const SizedBox(width: 8),
      Expanded(child: _StatItem(icon: Icons.cancel_outlined, value: wrong != null ? wrong.toString().padLeft(2, '0') : '--', label: 'Sai', color: const Color(0xFFEF4444))),
      const SizedBox(width: 8),
      Expanded(child: _StatItem(icon: Icons.timer_outlined, value: timeMin != null ? "$timeMin'" : '--', label: 'Thời gian', color: const Color(0xFF374151))),
    ]);
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: _cardDecor(),
      child: Column(children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        ]),
      ]),
    );
  }
}

class _AiFeedbackCard extends StatelessWidget {
  final String feedback;
  const _AiFeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: DesignColors.primary, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          const Text('Phản hồi AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937))),
        ]),
        const SizedBox(height: 10),
        Text(feedback, style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.5)),
      ]),
    );
  }
}

class _TeacherCommentCard extends StatelessWidget {
  final String comment;
  final String? name;
  const _TeacherCommentCard({required this.comment, this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecor(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 16, backgroundColor: Colors.grey[100],
            child: Icon(Icons.person_outline, size: 18, color: Colors.grey[600])),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Giáo viên nhận xét', style: _labelStyle()),
            if (name != null) Text(name!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          ]),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
          child: Text('"$comment"', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontStyle: FontStyle.italic, height: 1.5)),
        ),
      ]),
    );
  }
}

class _SubmittedFooter extends StatelessWidget {
  final String assignmentId;
  // 'none' = ẩn hết, 'score_only' = chỉ điểm, 'full_review' = xem lại cả bài
  final String studentReviewMode;
  final int? maxAttempts;
  final int attemptCount;

  const _SubmittedFooter({
    required this.assignmentId,
    required this.studentReviewMode,
    this.maxAttempts,
    required this.attemptCount,
  });

  @override
  Widget build(BuildContext context) {
    final canReview = studentReviewMode == 'full_review';
    final canRetry = maxAttempts == null || attemptCount < maxAttempts!;

    if (!canReview && !canRetry) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(child: Row(children: [
        if (canReview) ...[
          Expanded(child: OutlinedButton.icon(
            onPressed: () => context.pushNamed(
              AppRoute.studentAssignmentWorkspace,
              pathParameters: {'distributionId': assignmentId},
              extra: {'isReadOnly': true},
            ),
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text('Xem lại bài làm'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          )),
          if (canRetry) const SizedBox(width: 12),
        ],
        if (canRetry)
          Expanded(child: ElevatedButton.icon(
            onPressed: () => context.pushNamed(AppRoute.studentAssignmentWorkspace, pathParameters: {'distributionId': assignmentId}),
            icon: const Icon(Icons.replay, size: 18),
            label: Text(maxAttempts != null ? 'Làm lại (${attemptCount + 1}/$maxAttempts)' : 'Làm lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          )),
      ])),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// IN-PROGRESS / NOT-STARTED VIEW
// ──────────────────────────────────────────────────────────────────────────────

class _InProgressView extends StatelessWidget {
  final String assignmentId;
  final String title;
  final String? description;
  final DateTime? dueDateTime;
  final num? totalPoints;
  final int? timeLimitMinutes;
  final int questionCount;
  final Map<String, dynamic>? submission;

  const _InProgressView({
    required this.assignmentId,
    required this.title,
    this.description,
    this.dueDateTime,
    this.totalPoints,
    this.timeLimitMinutes,
    required this.questionCount,
    required this.submission,
  });

  @override
  Widget build(BuildContext context) {
    final isDraft = (submission?['status'] as String?) == 'in_progress';
    final answeredCount = (submission?['answers'] as Map?)?.length ?? 0;
    final progress = (questionCount > 0 && isDraft) ? answeredCount / questionCount : 0.0;
    final isExpired = dueDateTime != null && DateTime.now().isAfter(dueDateTime!);

    return Column(children: [
      _AppBarRow(context: context, title: title),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Progress or New card
            isDraft && questionCount > 0
              ? _ProgressCard(progress: progress, answered: answeredCount, total: questionCount)
              : _NewAssignmentCard(questionCount: questionCount),
            const SizedBox(height: 20),
            Text('THÔNG TIN BÀI TẬP', style: _labelStyle()),
            const SizedBox(height: 8),
            if (dueDateTime != null)
              _InfoTile(icon: Icons.event_busy_outlined, iconColor: isExpired ? Colors.red : const Color(0xFFEF4444),
                label: 'Hạn nộp bài', value: _fmtDate(dueDateTime!), isExpired: isExpired),
            const SizedBox(height: 8),
            Row(children: [
              if (timeLimitMinutes != null)
                Expanded(child: _InfoSmall(icon: Icons.timer_outlined, iconColor: DesignColors.primary, label: 'Thời gian', value: '$timeLimitMinutes phút')),
              if (timeLimitMinutes != null && totalPoints != null) const SizedBox(width: 8),
              if (totalPoints != null)
                Expanded(child: _InfoSmall(icon: Icons.workspace_premium_outlined, iconColor: const Color(0xFFD97706), label: 'Tổng điểm', value: '$totalPoints đ')),
            ]),
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('HƯỚNG DẪN LÀM BÀI', style: _labelStyle()),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                child: Text(description!, style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.6)),
              ),
            ],
          ]),
        ),
      ),
      _InProgressFooter(assignmentId: assignmentId, isDraft: isDraft),
    ]);
  }

  String _fmtDate(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} - ${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

class _ProgressCard extends StatelessWidget {
  final double progress;
  final int answered;
  final int total;

  const _ProgressCard({required this.progress, required this.answered, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE))),
      child: Row(children: [
        SizedBox(width: 64, height: 64,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 64, height: 64,
              child: CircularProgressIndicator(
                value: progress, strokeWidth: 5,
                backgroundColor: DesignColors.primary.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(DesignColors.primary),
              )),
            Text('$pct%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DesignColors.primary)),
          ])),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('Đang làm dở', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: DesignColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('Tiếp tục', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: DesignColors.primary, letterSpacing: 0.8))),
          ]),
          const SizedBox(height: 4),
          Text('Bạn đã hoàn thành $answered trên tổng số $total câu hỏi.',
            style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontStyle: FontStyle.italic)),
        ])),
      ]),
    );
  }
}

class _NewAssignmentCard extends StatelessWidget {
  final int questionCount;
  const _NewAssignmentCard({required this.questionCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE))),
      child: Row(children: [
        Container(width: 48, height: 48,
          decoration: BoxDecoration(color: DesignColors.primary, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 26)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Chưa bắt đầu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          const SizedBox(height: 4),
          Text('Bài có $questionCount câu hỏi. Nhấn bắt đầu khi bạn sẵn sàng.',
            style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB))),
        ])),
      ]),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isExpired;

  const _InfoTile({required this.icon, required this.iconColor, required this.label, required this.value, this.isExpired = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
      child: Row(children: [
        _iconBox(icon, Colors.white, isExpired ? Colors.red : iconColor),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: _labelStyle()),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isExpired ? Colors.red : const Color(0xFF1F2937))),
        ]),
      ]),
    );
  }
}

class _InfoSmall extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoSmall({required this.icon, required this.iconColor, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
      child: Row(children: [
        _iconBox(icon, Colors.white, iconColor, size: 40),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: _labelStyle()),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
        ]),
      ]),
    );
  }
}

class _InProgressFooter extends StatelessWidget {
  final String assignmentId;
  final bool isDraft;
  const _InProgressFooter({required this.assignmentId, required this.isDraft});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: double.infinity, height: 56,
          child: ElevatedButton.icon(
            onPressed: () => context.pushNamed(AppRoute.studentAssignmentWorkspace, pathParameters: {'distributionId': assignmentId}),
            icon: Icon(isDraft ? Icons.play_circle_outline : Icons.play_arrow_rounded, size: 26),
            label: Text(isDraft ? 'Tiếp tục làm bài' : 'Bắt đầu làm bài',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4, shadowColor: DesignColors.primary.withValues(alpha: 0.3),
            ),
          )),
        const SizedBox(height: 4),
        const Text('Hệ thống sẽ tự động lưu lại tiến trình của bạn',
          style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)), textAlign: TextAlign.center),
      ])),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS
// ──────────────────────────────────────────────────────────────────────────────

class _AppBarRow extends StatelessWidget {
  final BuildContext context;
  final String title;
  final Widget? trailing;

  const _AppBarRow({required this.context, required this.title, this.trailing});

  @override
  Widget build(BuildContext ctx) {
    return Container(
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: Colors.white,
      child: Row(children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        Expanded(child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          overflow: TextOverflow.ellipsis)),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: Center(
        child: Padding(padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Lỗi khi tải thông tin bài tập', style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(error.toString(), style: TextStyle(fontSize: 14, color: Colors.grey[500]), textAlign: TextAlign.center),
          ])),
      ),
    );
  }
}

BoxDecoration _cardDecor() => BoxDecoration(
  color: Colors.white, borderRadius: BorderRadius.circular(16),
  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
);

Widget _iconBox(IconData icon, Color bgColor, Color iconColor, {double size = 42}) => Container(
  width: size, height: size,
  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)]),
  child: Icon(icon, color: iconColor, size: size * 0.5),
);

TextStyle _labelStyle() => const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF), letterSpacing: 0.8);
