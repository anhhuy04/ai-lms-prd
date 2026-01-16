import 'package:flutter/material.dart';
import 'flexible_dialog.dart';

/// Dialog thành công với thiết kế tối ưu hóa
/// Sử dụng cho các trường hợp xác nhận thành công
class SuccessDialog {
  /// Hiển thị dialog thành công với các hành động tùy chỉnh
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    DialogAction? primaryAction,
    DialogAction? secondaryAction,
    DialogAction? tertiaryAction,
    bool barrierDismissible = true,
  }) {
    // Tạo danh sách hành động, ưu tiên primary action
    final actions = <DialogAction>[];

    if (primaryAction != null) {
      actions.add(primaryAction.copyWith(type: DialogActionType.primary));
    }

    if (secondaryAction != null) {
      actions.add(secondaryAction.copyWith(type: DialogActionType.secondary));
    }

    if (tertiaryAction != null) {
      actions.add(tertiaryAction.copyWith(type: DialogActionType.tertiary));
    }

    return FlexibleDialog.show<T>(
      context: context,
      title: title,
      message: message,
      type: DialogType.success,
      actions: actions,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Hiển thị dialog thành công đơn giản với nút OK
  static Future<void> showSimple({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onOkPressed,
    bool barrierDismissible = true,
  }) {
    return show<void>(
      context: context,
      title: title,
      message: message,
      primaryAction: DialogAction(
        text: 'OK',
        onPressed: onOkPressed ?? () => Navigator.pop(context),
        type: DialogActionType.primary,
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// Hiển thị dialog thành công với hai nút (Xem chi tiết + Đóng)
  static Future<void> showWithDetails({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onViewDetails,
    bool barrierDismissible = true,
  }) {
    return show<void>(
      context: context,
      title: title,
      message: message,
      primaryAction: DialogAction(
        text: 'Xem chi tiết',
        onPressed: onViewDetails,
        type: DialogActionType.primary,
      ),
      secondaryAction: DialogAction(
        text: 'Đóng',
        onPressed: () => Navigator.pop(context),
        type: DialogActionType.secondary,
      ),
      barrierDismissible: barrierDismissible,
    );
  }
}

/// Extension method cho DialogAction để dễ dàng copy với type mới
extension DialogActionExtension on DialogAction {
  DialogAction copyWith({
    String? text,
    VoidCallback? onPressed,
    DialogActionType? type,
    bool? isDestructive,
  }) {
    return DialogAction(
      text: text ?? this.text,
      onPressed: onPressed ?? this.onPressed,
      type: type ?? this.type,
      isDestructive: isDestructive ?? this.isDestructive,
    );
  }
}