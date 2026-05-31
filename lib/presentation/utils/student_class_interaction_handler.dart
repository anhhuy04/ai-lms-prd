import 'package:ai_mls/domain/entities/class.dart';
import 'package:flutter/material.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';

/// Handler chung cho các tương tác với lớp học của học sinh
/// Đặc biệt là xử lý các lớp đang chờ duyệt
class StudentClassInteractionHandler {
  StudentClassInteractionHandler._(); // Prevent instantiation

  /// Hiển thị thông báo khi học sinh cố gắng truy cập lớp đang chờ duyệt
  ///
  /// [context] - BuildContext để hiển thị SnackBar
  /// [className] - Tên lớp học
  static void showPendingClassMessage(BuildContext context, String className) {
    AppToast.info(context, 'Lớp học "$className" đang chờ giáo viên duyệt. Vui lòng đợi!');
  }

  /// Xử lý khi học sinh tap vào một lớp học
  ///
  /// [context] - BuildContext để điều hướng hoặc hiển thị thông báo
  /// [classItem] - Lớp học được tap
  /// [onNavigate] - Callback để điều hướng đến chi tiết lớp (chỉ gọi nếu lớp không chờ duyệt)
  ///
  /// Trả về true nếu đã điều hướng thành công, false nếu lớp đang chờ duyệt
  static bool handleClassTap(
    BuildContext context,
    Class classItem, {
    required VoidCallback onNavigate,
  }) {
    // Chỉ block khi lớp đang chờ duyệt
    if (classItem.isPending) {
      showPendingClassMessage(context, classItem.name);
      return false;
    }

    // Cho phép điều hướng nếu đã duyệt hoặc memberStatus null (fallback)
    onNavigate();
    return true;
  }
}
