import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/submission/teacher_feedback_editor.dart';
import 'package:flutter/material.dart';

/// Grading Action Buttons - Human-in-the-Loop
/// Approve / Override điểm AI
class GradingActionButtons extends StatelessWidget {
  final Map<String, dynamic> answer;
  final VoidCallback onApprove;
  final void Function(double score, String reason) onOverride;
  final void Function(String feedback)? onFeedbackChanged;

  const GradingActionButtons({
    super.key,
    required this.answer,
    required this.onApprove,
    required this.onOverride,
    this.onFeedbackChanged,
  });

  @override
  Widget build(BuildContext context) {
    final aiScore = answer['ai_score'] as num?;
    final hasAiScore = aiScore != null;

    return Container(
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: const Border(
          top: BorderSide(color: DesignColors.dividerMedium),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasAiScore) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Điểm AI: ',
                  style: DesignTypography.bodyMedium?.copyWith(color: DesignColors.textSecondary),
                ),
                Text(
                  '${aiScore.toStringAsFixed(1)}',
                  style: DesignTypography.titleLarge?.copyWith(
                    color: DesignColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSpacing.md),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check),
                  label: const Text('Duyệt điểm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: DesignSpacing.md),
                  ),
                ),
              ),
              const SizedBox(width: DesignSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showOverrideDialog(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Sửa điểm'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: DesignSpacing.md),
                  ),
                ),
              ),
            ],
          ),

          // Teacher Feedback Editor
          if (onFeedbackChanged != null) ...[
            const SizedBox(height: DesignSpacing.md),
            const Divider(height: 1),
            TeacherFeedbackEditor(
              answerId: answer['id']?.toString() ?? '',
              aiFeedback: answer['ai_feedback'],
              teacherFeedback: answer['teacher_feedback'],
              onSave: onFeedbackChanged!,
            ),
          ],
        ],
      ),
    );
  }

  void _showOverrideDialog(BuildContext context) {
    final scoreController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa điểm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: scoreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Điểm mới',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: DesignSpacing.md),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Lý do sửa',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final score = double.tryParse(scoreController.text);
              final reason = reasonController.text;

              if (score != null && reason.isNotEmpty) {
                Navigator.pop(context);
                onOverride(score, reason);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
