/// File ví dụ cách sử dụng hệ thống dialog
/// Chứa các ví dụ thực tế cho từng loại dialog
library;

import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:flutter/material.dart';

import 'error_dialog.dart';
import 'flexible_dialog.dart';
import 'success_dialog.dart';
import 'warning_dialog.dart';

class DialogExamples {
  /// Ví dụ 1: Dialog thành công duyệt học sinh (theo thiết kế HTML gốc)
  static void showStudentApprovalSuccess(BuildContext context) {
    SuccessDialog.showWithDetails(
      context: context,
      title: 'Đã duyệt thành công',
      message: 'Học sinh Nguyễn Văn A đã được thêm vào danh sách lớp học.',
      onViewDetails: () {
        // Đi đến màn hình chi tiết học sinh
        Navigator.pop(context);
        // TODO: Navigate to student profile
      },
    );
  }

  /// Ví dụ 2: Dialog cảnh báo xóa bài tập
  static void showDeleteAssignmentWarning(BuildContext context) {
    WarningDialog.showDeleteConfirmation(
      context: context,
      itemName: 'Bài tập Toán - Chương 1',
      onDelete: () {
        // Thực hiện xóa bài tập
        AppLogger.debug('Đang xóa bài tập...');
      },
    );
  }

  /// Ví dụ 3: Dialog lỗi kết nối mạng
  static void showNetworkErrorDialog(BuildContext context) {
    ErrorDialog.showNetworkError(
      context: context,
      onRetry: () {
        // Thử kết nối lại
        AppLogger.debug('Đang thử kết nối lại...');
      },
    );
  }

  /// Ví dụ 4: Dialog xác nhận không lưu thay đổi
  /// Lưu ý: Method này đã được cập nhật, không còn callback onDiscard/onSave
  /// Thay vào đó, method trả về bool? để caller xử lý
  static Future<void> showUnsavedChangesDialog(BuildContext context) async {
    final result = await WarningDialog.showUnsavedChanges(context: context);
    if (!context.mounted) return;

    if (result == true) {
      // User chọn "Không lưu" → bỏ qua thay đổi và quay lại
      Navigator.pop(context);
    } else if (result == false) {
      // User chọn "Lưu thay đổi" → lưu trước khi rời khỏi
      AppLogger.debug('Đang lưu thay đổi...');
      // TODO: Gọi method lưu thay đổi ở đây
      // Sau khi lưu xong, có thể pop nếu cần
    }
    // result == null: User đóng dialog → không làm gì
  }

  /// Ví dụ 5: Dialog lỗi xác thực
  static void showAuthenticationErrorDialog(BuildContext context) {
    ErrorDialog.showAuthenticationError(
      context: context,
      message: 'Mật khẩu phải có ít nhất 8 ký tự và chứa cả chữ và số.',
    );
  }

  /// Ví dụ 6: Dialog thành công đơn giản
  static void showSimpleSuccessDialog(BuildContext context) {
    SuccessDialog.showSimple(
      context: context,
      title: 'Thành công',
      message: 'Dữ liệu đã được lưu thành công.',
    );
  }

  /// Ví dụ 7: Dialog lỗi với mã lỗi
  static void showErrorWithCodeDialog(BuildContext context) {
    ErrorDialog.showErrorWithCode(
      context: context,
      errorCode: 'AUTH-403',
      errorMessage: 'Bạn không có quyền thực hiện hành động này.',
      onDetails: () {
        // Hiển thị chi tiết lỗi
        AppLogger.debug('Hiển thị chi tiết lỗi AUTH-403');
      },
    );
  }

  /// Ví dụ 8: Dialog cảnh báo tùy chỉnh
  static void showCustomWarningDialog(BuildContext context) {
    WarningDialog.showConfirmation(
      context: context,
      title: 'Cảnh báo',
      message: 'Bạn chưa hoàn thành bài tập. Bạn có muốn nộp bài không?',
      confirmText: 'Nộp bài',
      cancelText: 'Tiếp tục làm',
      isDestructive: false,
    );
  }

  /// Ví dụ 9: Dialog linh hoạt với thiết kế tùy chỉnh
  static void showCustomFlexibleDialog(BuildContext context) {
    FlexibleDialog.show(
      context: context,
      title: 'Thông báo hệ thống',
      message:
          'Có bản cập nhật mới cho ứng dụng. Bạn có muốn cập nhật ngay bây giờ?',
      type: DialogType.info,
      actions: [
        DialogAction(
          text: 'Cập nhật ngay',
          onPressed: () {
            // Thực hiện cập nhật
            AppLogger.debug('Đang cập nhật ứng dụng...');
          },
          type: DialogActionType.primary,
        ),
        DialogAction(
          text: 'Nhắc sau',
          onPressed: () => Navigator.pop(context),
          type: DialogActionType.secondary,
        ),
        DialogAction(
          text: 'Bỏ qua',
          onPressed: () => Navigator.pop(context),
          type: DialogActionType.tertiary,
        ),
      ],
    );
  }

  /// Ví dụ 10: Dialog lỗi với tùy chọn thử lại
  static void showErrorWithRetryDialog(BuildContext context) {
    ErrorDialog.showWithRetry(
      context: context,
      title: 'Lỗi tải dữ liệu',
      message: 'Không thể tải danh sách lớp học. Vui lòng thử lại.',
      onRetry: () {
        // Thử tải lại dữ liệu
        AppLogger.debug('Đang tải lại dữ liệu...');
      },
    );
  }

  /// Ví dụ 11: Dialog xác nhận thêm lớp học mới
  static void showAddClassConfirmationDialog(BuildContext context) {
    WarningDialog.showConfirmation(
      context: context,
      title: 'Xác nhận tạo lớp học',
      message: 'Bạn có chắc chắn muốn tạo lớp học mới với thông tin đã nhập?',
      confirmText: 'Tạo lớp',
      cancelText: 'Hủy',
      isDestructive: false,
    ).then((confirmed) async {
      if (confirmed == true) {
        try {
          // Giả lập gọi API tạo lớp
          await Future.delayed(const Duration(seconds: 1));

          // Sau async gap, đảm bảo context vẫn còn mounted
          if (!context.mounted) return;

          // Nếu thành công, hiển thị dialog thành công
          showClassCreationSuccessDialog(context);
        } catch (e) {
          if (!context.mounted) return;
          // Nếu thất bại, hiển thị dialog lỗi
          showClassCreationFailureDialog(context);
        }
      }
    });
  }

  /// Ví dụ 12: Dialog thành công khi tạo lớp học thành công
  static void showClassCreationSuccessDialog(BuildContext context) {
    SuccessDialog.showWithDetails(
      context: context,
      title: 'Tạo lớp học thành công',
      message: 'Lớp học "Lớp 10A1 - Toán học" đã được tạo thành công.',
      onViewDetails: () {
        Navigator.pop(context);
        // TODO: Điều hướng đến màn hình chi tiết lớp học
        AppLogger.debug('Điều hướng đến chi tiết lớp học');
      },
    );
  }

  /// Ví dụ 13: Dialog lỗi khi tạo lớp học thất bại
  static void showClassCreationFailureDialog(BuildContext context) {
    ErrorDialog.showWithRetry(
      context: context,
      title: 'Tạo lớp học thất bại',
      message:
          'Không thể tạo lớp học. Vui lòng kiểm tra kết nối mạng và thử lại.',
      onRetry: () {
        // Thử tạo lại lớp học
        AppLogger.debug('Đang thử tạo lại lớp học...');
        // TODO: Gọi lại hàm tạo lớp
      },
    );
  }

  /// Ví dụ 14: Dialog xác nhận thêm nhiều học sinh vào lớp
  static void showAddMultipleStudentsConfirmationDialog(
    BuildContext context,
    int studentCount,
  ) {
    WarningDialog.showConfirmation(
      context: context,
      title: 'Xác nhận thêm học sinh',
      message: 'Bạn có chắc chắn muốn thêm $studentCount học sinh vào lớp này?',
      confirmText: 'Thêm học sinh',
      cancelText: 'Hủy',
      isDestructive: false,
    ).then((confirmed) async {
      if (confirmed == true) {
        try {
          // Giả lập quá trình thêm học sinh
          await Future.delayed(const Duration(seconds: 2));

          if (!context.mounted) return;

          // Hiển thị kết quả
          SuccessDialog.showSimple(
            context: context,
            title: 'Thêm học sinh thành công',
            message: 'Đã thêm $studentCount học sinh vào lớp thành công.',
          );
        } catch (e) {
          if (!context.mounted) return;
          ErrorDialog.showSimple(
            context: context,
            title: 'Thêm học sinh thất bại',
            message: 'Không thể thêm học sinh. Vui lòng thử lại sau.',
          );
        }
      }
    });
  }
}

/// Widget demo để test tất cả các loại dialog
class DialogDemoScreen extends StatelessWidget {
  const DialogDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dialog System Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDemoButton(
              context,
              '1. Success Dialog - Duyệt học sinh',
              DialogExamples.showStudentApprovalSuccess,
            ),
            const SizedBox(height: 8),
            _buildDemoButton(
              context,
              '2. Warning Dialog - Xóa bài tập',
              DialogExamples.showDeleteAssignmentWarning,
            ),
            const SizedBox(height: 8),
            _buildDemoButton(
              context,
              '3. Error Dialog - Lỗi mạng',
              DialogExamples.showNetworkErrorDialog,
            ),
            const SizedBox(height: 8),
            _buildDemoButton(
              context,
              '4. Warning Dialog - Không lưu thay đổi',
              DialogExamples.showUnsavedChangesDialog,
            ),
            const SizedBox(height: 8),
            _buildDemoButton(
              context,
              '5. Error Dialog - Lỗi xác thực',
              DialogExamples.showAuthenticationErrorDialog,
            ),
            const SizedBox(height: 8),
            _buildDemoButton(
              context,
              '6. Success Dialog - Đơn giản',
              DialogExamples.showSimpleSuccessDialog,
            ),
            const SizedBox(height: 8),
            _buildDemoButton(
              context,
              '7. Error Dialog - Với mã lỗi',
              DialogExamples.showErrorWithCodeDialog,
            ),
            const SizedBox(height: 8),
            _buildDemoButton(
              context,
              '8. Warning Dialog - Tùy chỉnh',
              DialogExamples.showCustomWarningDialog,
            ),
            const SizedBox(height: 8),
            _buildDemoButton(
              context,
              '9. Flexible Dialog - Tùy chỉnh',
              DialogExamples.showCustomFlexibleDialog,
            ),
            const SizedBox(height: 8),
            _buildDemoButton(
              context,
              '10. Error Dialog - Với thử lại',
              DialogExamples.showErrorWithRetryDialog,
            ),
            const SizedBox(height: 8),
            _buildDemoButton(
              context,
              '11. Warning Dialog - Tạo lớp học',
              DialogExamples.showAddClassConfirmationDialog,
            ),
            const SizedBox(height: 8),
            _buildDemoButton(
              context,
              '12. Success Dialog - Tạo lớp thành công',
              DialogExamples.showClassCreationSuccessDialog,
            ),
            const SizedBox(height: 8),
            _buildDemoButton(
              context,
              '13. Error Dialog - Tạo lớp thất bại',
              DialogExamples.showClassCreationFailureDialog,
            ),
            const SizedBox(height: 8),
            _buildDemoButton(
              context,
              '14. Warning Dialog - Thêm nhiều học sinh',
              (ctx) => DialogExamples.showAddMultipleStudentsConfirmationDialog(
                ctx,
                5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoButton(
    BuildContext context,
    String title,
    Function(BuildContext) onPressed,
  ) {
    return ElevatedButton(
      onPressed: () => onPressed(context),
      child: Text(title),
    );
  }
}
