import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:flutter/material.dart';

/// Handler chung cho các tương tác với lớp học của học sinh
/// Đặc biệt là xử lý các lớp đang chờ duyệt
class StudentClassInteractionHandler {
  StudentClassInteractionHandler._(); // Prevent instantiation

  /// Hiển thị thông báo khi học sinh cố gắng truy cập lớp đang chờ duyệt
  ///
  /// [context] - BuildContext để hiển thị SnackBar
  /// [className] - Tên lớp học
  static void showPendingClassMessage(BuildContext context, String className) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.hourglass_top, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Lớp học "$className" đang chờ giáo viên duyệt. Vui lòng đợi!',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: DesignColors.primary,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Xử lý khi học sinh tap vào một lớp học
  ///
  /// [context] - BuildContext để điều hướng hoặc hiển thị thông báo
  /// [classItem] - Lớp học được tap
  /// [onNavigate] - Callback để điều hướng đến chi tiết lớp (chỉ gọi nếu lớp đã được duyệt)
  ///
  /// Trả về true nếu đã xử lý thành công, false nếu lớp đang chờ duyệt
  static bool handleClassTap(
    BuildContext context,
    Class classItem, {
    required VoidCallback onNavigate,
  }) {
    if (classItem.isPending) {
      showPendingClassMessage(context, classItem.name);
      return false;
    }

    if (classItem.canAccess) {
      onNavigate();
      return true;
    }

    return false;
  }
}
