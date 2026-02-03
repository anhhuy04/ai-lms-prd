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
      actions.add(
        confirmAction.copyWith(
          type: DialogActionType.primary,
          isDestructive: confirmAction.isDestructive,
        ),
      );
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
  /// Trả về: true nếu user chọn "Lưu thay đổi", false nếu chọn "Không lưu", null nếu đóng dialog (hủy)
  /// Layout: "Lưu thay đổi" (bên trái, có màu) | "Không lưu" (bên phải, không màu)
  /// Bấm ra ngoài dialog = hủy (ở lại trang) = trả về null
  static Future<bool?> showUnsavedChanges({
    required BuildContext context,
    bool barrierDismissible = true,
  }) {
    return show<bool>(
      context: context,
      title: 'Thay đổi chưa được lưu',
      message: 'Bạn có muốn lưu thay đổi trước khi rời khỏi?',
      // Nút "Lưu thay đổi" - bên trái, có màu (primary)
      confirmAction: DialogAction(
        text: 'Lưu thay đổi',
        onPressed: () => Navigator.pop(context, true), // true = lưu thay đổi
        isDestructive: false,
      ),
      // Nút "Không lưu" - bên phải, không màu (secondary)
      cancelAction: DialogAction(
        text: 'Không lưu',
        onPressed: () => Navigator.pop(context, false), // false = không lưu
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// Trạng thái cho dialog "thay đổi chưa lưu" dạng 3 lựa chọn.
  /// - save: lưu rồi thoát
  /// - discard: không lưu rồi thoát
  /// - cancel: ở lại trang
  static Future<WarningUnsavedDecision> showUnsavedChangesWithCancel({
    required BuildContext context,
    String title = 'Thay đổi chưa được lưu',
    String message = 'Bạn có muốn lưu thay đổi trước khi rời khỏi?',
    String saveText = 'Lưu',
    String discardText = 'Không lưu',
    String cancelText = 'Hủy',
    bool barrierDismissible = true,
  }) async {
    final result = await FlexibleDialog.show<WarningUnsavedDecision>(
      context: context,
      title: title,
      message: message,
      type: DialogType.warning,
      barrierDismissible: barrierDismissible,
      actions: [
        DialogAction(
          text: cancelText,
          type: DialogActionType.tertiary,
          onPressed: () =>
              Navigator.pop(context, WarningUnsavedDecision.cancel),
        ),
        DialogAction(
          text: discardText,
          type: DialogActionType.secondary,
          onPressed: () =>
              Navigator.pop(context, WarningUnsavedDecision.discard),
        ),
        DialogAction(
          text: saveText,
          type: DialogActionType.primary,
          onPressed: () => Navigator.pop(context, WarningUnsavedDecision.save),
        ),
      ],
    );

    return result ?? WarningUnsavedDecision.cancel;
  }

  /// Hiển thị dialog xác nhận lưu thay đổi
  /// Trả về: true nếu user chọn "Lưu", false nếu chọn "Hủy", null nếu đóng dialog
  static Future<bool?> showSaveConfirmation({
    required BuildContext context,
    String title = 'Xác nhận lưu',
    String message = 'Bạn có chắc chắn muốn lưu các thay đổi?',
    bool barrierDismissible = true,
  }) {
    return showConfirmation(
      context: context,
      title: title,
      message: message,
      confirmText: 'Lưu',
      cancelText: 'Hủy',
      isDestructive: false,
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
      message:
          'Bạn có chắc chắn muốn xóa "$itemName"? Hành động này không thể hoàn tác.',
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

enum WarningUnsavedDecision { save, discard, cancel }
