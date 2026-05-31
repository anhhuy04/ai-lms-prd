import 'package:flutter/material.dart';

import 'package:ai_mls/core/constants/design_tokens.dart';

/// Dialog xác nhận xoá câu hỏi — 2 mode theo trạng thái link:
///
/// - **Đã link** (đang được dùng trong 1+ bài tập): chỉ cho phép **ẩn**
///   (warning màu vàng) — không xoá để bảo toàn dữ liệu bài tập đã giao.
/// - **Chưa link**: cho phép **xoá vĩnh viễn** (vào thùng rác 30 ngày,
///   error màu đỏ).
///
/// Caller chịu trách nhiệm pre-check usage (vd: `questionUsageProvider`)
/// và truyền vào `isLinked` + `linkedCount`.
class QuestionDeleteConfirmDialog extends StatelessWidget {
  final bool isLinked;
  final int linkedCount;
  final String? firstAssignmentTitle;

  const QuestionDeleteConfirmDialog({
    super.key,
    required this.isLinked,
    required this.linkedCount,
    this.firstAssignmentTitle,
  });

  /// Helper hiển thị nhanh + trả về true nếu user xác nhận.
  static Future<bool> show(
    BuildContext context, {
    required bool isLinked,
    required int linkedCount,
    String? firstAssignmentTitle,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => QuestionDeleteConfirmDialog(
        isLinked: isLinked,
        linkedCount: linkedCount,
        firstAssignmentTitle: firstAssignmentTitle,
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final accent = isLinked ? DesignColors.warning : DesignColors.error;
    final icon = isLinked
        ? Icons.visibility_off_rounded
        : Icons.delete_forever_rounded;
    final title = isLinked ? 'Ẩn câu hỏi?' : 'Xoá vĩnh viễn câu hỏi?';
    final actionLabel = isLinked ? 'Ẩn' : 'Xoá vĩnh viễn';

    return AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: accent, size: 28),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: DesignTypography.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge mô tả ngắn loại hành động
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(DesignRadius.full),
              border: Border.all(
                color: accent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLinked
                      ? Icons.shield_outlined
                      : Icons.warning_amber_rounded,
                  size: 14,
                  color: accent,
                ),
                const SizedBox(width: 6),
                Text(
                  isLinked
                      ? 'Chỉ ẩn (đã có ràng buộc)'
                      : 'Xoá vào thùng rác 30 ngày',
                  style: DesignTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (isLinked) ...[
            Text(
              'Câu hỏi này đang được dùng trong $linkedCount bài tập'
              '${firstAssignmentTitle != null ? " (\"$firstAssignmentTitle\"${linkedCount > 1 ? " và ${linkedCount - 1} bài khác" : ""})" : ""}.',
              style: DesignTypography.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Để bảo toàn dữ liệu của bài tập đã giao hoặc đang biên soạn, '
              'câu hỏi sẽ CHỈ bị ẩn khỏi Ngân hàng — vẫn giữ nguyên nội '
              'dung trong các bài tập đó.',
              style: DesignTypography.bodySmall.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ] else ...[
            Text(
              'Câu hỏi này không thuộc bài tập nào — an toàn để xoá.',
              style: DesignTypography.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Câu hỏi sẽ chuyển vào Thùng rác. Có thể khôi phục trong '
              '30 ngày, sau đó hệ thống tự xoá vĩnh viễn.',
              style: DesignTypography.bodySmall.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: accent),
          icon: Icon(icon, size: 16),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}
