import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:flutter/material.dart';

/// Drawer công cụ bên phải để tạo câu hỏi và các tùy chọn khác
class ToolsDrawer extends StatelessWidget {
  final VoidCallback? onClose;
  final VoidCallback? onAddMultipleChoice;
  final VoidCallback? onAddShortAnswer;
  final VoidCallback? onAddEssay;
  final VoidCallback? onAddMath;
  final VoidCallback? onAiGenerateQuestion;
  final VoidCallback? onOpenQuestionBank;
  final VoidCallback? onUploadFile;
  final VoidCallback? onPreview;
  final VoidCallback? onSaveDraft;
  final VoidCallback? onSaveAndPublish;
  final bool isLoading;

  const ToolsDrawer({
    super.key,
    this.onClose,
    this.onAddMultipleChoice,
    this.onAddShortAnswer,
    this.onAddEssay,
    this.onAddMath,
    this.onAiGenerateQuestion,
    this.onOpenQuestionBank,
    this.onUploadFile,
    this.onPreview,
    this.onSaveDraft,
    this.onSaveAndPublish,
    this.isLoading = false,
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
            padding: EdgeInsets.all(DesignSpacing.lg + 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Công cụ',
                  style: DesignTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(DesignSpacing.lg + 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Create Question Section
                  _buildSectionHeader('TẠO CÂU HỎI MỚI', isDark),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildQuestionTypeButton(
                        icon: Icons.radio_button_checked,
                        label: 'Trắc nghiệm',
                        color: QuestionType.multipleChoice.color,
                        onTap: onAddMultipleChoice,
                        isDark: isDark,
                      ),
                      _buildQuestionTypeButton(
                        icon: Icons.short_text,
                        label: 'Trả lời ngắn',
                        color: QuestionType.shortAnswer.color,
                        onTap: onAddShortAnswer,
                        isDark: isDark,
                      ),
                      _buildQuestionTypeButton(
                        icon: Icons.article,
                        label: 'Tự luận',
                        color: QuestionType.essay.color,
                        onTap: onAddEssay,
                        isDark: isDark,
                      ),
                      _buildQuestionTypeButton(
                        icon: Icons.functions,
                        label: 'Bài toán',
                        color: QuestionType.math.color,
                        onTap: onAddMath,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildResourceButton(
                    icon: Icons.auto_awesome,
                    title: 'Tạo câu hỏi bằng AI',
                    subtitle: 'Sử dụng trí tuệ nhân tạo',
                    onTap: onAiGenerateQuestion,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),

                  // Resource Section
                  _buildSectionHeader('NGUỒN TÀI LIỆU', isDark),
                  const SizedBox(height: 12),
                  _buildResourceButton(
                    icon: Icons.library_add,
                    title: 'Ngân hàng câu hỏi',
                    subtitle: 'Chọn từ kho dữ liệu',
                    onTap: onOpenQuestionBank,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildResourceButton(
                    icon: Icons.upload_file,
                    title: 'Tải lên tệp',
                    subtitle: 'PDF, Word, Excel',
                    onTap: onUploadFile,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),

                  // Other Section
                  _buildSectionHeader('KHÁC', isDark),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    icon: Icons.visibility,
                    label: 'Xem trước bài tập',
                    onTap: onPreview,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          // Footer với nút Save
          Container(
            padding: EdgeInsets.all(DesignSpacing.lg + 4),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Save Draft button
                if (onSaveDraft != null)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : onSaveDraft,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.grey[300]
                            : DesignColors.textPrimary,
                        side: BorderSide(
                          color: isDark
                              ? Colors.grey[600]!
                              : DesignColors.primary.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            DesignRadius.lg * 1.5,
                          ),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark
                                      ? Colors.grey[300]!
                                      : DesignColors.textPrimary,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.save_outlined,
                                  size: 20,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : DesignColors.textPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Lưu bản nháp',
                                  style: DesignTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : DesignColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                if (onSaveDraft != null) const SizedBox(height: 12),
                // Save & Publish button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onSaveAndPublish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          DesignRadius.lg * 1.5,
                        ),
                      ),
                      elevation: 4,
                      shadowColor: DesignColors.primary.withValues(alpha: 0.3),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.save, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Lưu & Xuất bản',
                                style: DesignTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: DesignTypography.labelSmallSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildQuestionTypeButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey[800]!.withValues(alpha: 0.5)
              : Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignRadius.lg),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: DesignTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : DesignColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey[800]!.withValues(alpha: 0.5)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
          border: Border.all(
            color: isDark ? Colors.transparent : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700]! : Colors.white,
                borderRadius: BorderRadius.circular(DesignRadius.lg),
                border: Border.all(
                  color: isDark ? Colors.grey[600]! : Colors.grey[200]!,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DesignTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : DesignColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: DesignTypography.bodySmall.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: DesignColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
          border: Border.all(
            color: DesignColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: DesignColors.primary),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: DesignTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DesignColors.primary,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward,
              size: 18,
              color: DesignColors.primary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
