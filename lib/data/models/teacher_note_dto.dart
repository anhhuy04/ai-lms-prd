// ignore_for_file: invalid_annotation_target

import 'package:ai_mls/domain/entities/teacher_note.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'teacher_note_dto.freezed.dart';
part 'teacher_note_dto.g.dart';

/// DTO cho bảng `teacher_notes` — map JSON snake_case từ Supabase sang entity.
@freezed
class TeacherNoteDto with _$TeacherNoteDto {
  const TeacherNoteDto._();

  const factory TeacherNoteDto({
    required String id,
    @JsonKey(name: 'teacher_id') required String teacherId,
    @JsonKey(name: 'student_id') required String studentId,
    required String content,
    @JsonKey(name: 'is_private') @Default(true) bool isPrivate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _TeacherNoteDto;

  factory TeacherNoteDto.fromJson(Map<String, dynamic> json) =>
      _$TeacherNoteDtoFromJson(json);

  /// Chuyển DTO sang domain entity.
  TeacherNote toEntity() => TeacherNote(
        id: id,
        teacherId: teacherId,
        studentId: studentId,
        content: content,
        isPrivate: isPrivate,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// JSON dùng cho INSERT — teacher_id được set server-side qua auth.uid().
  /// id/created_at/updated_at do DB tự sinh.
  Map<String, dynamic> toInsertJson() => {
        'content': content,
        'student_id': studentId,
        'is_private': isPrivate,
      };
}
