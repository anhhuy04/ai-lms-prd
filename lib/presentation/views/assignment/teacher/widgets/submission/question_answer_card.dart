import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Question Answer Card - Hiển thị câu hỏi và câu trả lời
class QuestionAnswerCard extends StatelessWidget {
  final Map<String, dynamic> answer;
  final bool showStudentAnswer;
  final bool showCorrectAnswer;
  final bool showRubric;

  const QuestionAnswerCard({
    super.key,
    required this.answer,
    this.showStudentAnswer = false,
    this.showCorrectAnswer = false,
    this.showRubric = false,
  });

  @override
  Widget build(BuildContext context) {
    final questionContent = answer['assignment_question']?['content'] as Map<String, dynamic>?;
    final studentAnswer = answer['answer'] as Map<String, dynamic>?;
    final correctAnswer = answer['assignment_question']?['answer'] as Map<String, dynamic>?;

    return Card(
      margin: const EdgeInsets.all(DesignSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (questionContent != null) ...[
              Text('Câu hỏi', style: DesignTypography.bodySmall?.copyWith(color: DesignColors.textSecondary)),
              const SizedBox(height: DesignSpacing.xs),
              Text(questionContent['text']?.toString() ?? questionContent['override_text']?.toString() ?? '', style: DesignTypography.bodyMedium),
              const Divider(height: DesignSpacing.lg),
            ],
            if (showStudentAnswer && studentAnswer != null) ...[
              Text('Câu trả lời của học sinh', style: DesignTypography.bodySmall?.copyWith(color: DesignColors.textSecondary)),
              const SizedBox(height: DesignSpacing.xs),
              _buildAnswerContent(studentAnswer),
              const Divider(height: DesignSpacing.lg),
            ],
            if (showCorrectAnswer && correctAnswer != null) ...[
              Text('Đáp án đúng', style: DesignTypography.bodySmall?.copyWith(color: DesignColors.success)),
              const SizedBox(height: DesignSpacing.xs),
              _buildAnswerContent(correctAnswer),
              const Divider(height: DesignSpacing.lg),
            ],
            if (showRubric) ...[
              Text('Rubric', style: DesignTypography.bodySmall?.copyWith(color: DesignColors.textSecondary)),
              const SizedBox(height: DesignSpacing.xs),
              _buildRubric(answer['rubric']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerContent(Map<String, dynamic> answerData) {
    final selectedChoices = answerData['selected_choices'] as List<dynamic>?;
    if (selectedChoices != null) {
      return Wrap(
        spacing: DesignSpacing.sm,
        children: selectedChoices.map((choice) => Chip(label: Text(choice.id.toString()))).toList(),
      );
    }
    final text = answerData['text'] as String?;
    if (text != null) {
      return Container(
        padding: const EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(DesignRadius.sm)),
        child: Text(text, style: DesignTypography.bodyMedium),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildRubric(dynamic rubric) {
    if (rubric == null) return Text('Không có rubric', style: DesignTypography.bodyMedium?.copyWith(color: DesignColors.textTertiary));
    final rubricData = rubric as Map<String, dynamic>;
    final criteria = rubricData['criteria'] as List<dynamic>?;
    if (criteria == null || criteria.isEmpty) return Text('Không có tiêu chí', style: DesignTypography.bodyMedium?.copyWith(color: DesignColors.textTertiary));
    return Column(
      children: criteria.map((c) {
        final criterion = c as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.only(bottom: DesignSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(criterion['name']?.toString() ?? '', style: DesignTypography.bodyMedium)),
              Text('${criterion['score'] ?? 0}/${criterion['max_score'] ?? 0}', style: DesignTypography.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
