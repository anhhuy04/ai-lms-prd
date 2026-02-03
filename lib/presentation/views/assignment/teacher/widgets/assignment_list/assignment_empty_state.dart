import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Reusable empty state widget cho assignment list
class AssignmentEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const AssignmentEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  /// Empty state cho draft assignments
  factory AssignmentEmptyState.draft() {
    return const AssignmentEmptyState(
      icon: Icons.edit_document,
      title: 'Chưa có bài tập nháp',
      description: 'Tạo bài tập mới và lưu bản nháp để quản lý tại đây',
    );
  }

  /// Empty state cho published assignments
  factory AssignmentEmptyState.published() {
    return const AssignmentEmptyState(
      icon: Icons.assignment_outlined,
      title: 'Chưa có bài tập đã tạo',
      description: 'Xuất bản bài tập để quản lý tại đây',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.xxxxxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 64,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                SizedBox(height: DesignSpacing.lg),
                Text(
                  title,
                  style: DesignTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                ),
                SizedBox(height: DesignSpacing.sm),
                Text(
                  description,
                  style: DesignTypography.bodyMedium.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
