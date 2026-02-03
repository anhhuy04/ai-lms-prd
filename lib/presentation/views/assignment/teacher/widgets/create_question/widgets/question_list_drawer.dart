import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:flutter/material.dart';

/// Drawer hiển thị danh sách câu hỏi và cho phép chọn để chỉnh sửa
class QuestionListDrawer extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final Function(int index)? onQuestionSelected;
  final VoidCallback? onClose;
  final VoidCallback? onAddNew;
  final int?
  currentQuestionIndex; // Index của câu hỏi hiện tại đang được chỉnh sửa

  const QuestionListDrawer({
    super.key,
    required this.questions,
    this.onQuestionSelected,
    this.onClose,
    this.onAddNew,
    this.currentQuestionIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.85 > 320 ? 320.0 : screenWidth * 0.85;

    return Container(
      width: drawerWidth,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DesignRadius.lg * 1.5),
          bottomLeft: Radius.circular(DesignRadius.lg * 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(DesignSpacing.lg),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                ),
              ),
            ),
            child: Text(
              'Danh Sách Câu Hỏi',
              style: DesignTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : DesignColors.textPrimary,
              ),
            ),
          ),

          // Questions List
          Expanded(
            child: questions.isEmpty
                ? _buildEmptyState(context, isDark)
                : ListView.builder(
                    padding: EdgeInsets.all(DesignSpacing.lg),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      return _buildQuestionItem(context, isDark, index);
                    },
                  ),
          ),

          // Footer với nút thêm mới
          Container(
            padding: EdgeInsets.all(DesignSpacing.lg),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddNew,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Thêm câu hỏi mới'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: DesignColors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.help_outline,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          SizedBox(height: DesignSpacing.lg),
          Text(
            'Chưa có câu hỏi nào',
            style: DesignTypography.bodyMedium.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          SizedBox(height: DesignSpacing.sm),
          Text(
            'Thêm câu hỏi đầu tiên để bắt đầu',
            style: DesignTypography.bodySmall.copyWith(
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(BuildContext context, bool isDark, int index) {
    final question = questions[index];
    final questionType = question['type'] as QuestionType;
    final questionText = question['text'] as String? ?? '';
    final questionNumber = question['number'] as int? ?? (index + 1);
    final isCurrentQuestion = currentQuestionIndex == index;

    // Truncate text for preview
    final previewText = questionText.length > 60
        ? '${questionText.substring(0, 60)}...'
        : questionText;

    return InkWell(
      onTap: () {
        onQuestionSelected?.call(index);
        onClose?.call();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: DesignSpacing.xs),
        padding: EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: isCurrentQuestion
              ? (isDark
                    ? DesignColors.primary.withValues(alpha: 0.25)
                    : DesignColors.primary.withValues(alpha: 0.15))
              : Colors.transparent,
          border: isCurrentQuestion
              ? Border.all(color: DesignColors.primary, width: 2.5)
              : Border.all(color: Colors.transparent, width: 0),
          borderRadius: BorderRadius.circular(DesignRadius.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Question Number Badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCurrentQuestion
                    ? DesignColors.primary
                    : questionType.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignRadius.full),
              ),
              child: Center(
                child: Text(
                  '$questionNumber',
                  style: DesignTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCurrentQuestion
                        ? Colors.white
                        : questionType.color,
                  ),
                ),
              ),
            ),
            SizedBox(width: DesignSpacing.md),

            // Question Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isCurrentQuestion
                              ? DesignColors.primary
                              : questionType.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: DesignSpacing.xs),
                      Text(
                        questionType.label,
                        style: TextStyle(
                          fontSize: DesignTypography.labelSmallSize,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: isCurrentQuestion
                              ? DesignColors.primary
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: DesignSpacing.xs),
                  Text(
                    previewText,
                    style: DesignTypography.bodySmall.copyWith(
                      color: isDark ? Colors.white : DesignColors.textPrimary,
                      fontWeight: isCurrentQuestion
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isCurrentQuestion
                  ? DesignColors.primary
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
