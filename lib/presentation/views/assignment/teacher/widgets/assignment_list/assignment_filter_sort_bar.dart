import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/dialogs/assignment_filter_bottom_sheet.dart';
import 'package:ai_mls/widgets/dialogs/assignment_sort_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// Thanh điều khiển dùng chung cho 2 màn hình kho bài tập (nháp / đã tạo):
/// • Ô tìm kiếm tên bài tập (live, debounced bởi consumer dùng setState).
/// • Nút sort → mở [AssignmentSortBottomSheet].
/// • Nút filter → mở [AssignmentFilterBottomSheet] (kèm badge số tiêu chí).
///
/// Stateless — toàn bộ state do parent quản lý để dễ test và tránh lệch
/// nguồn chân lý giữa 2 nơi.
class AssignmentFilterSortBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final AssignmentSortOption currentSort;
  final ValueChanged<AssignmentSortOption> onSortChanged;
  final AssignmentFilter currentFilter;
  final ValueChanged<AssignmentFilter> onFilterChanged;

  /// Hiển thị label "Danh sách" bên trái nút sort/filter cho nhất quán
  /// với teacher class screen. Truyền null để ẩn label.
  final String? listLabel;

  const AssignmentFilterSortBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.currentSort,
    required this.onSortChanged,
    required this.currentFilter,
    required this.onFilterChanged,
    this.listLabel = 'Danh sách bài tập',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.fromLTRB(DesignSpacing.lg,
              DesignSpacing.sm, DesignSpacing.lg, 0),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey[800]!.withValues(alpha: 0.5)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.search,
                    size: 20,
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isDark ? DesignColors.white : DesignColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên bài tập...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                    child: Icon(Icons.close,
                        size: 18,
                        color: isDark ? Colors.grey[400] : Colors.grey[500]),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Label + sort/filter buttons
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.md, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (listLabel != null)
                Text(listLabel!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold))
              else
                const SizedBox.shrink(),
              Row(
                children: [
                  _FilterButton(
                    activeCount: currentFilter.activeCount,
                    onTap: () {
                      AssignmentFilterBottomSheet.show(
                        context,
                        initial: currentFilter,
                        onApply: onFilterChanged,
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.sort,
                        size: 20, color: Colors.grey[600]),
                    tooltip: 'Sắp xếp',
                    onPressed: () {
                      AssignmentSortBottomSheet.show(
                        context,
                        currentOption: currentSort,
                        onSelected: onSortChanged,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// IconButton có badge số tiêu chí filter đang active.
class _FilterButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;

  const _FilterButton({required this.activeCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.filter_list,
            size: 20,
            color: activeCount > 0 ? DesignColors.primary : Colors.grey[600],
          ),
          tooltip: 'Lọc',
          onPressed: onTap,
        ),
        if (activeCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              width: 16,
              height: 16,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: DesignColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$activeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
