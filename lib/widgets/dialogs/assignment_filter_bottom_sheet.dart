import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:flutter/material.dart';

/// Trạng thái bài tập trong ngân hàng đề.
/// • [all]       — Tất cả (mặc định ở entry point Tổng quan).
/// • [draft]     — Bản nháp (is_published = false).
/// • [published] — Đã xuất bản (is_published = true).
enum AssignmentStatusFilter { all, draft, published }

extension AssignmentStatusFilterX on AssignmentStatusFilter {
  /// Nhãn ngắn dùng cho chip + tiêu đề màn hình.
  String get label {
    switch (this) {
      case AssignmentStatusFilter.all:
        return 'Tất cả';
      case AssignmentStatusFilter.draft:
        return 'Bản nháp';
      case AssignmentStatusFilter.published:
        return 'Đã xuất bản';
    }
  }

  /// Mô tả phụ hiển thị bên dưới label trong sheet.
  String get description {
    switch (this) {
      case AssignmentStatusFilter.all:
        return 'Hiển thị cả bài đã xuất bản lẫn bản nháp';
      case AssignmentStatusFilter.draft:
        return 'Bài tập chưa được xuất bản cho học sinh';
      case AssignmentStatusFilter.published:
        return 'Bài tập đã xuất bản và phân phối';
    }
  }

  IconData get icon {
    switch (this) {
      case AssignmentStatusFilter.all:
        return Icons.layers_outlined;
      case AssignmentStatusFilter.draft:
        return Icons.edit_document;
      case AssignmentStatusFilter.published:
        return Icons.assignment_turned_in_outlined;
    }
  }
}

/// Bộ lọc danh sách bài tập trong ngân hàng đề.
///
/// Hiện chỉ lọc theo [status] (mặc định = all). Cấu trúc class giữ dạng
/// immutable + [copyWith] để dễ mở rộng nếu cần thêm tiêu chí khác sau này.
class AssignmentFilter {
  final AssignmentStatusFilter status;

  const AssignmentFilter({this.status = AssignmentStatusFilter.all});

  /// Filter rỗng (status = all).
  static const empty = AssignmentFilter();

  bool get isEmpty => status == AssignmentStatusFilter.all;

  /// Số tiêu chí đang active — hiển thị badge số trên nút filter.
  int get activeCount => status == AssignmentStatusFilter.all ? 0 : 1;

  AssignmentFilter copyWith({AssignmentStatusFilter? status}) {
    return AssignmentFilter(status: status ?? this.status);
  }
}

/// Áp filter lên danh sách bài tập (immutable, trả list mới).
List<Assignment> applyAssignmentFilter(
  List<Assignment> source,
  AssignmentFilter filter,
) {
  switch (filter.status) {
    case AssignmentStatusFilter.all:
      return List.of(source);
    case AssignmentStatusFilter.draft:
      return source.where((a) => !a.isPublished).toList();
    case AssignmentStatusFilter.published:
      return source.where((a) => a.isPublished).toList();
  }
}

/// Bottom sheet cấu hình filter — apply ngay khi user chọn 1 trạng thái
/// (không cần nút "Áp dụng" vì chỉ có 1 tiêu chí, click → đóng sheet).
class AssignmentFilterBottomSheet extends StatelessWidget {
  final AssignmentFilter initial;
  final ValueChanged<AssignmentFilter> onApply;

  const AssignmentFilterBottomSheet({
    super.key,
    required this.initial,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required AssignmentFilter initial,
    required ValueChanged<AssignmentFilter> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AssignmentFilterBottomSheet(
        initial: initial,
        onApply: onApply,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: DesignSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
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
                'Lọc theo trạng thái',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            // 3 dòng theo thứ tự: Tất cả → Bản nháp → Đã xuất bản
            ...AssignmentStatusFilter.values.map((s) => _row(context, s)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, AssignmentStatusFilter s) {
    final selected = initial.status == s;
    return ListTile(
      leading: Icon(
        s.icon,
        color: selected ? DesignColors.primary : Colors.grey[600],
      ),
      title: Text(
        s.label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? DesignColors.primary : Colors.black87,
        ),
      ),
      subtitle: Text(
        s.description,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: selected
          ? Icon(Icons.check_circle, color: DesignColors.primary)
          : Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
      onTap: () {
        onApply(AssignmentFilter(status: s));
        Navigator.of(context).pop();
      },
    );
  }
}
