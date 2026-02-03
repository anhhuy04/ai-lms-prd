import 'package:ai_mls/widgets/dialogs/delete_dialog.dart';
import 'package:flutter/material.dart';

/// Dialog xác nhận xóa câu hỏi
/// Sử dụng DeleteDialog chung và truyền dữ liệu vào
class DeleteQuestionDialog {
  /// Hiển thị dialog xóa câu hỏi
  /// Trả về `true` nếu người dùng xác nhận xóa, `false` nếu hủy, `null` nếu đóng
  static Future<bool?> show({
    required BuildContext context,
    required int questionNumber,
    String? questionText,
    bool barrierDismissible = true,
  }) {
    return DeleteDialog.show(
      context: context,
      title: 'Xác nhận xóa',
      message: 'Bạn có chắc chắn muốn xóa câu hỏi số $questionNumber?',
      previewContent: questionText,
      barrierDismissible: barrierDismissible,
    );
  }
}
