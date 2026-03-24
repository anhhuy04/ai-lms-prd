import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/presentation/providers/teacher_submission_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/submission/ai_confidence_indicator.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/submission/grade_audit_trail.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/submission/grading_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Teacher Submission Detail Screen - Hiển thị tất cả câu hỏi trong list (giống HTML mẫu)
class TeacherSubmissionDetailScreen extends ConsumerStatefulWidget {
  final String submissionId;
  final String? distributionId;
  final List<String>? allSubmissionIds;

  const TeacherSubmissionDetailScreen({
    super.key,
    required this.submissionId,
    this.distributionId,
    this.allSubmissionIds,
  });

  @override
  ConsumerState<TeacherSubmissionDetailScreen> createState() =>
      _TeacherSubmissionDetailScreenState();
}

class _TeacherSubmissionDetailScreenState
    extends ConsumerState<TeacherSubmissionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(teacherSubmissionDetailProvider(
      submissionId: widget.submissionId,
    ));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DesignColors.textSecondary),
          onPressed: () => context.pop(),
        ),
        title: detailAsync.when(
          data: (data) {
            final student = data['profiles'] as Map<String, dynamic>?;
            final distribution = data['assignment_distributions'] as Map<String, dynamic>?;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chấm bài tập chi tiết',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DesignColors.textPrimary,
                  ),
                ),
                Text(
                  '${student?['full_name'] ?? 'Học sinh'} ${distribution?['classes']?['name'] != null ? '• ${distribution!['classes']!['name']}' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignColors.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            );
          },
          loading: () => const Text('Đang tải...'),
          error: (_, __) => const Text('Lỗi'),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: DesignColors.dividerLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: DesignColors.textSecondary, size: 20),
              onPressed: () {},
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: DesignColors.dividerLight,
            height: 1,
          ),
        ),
      ),
      body: Container(
        color: DesignColors.moonLight,
        child: detailAsync.when(
          data: (data) {
            final student = data['profiles'] as Map<String, dynamic>?;
            final distribution = data['assignment_distributions'] as Map<String, dynamic>?;
            final assignment = distribution?['assignments'] as Map<String, dynamic>?;
            final answers = data['submission_answers'] as List<Map<String, dynamic>>? ?? [];

            // Auto-grade logic for 100% objective assignments
            final workSession = data['work_sessions'] as Map<String, dynamic>?;
            final status = workSession?['status'] as String?;
            final submittedAt = workSession?['submitted_at'] as String?;
            
            if (status == 'submitted' && answers.isNotEmpty) {
              bool allObjective = true;
              for (final answer in answers) {
                final question = answer['assignment_questions'] as Map<String, dynamic>?;
                final type = _extractQuestionType(question);
                if (type != 'multiple_choice' && type != 'true_false') {
                  allObjective = false;
                  break;
                }
              }
              
              if (allObjective) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _autoPublishGrades();
                });
              }
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(DesignSpacing.md),
                    itemCount: answers.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildAssignmentInfoHeader(student, distribution, assignment, submittedAt);
                      }
                      return _buildQuestionCard(answers[index - 1], index - 1);
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: DesignColors.error),
                const SizedBox(height: DesignSpacing.md),
                Text('Lỗi tải dữ liệu', style: DesignTypography.bodyMedium),
                const SizedBox(height: DesignSpacing.md),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(teacherSubmissionDetailProvider(
                      submissionId: widget.submissionId,
                    ));
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildScoreFooter(),
    );
  }

  /// Assignment Info Header - Theo mẫu HTML
  Widget _buildAssignmentInfoHeader(
    Map<String, dynamic>? student,
    Map<String, dynamic>? distribution,
    Map<String, dynamic>? assignment,
    String? submittedAt,
  ) {
    final dueAt = distribution?['due_at'] as String?;
    final duration = assignment?['duration_minutes'] as int?;
    final className = distribution?['classes']?['name'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.lg),
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignColors.dividerLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: DesignComponents.avatarLarge,
            height: DesignComponents.avatarLarge,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: DesignColors.primaryLight, width: 2),
            ),
            child: ClipOval(
              child: student?['avatar_url'] != null
                  ? Image.network(
                      student!['avatar_url']!,
                      width: DesignComponents.avatarLarge,
                      height: DesignComponents.avatarLarge,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(student['full_name'] ?? '?'),
                    )
                  : _buildAvatarPlaceholder(student?['full_name'] ?? '?'),
            ),
          ),
          const SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment?['title'] ?? 'Bài tập',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DesignColors.textPrimary,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (className != null)
                  _buildInfoRow(
                    icon: Icons.school_outlined,
                    text: className,
                  ),
                _buildInfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: dueAt != null ? _formatDate(dueAt) : 'Không có deadline',
                ),
                if (submittedAt != null)
                  _buildInfoRow(
                    icon: Icons.access_time,
                    text: 'Nộp lúc: ${_formatDate(submittedAt)}',
                  ),
                if (duration != null && submittedAt == null)
                  _buildInfoRow(
                    icon: Icons.access_time,
                    text: '$duration phút làm bài',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF64B5F6),
            Color(0xFF1976D2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(name),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 14, color: DesignColors.textSecondary),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: DesignColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Question Card - Theo mẫu HTML
  Widget _buildQuestionCard(Map<String, dynamic> answer, int index) {
    final question = answer['assignment_questions'] as Map<String, dynamic>?;
    final questionType = _extractQuestionType(question);
    final maxScore = (question?['points'] as num?)?.toInt() ?? 10;
    final aiScore = answer['ai_score'] as num?;
    final finalScore = answer['final_score'] as num?;
    final currentScore = finalScore ?? aiScore ?? 0;
    final isCorrect = currentScore >= maxScore; // Đúng nếu đạt điểm tối đa

    // Xác định loại câu hỏi để hiển thị
    final isMultipleChoice = questionType == 'multiple_choice' || questionType == 'true_false';
    
    final studentAnswer = answer['answer'] as Map<String, dynamic>?;
    final selectedChoices = studentAnswer?['selected_choice_ids'] as List<dynamic>? ?? studentAnswer?['selected_choices'] as List<dynamic>?;
    final isUnansweredMcq = isMultipleChoice && (selectedChoices == null || selectedChoices.isEmpty);

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.lg),
      padding: const EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnansweredMcq ? DesignColors.error.withValues(alpha: 0.5) : DesignColors.dividerLight,
          width: isUnansweredMcq ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Question type + Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Câu ${index + 1}: ${_getQuestionTypeLabel(questionType)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: DesignColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Score - Màu đỏ nếu sai, xanh nếu đúng
              Row(
                children: [
                  const Text(
                    'Điểm:',
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 56,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.white : DesignColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isCorrect ? DesignColors.dividerLight : DesignColors.error,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${currentScore.toInt()}/$maxScore',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? DesignColors.primary : DesignColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Question content
          Text(
            _getQuestionContent(question),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: DesignColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Student Answer Box
          _buildStudentAnswerBox(answer, question, isMultipleChoice),
          const SizedBox(height: 16),

          // AI Feedback Box
          _buildAiFeedbackBox(answer, maxScore, isMultipleChoice),
          const SizedBox(height: 16),

          // AI Confidence Indicator
          if (aiScore != null)
            AiConfidenceIndicator(
              confidence: (answer['ai_confidence'] as num?)?.toDouble(),
            ),
          const SizedBox(height: 16),

          // Comment Section
          _buildCommentSection(answer, index),
          const SizedBox(height: DesignSpacing.md),

          // Grading Action Buttons
          if (aiScore != null)
            GradingActionButtons(
              answer: answer,
              onApprove: () => _approveScore(answer['id'] as String),
              onOverride: (score, reason) => _overrideScore(answer['id'] as String, score, reason),
              onFeedbackChanged: (feedback) => _updateFeedback(answer['id'] as String, feedback),
            ),
          const SizedBox(height: DesignSpacing.md),

          // Grade Audit Trail
          _buildGradeAuditTrail(answer['id'] as String),
        ],
      ),
    );
  }

  /// Build Grade Audit Trail widget
  Widget _buildGradeAuditTrail(String submissionAnswerId) {
    final historyAsync = ref.watch(gradeOverrideHistoryProvider(
      submissionAnswerId: submissionAnswerId,
    ));

    return historyAsync.when(
      data: (history) => GradeAuditTrail(history: history),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Comment Section - Auto-expand text field when feedback exists
  Widget _buildCommentSection(Map<String, dynamic> answer, int index) {
    final answerId = answer['id'] as String;

    // Xử lý an toàn: teacher_feedback có thể là String hoặc Map
    final teacherFeedbackRaw = answer['teacher_feedback'];
    String? teacherFeedback;
    if (teacherFeedbackRaw is String && teacherFeedbackRaw.isNotEmpty) {
      teacherFeedback = teacherFeedbackRaw;
    } else if (teacherFeedbackRaw is Map) {
      teacherFeedback = teacherFeedbackRaw['text']?.toString();
    }

    // Auto-expand nếu có feedback (lần đầu hiển thị)
    final hasFeedback = teacherFeedback != null && teacherFeedback.isNotEmpty;

    // Track expanded theo answerId
    // Nếu chưa từng toggle: dùng hasFeedback làm default
    // Nếu đã toggle: dùng giá trị đã lưu
    final bool isExpanded;
    if (_expandedComments.containsKey(answerId)) {
      isExpanded = _expandedComments[answerId]!;
    } else {
      isExpanded = hasFeedback;
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: DesignColors.dividerLight),
        ),
      ),
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _toggleComment(answerId),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isExpanded ? Icons.chat_bubble : Icons.chat_bubble_outline,
                    size: 16,
                    color: isExpanded ? DesignColors.primary : DesignColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isExpanded ? 'Nhận xét' : 'Thêm nhận xét',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isExpanded ? DesignColors.primary : DesignColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 12),
            _CommentTextField(
              key: ValueKey('comment_$answerId'),
              answerId: answerId,
              initialValue: teacherFeedback,
              submissionId: widget.submissionId,
            ),
          ],
        ],
      ),
    );
  }

  /// Track expanded comments theo answerId - dùng Map để trigger rebuild
  final Map<String, bool> _expandedComments = {};

  void _toggleComment(String answerId) {
    final current = _expandedComments[answerId] ?? false;
    setState(() {
      _expandedComments[answerId] = !current;
    });
  }

  /// Student Answer Box
  Widget _buildStudentAnswerBox(Map<String, dynamic> answer, Map<String, dynamic>? question, bool isMultipleChoice) {
    final studentAnswer = answer['answer'] as Map<String, dynamic>?;
    final answerText = studentAnswer?['text'] as String?;
    final selectedChoices = studentAnswer?['selected_choice_ids'] as List<dynamic>? ?? studentAnswer?['selected_choices'] as List<dynamic>?;

    // Nếu là trắc nghiệm
    if (isMultipleChoice) {
      return _buildMcqOptions(selectedChoices ?? [], question);
    }

    // Hiển thị text answer (tự luận)
    final hasAnswer = answerText != null && answerText.trim().isNotEmpty;

    if (!hasAnswer) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Row(
          children: [
            const Text('🟠', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Học sinh không có câu trả lời',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignColors.moonLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BÀI LÀM HỌC SINH',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: DesignColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answerText,
            style: const TextStyle(
              fontSize: 14,
              color: DesignColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// MCQ Options Display - Theo mẫu HTML với màu sắc đúng/sai
  Widget _buildMcqOptions(List<dynamic> selectedChoices, Map<String, dynamic>? question) {
    // Lấy choices từ custom_content
    final customContent = question?['custom_content'] as Map<String, dynamic>?;
    final choices = customContent?['choices'] as List<dynamic>?;

    if (choices == null || choices.isEmpty) {
      // Fallback: hiển thị danh sách lựa chọn
      return Wrap(
        spacing: DesignSpacing.sm,
        runSpacing: DesignSpacing.sm,
        children: selectedChoices.map((choice) {
          if (choice is int) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DesignColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Lựa chọn ${choice + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  color: DesignColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: DesignColors.dividerLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$choice',
              style: const TextStyle(
                fontSize: 14,
                color: DesignColors.textSecondary,
              ),
            ),
          );
        }).toList(),
      );
    }

    // Lấy đáp án đúng từ custom_content
    final correctChoiceIndex = _getCorrectChoiceIndex(choices);
    final selectedIndices = _getSelectedIndices(selectedChoices);

    final optionsWidget = Column(
      children: choices.asMap().entries.map((entry) {
        final choiceIndex = entry.key;
        final choice = entry.value as Map<String, dynamic>;
        final choiceText = choice['text']?.toString() ?? 'Lựa chọn ${choiceIndex + 1}';
        final isCorrect = choiceIndex == correctChoiceIndex;
        final isSelected = selectedIndices.contains(choiceIndex);

        // Xác định màu sắc theo spec:
        // - HS chọn sai: Tô đỏ đáp án HS chọn, tô xanh đáp án đúng
        // - HS chọn đúng: Tô xanh cả hai
        Color borderColor = DesignColors.dividerLight;
        Color bgColor = Colors.white;

        if (isSelected && !isCorrect) {
          // HS chọn sai: Tô đỏ
          borderColor = DesignColors.error;
          bgColor = DesignColors.error.withValues(alpha: 0.3);
        } else if (isCorrect) {
          // Đáp án đúng: Tô xanh
          borderColor = DesignColors.success;
          bgColor = DesignColors.success.withValues(alpha: 0.3);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isSelected || isCorrect ? 2 : 1),
          ),
          child: Row(
            children: [
              // Radio icon / Checkmark / X icon
              _buildOptionIcon(isSelected, isCorrect),
              const SizedBox(width: 12),
              // Option text
              Expanded(
                child: Text(
                  choiceText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected || isCorrect ? FontWeight.w600 : FontWeight.w500,
                    color: DesignColors.textPrimary,
                  ),
                ),
              ),
              // Icon bên phải: checkmark cho đáp án đúng
              if (isCorrect)
                Icon(
                  Icons.check_circle,
                  color: DesignColors.success,
                  size: 20,
                ),
            ],
          ),
        );
      }).toList(),
    );

    if (selectedChoices.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: DesignColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DesignColors.error.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: DesignColors.error, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Học sinh chưa chọn đáp án',
                    style: TextStyle(
                      fontSize: 14,
                      color: DesignColors.error,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          optionsWidget,
        ],
      );
    }

    return optionsWidget;
  }

  /// Build icon cho option: check/x/empty tùy trạng thái
  Widget _buildOptionIcon(bool isSelected, bool isCorrect) {
    if (isSelected && !isCorrect) {
      // HS chọn sai: X đỏ
      return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: DesignColors.error,
        ),
        child: const Icon(Icons.close, size: 12, color: Colors.white),
      );
    } else if (isCorrect) {
      // Đáp án đúng: Check xanh
      if (isSelected) {
        // HS chọn đúng: Check tròn xanh
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: DesignColors.success,
          ),
          child: const Icon(Icons.check, size: 12, color: Colors.white),
        );
      } else {
        // Chỉ đáp án đúng (HS không chọn): Chấm tròn xanh
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: DesignColors.success, width: 2),
          ),
          child: const Center(
            child: DotIndicator(),
          ),
        );
      }
    } else {
      // Không chọn, không đúng: Empty circle
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: DesignColors.dividerMedium, width: 2),
        ),
      );
    }
  }

  /// Lấy index của đáp án đúng
  int _getCorrectChoiceIndex(List<dynamic> choices) {
    for (var i = 0; i < choices.length; i++) {
      final choice = choices[i] as Map<String, dynamic>;
      if (choice['isCorrect'] == true) {
        return i;
      }
    }
    return -1;
  }

  /// Lấy danh sách indices mà HS đã chọn
  List<int> _getSelectedIndices(List<dynamic> selectedChoices) {
    final indices = <int>[];
    for (final choice in selectedChoices) {
      if (choice is int) {
        indices.add(choice);
      } else if (choice is Map) {
        // Map có thể có 'id' hoặc 'index'
        final id = choice['id'];
        if (id is int) {
          indices.add(id);
        }
      }
    }
    return indices;
  }

  /// AI Feedback Box - Chỉ hiển thị AI feedback hoặc MCQ explanation
  Widget _buildAiFeedbackBox(Map<String, dynamic> answer, int maxScore, bool isMultipleChoice) {
    // Xử lý an toàn: ai_feedback có thể là String hoặc Map
    final aiFeedbackRaw = answer['ai_feedback'];
    final aiFeedback = aiFeedbackRaw is String ? aiFeedbackRaw : (aiFeedbackRaw as Map<String, dynamic>?)?['text']?.toString();

    // Ẩn box nếu không có AI feedback và không phải MCQ
    if ((aiFeedback == null || aiFeedback.isEmpty) && !isMultipleChoice) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignColors.primaryLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesignColors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with AI icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: DesignColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 12,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'AI Feedback',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: DesignColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Hiển thị AI feedback hoặc MCQ explanation
          if (aiFeedback != null && aiFeedback.isNotEmpty)
            Text(
              aiFeedback,
              style: const TextStyle(
                fontSize: 12,
                color: DesignColors.textSecondary,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            )
          else if (isMultipleChoice)
            _buildMcqExplanation(answer),
        ],
      ),
    );
  }

  /// MCQ Error Explanation
  Widget _buildMcqExplanation(Map<String, dynamic> answer) {
    final question = answer['assignment_questions'] as Map<String, dynamic>?;
    final studentAnswer = answer['answer'] as Map<String, dynamic>?;
    final customContent = question?['custom_content'] as Map<String, dynamic>?;
    final choices = customContent?['choices'] as List<dynamic>?;
    final selectedChoices = studentAnswer?['selected_choice_ids'] as List<dynamic>? ?? studentAnswer?['selected_choices'] as List<dynamic>?;
    final correctIndex = choices != null ? _getCorrectChoiceIndex(choices) : -1;
    final selectedIndices = _getSelectedIndices(selectedChoices ?? []);

    String explanation = '';
    if (selectedIndices.isNotEmpty && correctIndex >= 0) {
      if (selectedIndices.contains(correctIndex)) {
        explanation = 'Học sinh đã chọn đáp án đúng!';
      } else {
        final correctText = choices != null && correctIndex < choices.length
            ? (choices[correctIndex] as Map<String, dynamic>)['text']?.toString() ?? 'Đáp án đúng'
            : 'Đáp án đúng';
        explanation = 'Học sinh chọn sai. $correctText.';
      }
    }

    return Text(
      explanation.isNotEmpty ? explanation : 'Không có phân tích',
      style: const TextStyle(
        fontSize: 12,
        color: DesignColors.textSecondary,
        fontStyle: FontStyle.italic,
        height: 1.5,
      ),
    );
  }

  /// Score Footer
  Widget _buildScoreFooter() {
    final detailAsync = ref.watch(teacherSubmissionDetailProvider(
      submissionId: widget.submissionId,
    ));

    return detailAsync.when(
      data: (data) {
        double totalScore = 0;
        final answers = data['submission_answers'] as List<Map<String, dynamic>>? ?? [];
        int totalMaxScore = 0;
        for (final answer in answers) {
          final question = answer['assignment_questions'] as Map<String, dynamic>?;
          final maxScore = (question?['points'] as num?)?.toInt() ?? 10;
          totalMaxScore += maxScore;
          final score = answer['final_score'] as num? ?? answer['ai_score'] as num? ?? 0;
          totalScore += score.toDouble();
        }

        final percentage = totalMaxScore > 0 ? (totalScore / totalMaxScore * 10).clamp(0.0, 10.0) : 0.0;
        final workSession = data['work_sessions'] as Map<String, dynamic>?;
        final isPublished = workSession?['status'] == 'graded';

        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 32,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              top: BorderSide(color: DesignColors.dividerLight),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x0A000000).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng điểm hiện tại',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: DesignColors.textSecondary,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        percentage.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: DesignColors.primary,
                        ),
                      ),
                      const Text(
                        ' / 10',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: DesignColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (!isPublished) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _publishGrades,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Hoàn thành',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
              if (isPublished) ...[
                const SizedBox(height: 12),
                const Text(
                  'Đã xuất bản điểm',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: DesignColors.success,
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'TRẮC NGHIỆM';
      case 'true_false':
        return 'ĐÚNG/Sai';
      case 'essay':
      default:
        return 'TỰ LUẬN';
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  String _extractQuestionType(Map<String, dynamic>? question) {
    if (question == null) return 'essay';
    
    // 1. Đọc từ custom_content.type (format: multipleChoice, trueFalse, essay)
    final customContent = question['custom_content'] as Map<String, dynamic>?;
    String? type = customContent?['type'] as String?;
    
    // 2. Fallback: đọc từ questions table (nested JOIN question_id.type)
    if (type == null || type.isEmpty) {
      final questionRef = question['question_id'];
      if (questionRef is Map<String, dynamic>) {
        type = questionRef['type'] as String?;
      }
    }
    
    // 3. Normalize formats
    if (type == 'multipleChoice') return 'multiple_choice';
    if (type == 'trueFalse') return 'true_false';
    return type ?? 'essay';
  }

  String _getQuestionContent(Map<String, dynamic>? question) {
    if (question == null) return '';
    final content = question['custom_content'];
    if (content is Map) {
      return content['text']?.toString() ??
             content['override_text']?.toString() ??
             content['question_text']?.toString() ??
             '';
    }
    return question['question_text']?.toString() ?? '';
  }

  Future<void> _approveScore(String answerId) async {
    try {
      await ref
          .read(submissionGradingNotifierProvider.notifier)
          .approveAiScore(answerId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã duyệt điểm AI')),
        );
        ref.invalidate(teacherSubmissionDetailProvider(
          submissionId: widget.submissionId,
        ));
      }
    } catch (e) {
      AppLogger.error('Error approving score: $e');
    }
  }

  Future<void> _overrideScore(
      String answerId, double newScore, String reason) async {
    try {
      await ref.read(submissionGradingNotifierProvider.notifier).overrideScore(
            submissionAnswerId: answerId,
            newScore: newScore,
            reason: reason,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật điểm: $newScore')),
        );
        ref.invalidate(teacherSubmissionDetailProvider(
          submissionId: widget.submissionId,
        ));
      }
    } catch (e) {
      AppLogger.error('Error overriding score: $e');
    }
  }

  Future<void> _updateFeedback(String answerId, String feedback) async {
    try {
      await ref.read(submissionGradingNotifierProvider.notifier).updateTeacherFeedback(
            submissionAnswerId: answerId,
            feedback: feedback,
          );
      // Refresh dữ liệu sau khi lưu
      ref.invalidate(teacherSubmissionDetailProvider(
        submissionId: widget.submissionId,
      ));
    } catch (e) {
      AppLogger.error('Error updating feedback: $e');
    }
  }

  Future<void> _publishGrades() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xuất bản điểm'),
        content: const Text(
          'Sau khi xuất bản, học sinh sẽ thấy điểm số. Bạn có chắc chắn muốn tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xuất bản'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(submissionGradingNotifierProvider.notifier).publishGrades(
              widget.submissionId,
              distributionId: widget.distributionId,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xuất bản điểm')),
          );
          context.pop();
        }
      } catch (e) {
        AppLogger.error('Error publishing grades: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi xuất bản điểm: $e')),
          );
        }
      }
    }
  }

  Future<void> _autoPublishGrades() async {
    try {
      await ref.read(submissionGradingNotifierProvider.notifier).publishGrades(
            widget.submissionId,
            distributionId: widget.distributionId,
          );

      if (mounted) {
        AppLogger.info('Auto-published grades for 100% objective assignment');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tự động xuất bản điểm (bài trắc nghiệm)')),
        );
        ref.invalidate(teacherSubmissionDetailProvider(
          submissionId: widget.submissionId,
        ));
      }
    } catch (e) {
      AppLogger.error('Error auto publishing grades: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xuất bản: $e')),
        );
      }
    }
  }
}

/// Dot indicator cho MCQ
class DotIndicator extends StatelessWidget {
  const DotIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: DesignColors.success,
      ),
    );
  }
}

/// TextField widget cho comment với state management riêng
class _CommentTextField extends ConsumerStatefulWidget {
  final String answerId;
  final String? initialValue;
  final String submissionId;

  const _CommentTextField({
    super.key,
    required this.answerId,
    this.initialValue,
    required this.submissionId,
  });

  @override
  ConsumerState<_CommentTextField> createState() => _CommentTextFieldState();
}

class _CommentTextFieldState extends ConsumerState<_CommentTextField> {
  late TextEditingController _controller;
  bool _isSaving = false;
  String _lastSaved = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _lastSaved = widget.initialValue ?? '';
  }

  @override
  void didUpdateWidget(covariant _CommentTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller khi initialValue thay đổi (sau khi refresh)
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue ?? '';
      _lastSaved = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveFeedback(String value) async {
    // Không save nếu giá trị không đổi
    if (value == _lastSaved || _isSaving) return;
    if (value.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      await ref.read(submissionGradingNotifierProvider.notifier).updateTeacherFeedback(
            submissionAnswerId: widget.answerId,
            feedback: value,
          );
      _lastSaved = value;
      // Refresh dữ liệu
      ref.invalidate(teacherSubmissionDetailProvider(
        submissionId: widget.submissionId,
      ));
    } catch (e) {
      AppLogger.error('Error updating feedback: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignColors.moonLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: TextField(
        controller: _controller,
        minLines: 1,
        maxLines: 5,
        scrollPhysics: const ClampingScrollPhysics(),
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: 'Nhập nhận xét của bạn...',
          hintStyle: const TextStyle(
            fontSize: 12,
            color: DesignColors.textTertiary,
          ),
          contentPadding: const EdgeInsets.all(12),
          border: InputBorder.none,
          suffixIcon: _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
        ),
        onChanged: (value) {
          // Debounce: chỉ save sau khi ngừng gõ 1 giây
          Future.delayed(const Duration(seconds: 1), () {
            if (_controller.text == value) {
              _saveFeedback(value);
            }
          });
        },
        onEditingComplete: () {
          // Save ngay khi bấm done
          _saveFeedback(_controller.text);
        },
      ),
    );
  }
}
