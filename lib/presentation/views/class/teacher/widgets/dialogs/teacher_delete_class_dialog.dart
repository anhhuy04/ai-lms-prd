import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/widgets/dialogs/delete_dialog.dart';
import 'package:flutter/material.dart';

/// Dialog xác nhận xóa lớp học
/// Sử dụng DeleteDialog generic với thông tin chi tiết về dữ liệu sẽ bị xóa
class DeleteConfirmationDialog {
  /// Hiển thị dialog xác nhận xóa lớp học
  /// Trả về `true` nếu người dùng xác nhận xóa, `false` nếu hủy, `null` nếu đóng
  static Future<bool?> show({
    required BuildContext context,
    required Class classItem,
    required int studentCount,
    required int pendingCount,
  }) {
    final totalStudents = studentCount + pendingCount;

    // Xây dựng preview content với thông tin chi tiết
    String? previewContent;
    if (totalStudents > 0) {
      final List<String> items = [];
      if (studentCount > 0) {
        items.add('$studentCount học sinh đã được duyệt');
      }
      if (pendingCount > 0) {
        items.add('$pendingCount yêu cầu tham gia đang chờ');
      }
      items.add('Tất cả nhóm học tập và bài tập liên quan');
      previewContent = items.join(', ');
    }

    return DeleteDialog.show(
      context: context,
      title: 'Xác nhận xóa lớp học',
      message: 'Bạn có chắc chắn muốn xóa lớp "${classItem.name}"?',
      previewContent: previewContent,
      previewLabel: totalStudents > 0 ? 'Dữ liệu sẽ bị xóa:' : null,
    );
  }
}
