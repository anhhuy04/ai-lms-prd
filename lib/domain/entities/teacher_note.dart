import 'package:freezed_annotation/freezed_annotation.dart';

part 'teacher_note.freezed.dart';

/// Entity cho bảng `teacher_notes` — ghi chú riêng tư của giáo viên về một học sinh.
/// Giáo viên có thể tạo nhiều ghi chú cho cùng một học sinh.
@freezed
class TeacherNote with _$TeacherNote {
  const factory TeacherNote({
    required String id,

    /// ID của giáo viên sở hữu ghi chú (teacher_notes.teacher_id)
    required String teacherId,

    /// ID của học sinh được ghi chú (teacher_notes.student_id)
    required String studentId,

    /// Nội dung ghi chú
    required String content,

    /// Ghi chú riêng tư (chỉ giáo viên thấy)
    required bool isPrivate,

    /// Thời điểm tạo ghi chú
    required DateTime createdAt,

    /// Thời điểm cập nhật gần nhất
    required DateTime updatedAt,
  }) = _TeacherNote;
}
