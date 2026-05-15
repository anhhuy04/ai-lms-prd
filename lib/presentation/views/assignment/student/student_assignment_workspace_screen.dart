import 'dart:async';
import 'dart:io';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/providers/workspace_provider.dart';
import 'package:ai_mls/presentation/views/assignment/student/widgets/essay_answer_field.dart';
import 'package:ai_mls/widgets/editor/rich_text_toolbar.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:ai_mls/widgets/rubric/read_only_rubric_viewer.dart';
import 'package:ai_mls/widgets/text/math_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Màn hình workspace để học sinh làm bài tập.
/// [isReadOnly] = true: chỉ xem lại bài đã nộp, không cho sửa.
class StudentAssignmentWorkspaceScreen extends ConsumerStatefulWidget {
  final String distributionId;
  final bool isReadOnly;

  const StudentAssignmentWorkspaceScreen({
    super.key,
    required this.distributionId,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<StudentAssignmentWorkspaceScreen> createState() =>
      _StudentAssignmentWorkspaceScreenState();
}

class _StudentAssignmentWorkspaceScreenState
    extends ConsumerState<StudentAssignmentWorkspaceScreen>
    with WidgetsBindingObserver {
  // Map to store TextEditingControllers for fill-in-blank questions
  final Map<String, TextEditingController> _fillInBlankControllers = {};

  // Per-question time tracking (D-10)
  final Map<String, Stopwatch> _questionTimers = {};
  String? _currentQuestionId;

  /// Watchdog hạn nạp bài: tick 1s. Khi quá due_at + !allow_late → auto-submit.
  /// Chỉ chạy 1 lần (tự huỷ sau khi fire).
  Timer? _dueAtWatchdog;
  bool _autoSubmittedDueAt = false;

  @override
  void initState() {
    super.initState();
    // Register observer for back button
    WidgetsBinding.instance.addObserver(this);
    // Initialize workspace
    Future.microtask(() {
      ref
          .read(workspaceNotifierProvider(widget.distributionId).notifier)
          .initialize();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dueAtWatchdog?.cancel();
    // Dispose all TextEditingControllers
    for (final controller in _fillInBlankControllers.values) {
      controller.dispose();
    }
    _fillInBlankControllers.clear();
    // Stop all question timers
    for (final sw in _questionTimers.values) {
      sw.stop();
    }
    super.dispose();
  }

  /// Bật watchdog 1 lần khi state đã có due_at và đang in_progress.
  /// Tick mỗi 5s — đủ kịp thời mà không tốn tài nguyên. Nếu DB đã đóng cứng
  /// (past due + !allow_late) ngay khi load → auto-submit ngay frame sau.
  void _ensureDueAtWatchdog(WorkspaceState ws) {
    if (_dueAtWatchdog != null) return;
    if (_autoSubmittedDueAt) return;
    if (ws.submissionStatus != WorkspaceSubmissionStatus.inProgress) return;
    final due = ws.dueAt;
    if (due == null) return;
    if (ws.allowLate) return;

    void tickCheck() {
      if (!mounted || _autoSubmittedDueAt) return;
      if (DateTime.now().isAfter(due)) {
        _autoSubmittedDueAt = true;
        _dueAtWatchdog?.cancel();
        _dueAtWatchdog = null;
        _onTimeUp();
      }
    }

    // Check ngay (trường hợp vào màn hình lúc đã quá hạn)
    WidgetsBinding.instance.addPostFrameCallback((_) => tickCheck());
    _dueAtWatchdog =
        Timer.periodic(const Duration(seconds: 5), (_) => tickCheck());
  }

  /// Switch active question timer: pause old, start/resume new (D-10)
  void _onQuestionChanged(String newQuestionId) {
    if (_currentQuestionId == newQuestionId) return;
    if (_currentQuestionId != null) {
      _questionTimers[_currentQuestionId!]?.stop();
    }
    _questionTimers.putIfAbsent(newQuestionId, () => Stopwatch());
    _questionTimers[newQuestionId]!.start();
    _currentQuestionId = newQuestionId;
  }

  /// Get elapsed seconds per question for analytics (D-10)
  Map<String, int> getTimeLog() {
    // Stop active timer before reading
    if (_currentQuestionId != null) {
      _questionTimers[_currentQuestionId!]?.stop();
    }
    return _questionTimers.map((id, sw) => MapEntry(id, sw.elapsed.inSeconds));
  }

  @override
  Future<bool> didPopRoute() async {
    final workspaceAsync = ref.read(
      workspaceNotifierProvider(widget.distributionId),
    );
    await _handleBackPress(context, workspaceAsync);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final workspaceAsync = ref.watch(
      workspaceNotifierProvider(widget.distributionId),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress(context, workspaceAsync);
      },
      child: Scaffold(
        backgroundColor: DesignColors.moonLight,
        appBar: _buildAppBar(context, workspaceAsync),
        body: workspaceAsync.when(
          loading: () => const ShimmerLoading(),
          error: (error, _) => _buildErrorState(context, error),
          data: (workspace) => _buildBody(context, workspace),
        ),
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
        onPressed: () => _handleBackPress(context, workspaceAsync),
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
              widget.isReadOnly
                  ? 'Chế độ xem lại bài làm'
                  : workspace.attempt > 1
                      ? 'Lần làm thứ ${workspace.attempt}${workspace.maxAttempts != null ? '/${workspace.maxAttempts}' : ''} · ${workspace.answeredCount}/${workspace.totalQuestions} câu'
                      : 'Câu ${workspace.answeredCount}/${workspace.totalQuestions} đã trả lời',
              style: TextStyle(
                fontSize: DesignTypography.captionSize,
                color: widget.isReadOnly
                    ? DesignColors.warning
                    : workspace.attempt > 1
                        ? DesignColors.primary
                        : DesignColors.textSecondary,
              ),
            ),
          ],
        ),
        orElse: () => Text(widget.isReadOnly ? 'Xem lại bài làm' : 'Làm bài tập'),
      ),
      actions: [
        // Đồng hồ đếm ngược — chỉ hiển thị khi đang làm bài và có giới hạn thời gian
        if (!widget.isReadOnly)
          workspaceAsync.maybeWhen(
            data: (workspace) {
              if (workspace.timeLimitMinutes != null &&
                  workspace.sessionStartedAt != null &&
                  workspace.submissionStatus == WorkspaceSubmissionStatus.inProgress) {
                return _CountdownTimerWidget(
                  totalSeconds: workspace.timeLimitMinutes! * 60,
                  startedAt: workspace.sessionStartedAt!,
                  onTimeUp: _onTimeUp,
                );
              }
              return const SizedBox.shrink();
            },
            orElse: () => const SizedBox.shrink(),
          ),
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
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      case SavingStatus.saved:
        return Padding(
          padding: const EdgeInsets.only(right: DesignSpacing.md),
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: DesignColors.success),
              const SizedBox(width: 6),
              Text(
                'Đã lưu',
                style: TextStyle(fontSize: 12, color: DesignColors.success),
              ),
            ],
          ),
        );
      case SavingStatus.error:
        return Padding(
          padding: const EdgeInsets.only(right: DesignSpacing.md),
          child: Row(
            children: [
              Icon(Icons.error_outline, size: 16, color: DesignColors.error),
              const SizedBox(width: 6),
              Text(
                'Lỗi lưu',
                style: TextStyle(fontSize: 12, color: DesignColors.error),
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
            Icon(Icons.error_outline, size: 48, color: DesignColors.error),
            const SizedBox(height: DesignSpacing.md),
            Text(
              'Lỗi khi tải bài tập',
              style: DesignTypography.bodyLarge.copyWith(
                color: DesignColors.textSecondary,
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
                    .read(
                      workspaceNotifierProvider(widget.distributionId).notifier,
                    )
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
    // Bật watchdog hạn nạp bài (chỉ 1 lần per state lifecycle).
    _ensureDueAtWatchdog(workspace);

    if (workspace.questions.isEmpty) {
      return _buildEmptyQuestions();
    }

    // Start timer for first question on first build (D-10)
    if (_currentQuestionId == null && workspace.questions.isNotEmpty) {
      _onQuestionChanged(workspace.questions.first.id);
    }

    return Column(
      children: [
        // Banner xem lại khi readOnly
        if (widget.isReadOnly)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: DesignColors.warning.withValues(alpha: 0.08),
            child: Row(children: [
              Icon(Icons.visibility_outlined, size: 16, color: DesignColors.warning),
              const SizedBox(width: 8),
              Expanded(child: Text(
                'Bạn đang xem lại bài đã nộp. Các câu trả lời không thể chỉnh sửa.',
                style: TextStyle(fontSize: 12, color: DesignColors.warning),
              )),
            ]),
          ),
        // Content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(DesignSpacing.md),
            children: [
              // Questions — wrapped with IgnorePointer khi readOnly
              ...workspace.questions.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                final answer = workspace.answers[question.id];
                return IgnorePointer(
                  ignoring: widget.isReadOnly,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _onQuestionChanged(question.id),
                    child: _buildQuestionCard(context, question, answer, index + 1),
                  ),
                );
              }),
            ],
          ),
        ),

        // Bottom Action Bar
        widget.isReadOnly
            ? _buildReadOnlyActionBar(context)
            : _buildBottomActionBar(context, workspace),
      ],
    );
  }

  /// Action bar khi xem lại — chỉ có nút "Đóng"
  Widget _buildReadOnlyActionBar(BuildContext context) {
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
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Đóng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.md)),
            ),
          ),
        ),
      ),
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

  // File upload đã chuyển vào EssayAnswerField widget

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
      case 'short_answer':
        return _buildShortAnswer(question, answer);
      case 'fill_blank':
        return _buildFillInBlank(question, answer);
      case 'matching':
        return _buildMatching(question, answer);
      case 'math':
      case 'problem_solving':
        return _buildProblemSolving(question, answer);
      case 'file_upload':
        return _buildFileUpload(question, answer);
      default:
        return _buildMultipleChoice(question, answer);
    }
  }

  Widget _buildMultipleChoice(QuestionState question, dynamic answer) {
    if (question.choices.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: question.choices.asMap().entries.map((entry) {
        final choice = entry.value;
        // Tử Huyệt 5: đọc format mới (selected_choice_ids) trước, fallback format cũ (selected_choices)
        final selectedList = answer is Map
            ? ((answer['selected_choice_ids'] as List?) ??
                  (answer['selected_choices'] as List?))
            : null;
        final isSelected =
            selectedList?.any(
              (e) => e == choice.id || e.toString() == choice.id.toString(),
            ) ==
            true;
        return InkWell(
          onTap: () {
            ref
                .read(workspaceNotifierProvider(widget.distributionId).notifier)
                .updateAnswer(question.id, {
                  'selected_choice_ids': [choice.id],
                });
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
                      color: isSelected
                          ? DesignColors.primary
                          : Colors.grey[400]!,
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
    // Tử Huyệt 5: đọc format mới trước, fallback cũ
    final selectedChoices = answer is Map
        ? ((answer['selected_choice_ids'] as List?) ??
              (answer['selected_choices'] as List?))
        : null;
    final selectedChoiceId = selectedChoices?.firstOrNull?.toString();

    // Find the choice ID for true/false
    final trueChoice = question.choices
        .where(
          (c) =>
              c.content.toLowerCase() == 'true' ||
              c.content.toLowerCase() == 'đúng',
        )
        .firstOrNull;
    final falseChoice = question.choices
        .where(
          (c) =>
              c.content.toLowerCase() == 'false' ||
              c.content.toLowerCase() == 'sai',
        )
        .firstOrNull;

    return Row(
      children: [
        Expanded(
          child: _buildTrueFalseButton(
            question: question,
            value: 'true',
            label: 'Đúng',
            icon: Icons.check_circle_outline,
            isSelected: selectedChoiceId == trueChoice?.id.toString(),
            choiceId: trueChoice?.id.toString() ?? 'true',
          ),
        ),
        const SizedBox(width: DesignSpacing.md),
        Expanded(
          child: _buildTrueFalseButton(
            question: question,
            value: 'false',
            label: 'Sai',
            icon: Icons.cancel_outlined,
            isSelected: selectedChoiceId == falseChoice?.id.toString(),
            choiceId: falseChoice?.id.toString() ?? 'false',
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
    required String choiceId, // int converted to String for selected_choices
  }) {
    return InkWell(
      onTap: () {
        ref
            .read(workspaceNotifierProvider(widget.distributionId).notifier)
            .updateAnswer(question.id, {
              'selected_choice_ids': [choiceId],
            });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: DesignSpacing.md,
          horizontal: DesignSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (value == 'true' ? DesignColors.success : DesignColors.error).withValues(alpha: 0.1)
              : DesignColors.moonLight,
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(
            color: isSelected
                ? (value == 'true' ? DesignColors.success : DesignColors.error)
                : DesignColors.dividerMedium,
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
                  ? (value == 'true' ? DesignColors.success : DesignColors.error)
                  : DesignColors.textSecondary,
            ),
            const SizedBox(width: DesignSpacing.sm),
            Text(
              label,
              style: DesignTypography.bodyLarge.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (value == 'true' ? DesignColors.success : DesignColors.error)
                    : DesignColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEssay(QuestionState question, dynamic answer) {
    // Get text from answer map: {"text": "content"}
    final answerText = answer is Map ? (answer['text'] as String?) ?? '' : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRubricButton(question),
        EssayAnswerField(
          questionId: question.id,
          initialValue: answerText,
          distributionId: widget.distributionId,
        ),
      ],
    );
  }

  /// Shows "Xem Tiêu chí" button if question has a rubric attached.
  Widget _buildRubricButton(QuestionState question) {
    if (question.rubric == null) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        icon: Icon(
          Icons.info_outline,
          size: DesignIcons.xsSize,
          color: DesignColors.tealPrimary,
        ),
        label: Text(
          'Xem Tiêu chí',
          style: DesignTypography.caption.copyWith(color: DesignColors.tealPrimary),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSpacing.sm,
            vertical: DesignSpacing.xs,
          ),
          minimumSize: const Size(0, 32),
        ),
        onPressed: () => _showRubricSheet(question.rubric!),
      ),
    );
  }

  /// Opens a read-only bottom sheet with the rubric criteria (D-03 compliant).
  void _showRubricSheet(Map<String, dynamic> rubric) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DesignRadius.lg),
          topRight: Radius.circular(DesignRadius.lg),
        ),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: DesignSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DesignColors.dividerMedium,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: ReadOnlyRubricViewer(rubric: rubric),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFillInBlank(QuestionState question, dynamic answer) {
    // For fill in blank, answer can be a map with blank indices
    final answersMap = answer is Map
        ? answer as Map<String, dynamic>
        : <String, dynamic>{};

    // Ưu tiên question.blanks (đúng schema), fallback choices (legacy)
    final blankCount =
        question.blanks?.length ?? question.choices.length;
    if (blankCount == 0) {
      return Padding(
        padding: const EdgeInsets.all(DesignSpacing.md),
        child: Text(
          'Câu hỏi điền khuyết chưa có ô trống',
          style: TextStyle(
            color: DesignColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      children: List.generate(blankCount, (index) {
        final blankId = '${question.id}_blank_$index';
        final initialValue = answersMap[blankId] as String? ?? '';

        // Get or create controller for this blank
        final controller = _fillInBlankControllers.putIfAbsent(
          blankId,
          () => TextEditingController(text: initialValue),
        );

        // UI-3 fix: chỉ sync ngược khi controller đang trống (lần đầu mount
        // sau khi đáp án nháp được nạp từ DB). Sau đó user-gõ là nguồn chân
        // lý — KHÔNG ghi đè controller.text mỗi rebuild vì autosave debounce
        // sẽ trigger setState → cursor nhảy cuối, mất ký tự đang gõ.
        if (controller.text.isEmpty && initialValue.isNotEmpty) {
          controller.value = TextEditingValue(
            text: initialValue,
            selection: TextSelection.collapsed(offset: initialValue.length),
          );
        }

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
                  controller: controller,
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
                      borderSide: BorderSide(
                        color: DesignColors.primary,
                        width: 2,
                      ),
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
                        .read(
                          workspaceNotifierProvider(
                            widget.distributionId,
                          ).notifier,
                        )
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

  /// Short Answer - tương tự essay nhưng ngắn gọn hơn
  Widget _buildShortAnswer(QuestionState question, dynamic answer) {
    return _buildEssay(question, answer);
  }

  /// Matching - dropdown chọn cặp tương ứng cho mỗi mục bên trái.
  /// Student answer format: `{<qId>_match_<leftIdx>: rightIdx}`
  Widget _buildMatching(QuestionState question, dynamic answer) {
    final pairs = question.pairs ?? const <Map<String, dynamic>>[];
    if (pairs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(DesignSpacing.md),
        child: Text(
          'Câu hỏi nối khớp chưa có cặp',
          style: TextStyle(
            color: DesignColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final answersMap = answer is Map
        ? answer as Map<String, dynamic>
        : <String, dynamic>{};

    // Build right options: lấy right_text từ pairs + distractors (nếu có)
    final rightOptions = <String>[];
    for (final p in pairs) {
      final t = p['right_text']?.toString() ?? '';
      if (t.isNotEmpty) rightOptions.add(t);
    }
    final distractors = question.distractors ?? const <Map<String, dynamic>>[];
    for (final d in distractors) {
      final t = d['right_text']?.toString() ?? d['text']?.toString() ?? '';
      if (t.isNotEmpty) rightOptions.add(t);
    }

    return Padding(
      padding: const EdgeInsets.all(DesignSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn mục bên phải tương ứng với mỗi mục bên trái',
            style: TextStyle(
              color: DesignColors.textSecondary,
              fontStyle: FontStyle.italic,
              fontSize: DesignTypography.bodySmallSize,
            ),
          ),
          SizedBox(height: DesignSpacing.md),
          ...pairs.asMap().entries.map((entry) {
            final idx = entry.key;
            final pair = entry.value;
            final key = '${question.id}_match_$idx';
            final selected = answersMap[key]?.toString();

            return Padding(
              padding: const EdgeInsets.only(bottom: DesignSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: MathText(
                      pair['left_text']?.toString() ?? '',
                      style: DesignTypography.bodyMedium,
                    ),
                  ),
                  SizedBox(width: DesignSpacing.sm),
                  Icon(Icons.arrow_forward, size: 18, color: DesignColors.primary),
                  SizedBox(width: DesignSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(DesignRadius.md),
                        color: Colors.grey[50],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selected,
                          isExpanded: true,
                          hint: Text(
                            'Chọn...',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          items: rightOptions
                              .map(
                                (opt) => DropdownMenuItem<String>(
                                  value: opt,
                                  child: Text(
                                    opt,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: widget.isReadOnly
                              ? null
                              : (value) {
                                  final newAnswers =
                                      Map<String, dynamic>.from(answersMap);
                                  if (value == null) {
                                    newAnswers.remove(key);
                                  } else {
                                    newAnswers[key] = value;
                                  }
                                  ref
                                      .read(
                                        workspaceNotifierProvider(
                                          widget.distributionId,
                                        ).notifier,
                                      )
                                      .updateAnswer(question.id, newAnswers);
                                },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Problem Solving / Math - 3-section workspace:
  /// 1. Ô đáp số ngắn (auto-check)
  /// 2. Ô lời giải LaTeX (AI/GV chấm)
  /// 3. Ảnh đính kèm tuỳ chọn (giấy nháp)
  ///
  /// Student answer format:
  /// `{final_answer: "x = 3", solution_text: "...", image_urls: [...]}`
  Widget _buildProblemSolving(QuestionState question, dynamic answer) {
    final answerMap = answer is Map
        ? answer as Map<String, dynamic>
        : <String, dynamic>{};

    final finalAnswerCtrlKey = '${question.id}_final';
    final solutionCtrlKey = '${question.id}_solution';

    final finalAnswerCtrl = _fillInBlankControllers.putIfAbsent(
      finalAnswerCtrlKey,
      () => TextEditingController(text: answerMap['final_answer'] as String? ?? ''),
    );
    final solutionCtrl = _fillInBlankControllers.putIfAbsent(
      solutionCtrlKey,
      () => TextEditingController(text: answerMap['solution_text'] as String? ?? ''),
    );

    final imageUrls = (answerMap['image_urls'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];

    void update(Map<String, dynamic> patch) {
      final next = Map<String, dynamic>.from(answerMap)..addAll(patch);
      ref
          .read(workspaceNotifierProvider(widget.distributionId).notifier)
          .updateAnswer(question.id, next);
    }

    return Padding(
      padding: const EdgeInsets.all(DesignSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRubricButton(question),
          // ── Section 1: Đáp số ngắn ────────────────────────────────────────
          _sectionLabel('ĐÁP SỐ', Icons.flag_outlined),
          SizedBox(height: DesignSpacing.xs),
          TextField(
            controller: finalAnswerCtrl,
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              hintText: 'VD: x = 3 hoặc \$x = \\frac{1}{2}\$',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignRadius.md),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DesignSpacing.md,
                vertical: DesignSpacing.sm,
              ),
            ),
            onChanged: (v) => update({'final_answer': v}),
          ),
          SizedBox(height: DesignSpacing.md),
          // ── Section 2: Lời giải LaTeX ─────────────────────────────────────
          _sectionLabel('LỜI GIẢI', Icons.edit_note),
          SizedBox(height: DesignSpacing.xs),
          if (!widget.isReadOnly)
            RichTextToolbar(controller: solutionCtrl),
          SizedBox(height: DesignSpacing.xs),
          TextField(
            controller: solutionCtrl,
            readOnly: widget.isReadOnly,
            minLines: 4,
            maxLines: 12,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: 'Trình bày lời giải chi tiết...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignRadius.md),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.all(DesignSpacing.md),
            ),
            onChanged: (v) => update({'solution_text': v}),
          ),
          SizedBox(height: DesignSpacing.md),
          // ── Section 3: Ảnh đính kèm ───────────────────────────────────────
          _sectionLabel('ẢNH ĐÍNH KÈM (tuỳ chọn)', Icons.image_outlined),
          SizedBox(height: DesignSpacing.xs),
          _buildImageAttachments(
            urls: imageUrls,
            onAdd: widget.isReadOnly
                ? null
                : () => _pickAndUploadImage(
                      onUrl: (url) => update({
                        'image_urls': [...imageUrls, url],
                      }),
                    ),
            onRemove: widget.isReadOnly
                ? null
                : (url) => update({
                      'image_urls':
                          imageUrls.where((u) => u != url).toList(),
                    }),
          ),
        ],
      ),
    );
  }

  /// File Upload - chụp ảnh / chọn từ thư viện bài giải.
  /// Student answer format: `{image_urls: [...]}`
  Widget _buildFileUpload(QuestionState question, dynamic answer) {
    final answerMap = answer is Map
        ? answer as Map<String, dynamic>
        : <String, dynamic>{};
    final imageUrls = (answerMap['image_urls'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];

    return Padding(
      padding: const EdgeInsets.all(DesignSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chụp ảnh hoặc tải lên bài làm của bạn',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: DesignColors.textPrimary,
            ),
          ),
          SizedBox(height: DesignSpacing.md),
          _buildImageAttachments(
            urls: imageUrls,
            onAdd: widget.isReadOnly
                ? null
                : () => _pickAndUploadImage(
                      onUrl: (url) {
                        final newUrls = [...imageUrls, url];
                        ref
                            .read(
                              workspaceNotifierProvider(
                                widget.distributionId,
                              ).notifier,
                            )
                            .updateAnswer(question.id, {'image_urls': newUrls});
                      },
                    ),
            onRemove: widget.isReadOnly
                ? null
                : (url) {
                    final newUrls =
                        imageUrls.where((u) => u != url).toList();
                    ref
                        .read(
                          workspaceNotifierProvider(
                            widget.distributionId,
                          ).notifier,
                        )
                        .updateAnswer(question.id, {'image_urls': newUrls});
                  },
          ),
        ],
      ),
    );
  }

  // ── Helpers: section label + image attachments + picker ──────────────────

  Widget _sectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: DesignColors.primary),
        SizedBox(width: DesignSpacing.xs),
        Text(
          label,
          style: TextStyle(
            fontSize: DesignTypography.labelSmallSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: DesignColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildImageAttachments({
    required List<String> urls,
    VoidCallback? onAdd,
    void Function(String url)? onRemove,
  }) {
    return Wrap(
      spacing: DesignSpacing.sm,
      runSpacing: DesignSpacing.sm,
      children: [
        ...urls.map(
          (url) => Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignRadius.md),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DesignRadius.md),
                  child: Image.network(
                    url,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 32),
                    ),
                  ),
                ),
              ),
              if (onRemove != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => onRemove(url),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (onAdd != null)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignRadius.md),
                border: Border.all(
                  color: DesignColors.primary,
                  style: BorderStyle.solid,
                  width: 2,
                ),
                color: DesignColors.primary.withValues(alpha: 0.05),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: DesignColors.primary,
                    size: 32,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Thêm ảnh',
                    style: TextStyle(
                      fontSize: 11,
                      color: DesignColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickAndUploadImage({
    required void Function(String url) onUrl,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (xfile == null || !mounted) return;

      final url = await ref
          .read(workspaceNotifierProvider(widget.distributionId).notifier)
          .uploadFile(File(xfile.path));

      if (!mounted) return;
      if (url != null) {
        onUrl(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tải ảnh lên thất bại. Thử lại?'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: DesignColors.error,
        ),
      );
    }
  }

  Widget _buildBottomActionBar(BuildContext context, WorkspaceState workspace) {
    final isSubmitting =
        workspace.submissionStatus == WorkspaceSubmissionStatus.submitting;
    final isSubmitted =
        workspace.submissionStatus == WorkspaceSubmissionStatus.submitted;
    final isPastDueClosed = workspace.isPastDueClosed;

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
            // Banner báo bài tập đã đóng — chặn submit thủ công khi quá hạn
            // + GV không cho nộp muộn. Watchdog sẽ tự auto-submit, banner ở
            // đây là phòng vệ cuối nếu watchdog chưa kịp tick.
            if (isPastDueClosed && !isSubmitted)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: DesignSpacing.sm),
                padding: const EdgeInsets.symmetric(
                    horizontal: DesignSpacing.md,
                    vertical: DesignSpacing.sm),
                decoration: BoxDecoration(
                  color: DesignColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                  border: Border.all(
                    color: DesignColors.error.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_clock,
                        size: 16, color: DesignColors.error),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Đã quá hạn nạp bài. Hệ thống đang tự động nộp bài làm hiện tại của bạn.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            // Progress indicator
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: workspace.totalQuestions > 0
                        ? workspace.answeredCount / workspace.totalQuestions
                        : 0,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      DesignColors.primary,
                    ),
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

            // Submit button — disable khi đang nộp / đã nộp / quá hạn đóng cứng.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSubmitting || isSubmitted || isPastDueClosed
                    ? null
                    : () => _showSubmitConfirmation(context, workspace),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSubmitted || isPastDueClosed
                      ? Colors.grey[300]
                      : DesignColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: DesignSpacing.md,
                  ),
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
                    : Icon(isSubmitted
                        ? Icons.check_circle
                        : isPastDueClosed
                            ? Icons.lock_clock
                            : Icons.send),
                label: Text(
                  isSubmitting
                      ? 'Đang nộp...'
                      : isSubmitted
                          ? 'Đã nộp'
                          : isPastDueClosed
                              ? 'Bài đã đóng'
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

  /// Tự động nộp bài khi hết giờ — không cần xác nhận
  Future<void> _onTimeUp() async {
    if (!mounted) return;
    final timeLog = getTimeLog();
    final success = await ref
        .read(workspaceNotifierProvider(widget.distributionId).notifier)
        .submit(timeLog: timeLog);
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(Icons.timer_off, color: Colors.red.shade700),
          const SizedBox(width: 8),
          const Text('Hết giờ!'),
        ]),
        content: Text(
          success
              ? 'Bài làm của bạn đã được nộp tự động.'
              : 'Hết giờ nhưng nộp bài thất bại. Vui lòng thử lại.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (success && context.mounted) context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đóng'),
          ),
        ],
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
      final timeLog = getTimeLog();
      final success = await ref
          .read(workspaceNotifierProvider(widget.distributionId).notifier)
          .submit(timeLog: timeLog);

      if (success && context.mounted) {
        // Show success screen
        _showSuccessScreen(context, workspace);
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

  void _showSuccessScreen(BuildContext context, WorkspaceState workspace) {
    final now = DateTime.now();
    final submissionId = '${now.millisecondsSinceEpoch}';
    final confirmationNumber =
        'NS${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${submissionId.substring(submissionId.length - 6)}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Colors.green[600],
                ),
              ),

              const SizedBox(height: DesignSpacing.lg),

              // Title
              Text(
                'Nộp bài thành công!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: DesignColors.textPrimary,
                ),
              ),

              const SizedBox(height: DesignSpacing.lg),

              // Submission details
              Container(
                padding: const EdgeInsets.all(DesignSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(DesignRadius.md),
                ),
                child: Column(
                  children: [
                    // Assignment name
                    Row(
                      children: [
                        Icon(
                          Icons.assignment,
                          size: 18,
                          color: DesignColors.textSecondary,
                        ),
                        const SizedBox(width: DesignSpacing.sm),
                        Expanded(
                          child: Text(
                            workspace.assignmentTitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: DesignColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: DesignSpacing.sm),

                    // Submission timestamp
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: DesignColors.textSecondary,
                        ),
                        const SizedBox(width: DesignSpacing.sm),
                        Text(
                          'Ngày nộp: ${_formatDateTime(now)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: DesignColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: DesignSpacing.sm),

                    // Confirmation number
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number,
                          size: 18,
                          color: DesignColors.textSecondary,
                        ),
                        const SizedBox(width: DesignSpacing.sm),
                        Expanded(
                          child: Text(
                            'Mã xác nhận: $confirmationNumber',
                            style: TextStyle(
                              fontSize: 14,
                              color: DesignColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DesignSpacing.lg),

              // Back to list button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to previous screen in stack
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: DesignSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignRadius.md),
                    ),
                  ),
                  child: const Text(
                    'Về danh sách bài tập',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Future<void> _handleBackPress(
    BuildContext context,
    AsyncValue<WorkspaceState> workspaceAsync,
  ) async {
    final workspace = workspaceAsync.valueOrNull;

    // Skip confirm dialog if nothing answered yet
    if (workspace == null || workspace.answeredCount == 0) {
      if (context.mounted) context.pop();
      return;
    }

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text(
          workspace.answeredCount > 0
              ? 'Bạn đang có câu trả lời chưa lưu. Bạn có chắc muốn thoát không?'
              : 'Bạn có chắc muốn thoát không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );

    if (shouldLeave == true && context.mounted) {
      // Save draft before leaving if there are answers
      if (workspace.answeredCount > 0) {
        // Save draft, NOT submit!
        await ref
            .read(workspaceNotifierProvider(widget.distributionId).notifier)
            .saveDraft();
      }
      if (context.mounted) {
        context.pop();
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

/// Widget đồng hồ đếm ngược cho workspace.
/// - Tính thời gian còn lại dựa trên [startedAt] (từ server) + [totalSeconds]
/// - Hiển thị MM:SS
/// - Đổi màu đỏ khi còn ≤ 120 giây
/// - Gọi [onTimeUp] khi hết giờ (kể cả khi đã hết giờ lúc khởi tạo)
class _CountdownTimerWidget extends StatefulWidget {
  final int totalSeconds;
  final DateTime startedAt;
  final VoidCallback? onTimeUp;

  const _CountdownTimerWidget({
    required this.totalSeconds,
    required this.startedAt,
    this.onTimeUp,
  });

  @override
  State<_CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<_CountdownTimerWidget> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initRemaining();
    if (_remainingSeconds <= 0) {
      // Đã hết giờ ngay lúc vào (ví dụ: thoát ra rồi vào lại sau khi quá hạn)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onTimeUp?.call();
      });
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
            if (_remainingSeconds == 0) {
              _timer?.cancel();
              widget.onTimeUp?.call();
            }
          } else {
            _timer?.cancel();
          }
        });
      });
    }
  }

  void _initRemaining() {
    final elapsed = DateTime.now().difference(widget.startedAt).inSeconds;
    _remainingSeconds = (widget.totalSeconds - elapsed).clamp(0, widget.totalSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWarning = _remainingSeconds <= 120;
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isWarning ? Colors.red.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isWarning ? Colors.red.shade300 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 14,
              color: isWarning ? Colors.red.shade700 : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              timeText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isWarning ? Colors.red.shade700 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
