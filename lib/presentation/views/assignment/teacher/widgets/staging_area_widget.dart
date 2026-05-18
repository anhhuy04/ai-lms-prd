// ignore_for_file: use_build_context_synchronously
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/data/models/question_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Hiển thị Staging Area dưới dạng DraggableScrollableSheet.
///
/// Gọi hàm này sau khi AI trả về danh sách câu hỏi để teacher xem trước
/// và quyết định lưu vào Ngân hàng hoặc thêm vào Đề thi (D-26, D-27, D-28).
void showStagingArea(
  BuildContext context, {
  required List<QuestionDTO> questions,
  required String? assignmentId, // null nếu không trong ngữ cảnh đề thi
  required VoidCallback onComplete,
  String entrySource = 'ai_generated',
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      builder: (_, scrollController) => StagingAreaWidget(
        questions: questions,
        assignmentId: assignmentId,
        onComplete: onComplete,
        scrollController: scrollController,
        entrySource: entrySource,
      ),
    ),
  );
}

/// Widget hiển thị danh sách câu hỏi AI để teacher xem trước trước khi lưu.
///
/// Implements D-26 (staging area), D-27 (hai nút lưu), D-28 (no orphan data).
/// Both save actions go through save_questions_to_assignment RPC (atomic).
class StagingAreaWidget extends ConsumerStatefulWidget {
  final List<QuestionDTO> questions;
  final String? assignmentId;
  final VoidCallback onComplete;
  final ScrollController scrollController;

  /// Nguồn gốc câu hỏi cho RPC `save_questions_to_assignment` (D-24/D-25).
  /// Mặc định `'ai_generated'` vì staging area thường được mở sau khi
  /// AI generate/extract trả về. Có thể override khi gọi từ flow khác.
  final String entrySource;

  const StagingAreaWidget({
    super.key,
    required this.questions,
    required this.assignmentId,
    required this.onComplete,
    required this.scrollController,
    this.entrySource = 'ai_generated',
  });

  @override
  ConsumerState<StagingAreaWidget> createState() => _StagingAreaWidgetState();
}

class _StagingAreaWidgetState extends ConsumerState<StagingAreaWidget> {
  bool _isSaving = false;

  List<QuestionDTO> get questions => widget.questions;

  /// Lưu câu hỏi vào Ngân hàng (không link với đề thi nào).
  /// Calls save_questions_to_assignment RPC với p_assignment_id=null.
  Future<void> _saveToBank() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await Supabase.instance.client.rpc(
        'save_questions_to_assignment',
        params: {
          'p_questions': questions
              .map((q) => q.copyWith(source: widget.entrySource).toDbInsert())
              .toList(),
          'p_assignment_id': null, // Bank only — no orphan data possible
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã lưu ${questions.length} câu vào Ngân hàng câu hỏi'),
            backgroundColor: DesignColors.success,
          ),
        );
        widget.onComplete();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi lưu vào Ngân hàng: $e'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Lưu câu hỏi vào Ngân hàng VÀ link ngay vào Đề thi (atomic transaction).
  /// Calls save_questions_to_assignment RPC với p_assignment_id != null.
  /// D-28: không thể có orphan data — RPC bảo đảm atomic INSERT vào cả 2 bảng.
  Future<void> _saveAndAddToAssignment() async {
    if (_isSaving || widget.assignmentId == null) return;
    setState(() => _isSaving = true);
    try {
      await Supabase.instance.client.rpc(
        'save_questions_to_assignment',
        params: {
          'p_questions': questions
              .map((q) => q.copyWith(source: widget.entrySource).toDbInsert())
              .toList(),
          'p_assignment_id': widget.assignmentId, // Atomic: save + link
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Đã lưu và thêm ${questions.length} câu vào Đề thi'),
            backgroundColor: DesignColors.success,
          ),
        );
        widget.onComplete();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi lưu vào Đề thi: $e'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildHeader(),
          Expanded(child: _buildQuestionList()),
          _buildActionBar(),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignSpacing.sm),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: DesignColors.dividerMedium,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignSpacing.lg,
        DesignSpacing.xs,
        DesignSpacing.lg,
        DesignSpacing.md,
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: DesignColors.primary, size: 20),
          const SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: Text(
              'Xem trước câu hỏi AI (${questions.length} câu)',
              style: DesignTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionList() {
    if (questions.isEmpty) {
      return const Center(
        child: Text(
          'Không có câu hỏi nào',
          style: TextStyle(color: DesignColors.textSecondary),
        ),
      );
    }
    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
      itemCount: questions.length,
      itemBuilder: (context, index) => _buildQuestionCard(index, questions[index]),
    );
  }

  Widget _buildQuestionCard(int index, QuestionDTO question) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.md),
        side: const BorderSide(color: DesignColors.dividerLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionHeader(index, question),
            const SizedBox(height: DesignSpacing.sm),
            Text(
              question.content['text']?.toString() ?? '(Không có nội dung)',
              style: DesignTypography.bodyMedium,
            ),
            if (question.choices.isNotEmpty) ...[
              const SizedBox(height: DesignSpacing.sm),
              ...question.choices.asMap().entries.map(
                    (entry) => _buildChoiceRow(entry.key, entry.value, question),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionHeader(int index, QuestionDTO question) {
    return Row(
      children: [
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
            'Câu ${index + 1}',
            style: DesignTypography.labelSmall.copyWith(
              color: DesignColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: DesignSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSpacing.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: DesignColors.moonMedium,
            borderRadius: BorderRadius.circular(DesignRadius.sm),
          ),
          child: Text(
            _typeLabel(question.type),
            style: DesignTypography.labelSmall.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
        ),
        const Spacer(),
        Text(
          'Độ khó: ${question.difficulty}/5',
          style: DesignTypography.labelSmall.copyWith(
            color: DesignColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceRow(int index, ChoiceDTO choice, QuestionDTO question) {
    final letterLabels = ['A', 'B', 'C', 'D', 'E', 'F'];
    final label = index < letterLabels.length ? letterLabels[index] : '${index + 1}';

    // Determine if this choice is the correct answer
    final correctIndex = question.answer['correct_index'];
    final isCorrect = choice.isCorrect || correctIndex == index;

    return Padding(
      padding: const EdgeInsets.only(top: DesignSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCorrect ? DesignColors.success : DesignColors.moonMedium,
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isCorrect ? DesignColors.white : DesignColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: Text(
              choice.text,
              style: DesignTypography.bodySmall.copyWith(
                color: isCorrect ? DesignColors.success : DesignColors.textPrimary,
                fontWeight: isCorrect ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    final hasAssignment = widget.assignmentId != null;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(DesignSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : _saveToBank,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: DesignColors.primary),
                  foregroundColor: DesignColors.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: DesignSpacing.md,
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: DesignColors.primary,
                        ),
                      )
                    : const Text('Lưu vào Ngân hàng'),
              ),
            ),
            if (hasAssignment) ...[
              const SizedBox(width: DesignSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      (_isSaving || !hasAssignment) ? null : _saveAndAddToAssignment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.primary,
                    foregroundColor: DesignColors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: DesignSpacing.md,
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: DesignColors.white,
                          ),
                        )
                      : const Text(
                          'Lưu & Thêm vào Đề thi',
                          textAlign: TextAlign.center,
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Trắc nghiệm';
      case 'true_false':
        return 'Đúng/Sai';
      case 'short_answer':
        return 'Trả lời ngắn';
      case 'essay':
        return 'Tự luận';
      default:
        return type;
    }
  }
}
