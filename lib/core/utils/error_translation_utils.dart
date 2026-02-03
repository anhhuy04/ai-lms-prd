/// Utility class để translate error messages sang tiếng Việt.
/// Tái sử dụng cho tất cả repository implementations để đảm bảo consistency.
class ErrorTranslationUtils {
  ErrorTranslationUtils._();

  /// Translate error messages sang tiếng Việt.
  ///
  /// [error] - Error object cần translate
  /// [operation] - Tên operation đang thực hiện (ví dụ: 'Tạo lớp học', 'Xóa câu hỏi')
  /// 
  /// Returns Exception với message tiếng Việt
  static Exception translateError(dynamic error, String operation) {
    final errorMessage = error.toString();

    // Kiểm tra các lỗi phổ biến
    if (errorMessage.contains('duplicate') ||
        errorMessage.contains('already exists') ||
        errorMessage.contains('23505')) {
      return Exception('$operation: Dữ liệu đã tồn tại trong hệ thống');
    }

    if (errorMessage.contains('not found') ||
        errorMessage.contains('PGRST116') ||
        errorMessage.contains('does not exist')) {
      return Exception('$operation: Không tìm thấy dữ liệu');
    }

    if (errorMessage.contains('permission') ||
        errorMessage.contains('42501') ||
        errorMessage.contains('unauthorized')) {
      return Exception('$operation: Bạn không có quyền thực hiện thao tác này');
    }

    if (errorMessage.contains('foreign key') ||
        errorMessage.contains('23503')) {
      return Exception('$operation: Dữ liệu liên quan không tồn tại');
    }

    if (errorMessage.contains('null') || errorMessage.contains('23502')) {
      return Exception('$operation: Thiếu dữ liệu bắt buộc');
    }

    // Nếu error đã là Exception với message tiếng Việt, giữ nguyên
    if (error is Exception) {
      return error;
    }

    // Mặc định: trả về message gốc với prefix
    return Exception(
      '$operation: ${errorMessage.replaceAll('Exception: ', '')}',
    );
  }
}
