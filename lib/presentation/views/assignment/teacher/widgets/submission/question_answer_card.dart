import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/rubric/interactive_rubric_grader.dart';
import 'package:ai_mls/widgets/rubric/read_only_rubric_viewer.dart';
import 'package:flutter/material.dart';

/// Question Answer Card - Hiển thị câu hỏi và câu trả lời.
///
/// Supports two rubric display modes controlled by [isGrading]:
/// - isGrading = false (default): renders [ReadOnlyRubricViewer]
/// - isGrading = true + submissionAnswerId + callbacks present:
///   renders [InteractiveRubricGrader] for teacher click-to-select grading (D-04).
class QuestionAnswerCard extends StatelessWidget {
  final Map<String, dynamic> answer;
  final bool showStudentAnswer;
  final bool showCorrectAnswer;
  final bool showRubric;

  // Grading mode props
  final bool isGrading;
  final String? submissionAnswerId;
  final void Function(double points, String criterionId)? onLevelSelected;
  final void Function(double score, String reason)? onManualOverride;

  const QuestionAnswerCard({
    super.key,
    required this.answer,
    this.showStudentAnswer = false,
    this.showCorrectAnswer = false,
    this.showRubric = false,
    this.isGrading = false,
    this.submissionAnswerId,
    this.onLevelSelected,
    this.onManualOverride,
  });

  @override
  Widget build(BuildContext context) {
    final aq = answer['assignment_question'] as Map<String, dynamic>?;
    final questionContent = (aq?['content'] ?? aq?['custom_content']) as Map<String, dynamic>?;
    final studentAnswer = answer['answer'] as Map<String, dynamic>?;
    final correctAnswer = aq?['answer'] as Map<String, dynamic>?;

    return Card(
      margin: const EdgeInsets.all(DesignSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (questionContent != null) ...[
              Text(
                'Câu hỏi',
                style: DesignTypography.bodySmall
                    .copyWith(color: DesignColors.textSecondary),
              ),
              const SizedBox(height: DesignSpacing.xs),
              Text(
                questionContent['text']?.toString() ??
                    questionContent['override_text']?.toString() ??
                    '',
                style: DesignTypography.bodyMedium,
              ),
              const Divider(height: DesignSpacing.lg),
            ],
            if (showStudentAnswer && studentAnswer != null) ...[
              Text(
                'Câu trả lời của học sinh',
                style: DesignTypography.bodySmall
                    .copyWith(color: DesignColors.textSecondary),
              ),
              const SizedBox(height: DesignSpacing.xs),
              _buildAnswerContent(studentAnswer, questionContent),
              const Divider(height: DesignSpacing.lg),
            ],
            if (showCorrectAnswer && (correctAnswer != null || _hasCorrectChoices(questionContent))) ...[
              Text(
                'Đáp án đúng',
                style: DesignTypography.bodySmall
                    .copyWith(color: DesignColors.success),
              ),
              const SizedBox(height: DesignSpacing.xs),
              if (correctAnswer != null) _buildAnswerContent(correctAnswer, questionContent),
              if (correctAnswer == null && _hasCorrectChoices(questionContent)) _buildCorrectChoices(questionContent!),
              const Divider(height: DesignSpacing.lg),
            ],
            if (showRubric) ...[
              Text(
                'Rubric',
                style: DesignTypography.bodySmall
                    .copyWith(color: DesignColors.textSecondary),
              ),
              const SizedBox(height: DesignSpacing.xs),
              _buildRubricSection(),
            ],
          ],
        ),
      ),
    );
  }

  bool _hasCorrectChoices(Map<String, dynamic>? content) {
    if (content == null) return false;
    final choices = content['choices'] as List<dynamic>?;
    return choices?.any((c) => c['isCorrect'] == true) ?? false;
  }

  Widget _buildCorrectChoices(Map<String, dynamic> content) {
    final choices = content['choices'] as List<dynamic>?;
    if (choices == null) return const SizedBox.shrink();
    final correctChoices = choices.where((c) => c['isCorrect'] == true).toList();
    return Wrap(
      spacing: DesignSpacing.sm,
      children: correctChoices
          .map((choice) => Chip(
                label: Text(choice['content']?.toString() ?? choice['text']?.toString() ?? choice['id'].toString()),
                backgroundColor: DesignColors.success.withValues(alpha: 0.1),
              ))
          .toList(),
    );
  }

  Widget _buildAnswerContent(Map<String, dynamic> answerData, Map<String, dynamic>? questionContent) {
    final selectedChoices = (answerData['selected_choice_ids'] as List<dynamic>?) ?? 
                            (answerData['selected_choices'] as List<dynamic>?);
    if (selectedChoices != null) {
      final choicesList = questionContent?['choices'] as List<dynamic>?;
      return Wrap(
        spacing: DesignSpacing.sm,
        children: selectedChoices.map((choiceId) {
          String displayLabel = choiceId.toString();
          if (choicesList != null) {
            final matchingChoice = choicesList.firstWhere(
                (c) => c['id'].toString() == choiceId.toString(),
                orElse: () => null);
            if (matchingChoice != null) {
              displayLabel = matchingChoice['content']?.toString() ?? matchingChoice['text']?.toString() ?? displayLabel;
            }
          }
          return Chip(label: Text(displayLabel));
        }).toList(),
      );
    }
    final text = answerData['text'] as String?;
    if (text != null) {
      return Container(
        padding: const EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: DesignColors.moonLight,
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        child: Text(text, style: DesignTypography.bodyMedium),
      );
    }
    return const SizedBox.shrink();
  }

  /// Renders the rubric section based on the current display mode.
  ///
  /// - Grading mode (isGrading=true + all callbacks present):
  ///   → [InteractiveRubricGrader] for click-to-select levels (D-04).
  /// - Read-only mode:
  ///   → [ReadOnlyRubricViewer] (correct D-02 keys: max_points, levels).
  Widget _buildRubricSection() {
    final rubricData = answer['rubric'] as Map<String, dynamic>?;
    if (rubricData == null) {
      return Text(
        'Không có rubric',
        style: DesignTypography.bodyMedium
            .copyWith(color: DesignColors.textTertiary),
      );
    }
    if (isGrading &&
        submissionAnswerId != null &&
        onLevelSelected != null &&
        onManualOverride != null) {
      return InteractiveRubricGrader(
        rubric: rubricData,
        currentScore: (answer['final_score'] as num?)?.toDouble(),
        submissionAnswerId: submissionAnswerId!,
        onLevelSelected: onLevelSelected!,
        onManualOverride: onManualOverride!,
      );
    }
    return ReadOnlyRubricViewer(rubric: rubricData);
  }
}
