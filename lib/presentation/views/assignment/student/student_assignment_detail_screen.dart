import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/presentation/providers/student_assignment_providers.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình chi tiết bài tập dành cho học sinh.
/// Hiển thị thông tin bài tập, danh sách câu hỏi, và nút bắt đầu làm bài.
class StudentAssignmentDetailScreen extends ConsumerWidget {
  final String assignmentId;

  const StudentAssignmentDetailScreen({
    super.key,
    required this.assignmentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(studentAssignmentDetailProvider(assignmentId));

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
        onPressed: () => Navigator.of(context).pop(),
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
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: DesignSpacing.md),
            Text(
              'Lỗi khi tải thông tin bài tập',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: DesignSpacing.sm),
            Text(
              error.toString(),
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
    final isSubmitted = submissionStatus == 'submitted' || submissionStatus == 'graded';
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
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
              _buildStatusBadge(isSubmitted: isSubmitted, isExpired: isExpired),

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
                  color: isExpired ? Colors.red : Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Hạn nộp: ${_formatDate(dueDateTime)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isExpired ? Colors.red : Colors.grey[600],
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
                    color: isExpired ? Colors.red : DesignColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeRemaining,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isExpired ? Colors.red : DesignColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],

          // Score (if graded)
          if (score != null && isSubmitted) ...[
            const SizedBox(height: DesignSpacing.md),
            Container(
              padding: const EdgeInsets.all(DesignSpacing.md),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(DesignRadius.md),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700]),
                  const SizedBox(width: DesignSpacing.sm),
                  Text(
                    'Điểm số: ${score.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
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
  }) {
    if (isSubmitted) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          border: Border.all(color: Colors.green[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
            const SizedBox(width: 4),
            Text(
              'Đã nộp',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
      );
    }

    if (isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          border: Border.all(color: Colors.red[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, size: 16, color: Colors.red[700]),
            const SizedBox(width: 4),
            Text(
              'Đã hết hạn',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_circle_outline, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 4),
          Text(
            'Đang mở',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.quiz_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: DesignSpacing.sm),
            Text(
              'Chưa có câu hỏi',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int number) {
    final content = question['content'] as String? ?? 'Câu hỏi';
    final questionType = question['type'] as String? ?? 'multiple_choice';
    final points = question['points'] as num? ?? 1;

    final typeIcon = _getQuestionTypeIcon(questionType);
    final typeLabel = _getQuestionTypeLabel(questionType);

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: Colors.grey[200]!),
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
                    Icon(typeIcon, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      typeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$points điểm',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignSpacing.xs),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
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
                    context.goNamed(
                      AppRoute.studentAssignmentWorkspace,
                      pathParameters: {'distributionId': assignmentId},
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSubmitted ? Colors.grey[300] : DesignColors.primary,
              foregroundColor: Colors.white,
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
