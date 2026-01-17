import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:flutter/material.dart';

/// Dialog xác nhận xóa lớp học
/// Hiển thị thông tin về dữ liệu sẽ bị xóa
class DeleteConfirmationDialog extends StatelessWidget {
  final Class classItem;
  final int studentCount;
  final int pendingCount;

  const DeleteConfirmationDialog({
    super.key,
    required this.classItem,
    required this.studentCount,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    final totalStudents = studentCount + pendingCount;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: DesignColors.error,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Expanded(child: Text('Xác nhận xóa lớp học')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bạn có chắc chắn muốn xóa lớp "${classItem.name}"?',
            style: DesignTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (totalStudents > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(DesignRadius.sm),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dữ liệu sẽ bị xóa:',
                    style: DesignTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (studentCount > 0)
                    Text(
                      '• $studentCount học sinh đã được duyệt',
                      style: DesignTypography.bodySmall,
                    ),
                  if (pendingCount > 0)
                    Text(
                      '• $pendingCount yêu cầu tham gia đang chờ',
                      style: DesignTypography.bodySmall,
                    ),
                  Text(
                    '• Tất cả nhóm học tập và bài tập liên quan',
                    style: DesignTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
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
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: DesignColors.error),
          child: const Text('Xóa'),
        ),
      ],
    );
  }
}
