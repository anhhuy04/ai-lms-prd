import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:flutter/material.dart';

/// Màn hình xem trước bài tập trước khi publish
class TeacherPreviewAssignmentScreen extends StatelessWidget {
  final String title;
  final String? description;
  final List<Map<String, dynamic>> questions;
  final DateTime? dueDate;
  final TimeOfDay? dueTime;
  final String? timeLimit;
  final double totalPoints;

  const TeacherPreviewAssignmentScreen({
    super.key,
    required this.title,
    this.description,
    required this.questions,
    this.dueDate,
    this.dueTime,
    this.timeLimit,
    required this.totalPoints,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: isDark ? Colors.grey[300] : Colors.grey[700],
        ),
        title: Text(
          'Xem trước bài tập',
          style: DesignTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assignment Info Card
            _buildInfoCard(context, isDark),
            SizedBox(height: DesignSpacing.xxl),

            // Questions List
            Text(
              'Nội dung bài tập',
              style: DesignTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : DesignColors.textPrimary,
              ),
            ),
            SizedBox(height: DesignSpacing.lg),
            ...questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return _buildQuestionPreview(context, isDark, question, index + 1);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: DesignTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : DesignColors.textPrimary,
            ),
          ),
          if (description != null && description!.isNotEmpty) ...[
            SizedBox(height: DesignSpacing.md),
            Text(
              description!,
              style: DesignTypography.bodyMedium.copyWith(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
          SizedBox(height: DesignSpacing.lg),
          Divider(
            color: isDark ? Colors.grey[700] : Colors.grey[200],
          ),
          SizedBox(height: DesignSpacing.md),
          Wrap(
            spacing: DesignSpacing.md,
            runSpacing: DesignSpacing.sm,
            children: [
              if (dueDate != null && dueTime != null)
                _buildInfoChip(
                  icon: Icons.schedule,
                  label: 'Hết hạn: ${_formatDueDate()}',
                  isDark: isDark,
                ),
              if (timeLimit != null && timeLimit != 'unlimited')
                _buildInfoChip(
                  icon: Icons.timer,
                  label: 'Thời gian: $timeLimit phút',
                  isDark: isDark,
                ),
              _buildInfoChip(
                icon: Icons.quiz,
                label: '${questions.length} câu hỏi',
                isDark: isDark,
              ),
              _buildInfoChip(
                icon: Icons.star,
                label: 'Tổng điểm: $totalPoints',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: DesignColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.full),
        border: Border.all(
          color: DesignColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: DesignColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: DesignTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: DesignColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPreview(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> question,
    int questionNumber,
  ) {
    final questionType = question['type'] as QuestionType;
    final questionText = question['text'] as String? ?? '';
    final points = question['points'] as double? ?? 0.0;
    final options = question['options'] as List<Map<String, dynamic>>?;

    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: questionType.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.md),
                ),
                child: Text(
                  'Câu $questionNumber',
                  style: DesignTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: questionType.color,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
                child: Text(
                  '${points.toStringAsFixed(1)} điểm',
                  style: DesignTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DesignColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          Text(
            questionText,
            style: DesignTypography.bodyMedium.copyWith(
              color: isDark ? Colors.white : DesignColors.textPrimary,
            ),
          ),
          if (options != null && options.isNotEmpty) ...[
            SizedBox(height: DesignSpacing.md),
            ...options.asMap().entries.map((entry) {
              final optIndex = entry.key;
              final opt = entry.value;
              final optText = opt['text'] as String? ?? '';
              final isCorrect = opt['isCorrect'] as bool? ?? false;
              return Container(
                margin: EdgeInsets.only(bottom: DesignSpacing.sm),
                padding: EdgeInsets.all(DesignSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[800]!.withValues(alpha: 0.5)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(DesignRadius.md),
                  border: Border.all(
                    color: isCorrect
                        ? DesignColors.success
                        : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
                    width: isCorrect ? 2 : 1,
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
                          color: isCorrect
                              ? DesignColors.success
                              : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                          width: 2,
                        ),
                        color: isCorrect
                            ? DesignColors.success.withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      child: isCorrect
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: DesignColors.success,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${String.fromCharCode(65 + optIndex)}. $optText',
                        style: DesignTypography.bodyMedium.copyWith(
                          color: isDark ? Colors.white : DesignColors.textPrimary,
                          fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isCorrect)
                      Icon(
                        Icons.star,
                        size: 16,
                        color: DesignColors.success,
                      ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  String _formatDueDate() {
    if (dueDate == null || dueTime == null) return '';
    final dateTime = DateTime(
      dueDate!.year,
      dueDate!.month,
      dueDate!.day,
      dueTime!.hour,
      dueTime!.minute,
    );
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dueTime!.hour.toString().padLeft(2, '0')}:${dueTime!.minute.toString().padLeft(2, '0')}';
  }
}
