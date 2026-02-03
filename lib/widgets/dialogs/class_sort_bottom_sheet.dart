import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/utils/sorting_utils.dart';
import 'package:flutter/material.dart';

/// Bottom sheet chung để chọn cách sắp xếp lớp học
/// Có thể dùng cho cả teacher và student
class ClassSortBottomSheet extends StatelessWidget {
  /// Option sắp xếp hiện tại
  final ClassSortOption currentSortOption;

  /// Callback khi chọn option mới
  final ValueChanged<ClassSortOption> onSortOptionSelected;

  /// Tiêu đề của bottom sheet (mặc định: "Sắp xếp lớp học")
  final String? title;

  const ClassSortBottomSheet({
    super.key,
    required this.currentSortOption,
    required this.onSortOptionSelected,
    this.title,
  });

  /// Hiển thị bottom sheet
  static void show(
    BuildContext context, {
    required ClassSortOption currentSortOption,
    required ValueChanged<ClassSortOption> onSortOptionSelected,
    String? title,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ClassSortBottomSheet(
        currentSortOption: currentSortOption,
        onSortOptionSelected: onSortOptionSelected,
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  title ?? 'Sắp xếp lớp học',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
              const Divider(),
              // Sort options
              _buildSortOption(
                context,
                'Tên lớp (A-Z)',
                ClassSortOption.nameAscending,
                Icons.sort_by_alpha,
              ),
              _buildSortOption(
                context,
                'Tên lớp (Z-A)',
                ClassSortOption.nameDescending,
                Icons.sort_by_alpha,
              ),
              _buildSortOption(
                context,
                'Mới nhất',
                ClassSortOption.dateNewest,
                Icons.access_time,
              ),
              _buildSortOption(
                context,
                'Cũ nhất',
                ClassSortOption.dateOldest,
                Icons.access_time,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String title,
    ClassSortOption option,
    IconData icon,
  ) {
    final isSelected = currentSortOption == option;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? DesignColors.primary : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? DesignColors.primary : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: DesignColors.primary)
          : null,
      onTap: () {
        onSortOptionSelected(option);
        Navigator.of(context).pop();
      },
    );
  }
}
