/// Date formatting utilities - không cần intl package
class DateUtils {
  DateUtils._();

  /// Format ngày giờ: dd/MM/yyyy HH:mm
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return '${_twoDigits(dateTime.day)}/${_twoDigits(dateTime.month)}/${dateTime.year} ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  /// Format ngày: dd/MM/yyyy
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return '${_twoDigits(dateTime.day)}/${_twoDigits(dateTime.month)}/${dateTime.year}';
  }

  /// Format giờ: HH:mm
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  /// Format tương đối (Vừa xong, 5 phút trước, ...)
  static String formatRelative(DateTime? dateTime) {
    if (dateTime == null) return '-';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return formatDate(dateTime);
    }
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
