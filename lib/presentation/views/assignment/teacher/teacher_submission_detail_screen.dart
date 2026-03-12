import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/presentation/providers/teacher_submission_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/submission/ai_confidence_indicator.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/submission/grading_action_buttons.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Teacher Submission Detail Screen - Side-by-Side Layout
/// Desktop: 2 cột | Mobile: Bottom Sheet
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
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  int _totalQuestions = 0;
  List<Map<String, dynamic>> _answers = [];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết bài nộp'),
        actions: [
          // Quick Navigation
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentIndex > 0 ? _previousQuestion : null,
            tooltip: 'Câu trước',
          ),
          Text(
            '${_currentIndex + 1}/$_totalQuestions',
            style: DesignTypography.bodyMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                _currentIndex < _totalQuestions - 1 ? _nextQuestion : null,
            tooltip: 'Câu tiếp',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ref.read(teacherSubmissionDetailProvider(
          submissionId: widget.submissionId,
        ).future),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: DesignColors.error),
                  const SizedBox(height: DesignSpacing.md),
                  Text('Lỗi tải dữ liệu',
                      style: DesignTypography.bodyMedium),
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
            );
          }

          final submission = snapshot.data!;
          final student = submission['profiles'] as Map<String, dynamic>?;
          _answers = submission['submission_answers'] as List<Map<String, dynamic>>? ?? [];
          _totalQuestions = _answers.length;

          if (isDesktop) {
            return _buildDesktopLayout(submission, student);
          } else {
            return _buildMobileLayout(submission, student);
          }
        },
      ),
    );
  }

  /// Desktop: Side-by-Side Layout
  Widget _buildDesktopLayout(
      Map<String, dynamic> submission, Map<String, dynamic>? student) {
    final currentAnswer = _answers.isNotEmpty && _currentIndex < _answers.length
        ? _answers[_currentIndex]
        : null;

    return Row(
      children: [
        // Cột trái: Bài làm của học sinh
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: DesignColors.dividerMedium),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student info header
                _buildStudentHeader(student),
                const Divider(height: 1),

                // Câu trả lời
                Expanded(
                  child: currentAnswer != null
                      ? QuestionAnswerCard(
                          answer: currentAnswer,
                          showStudentAnswer: true,
                        )
                      : const Center(child: Text('Không có dữ liệu')),
                ),
              ],
            ),
          ),
        ),

        // Cột phải: Đáp án + Rubric + Grading
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Confidence Indicator
              if (currentAnswer != null)
                AiConfidenceIndicator(
                  confidence: (currentAnswer['ai_confidence'] as num?)?.toDouble(),
                ),

              // Đáp án đúng + Rubric
              Expanded(
                child: currentAnswer != null
                    ? QuestionAnswerCard(
                        answer: currentAnswer,
                        showCorrectAnswer: true,
                        showRubric: true,
                      )
                    : const Center(child: Text('Không có dữ liệu')),
              ),

              // Grading Actions
              if (currentAnswer != null)
                GradingActionButtons(
                  answer: currentAnswer,
                  onApprove: () => _approveScore(currentAnswer['id']),
                  onOverride: (score, reason) =>
                      _overrideScore(currentAnswer['id'], score, reason),
                  onFeedbackChanged: (feedback) =>
                      _updateFeedback(currentAnswer['id'], feedback),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Mobile: Bottom Sheet Layout
  Widget _buildMobileLayout(
      Map<String, dynamic> submission, Map<String, dynamic>? student) {
    return Column(
      children: [
        // Student info
        _buildStudentHeader(student),

        // Page view for questions
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemCount: _totalQuestions,
            itemBuilder: (context, index) {
              final answer = _answers[index];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(DesignSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Câu hỏi + Câu trả lời HS
                    QuestionAnswerCard(
                      answer: answer,
                      showStudentAnswer: true,
                    ),

                    const SizedBox(height: DesignSpacing.md),

                    // AI Confidence
                    AiConfidenceIndicator(
                      confidence: (answer['ai_confidence'] as num?)?.toDouble(),
                    ),

                    const SizedBox(height: DesignSpacing.md),

                    // Nút xem đáp án
                    ElevatedButton.icon(
                      onPressed: () => _showAnswerBottomSheet(answer),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Xem đáp án & Rubric'),
                    ),

                    const SizedBox(height: DesignSpacing.md),

                    // Grading Actions
                    GradingActionButtons(
                      answer: answer,
                      onApprove: () => _approveScore(answer['id']),
                      onOverride: (score, reason) =>
                          _overrideScore(answer['id'], score, reason),
                      onFeedbackChanged: (feedback) =>
                          _updateFeedback(answer['id'], feedback),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Navigation dots
        Padding(
          padding: const EdgeInsets.all(DesignSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _totalQuestions,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: index == _currentIndex ? 12 : 8,
                height: index == _currentIndex ? 12 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentIndex
                      ? DesignColors.primary
                      : DesignColors.dividerMedium,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentHeader(Map<String, dynamic>? student) {
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: DesignColors.primary.withValues(alpha: 0.1),
            child: Text(
              student?['full_name']?.toString().substring(0, 1).toUpperCase() ?? '?',
              style: DesignTypography.bodyMedium?.copyWith(color: DesignColors.primary),
            ),
          ),
          const SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student?['full_name']?.toString() ?? 'Học sinh',
                  style: DesignTypography.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Nộp lúc: ${_formatDateTime(DateTime.now())}',
                  style: DesignTypography.bodySmall?.copyWith(color: DesignColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAnswerBottomSheet(Map<String, dynamic> answer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Đáp án & Rubric', style: DesignTypography.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(DesignSpacing.md),
                child: QuestionAnswerCard(
                  answer: answer,
                  showCorrectAnswer: true,
                  showRubric: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _totalQuestions - 1) {
      setState(() => _currentIndex++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
    } catch (e) {
      AppLogger.error('Error updating feedback: $e');
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
