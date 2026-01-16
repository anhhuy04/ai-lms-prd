import 'package:flutter/material.dart';
import 'flexible_dialog.dart';
import 'success_dialog.dart';

/// Dialog cảnh báo với thiết kế tối ưu hóa
/// Sử dụng cho các trường hợp cần xác nhận trước khi thực hiện hành động
class WarningDialog {
  /// Hiển thị dialog cảnh báo với các hành động tùy chỉnh
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    DialogAction? confirmAction,
    DialogAction? cancelAction,
    bool barrierDismissible = true,
  }) {
    final actions = <DialogAction>[];

    // Thêm hành động xác nhận (nút chính)
    if (confirmAction != null) {
      actions.add(confirmAction.copyWith(
        type: DialogActionType.primary,
        isDestructive: confirmAction.isDestructive,
      ));
    }

    // Thêm hành động hủy (nút phụ)
    if (cancelAction != null) {
      actions.add(cancelAction.copyWith(type: DialogActionType.secondary));
    }

    return FlexibleDialog.show<T>(
      context: context,
      title: title,
      message: message,
      type: DialogType.warning,
      actions: actions,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Hiển thị dialog cảnh báo đơn giản với nút Xác nhận và Hủy
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Xác nhận',
    String cancelText = 'Hủy',
    bool isDestructive = false,
    bool barrierDismissible = true,
  }) {
    return show<bool>(
      context: context,
      title: title,
      message: message,
      confirmAction: DialogAction(
        text: confirmText,
        onPressed: () => Navigator.pop(context, true),
        isDestructive: isDestructive,
      ),
      cancelAction: DialogAction(
        text: cancelText,
        onPressed: () => Navigator.pop(context, false),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// Hiển thị dialog cảnh báo không lưu thay đổi
  static Future<bool?> showUnsavedChanges({
    required BuildContext context,
    required VoidCallback onDiscard,
    required VoidCallback onSave,
    bool barrierDismissible = true,
  }) {
    return show<bool>(
      context: context,
      title: 'Thay đổi chưa được lưu',
      message: 'Bạn có muốn lưu thay đổi trước khi rời khỏi?',
      confirmAction: DialogAction(
        text: 'Không lưu',
        onPressed: () {
          onDiscard();
          Navigator.pop(context, true);
        },
        isDestructive: false,
      ),
      cancelAction: DialogAction(
        text: 'Lưu thay đổi',
        onPressed: () {
          onSave();
          Navigator.pop(context, false);
        },
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// Hiển thị dialog cảnh báo xóa dữ liệu
  static Future<bool?> showDeleteConfirmation({
    required BuildContext context,
    required String itemName,
    required VoidCallback onDelete,
    bool barrierDismissible = true,
  }) {
    return show<bool>(
      context: context,
      title: 'Xác nhận xóa',
      message: 'Bạn có chắc chắn muốn xóa "$itemName"? Hành động này không thể hoàn tác.',
      confirmAction: DialogAction(
        text: 'Xóa',
        onPressed: () {
          onDelete();
          Navigator.pop(context, true);
        },
        isDestructive: true,
      ),
      cancelAction: DialogAction(
        text: 'Hủy',
        onPressed: () => Navigator.pop(context, false),
      ),
      barrierDismissible: barrierDismissible,
    );
  }
}