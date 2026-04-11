import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/presentation/providers/student_assignment_providers.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:ai_mls/widgets/rubric/read_only_rubric_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình chi tiết bài tập dành cho học sinh.
/// Hiển thị thông tin bài tập, danh sách câu hỏi, và nút bắt đầu làm bài.
class StudentAssignmentDetailScreen extends ConsumerWidget {
  final String distributionId;

  const StudentAssignmentDetailScreen({
    super.key,
    required this.distributionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.debug('🔵 [DetailScreen] building with distributionId: $distributionId');
    final detailAsync = ref.watch(studentAssignmentDetailProvider(distributionId));

    detailAsync.when(
      loading: () => AppLogger.debug('🔵 [DetailScreen] loading...'),
      error: (e, st) => AppLogger.error('🔴 [DetailScreen] error: $e', error: e, stackTrace: st),
      data: (d) => AppLogger.debug('🔵 [DetailScreen] data: $d'),
    );

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: _buildAppBar(context),
      body: detailAsync.when(
        loading: () => const ShimmerLoading(),
        error: (error, _) => _buildErrorState(context, error),
        data: (detail) => _buildBody(context, ref, detail),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: DesignColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: DesignIcons.smSize),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Chi tiết bài tập',
        style: TextStyle(
          fontSize: DesignTypography.bodyMediumSize,
          fontWeight: DesignTypography.bold,
          color: DesignColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: DesignColors.error),
            const SizedBox(height: DesignSpacing.md),
            Text(
              'Lỗi khi tải thông tin bài tập',
              style: DesignTypography.bodyLarge.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
            const SizedBox(height: DesignSpacing.sm),
            Text(
              error.toString(),
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> detail,
  ) {
    final assignment = detail['assignment'] as Map<String, dynamic>? ?? {};
    final questions = detail['questions'] as List<dynamic>? ?? [];
    final distribution = detail['distribution'] as Map<String, dynamic>? ?? {};
    final submission = detail['submission'] as Map<String, dynamic>?;

    final title = assignment['title'] as String? ?? 'Bài tập';
    final description = assignment['description'] as String?;
    final dueAt = distribution['due_at'] as String?;
    final totalPoints = assignment['total_points'] as num?;

    // Parse dates
    DateTime? dueDateTime;
    if (dueAt != null) {
      dueDateTime = DateTime.tryParse(dueAt);
    }

    // Check submission status
    final submissionStatus = submission?['status'] as String? ?? 'draft';
    final isSubmitted = submissionStatus == 'submitted'
        || submissionStatus == 'graded'
        || submissionStatus == 'ai_processing';
    final score = submission?['score'] as num?;

    return Column(
      children: [
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DesignSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                _buildHeaderCard(
                  context,
                  title: title,
                  description: description,
                  dueDateTime: dueDateTime,
                  totalPoints: totalPoints,
                  isSubmitted: isSubmitted,
                  score: score,
                  submissionStatus: submissionStatus,
                ),

                const SizedBox(height: DesignSpacing.lg),

                // Questions Section
                Text(
                  'Danh sách câu hỏi (${questions.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: DesignColors.textPrimary,
                  ),
                ),

                const SizedBox(height: DesignSpacing.md),

                if (questions.isEmpty)
                  _buildEmptyQuestions()
                else
                  ...questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value as Map<String, dynamic>;
                    return _buildQuestionCard(question, index + 1);
                  }),

                // Rubric preview section (D-03 Giai đoạn 1 + Giai đoạn 3)
                _buildRubricPreviewSection(questions, isSubmitted: isSubmitted),
              ],
            ),
          ),
        ),

        // Bottom Action Bar
        _buildBottomActionBar(
          context,
          isSubmitted: isSubmitted,
          submissionStatus: submissionStatus,
        ),
      ],
    );
  }

  Widget _buildHeaderCard(
    BuildContext context, {
    required String title,
    String? description,
    DateTime? dueDateTime,
    num? totalPoints,
    required bool isSubmitted,
    num? score,
    String submissionStatus = 'draft',
  }) {
    final now = DateTime.now();
    final isExpired = dueDateTime != null && now.isAfter(dueDateTime);

    String timeRemaining = '';
    if (dueDateTime != null && !isExpired) {
      final diff = dueDateTime.difference(now);
      if (diff.inDays > 0) {
        timeRemaining = 'Còn ${diff.inDays} ngày ${diff.inHours % 24} giờ';
      } else if (diff.inHours > 0) {
        timeRemaining = 'Còn ${diff.inHours} giờ ${diff.inMinutes % 60} phút';
      } else {
        timeRemaining = 'Còn ${diff.inMinutes} phút';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DesignSpacing.sm),
                decoration: BoxDecoration(
                  color: DesignColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: DesignColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: DesignSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: DesignColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          // Description
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: DesignSpacing.md),
            Text(
              description,
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ],

          const SizedBox(height: DesignSpacing.md),
          const Divider(),
          const SizedBox(height: DesignSpacing.sm),

          // Status & Points Row
          Row(
            children: [
              // Status Badge
              _buildStatusBadge(isSubmitted: isSubmitted, isExpired: isExpired, submissionStatus: submissionStatus),

              const Spacer(),

              // Points
              if (totalPoints != null && totalPoints > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                    border: Border.all(color: Colors.amber[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(
                        '${totalPoints.toStringAsFixed(0)} điểm',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: DesignSpacing.md),

          // Due Date & Time Remaining
          if (dueDateTime != null) ...[
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: isExpired ? DesignColors.error : DesignColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Hạn nộp: ${_formatDate(dueDateTime)}',
                    style: DesignTypography.bodyMedium.copyWith(
                      color: isExpired ? DesignColors.error : DesignColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            if (timeRemaining.isNotEmpty && !isSubmitted) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: isExpired ? DesignColors.error : DesignColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeRemaining,
                    style: DesignTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isExpired ? DesignColors.error : DesignColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],

          // Score (if graded)
          // Show score if graded or ai_processing (MCQ score already calculated)
          if (score != null && (submissionStatus == 'graded' || submissionStatus == 'ai_processing')) ...[
            const SizedBox(height: DesignSpacing.md),
            Container(
              padding: const EdgeInsets.all(DesignSpacing.md),
              decoration: BoxDecoration(
                color: DesignColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(DesignRadius.md),
                border: Border.all(color: DesignColors.success.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: DesignColors.success),
                  const SizedBox(width: DesignSpacing.sm),
                  Text(
                    'Điểm số: ${score.toStringAsFixed(1)}',
                    style: DesignTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: DesignColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge({
    required bool isSubmitted,
    required bool isExpired,
    String submissionStatus = 'draft',
  }) {
    final Color badgeColor;
    final IconData badgeIcon;
    final String badgeText;

    if (submissionStatus == 'graded') {
      badgeColor = DesignColors.success;
      badgeIcon = Icons.check_circle;
      badgeText = 'Đã chấm điểm';
    } else if (submissionStatus == 'ai_processing') {
      badgeColor = DesignColors.primary;
      badgeIcon = Icons.auto_awesome;
      badgeText = 'Đã nộp \u00b7 AI đang phân tích';
    } else if (submissionStatus == 'submitted') {
      badgeColor = DesignColors.warning;
      badgeIcon = Icons.hourglass_top;
      badgeText = 'Đã nộp \u00b7 Chờ giáo viên';
    } else if (isExpired) {
      badgeColor = DesignColors.error;
      badgeIcon = Icons.cancel;
      badgeText = 'Đã hết hạn';
    } else {
      badgeColor = DesignColors.textSecondary;
      badgeIcon = Icons.play_circle_outline;
      badgeText = 'Chưa nộp';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 16, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: DesignTypography.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQuestions() {
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: DesignColors.moonLight,
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.quiz_outlined, size: 48, color: DesignColors.textTertiary),
            const SizedBox(height: DesignSpacing.sm),
            Text(
              'Chưa có câu hỏi',
              style: DesignTypography.bodyMedium.copyWith(color: DesignColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int number) {
    // Handle content as either String or JSON object
    String contentText = 'Câu hỏi';
    dynamic contentData = question['content'];
    if (contentData is String) {
      contentText = contentData;
    } else if (contentData is Map) {
      contentText = contentData['text'] as String? ?? 'Câu hỏi';
    }

    // Handle type - could be 'multipleChoice' or 'multiple_choice'
    String questionType = question['type'] as String? ?? 'multiple_choice';
    if (contentData is Map) {
      final contentType = contentData['type'] as String?;
      if (contentType != null) {
        questionType = contentType;
      }
    }

    final points = question['points'] as num? ?? 1;

    final typeIcon = _getQuestionTypeIcon(questionType);
    final typeLabel = _getQuestionTypeLabel(questionType);

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DesignColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: DesignColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: DesignSpacing.md),

          // Question Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(typeIcon, size: 16, color: DesignColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      typeLabel,
                      style: DesignTypography.caption.copyWith(
                        color: DesignColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: DesignColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DesignRadius.xs),
                      ),
                      child: Text(
                        '$points điểm',
                        style: DesignTypography.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: DesignColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignSpacing.xs),
                Text(
                  contentText,
                  style: DesignTypography.bodyMedium.copyWith(
                    color: DesignColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context, {
    required bool isSubmitted,
    required String submissionStatus,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isSubmitted
                ? null
                : () {
                    // Navigate to workspace with distributionId
                    // Use pushNamed because we need back button to work
                    context.pushNamed(
                      AppRoute.studentAssignmentWorkspace,
                      pathParameters: {'distributionId': distributionId},
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSubmitted ? DesignColors.disabledMedium : DesignColors.primary,
              foregroundColor: DesignColors.white,
              padding: const EdgeInsets.symmetric(vertical: DesignSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignRadius.md),
              ),
            ),
            icon: Icon(
              isSubmitted ? Icons.check_circle : Icons.edit,
            ),
            label: Text(
              isSubmitted ? 'Đã nộp bài' : 'Bắt đầu làm bài',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds rubric preview section for essay/shortAnswer questions with rubrics.
  /// D-03 Giai đoạn 1: Pre-workspace preview (isSubmitted=false).
  /// D-03 Giai đoạn 3: Post-grading foundation (isSubmitted=true).
  Widget _buildRubricPreviewSection(
    List<dynamic> questions, {
    required bool isSubmitted,
  }) {
    final rubricQuestions = questions
        .asMap()
        .entries
        .where((entry) {
          final q = entry.value as Map<String, dynamic>;
          final type = q['type'] as String? ?? q['question_type'] as String? ?? '';
          final hasRubric = q['rubric'] != null;
          const essayTypes = {'essay', 'short_answer', 'shortAnswer'};
          return hasRubric && essayTypes.contains(type);
        })
        .toList();

    if (rubricQuestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: DesignSpacing.lg),
        Text(
          isSubmitted ? 'Tiêu chí chấm điểm (Xem lại)' : 'Tiêu chí chấm điểm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: DesignColors.textPrimary,
          ),
        ),
        const SizedBox(height: DesignSpacing.md),
        ...rubricQuestions.map((entry) {
          final index = entry.key;
          final question = entry.value as Map<String, dynamic>;
          final rubric = question['rubric'] as Map<String, dynamic>?;
          return _RubricPreviewCard(
            rubric: rubric,
            questionNumber: index + 1,
            isSubmitted: isSubmitted,
          );
        }),
      ],
    );
  }

  IconData _getQuestionTypeIcon(String type) {
    switch (type) {
      case 'multiple_choice':
        return Icons.list;
      case 'true_false':
        return Icons.check_box_outlined;
      case 'essay':
        return Icons.notes;
      case 'fill_blank':
        return Icons.short_text;
      default:
        return Icons.quiz;
    }
  }

  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Trắc nghiệm';
      case 'true_false':
        return 'Đúng/Sai';
      case 'essay':
        return 'Tự luận';
      case 'fill_blank':
        return 'Điền trống';
      default:
        return 'Câu hỏi';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Expandable rubric preview card for a single essay/shortAnswer question.
/// Collapsed (default): compact mode — criterion names + max_points overview.
/// Expanded: full mode — criteria with all level descriptions.
/// D-03 isSubmitted mode: shows ReadOnlyRubricViewer with selectedLevels=null
/// as foundation for Phase 6 AI criteria_scores integration.
class _RubricPreviewCard extends StatefulWidget {
  final Map<String, dynamic>? rubric;
  final int questionNumber;

  /// When true, card shows Phase 6 placeholder (submitted/graded state).
  final bool isSubmitted;

  const _RubricPreviewCard({
    required this.rubric,
    required this.questionNumber,
    required this.isSubmitted,
  });

  @override
  State<_RubricPreviewCard> createState() => _RubricPreviewCardState();
}

class _RubricPreviewCardState extends State<_RubricPreviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
      color: DesignColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.all(DesignSpacing.lg),
            child: Row(
              children: [
                const Icon(
                  Icons.rule,
                  size: DesignIcons.smSize,
                  color: DesignColors.tealPrimary,
                ),
                const SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: Text(
                    'Tiêu chí chấm điểm - Câu ${widget.questionNumber}',
                    style: DesignTypography.titleMedium.copyWith(
                      fontSize: DesignTypography.titleSmallSize,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: DesignIcons.smSize,
                    color: DesignColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Body: compact or full
          if (_expanded) ...[
            const Divider(
              color: DesignColors.dividerLight,
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignSpacing.lg,
                0,
                DesignSpacing.lg,
                DesignSpacing.lg,
              ),
              child: ReadOnlyRubricViewer(
                rubric: widget.rubric,
                // Phase 6 placeholder: selectedLevels=null until AI criteria_scores available
                selectedLevels: null,
                showHeader: false,
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignSpacing.lg,
                0,
                DesignSpacing.lg,
                DesignSpacing.md,
              ),
              child: ReadOnlyRubricViewer(
                rubric: widget.rubric,
                compact: true,
                showHeader: false,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
