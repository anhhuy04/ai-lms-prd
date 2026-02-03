/// Utility class để format dates cho assignment cards
class AssignmentDateFormatter {
  /// Format thời gian cập nhật
  static String formatLastUpdated(DateTime? dateTime) {
    if (dateTime == null) return 'Chưa cập nhật';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  /// Format ngày hết hạn
  static String formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.inDays == 0) {
      return 'Hết hạn hôm nay';
    } else if (difference.inDays == 1) {
      return 'Hết hạn ngày mai';
    } else if (difference.inDays > 0) {
      return 'Hết hạn sau ${difference.inDays} ngày';
    } else {
      return 'Đã hết hạn';
    }
  }
}
