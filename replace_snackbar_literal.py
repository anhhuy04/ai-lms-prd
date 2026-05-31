import re
import sys

def replace_snackbars(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Remove hideCurrentSnackBar
    content = re.sub(r'ScaffoldMessenger\.of\(context\)\.hideCurrentSnackBar\(\);\s*', '', content)

    # 26 matched blocks
    replacements = [
        (
            """ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải chi tiết câu hỏi: $e'),
          backgroundColor: DesignColors.error,
        ),
      );""",
            "AppToast.error(context, 'Lỗi tải chi tiết câu hỏi: $e');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm ${picked.length} câu hỏi từ kho')),
    );""",
            "AppToast.success(context, 'Đã thêm ${picked.length} câu hỏi từ kho');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã đồng bộ — danh sách câu hỏi đã cập nhật')),
    );""",
            "AppToast.success(context, 'Đã đồng bộ — danh sách câu hỏi đã cập nhật');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Vui lòng nhập các thông tin bắt buộc trước khi tạo câu hỏi',
            ),
            backgroundColor: DesignColors.warning,
          ),
        );""",
            "AppToast.warning(context, 'Vui lòng nhập các thông tin bắt buộc trước khi tạo câu hỏi');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: DesignColors.error,
            duration: const Duration(seconds: 4),
          ),
        );""",
            "AppToast.error(context, e.toString().replaceAll('Exception: ', ''));"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa có câu hỏi nào để phân tích.'),
          duration: Duration(seconds: 3),
        ),
      );""",
            "AppToast.warning(context, 'Chưa có câu hỏi nào để phân tích.');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('AI đang phân tích câu hỏi...'),
          ],
        ),
        duration: Duration(seconds: 60),
      ),
    );""",
            "AppToast.info(context, 'AI đang phân tích câu hỏi...');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chưa có mục tiêu học tập nào trong hệ thống.'),
              backgroundColor: Colors.orange,
            ),
          );""",
            "AppToast.warning(context, 'Chưa có mục tiêu học tập nào trong hệ thống.');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã gán mục tiêu học tập cho $assignedCount/${_questions.length} câu hỏi.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );""",
            "AppToast.success(context, 'Đã gán mục tiêu học tập cho $assignedCount/${_questions.length} câu hỏi.');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: DesignColors.error,
            duration: const Duration(seconds: 4),
          ),
        );""",
            "AppToast.error(context, 'Lỗi: ${e.toString().replaceAll(\\'Exception: \\', \\'\\')}');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng thêm ít nhất một câu hỏi'),
            backgroundColor: DesignColors.warning,
          ),
        );""",
            "AppToast.warning(context, 'Vui lòng thêm ít nhất một câu hỏi');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Người dùng chưa đăng nhập'),
                backgroundColor: Colors.red,
              ),
            );""",
            "AppToast.error(context, 'Người dùng chưa đăng nhập');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu bản nháp thành công!'),
            backgroundColor: DesignColors.success,
          ),
        );""",
            "AppToast.success(context, 'Đã lưu bản nháp thành công!');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: DesignColors.error,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Đóng',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );""",
            "AppToast.error(context, errorMessage);"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ngày hết hạn phải là thời điểm trong tương lai'),
              backgroundColor: DesignColors.warning,
            ),
          );""",
            "AppToast.warning(context, 'Ngày hết hạn phải là thời điểm trong tương lai');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xuất bản bài tập thành công!'),
            backgroundColor: DesignColors.success,
          ),
        );""",
            "AppToast.success(context, 'Đã xuất bản bài tập thành công!');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
            'Câu hỏi đã sửa. Học sinh đã nộp có thể bị ảnh hưởng.'),
        action: SnackBarAction(
          label: 'Chấm lại tất cả',
          onPressed: _batchRegrade,
        ),
        duration: const Duration(seconds: 8),
      ));""",
            "AppToast.warning(context, 'Câu hỏi đã sửa. Học sinh đã nộp có thể bị ảnh hưởng.');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi khi lưu: $e'),
        backgroundColor: DesignColors.error,
      ));""",
            "AppToast.error(context, 'Lỗi khi lưu: $e');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Đã chấm lại $count bài nộp.'),
        backgroundColor: DesignColors.success,
      ));""",
            "AppToast.success(context, 'Đã chấm lại $count bài nộp.');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi khi chấm lại: $e'),
        backgroundColor: DesignColors.error,
      ));""",
            "AppToast.error(context, 'Lỗi khi chấm lại: $e');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi khi nhân bản: $e'),
        backgroundColor: DesignColors.error,
      ));""",
            "AppToast.error(context, 'Lỗi khi nhân bản: $e');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: DesignColors.error,
            content: Text(
              '${messages.join(' • ')}. Vui lòng kiểm tra lại trước khi phát hành.',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.white,
              ),
            ),
            duration: const Duration(seconds: 4),
          ),
        );""",
            "AppToast.error(context, '${messages.join(\\' • \\')}. Vui lòng kiểm tra lại trước khi phát hành.');"
        ),
        (
            """ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải bài tập: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );""",
            "AppToast.error(context, 'Lỗi khi tải bài tập: ${e.toString()}');"
        )
    ]

    for old_str, new_str in replacements:
        content = content.replace(old_str, new_str)
        
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print("Done replace literal blocks.")

if __name__ == '__main__':
    replace_snackbars('lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart')
