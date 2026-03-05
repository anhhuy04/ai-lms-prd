import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Màn hình workspace để học sinh làm bài tập
class StudentAssignmentWorkspaceScreen extends ConsumerStatefulWidget {
  final String distributionId;

  const StudentAssignmentWorkspaceScreen({
    super.key,
    required this.distributionId,
  });

  @override
  ConsumerState<StudentAssignmentWorkspaceScreen> createState() =>
      _StudentAssignmentWorkspaceScreenState();
}

class _StudentAssignmentWorkspaceScreenState
    extends ConsumerState<StudentAssignmentWorkspaceScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize workspace
    Future.microtask(() {
      ref
          .read(workspaceNotifierProvider(widget.distributionId).notifier)
          .initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workspaceAsync =
        ref.watch(workspaceNotifierProvider(widget.distributionId));

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: _buildAppBar(context, workspaceAsync),
      body: workspaceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(context, error),
        data: (workspace) => _buildBody(context, workspace),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AsyncValue<WorkspaceState> workspaceAsync,
  ) {
    return AppBar(
      backgroundColor: DesignColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: DesignIcons.smSize),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: workspaceAsync.maybeWhen(
        data: (workspace) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workspace.assignmentTitle,
              style: TextStyle(
                fontSize: DesignTypography.bodyMediumSize,
                fontWeight: DesignTypography.bold,
                color: DesignColors.textPrimary,
              ),
            ),
            Text(
              'Câu ${workspace.answeredCount}/${workspace.totalQuestions} đã trả lời',
              style: TextStyle(
                fontSize: DesignTypography.captionSize,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        orElse: () => const Text('Làm bài tập'),
      ),
      actions: [
        workspaceAsync.maybeWhen(
          data: (workspace) => _buildSavingIndicator(workspace.savingStatus),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSavingIndicator(SavingStatus status) {
    switch (status) {
      case SavingStatus.saving:
        return Padding(
          padding: const EdgeInsets.only(right: DesignSpacing.md),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: DesignColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Đang lưu...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      case SavingStatus.saved:
        return Padding(
          padding: const EdgeInsets.only(right: DesignSpacing.md),
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
              const SizedBox(width: 6),
              Text(
                'Đã lưu',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
        );
      case SavingStatus.error:
        return Padding(
          padding: const EdgeInsets.only(right: DesignSpacing.md),
          child: Row(
            children: [
              Icon(Icons.error_outline, size: 16, color: Colors.red[600]),
              const SizedBox(width: 6),
              Text(
                'Lỗi lưu',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
        );
      case SavingStatus.idle:
        return const SizedBox.shrink();
    }
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
              'Lỗi khi tải bài tập',
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
            const SizedBox(height: DesignSpacing.lg),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(workspaceNotifierProvider(widget.distributionId)
                        .notifier)
                    .initialize();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WorkspaceState workspace) {
    if (workspace.questions.isEmpty) {
      return _buildEmptyQuestions();
    }

    return Column(
      children: [
        // Content
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(DesignSpacing.md),
            itemCount: workspace.questions.length,
            itemBuilder: (context, index) {
              final question = workspace.questions[index];
              final answer = workspace.answers[question.id];
              return _buildQuestionCard(
                context,
                question,
                answer,
                index + 1,
              );
            },
          ),
        ),

        // Bottom Action Bar
        _buildBottomActionBar(context, workspace),
      ],
    );
  }

  Widget _buildEmptyQuestions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: DesignSpacing.md),
            Text(
              'Bài tập chưa có câu hỏi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    QuestionState question,
    dynamic answer,
    int number,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.lg),
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getQuestionTypeIcon(question.type),
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getQuestionTypeLabel(question.type),
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
                            '${question.points.toInt()} điểm',
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
                      question.content,
                      style: TextStyle(
                        fontSize: 15,
                        color: DesignColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: DesignSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: DesignSpacing.md),

          // Question input based on type
          _buildQuestionInput(question, answer),
        ],
      ),
    );
  }

  Widget _buildQuestionInput(QuestionState question, dynamic answer) {
    switch (question.type) {
      case 'multiple_choice':
        return _buildMultipleChoice(question, answer);
      case 'true_false':
        return _buildTrueFalse(question, answer);
      case 'essay':
        return _buildEssay(question, answer);
      case 'fill_blank':
        return _buildFillInBlank(question, answer);
      default:
        return _buildMultipleChoice(question, answer);
    }
  }

  Widget _buildMultipleChoice(QuestionState question, dynamic answer) {
    return Column(
      children: question.choices.map((choice) {
        final isSelected = answer == choice.id;
        return InkWell(
          onTap: () {
            ref
                .read(workspaceNotifierProvider(widget.distributionId).notifier)
                .updateAnswer(question.id, choice.id);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: DesignSpacing.sm),
            padding: const EdgeInsets.all(DesignSpacing.md),
            decoration: BoxDecoration(
              color: isSelected
                  ? DesignColors.primary.withValues(alpha: 0.1)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(DesignRadius.md),
              border: Border.all(
                color: isSelected ? DesignColors.primary : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? DesignColors.primary : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: DesignColors.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: DesignSpacing.md),
                Expanded(
                  child: Text(
                    choice.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: DesignColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalse(QuestionState question, dynamic answer) {
    return Row(
      children: [
        Expanded(
          child: _buildTrueFalseButton(
            question: question,
            value: 'true',
            label: 'Đúng',
            icon: Icons.check_circle_outline,
            isSelected: answer == 'true',
          ),
        ),
        const SizedBox(width: DesignSpacing.md),
        Expanded(
          child: _buildTrueFalseButton(
            question: question,
            value: 'false',
            label: 'Sai',
            icon: Icons.cancel_outlined,
            isSelected: answer == 'false',
          ),
        ),
      ],
    );
  }

  Widget _buildTrueFalseButton({
    required QuestionState question,
    required String value,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        ref
            .read(workspaceNotifierProvider(widget.distributionId).notifier)
            .updateAnswer(question.id, value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: DesignSpacing.md,
          horizontal: DesignSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (value == 'true' ? Colors.green : Colors.red).withValues(alpha: 0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(
            color: isSelected
                ? (value == 'true' ? Colors.green : Colors.red)
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? (value == 'true' ? Colors.green : Colors.red)
                  : Colors.grey[600],
            ),
            const SizedBox(width: DesignSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (value == 'true' ? Colors.green : Colors.red)
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEssay(QuestionState question, dynamic answer) {
    final controller = TextEditingController(text: answer as String? ?? '');

    return TextField(
      controller: controller,
      maxLines: 6,
      decoration: InputDecoration(
        hintText: 'Nhập câu trả lời của bạn...',
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.md),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.md),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.md),
          borderSide: BorderSide(color: DesignColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(DesignSpacing.md),
      ),
      onChanged: (value) {
        ref
            .read(workspaceNotifierProvider(widget.distributionId).notifier)
            .updateAnswer(question.id, value);
      },
    );
  }

  Widget _buildFillInBlank(QuestionState question, dynamic answer) {
    // For fill in blank, answer can be a map with blank indices
    final answersMap = answer is Map ? answer as Map<String, dynamic> : <String, dynamic>{};

    return Column(
      children: List.generate(question.choices.length, (index) {
        final blankId = 'blank_$index';
        final initialValue = answersMap[blankId] as String? ?? '';

        return Padding(
          padding: const EdgeInsets.only(bottom: DesignSpacing.md),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: DesignColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: DesignColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DesignSpacing.md),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: initialValue),
                  decoration: InputDecoration(
                    hintText: 'Nhập đáp án...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignRadius.md),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignRadius.md),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignRadius.md),
                      borderSide: BorderSide(color: DesignColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: DesignSpacing.md,
                      vertical: DesignSpacing.sm,
                    ),
                  ),
                  onChanged: (value) {
                    final newAnswers = Map<String, dynamic>.from(answersMap);
                    newAnswers[blankId] = value;
                    ref
                        .read(workspaceNotifierProvider(widget.distributionId)
                            .notifier)
                        .updateAnswer(question.id, newAnswers);
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, WorkspaceState workspace) {
    final isSubmitting =
        workspace.submissionStatus == WorkspaceSubmissionStatus.submitting;
    final isSubmitted =
        workspace.submissionStatus == WorkspaceSubmissionStatus.submitted;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: workspace.totalQuestions > 0
                        ? workspace.answeredCount / workspace.totalQuestions
                        : 0,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(DesignColors.primary),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: DesignSpacing.md),
                Text(
                  '${workspace.answeredCount}/${workspace.totalQuestions}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: DesignColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: DesignSpacing.md),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSubmitting || isSubmitted
                    ? null
                    : () => _showSubmitConfirmation(context, workspace),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSubmitted ? Colors.grey[300] : DesignColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: DesignSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.md),
                  ),
                ),
                icon: isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(isSubmitted ? Icons.check_circle : Icons.send),
                label: Text(
                  isSubmitting
                      ? 'Đang nộp...'
                      : isSubmitted
                          ? 'Đã nộp'
                          : 'Nộp bài',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSubmitConfirmation(
    BuildContext context,
    WorkspaceState workspace,
  ) async {
    final answeredCount = workspace.answeredCount;
    final totalQuestions = workspace.totalQuestions;
    final unanswered = totalQuestions - answeredCount;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận nộp bài'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn đã trả lời $answeredCount/$totalQuestions câu hỏi.'),
            if (unanswered > 0) ...[
              const SizedBox(height: DesignSpacing.sm),
              Text(
                'Còn $unanswered câu chưa trả lời.',
                style: TextStyle(color: Colors.orange[700]),
              ),
            ],
            const SizedBox(height: DesignSpacing.md),
            const Text('Bạn có chắc chắn muốn nộp bài không?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(workspaceNotifierProvider(widget.distributionId).notifier)
          .submit();

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nộp bài thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nộp bài thất bại. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
}
