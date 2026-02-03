/// Trạng thái tham gia lớp học của học sinh
enum StudentClassMemberStatus {
  /// Đã được duyệt và vào lớp
  approved('approved'),

  /// Đang chờ giáo viên duyệt
  pending('pending'),

  /// Đã bị từ chối (nếu có trong tương lai)
  rejected('rejected'),

  /// Đã rời lớp (nếu có trong tương lai)
  left('left');

  const StudentClassMemberStatus(this.value);

  /// Giá trị string trong database
  final String value;

  /// Chuyển đổi từ string sang enum
  /// Trả về null nếu không khớp với giá trị nào
  static StudentClassMemberStatus? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final status in StudentClassMemberStatus.values) {
      if (status.value == value) {
        return status;
      }
    }
    return null;
  }

  /// Chuyển đổi từ enum sang string (để lưu vào DB)
  String toJson() => value;
}
