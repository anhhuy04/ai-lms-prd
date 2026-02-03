import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Dialog xác nhận xóa với thiết kế tối ưu hóa
/// Có thể tái sử dụng cho nhiều trường hợp xóa khác nhau
class DeleteDialog {
  /// Hiển thị dialog xóa với các tùy chọn tùy chỉnh
  /// Trả về `true` nếu người dùng xác nhận xóa, `false` nếu hủy, `null` nếu đóng
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? previewContent, // Nội dung preview (chỉ hiển thị khi có)
    String? previewLabel, // Label cho preview content (ví dụ: "Nội dung:", "Tên:", ...)
    String confirmText = 'Xóa',
    String cancelText = 'Hủy',
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _DeleteDialogWidget(
        title: title,
        message: message,
        previewContent: previewContent,
        previewLabel: previewLabel,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
  }

  /// Hiển thị dialog xóa đơn giản (không có preview content)
  static Future<bool?> showSimple({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Xóa',
    String cancelText = 'Hủy',
    bool barrierDismissible = true,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      barrierDismissible: barrierDismissible,
    );
  }
}

/// Widget dialog xóa (internal)
class _DeleteDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? previewContent;
  final String? previewLabel;
  final String confirmText;
  final String cancelText;

  const _DeleteDialogWidget({
    required this.title,
    required this.message,
    this.previewContent,
    this.previewLabel,
    this.confirmText = 'Xóa',
    this.cancelText = 'Hủy',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPreview = previewContent != null && previewContent!.isNotEmpty;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
      ),
      title: Row(
        children: [
          Icon(Icons.delete_outline, color: DesignColors.error, size: 24),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: DesignTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : DesignColors.textPrimary,
            ),
          ),
          // Preview content - chỉ hiển thị khi có
          if (hasPreview) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey[800]!.withValues(alpha: 0.5)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(DesignRadius.sm),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (previewLabel != null && previewLabel!.isNotEmpty) ...[
                    Text(
                      previewLabel!,
                      style: DesignTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    previewContent!,
                    style: DesignTypography.bodySmall.copyWith(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2, // Tối đa 2 dòng
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Hành động này không thể hoàn tác.',
            style: DesignTypography.bodySmall.copyWith(
              color: DesignColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: DesignColors.error),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
