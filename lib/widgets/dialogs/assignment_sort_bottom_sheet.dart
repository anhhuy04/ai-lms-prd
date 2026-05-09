import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:flutter/material.dart';

/// Tuỳ chọn sắp xếp danh sách bài tập (Kho nháp / Đã tạo).
enum AssignmentSortOption {
  /// Mới cập nhật trước (default).
  recentlyUpdated,

  /// Lâu chưa cập nhật trước.
  oldestUpdated,

  /// A → Z theo title.
  nameAsc,

  /// Z → A theo title.
  nameDesc,

  /// Tổng điểm cao trước.
  pointsDesc,

  /// Tổng điểm thấp trước.
  pointsAsc,
}

/// Áp option sort lên danh sách bài tập (immutable, trả list mới).
List<Assignment> sortAssignments(
  List<Assignment> source,
  AssignmentSortOption option,
) {
  final list = [...source];
  DateTime epoch() => DateTime.fromMillisecondsSinceEpoch(0);

  switch (option) {
    case AssignmentSortOption.recentlyUpdated:
      list.sort((a, b) {
        final at = a.updatedAt ?? a.createdAt ?? epoch();
        final bt = b.updatedAt ?? b.createdAt ?? epoch();
        return bt.compareTo(at);
      });
    case AssignmentSortOption.oldestUpdated:
      list.sort((a, b) {
        final at = a.updatedAt ?? a.createdAt ?? epoch();
        final bt = b.updatedAt ?? b.createdAt ?? epoch();
        return at.compareTo(bt);
      });
    case AssignmentSortOption.nameAsc:
      list.sort((a, b) =>
          a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    case AssignmentSortOption.nameDesc:
      list.sort((a, b) =>
          b.title.toLowerCase().compareTo(a.title.toLowerCase()));
    case AssignmentSortOption.pointsDesc:
      list.sort((a, b) =>
          (b.totalPoints ?? 0).compareTo(a.totalPoints ?? 0));
    case AssignmentSortOption.pointsAsc:
      list.sort((a, b) =>
          (a.totalPoints ?? 0).compareTo(b.totalPoints ?? 0));
  }
  return list;
}

/// Bottom sheet chọn cách sắp xếp danh sách bài tập.
class AssignmentSortBottomSheet extends StatelessWidget {
  final AssignmentSortOption currentOption;
  final ValueChanged<AssignmentSortOption> onSelected;

  const AssignmentSortBottomSheet({
    super.key,
    required this.currentOption,
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required AssignmentSortOption currentOption,
    required ValueChanged<AssignmentSortOption> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AssignmentSortBottomSheet(
        currentOption: currentOption,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: DesignSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Sắp xếp bài tập',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              _row(context, AssignmentSortOption.recentlyUpdated,
                  'Mới cập nhật trước', Icons.update),
              _row(context, AssignmentSortOption.oldestUpdated,
                  'Cũ nhất trước', Icons.history),
              _row(context, AssignmentSortOption.nameAsc,
                  'Tên (A → Z)', Icons.sort_by_alpha),
              _row(context, AssignmentSortOption.nameDesc,
                  'Tên (Z → A)', Icons.sort_by_alpha),
              _row(context, AssignmentSortOption.pointsDesc,
                  'Điểm cao trước', Icons.trending_down),
              _row(context, AssignmentSortOption.pointsAsc,
                  'Điểm thấp trước', Icons.trending_up),
              const SizedBox(height: DesignSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, AssignmentSortOption option, String label,
      IconData icon) {
    final selected = currentOption == option;
    return ListTile(
      leading: Icon(icon,
          color: selected ? DesignColors.primary : Colors.grey[600]),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? DesignColors.primary : Colors.black87,
        ),
      ),
      trailing: selected ? Icon(Icons.check, color: DesignColors.primary) : null,
      onTap: () {
        onSelected(option);
        Navigator.of(context).pop();
      },
    );
  }
}
