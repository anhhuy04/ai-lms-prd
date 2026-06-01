import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/providers/student_assignment_providers.dart';
import 'package:ai_mls/widgets/responsive/wide_content_wrapper.dart';
import 'package:ai_mls/widgets/text/math_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình xem lại bài làm của học sinh (read-only).
/// Hiển thị câu hỏi + đáp án đúng/sai giống trang chấm của giáo viên.
/// Khi [sessionId] được truyền, hiển thị đáp án của lần làm đó thay vì lần mặc định.
class StudentSubmissionReviewScreen extends ConsumerWidget {
  final String distributionId;
  final String? sessionId;

  const StudentSubmissionReviewScreen({
    super.key,
    required this.distributionId,
    this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Khi học sinh chọn 1 lần làm cụ thể (sessionId != null) → load detail
    // theo session đó (header + answers cùng nguồn). Không có sessionId →
    // fallback về detail của lần mới nhất (behavior cũ cho 1-attempt case).
    final detailAsync = sessionId != null
        ? ref.watch(submissionReviewBySessionProvider(sessionId!))
        : ref.watch(studentSubmissionReviewProvider(distributionId));

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DesignColors.textSecondary),
          onPressed: () => context.pop(),
        ),
        title: detailAsync.when(
          data: (submission) {
            final distribution = submission?['assignment_distributions'] as Map<String, dynamic>?;
            final assignment = distribution?['assignments'] as Map<String, dynamic>?;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xem lại bài làm',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DesignColors.textPrimary,
                  ),
                ),
                if (assignment?['title'] != null)
                  Text(
                    assignment!['title'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: DesignColors.textSecondary,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            );
          },
          loading: () => const Text('Đang tải...'),
          error: (_, __) => const Text('Xem lại bài làm'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: DesignColors.dividerLight, height: 1),
        ),
      ),
      body: WideContentWrapper(
        child: detailAsync.when(
        data: (submission) {
          if (submission == null) {
            return const Center(child: Text('Không tìm thấy bài làm'));
          }

          final distribution = submission['assignment_distributions'] as Map<String, dynamic>?;
          final assignment = distribution?['assignments'] as Map<String, dynamic>?;
          final workSession = submission['workSessions'] as Map<String, dynamic>?;

          // Answers được nhúng sẵn trong detailAsync — cùng nguồn với header,
          // đảm bảo khi xem lần làm cũ thì cả title/submittedAt và bài làm
          // đều thuộc session đó (không bao giờ rớt về latest).
          final answers = List<Map<String, dynamic>>.from(
            (submission['submission_answers'] as List? ?? [])
                .map((e) => Map<String, dynamic>.from(e as Map)),
          );

          final distSettings = (() {
            final raw = distribution?['settings'];
            return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
          })();
          final aiEnabled = distSettings['ai_feedback_enabled'] as bool? ?? false;
          final submittedAt = workSession?['submitted_at'] as String?;
          final attemptNum = workSession?['attempt'] as int?;

          return Column(
            children: [
              // Banner cho biết đang xem lần làm nào — chỉ khi mở từ 1 attempt
              // cụ thể trong lịch sử (sessionId != null). Giúp học sinh dễ
              // phân biệt khi cùng đề có nhiều lần làm với nội dung tương tự.
              if (sessionId != null && attemptNum != null)
                _AttemptViewingBanner(attemptNum: attemptNum),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(DesignSpacing.md),
                  itemCount: answers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildHeader(assignment, distribution, submittedAt);
                    }
                    return _buildQuestionCard(
                      answers[index - 1],
                      index - 1,
                      aiEnabled: aiEnabled,
                    );
                  },
                ),
              ),
              _buildScoreFooter(answers),
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
              const Text('Không thể tải dữ liệu bài làm'),
              const SizedBox(height: DesignSpacing.md),
              ElevatedButton(
                onPressed: () {
                  if (sessionId != null) {
                    ref.invalidate(submissionReviewBySessionProvider(sessionId!));
                  } else {
                    ref.invalidate(studentSubmissionReviewProvider(distributionId));
                  }
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(
    Map<String, dynamic>? assignment,
    Map<String, dynamic>? distribution,
    String? submittedAt,
  ) {
    final dueAt = distribution?['due_at'] as String?;
    final className = distribution?['classes']?['name'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.lg),
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: DesignColors.dividerLight),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            assignment?['title'] as String? ?? 'Bài tập',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: DesignColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: DesignSpacing.sm),
          if (className != null)
            _infoRow(Icons.school_outlined, className),
          if (dueAt != null)
            _infoRow(Icons.calendar_today_outlined, 'Hạn nộp: ${_formatDate(dueAt)}'),
          if (submittedAt != null)
            _infoRow(Icons.check_circle_outline, 'Đã nộp: ${_formatDate(submittedAt)}'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: DesignColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: DesignColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Question Card ────────────────────────────────────────────────────────

  Widget _buildQuestionCard(
    Map<String, dynamic> answer,
    int index, {
    required bool aiEnabled,
  }) {
    final question = answer['assignment_questions'] as Map<String, dynamic>?;
    final questionType = _extractQuestionType(question);
    final maxScore = _toDouble(question?['points']) ?? 10.0;
    final currentScore = _toDouble(answer['final_score']) ?? _toDouble(answer['ai_score']) ?? 0.0;
    final isCorrect = currentScore >= maxScore;
    final isMultipleChoice = questionType == 'multiple_choice' || questionType == 'true_false';

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.lg),
      padding: const EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignColors.dividerLight),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: type badge + score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? DesignColors.success.withValues(alpha: 0.1)
                      : DesignColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isCorrect ? DesignColors.success : DesignColors.error,
                  ),
                ),
                child: Text(
                  // MCQ: chỉ hiện điểm số; Essay: hiện x/x
                  isMultipleChoice
                      ? _formatScore(currentScore)
                      : '${_formatScore(currentScore)}/${_formatScore(maxScore)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? DesignColors.success : DesignColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Question content
          MathText(
            _getQuestionContent(question),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: DesignColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),

          // Answer section
          if (isMultipleChoice)
            _buildMcqOptions(answer, question)
          else
            _buildTextAnswer(answer),

          _buildAiFeedback(answer, aiEnabled: aiEnabled),
          _buildTeacherFeedback(answer),
        ],
      ),
    );
  }

  // ─── MCQ Options ─────────────────────────────────────────────────────────

  Widget _buildMcqOptions(Map<String, dynamic> answer, Map<String, dynamic>? question) {
    final studentAnswer = answer['answer'] as Map<String, dynamic>?;
    final selectedChoices = studentAnswer?['selected_choice_ids'] as List<dynamic>?
        ?? studentAnswer?['selected_choices'] as List<dynamic>?
        ?? [];
    final customContent = question?['custom_content'] as Map<String, dynamic>?;
    final choices = customContent?['choices'] as List<dynamic>?;

    if (choices == null || choices.isEmpty) {
      return Wrap(
        spacing: DesignSpacing.sm,
        runSpacing: DesignSpacing.sm,
        children: selectedChoices.map((c) => Chip(label: Text('$c'))).toList(),
      );
    }

    final correctIndex = _getCorrectChoiceIndex(choices);
    final selectedIndices = _getSelectedIndices(selectedChoices);

    return Column(
      children: choices.asMap().entries.map((entry) {
        final i = entry.key;
        final choice = entry.value as Map<String, dynamic>;
        final text = choice['text']?.toString() ?? 'Lựa chọn ${i + 1}';
        final isCorrect = i == correctIndex;
        final isSelected = selectedIndices.contains(i);

        Color borderColor = DesignColors.dividerLight;
        Color bgColor = Colors.white;
        if (isSelected && !isCorrect) {
          borderColor = DesignColors.error;
          bgColor = DesignColors.error.withValues(alpha: 0.08);
        } else if (isCorrect) {
          borderColor = DesignColors.success;
          bgColor = DesignColors.success.withValues(alpha: 0.08);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: (isSelected || isCorrect) ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              _buildOptionIcon(isSelected, isCorrect),
              const SizedBox(width: 12),
              Expanded(
                child: MathText(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected && !isCorrect
                        ? DesignColors.error
                        : isCorrect
                            ? DesignColors.success
                            : DesignColors.textPrimary,
                    fontWeight: (isSelected || isCorrect) ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOptionIcon(bool isSelected, bool isCorrect) {
    if (isSelected && !isCorrect) {
      return Container(
        width: 20, height: 20,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: DesignColors.error),
        child: const Icon(Icons.close, size: 12, color: Colors.white),
      );
    } else if (isCorrect && isSelected) {
      return Container(
        width: 20, height: 20,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: DesignColors.success),
        child: const Icon(Icons.check, size: 12, color: Colors.white),
      );
    } else if (isCorrect) {
      return Container(
        width: 20, height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: DesignColors.success, width: 2),
        ),
        child: const Center(
          child: SizedBox(
            width: 6, height: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, color: DesignColors.success),
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 20, height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: DesignColors.dividerMedium, width: 2),
        ),
      );
    }
  }

  // ─── Text Answer ──────────────────────────────────────────────────────────

  Widget _buildTextAnswer(Map<String, dynamic> answer) {
    final studentAnswer = answer['answer'] as Map<String, dynamic>?;
    final text = studentAnswer?['text'] as String?;
    if (text == null || text.trim().isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: DesignColors.warning.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          border: Border.all(color: DesignColors.warning.withValues(alpha: 0.4)),
        ),
        child: const Text(
          'Không có câu trả lời',
          style: TextStyle(fontSize: 14, color: DesignColors.textSecondary, fontStyle: FontStyle.italic),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.moonLight,
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BÀI LÀM CỦA BẠN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: DesignColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(fontSize: 14, color: DesignColors.textPrimary, height: 1.5)),
        ],
      ),
    );
  }

  // ─── AI Feedback ──────────────────────────────────────────────────────────

  Widget _buildAiFeedback(Map<String, dynamic> answer, {required bool aiEnabled}) {
    final aiFeedbackRaw = answer['ai_feedback'];
    if (aiFeedbackRaw == null) return const SizedBox.shrink();
    final Map<String, dynamic>? feedbackMap =
        aiFeedbackRaw is Map ? Map<String, dynamic>.from(aiFeedbackRaw) : null;
    if (feedbackMap == null) return const SizedBox.shrink();

    final bool noApiKey = feedbackMap['status'] == 'no_api_key';
    final isCorrect = feedbackMap['is_correct'] as bool? ?? true;
    final Color headerColor = noApiKey
        ? DesignColors.warning
        : isCorrect
            ? DesignColors.success
            : DesignColors.error;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: DesignSpacing.md),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: headerColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: headerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                noApiKey ? Icons.key_off : isCorrect ? Icons.check_circle : Icons.cancel,
                size: 14,
                color: headerColor,
              ),
              const SizedBox(width: 6),
              Text(
                'AI Feedback',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: headerColor),
              ),
            ],
          ),
          if ((feedbackMap['summary'] as String? ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              feedbackMap['summary'] as String,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isCorrect ? DesignColors.success : DesignColors.error,
                height: 1.4,
              ),
            ),
          ],
          if ((feedbackMap['explanation'] as String? ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              feedbackMap['explanation'] as String,
              style: const TextStyle(fontSize: 12, color: DesignColors.textSecondary, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Teacher Feedback (read-only) ─────────────────────────────────────────

  Widget _buildTeacherFeedback(Map<String, dynamic> answer) {
    final raw = answer['teacher_feedback'];
    String? feedback;
    if (raw is String && raw.isNotEmpty) {
      feedback = raw;
    } else if (raw is Map) {
      feedback = raw['text']?.toString();
    }
    if (feedback == null || feedback.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: DesignSpacing.md),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignColors.primaryLight.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DesignColors.primaryLight.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.chat_bubble_outline, size: 13, color: DesignColors.primary),
              SizedBox(width: 6),
              Text(
                'Nhận xét của giáo viên',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: DesignColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            feedback,
            style: const TextStyle(fontSize: 13, color: DesignColors.textPrimary, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ─── Score Footer ─────────────────────────────────────────────────────────

  Widget _buildScoreFooter(List<Map<String, dynamic>> answers) {
    double total = 0;
    double maxTotal = 0;
    for (final a in answers) {
      final q = a['assignment_questions'] as Map<String, dynamic>?;
      maxTotal += _toDouble(q?['points']) ?? 10.0;
      total += _toDouble(a['final_score']) ?? _toDouble(a['ai_score']) ?? 0.0;
    }
    final correct = answers.where((a) {
      final q = a['assignment_questions'] as Map<String, dynamic>?;
      final max = _toDouble(q?['points']) ?? 10.0;
      final s = _toDouble(a['final_score']) ?? _toDouble(a['ai_score']) ?? 0.0;
      return s >= max;
    }).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: DesignColors.dividerLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Điểm của bạn',
                  style: TextStyle(fontSize: 11, color: DesignColors.textSecondary),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: _formatScore(total),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: DesignColors.primary,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${_formatScore(maxTotal)}',
                        style: const TextStyle(fontSize: 14, color: DesignColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$correct/${answers.length} câu đúng',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DesignColors.success,
                ),
              ),
              Text(
                '${answers.length - correct} câu sai',
                style: const TextStyle(fontSize: 12, color: DesignColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _extractQuestionType(Map<String, dynamic>? question) {
    if (question == null) return 'unknown';
    // Ưu tiên custom_content.type — luôn có trong DB, không phụ thuộc FK join
    final custom = question['custom_content'] as Map<String, dynamic>?;
    if (custom?['type'] is String) return custom!['type'] as String;
    // Fallback: question_id join (có thể null nếu RLS block)
    final qId = question['question_id'];
    if (qId is Map) {
      final t = qId['type'] as String?;
      if (t != null) return t;
    }
    return question['type'] as String? ?? 'unknown';
  }

  /// Parse số từ bất kỳ dạng nào (num, String "0.00", null).
  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Format số điểm: loại bỏ .0 nếu là số nguyên.
  String _formatScore(double score) {
    if (score == score.truncateToDouble()) return score.toInt().toString();
    return score.toStringAsFixed(1);
  }

  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'multiple_choice': return 'Trắc nghiệm';
      case 'true_false': return 'Đúng/Sai';
      case 'short_answer': return 'Trả lời ngắn';
      case 'essay': return 'Tự luận';
      default: return 'Câu hỏi';
    }
  }

  String _getQuestionContent(Map<String, dynamic>? question) {
    if (question == null) return '';
    final custom = question['custom_content'] as Map<String, dynamic>?;
    if (custom != null) {
      return custom['override_text']?.toString() ?? custom['text']?.toString() ?? '';
    }
    final qId = question['question_id'];
    if (qId is Map) {
      return qId['content']?.toString() ?? qId['text']?.toString() ?? '';
    }
    return '';
  }

  int _getCorrectChoiceIndex(List<dynamic> choices) {
    for (var i = 0; i < choices.length; i++) {
      if ((choices[i] as Map<String, dynamic>)['isCorrect'] == true) return i;
    }
    return -1;
  }

  List<int> _getSelectedIndices(List<dynamic> selected) {
    final indices = <int>[];
    for (final c in selected) {
      if (c is int) {
        indices.add(c);
      } else if (c is Map) {
        final id = c['id'];
        if (id is int) indices.add(id);
      }
    }
    return indices;
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

class _AttemptViewingBanner extends StatelessWidget {
  final int attemptNum;
  const _AttemptViewingBanner({required this.attemptNum});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: DesignColors.primary.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(
            color: DesignColors.primary.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.history, size: 16, color: DesignColors.primary),
          const SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: DesignColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'Đang xem kết quả '),
                  TextSpan(
                    text: 'lần $attemptNum',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
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
