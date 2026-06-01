import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/domain/entities/assignment_question.dart';
import 'package:ai_mls/presentation/providers/teacher_submission_providers.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:ai_mls/widgets/text/math_text.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Track 2 — Màn "Chấm theo câu": chấm cùng 1 câu hỏi cho TẤT CẢ học sinh trong
/// 1 distribution + duyệt hàng loạt điểm AI.
///
/// Luồng:
/// 1. Tải danh sách câu hỏi của bài tập (qua [batchGradeAssignmentQuestionsProvider]).
/// 2. GV chọn 1 câu → watch [distributionAnswersByQuestionProvider] để xem bài làm
///    của mọi HS cho câu đó (RPC get_distribution_answers_by_question).
/// 3. Nút "Duyệt tất cả điểm AI" gọi batchApproveScores cho mọi answer có ai_score.
///
/// GIẢ ĐỊNH: chỉ cần [distributionId]; danh sách câu hỏi tự load qua chain
/// distributionDetail → assignment_id → assignment_questions. [assignmentTitle]
/// chỉ để hiển thị tiêu đề (tuỳ chọn, lấy từ route extra).
class BatchGradeByQuestionScreen extends ConsumerStatefulWidget {
  final String distributionId;
  final String assignmentTitle;

  const BatchGradeByQuestionScreen({
    super.key,
    required this.distributionId,
    this.assignmentTitle = '',
  });

  @override
  ConsumerState<BatchGradeByQuestionScreen> createState() =>
      _BatchGradeByQuestionScreenState();
}

class _BatchGradeByQuestionScreenState
    extends ConsumerState<BatchGradeByQuestionScreen> {
  /// assignment_question_id của câu đang chọn.
  String? _selectedQuestionId;
  bool _isApproving = false;

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(batchGradeAssignmentQuestionsProvider(
      distributionId: widget.distributionId,
    ));

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        title: const Text('Chấm theo câu'),
      ),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return _buildEmptyQuestions();
          }
          // Mặc định chọn câu đầu nếu chưa chọn.
          final selectedId = _selectedQuestionId ?? questions.first.id;
          final selected = questions.firstWhere(
            (q) => q.id == selectedId,
            orElse: () => questions.first,
          );

          return Column(
            children: [
              _buildQuestionSelector(questions, selected),
              const Divider(height: 1, color: DesignColors.dividerLight),
              Expanded(child: _buildAnswersSection(selected)),
            ],
          );
        },
        loading: () => const ShimmerListTileLoading(),
        error: (e, _) => _buildError(
          'Lỗi tải danh sách câu hỏi',
          () => ref.invalidate(batchGradeAssignmentQuestionsProvider(
            distributionId: widget.distributionId,
          )),
        ),
      ),
    );
  }

  // ── Question selector ──────────────────────────────────────────────────────

  Widget _buildQuestionSelector(
    List<AssignmentQuestion> questions,
    AssignmentQuestion selected,
  ) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(DesignSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CHỌN CÂU HỎI',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: DesignColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: DesignSpacing.sm),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: questions.length,
              separatorBuilder: (_, __) => const SizedBox(width: DesignSpacing.sm),
              itemBuilder: (context, index) {
                final q = questions[index];
                final isSelected = q.id == selected.id;
                return ChoiceChip(
                  key: ValueKey('question_chip_${q.id}'),
                  label: Text('Câu ${index + 1}'),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedQuestionId = q.id);
                  },
                  selectedColor: DesignColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : DesignColors.textSecondary,
                  ),
                  backgroundColor: DesignColors.moonLight,
                );
              },
            ),
          ),
          const SizedBox(height: DesignSpacing.md),
          MathText(
            _questionText(selected),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: DesignColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Answers section ────────────────────────────────────────────────────────

  Widget _buildAnswersSection(AssignmentQuestion question) {
    final answersAsync = ref.watch(distributionAnswersByQuestionProvider(
      distributionId: widget.distributionId,
      assignmentQuestionId: question.id,
    ));

    return answersAsync.when(
      data: (answers) {
        if (answers.isEmpty) {
          return _buildEmptyAnswers();
        }
        final approvableIds = _approvableAnswerIds(answers);
        return Column(
          children: [
            _buildApproveAllBar(question, approvableIds),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(distributionAnswersByQuestionProvider(
                    distributionId: widget.distributionId,
                    assignmentQuestionId: question.id,
                  ));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(DesignSpacing.md),
                  itemCount: answers.length,
                  itemBuilder: (context, index) =>
                      _buildAnswerRow(answers[index], question),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const ShimmerListTileLoading(),
      error: (e, _) => _buildError(
        'Lỗi tải bài làm',
        () => ref.invalidate(distributionAnswersByQuestionProvider(
          distributionId: widget.distributionId,
          assignmentQuestionId: question.id,
        )),
      ),
    );
  }

  Widget _buildApproveAllBar(
    AssignmentQuestion question,
    List<String> approvableIds,
  ) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              approvableIds.isEmpty
                  ? 'Không có điểm AI để duyệt'
                  : '${approvableIds.length} câu có điểm AI',
              style: const TextStyle(
                fontSize: 13,
                color: DesignColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton.icon(
            key: const ValueKey('approve_all_ai_button'),
            onPressed: (approvableIds.isEmpty || _isApproving)
                ? null
                : () => _approveAll(question, approvableIds),
            icon: _isApproving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.done_all, size: 18),
            label: const Text('Duyệt tất cả điểm AI'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerRow(
    Map<String, dynamic> answer,
    AssignmentQuestion question,
  ) {
    final studentName = answer['student_name'] as String? ?? 'Học sinh';
    final aiScore = _toDouble(answer['ai_score']);
    final finalScore = _toDouble(answer['final_score']);
    final confidence = _toDouble(answer['ai_confidence']);
    final points = question.points;

    return Container(
      key: ValueKey('answer_row_${answer['answer_id']}'),
      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: DesignColors.dividerLight),
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
          // Header: student name + final/ai score
          Row(
            children: [
              Expanded(
                child: Text(
                  studentName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DesignColors.textPrimary,
                  ),
                ),
              ),
              _buildScoreBadge(finalScore, aiScore, points),
            ],
          ),
          const SizedBox(height: DesignSpacing.sm),
          // Student answer (MCQ choices vs essay text)
          _buildStudentAnswer(answer, question),
          // AI confidence
          if (aiScore != null && confidence != null) ...[
            const SizedBox(height: DesignSpacing.sm),
            _buildConfidenceBadge(confidence),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreBadge(double? finalScore, double? aiScore, double points) {
    final hasFinal = finalScore != null;
    final value = finalScore ?? aiScore;
    final label = value != null
        ? '${_formatScore(value)}/${_formatScore(points)}'
        : '--/${_formatScore(points)}';
    final color = hasFinal ? DesignColors.primary : DesignColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        hasFinal ? label : 'AI $label',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence) {
    final pct = (confidence * 100).clamp(0, 100).toStringAsFixed(0);
    final Color color = confidence >= 0.7
        ? DesignColors.success
        : (confidence >= 0.4 ? DesignColors.warning : DesignColors.error);
    return Row(
      children: [
        Icon(Icons.psychology_outlined, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          'Độ tin cậy AI: $pct%',
          style: TextStyle(fontSize: 11, color: color),
        ),
      ],
    );
  }

  Widget _buildStudentAnswer(
    Map<String, dynamic> answer,
    AssignmentQuestion question,
  ) {
    final studentAnswer = answer['answer'] as Map<String, dynamic>?;
    final type = _questionType(question);
    final isMcq = type == 'multiple_choice' || type == 'true_false';

    if (isMcq) {
      final selected = studentAnswer?['selected_choice_ids'] as List<dynamic>? ??
          studentAnswer?['selected_choices'] as List<dynamic>? ??
          const [];
      return _buildMcqAnswer(selected, question);
    }

    final text = studentAnswer?['text'] as String?;
    final hasAnswer = text != null && text.trim().isNotEmpty;
    if (!hasAnswer) {
      return Text(
        'Học sinh không có câu trả lời',
        style: TextStyle(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: DesignColors.warning,
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignSpacing.sm),
      decoration: BoxDecoration(
        color: DesignColors.moonLight,
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: MathText(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: DesignColors.textPrimary,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildMcqAnswer(
    List<dynamic> selected,
    AssignmentQuestion question,
  ) {
    final choices = _choices(question);
    final selectedIndices = _selectedIndices(selected);
    final correctIndex = _correctChoiceIndex(choices);

    if (choices.isEmpty) {
      return Text(
        selected.isEmpty ? 'Chưa chọn đáp án' : 'Đã chọn: ${selected.join(', ')}',
        style: const TextStyle(fontSize: 13, color: DesignColors.textSecondary),
      );
    }

    return Column(
      children: choices.asMap().entries.map((entry) {
        final idx = entry.key;
        final choice = entry.value;
        final text = (choice is Map ? choice['text']?.toString() : null) ??
            'Lựa chọn ${idx + 1}';
        final isSelected = selectedIndices.contains(idx);
        final isCorrect = idx == correctIndex;

        Color border = DesignColors.dividerLight;
        Color bg = Colors.white;
        if (isSelected && !isCorrect) {
          border = DesignColors.error;
          bg = DesignColors.error.withValues(alpha: 0.12);
        } else if (isCorrect) {
          border = DesignColors.success;
          bg = DesignColors.success.withValues(alpha: 0.12);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(DesignRadius.sm),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? (isCorrect ? Icons.check_circle : Icons.cancel)
                    : (isCorrect ? Icons.check_circle_outline : Icons.circle_outlined),
                size: 16,
                color: isCorrect
                    ? DesignColors.success
                    : (isSelected ? DesignColors.error : DesignColors.textTertiary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MathText(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    color: DesignColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _approveAll(
    AssignmentQuestion question,
    List<String> approvableIds,
  ) async {
    setState(() => _isApproving = true);
    try {
      final count = await ref
          .read(submissionGradingNotifierProvider.notifier)
          .batchApproveScores(
            approvableIds,
            distributionId: widget.distributionId,
            assignmentQuestionId: question.id,
          );
      if (mounted) {
        AppToast.info(context, 'Đã duyệt $count điểm AI');
      }
    } catch (e) {
      AppLogger.error('Error batch approving scores: $e');
      if (mounted) {
        AppToast.error(context, 'Duyệt điểm thất bại: $e');
      }
    } finally {
      if (mounted) setState(() => _isApproving = false);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// answerIds có ai_score (đủ điều kiện duyệt hàng loạt).
  List<String> _approvableAnswerIds(List<Map<String, dynamic>> answers) {
    return answers
        .where((a) => a['ai_score'] != null)
        .map((a) => a['answer_id'] as String)
        .toList();
  }

  String _questionText(AssignmentQuestion q) {
    final c = q.customContent;
    if (c == null) return '';
    return c['text']?.toString() ??
        c['override_text']?.toString() ??
        c['question_text']?.toString() ??
        '';
  }

  String _questionType(AssignmentQuestion q) {
    final type = q.customContent?['type']?.toString();
    if (type == 'multipleChoice') return 'multiple_choice';
    if (type == 'trueFalse') return 'true_false';
    return type ?? 'essay';
  }

  List<dynamic> _choices(AssignmentQuestion q) {
    final c = q.customContent?['choices'];
    return c is List ? c : const [];
  }

  int _correctChoiceIndex(List<dynamic> choices) {
    for (var i = 0; i < choices.length; i++) {
      final c = choices[i];
      if (c is Map && c['isCorrect'] == true) return i;
    }
    return -1;
  }

  List<int> _selectedIndices(List<dynamic> selected) {
    final out = <int>[];
    for (final s in selected) {
      if (s is int) {
        out.add(s);
      } else if (s is Map && s['id'] is int) {
        out.add(s['id'] as int);
      }
    }
    return out;
  }

  String _formatScore(double value) {
    if (value == value.truncateToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // ── Empty / error states ───────────────────────────────────────────────────

  Widget _buildEmptyQuestions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.help_outline, size: 64, color: DesignColors.textTertiary),
          const SizedBox(height: DesignSpacing.md),
          Text(
            'Bài tập chưa có câu hỏi',
            style: DesignTypography.titleMedium
                .copyWith(color: DesignColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAnswers() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: DesignColors.textTertiary),
          const SizedBox(height: DesignSpacing.md),
          Text(
            'Chưa có học sinh trả lời câu này',
            style: DesignTypography.bodyMedium
                .copyWith(color: DesignColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: DesignColors.error),
          const SizedBox(height: DesignSpacing.md),
          Text(message, style: DesignTypography.bodyMedium),
          const SizedBox(height: DesignSpacing.sm),
          ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
