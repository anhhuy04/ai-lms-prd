import 'package:flutter/material.dart';
import 'flexible_dialog.dart';
import 'success_dialog.dart';

/// Dialog lỗi với thiết kế tối ưu hóa
/// Sử dụng cho các trường hợp xảy ra lỗi hoặc thất bại
class ErrorDialog {
  /// Hiển thị dialog lỗi với các hành động tùy chỉnh
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    DialogAction? primaryAction,
    DialogAction? secondaryAction,
    bool barrierDismissible = true,
  }) {
    final actions = <DialogAction>[];

    // Thêm hành động chính
    if (primaryAction != null) {
      actions.add(primaryAction.copyWith(type: DialogActionType.primary));
    }

    // Thêm hành động phụ
    if (secondaryAction != null) {
      actions.add(secondaryAction.copyWith(type: DialogActionType.secondary));
    }

    return FlexibleDialog.show<T>(
      context: context,
      title: title,
      message: message,
      type: DialogType.error,
      actions: actions,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Hiển thị dialog lỗi đơn giản với nút OK
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

  /// Hiển thị dialog lỗi với tùy chọn thử lại
  static Future<bool?> showWithRetry({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onRetry,
    bool barrierDismissible = true,
  }) {
    return show<bool>(
      context: context,
      title: title,
      message: message,
      primaryAction: DialogAction(
        text: 'Thử lại',
        onPressed: () {
          onRetry();
          Navigator.pop(context, true);
        },
        type: DialogActionType.primary,
      ),
      secondaryAction: DialogAction(
        text: 'Hủy',
        onPressed: () => Navigator.pop(context, false),
        type: DialogActionType.secondary,
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// Hiển thị dialog lỗi kết nối mạng
  static Future<void> showNetworkError({
    required BuildContext context,
    VoidCallback? onRetry,
    bool barrierDismissible = true,
  }) {
    return show<void>(
      context: context,
      title: 'Lỗi kết nối',
      message: 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.',
      primaryAction: DialogAction(
        text: 'Thử lại',
        onPressed: onRetry ?? () => Navigator.pop(context),
        type: DialogActionType.primary,
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// Hiển thị dialog lỗi xác thực
  static Future<void> showAuthenticationError({
    required BuildContext context,
    String message = 'Thông tin đăng nhập không hợp lệ. Vui lòng thử lại.',
    bool barrierDismissible = true,
  }) {
    return show<void>(
      context: context,
      title: 'Lỗi xác thực',
      message: message,
      primaryAction: DialogAction(
        text: 'OK',
        onPressed: () => Navigator.pop(context),
        type: DialogActionType.primary,
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// Hiển thị dialog lỗi chung với mã lỗi
  static Future<void> showErrorWithCode({
    required BuildContext context,
    required String errorCode,
    required String errorMessage,
    VoidCallback? onDetails,
    bool barrierDismissible = true,
  }) {
    final message = 'Mã lỗi: $errorCode\n$errorMessage';

    if (onDetails != null) {
      return show<void>(
        context: context,
        title: 'Đã xảy ra lỗi',
        message: message,
        primaryAction: DialogAction(
          text: 'Xem chi tiết',
          onPressed: onDetails,
          type: DialogActionType.primary,
        ),
        secondaryAction: DialogAction(
          text: 'Đóng',
          onPressed: () => Navigator.pop(context),
          type: DialogActionType.secondary,
        ),
        barrierDismissible: barrierDismissible,
      );
    } else {
      return showSimple(
        context: context,
        title: 'Đã xảy ra lỗi',
        message: message,
        barrierDismissible: barrierDismissible,
      );
    }
  }
}