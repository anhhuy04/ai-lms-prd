// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment.freezed.dart';
part 'assignment.g.dart';

/// Entity cho bảng `assignments`.
@freezed
class Assignment with _$Assignment {
  const factory Assignment({
    required String id,
    @JsonKey(name: 'class_id') String? classId,
    @JsonKey(name: 'teacher_id') required String teacherId,
    required String title,
    String? description,
    @JsonKey(name: 'is_published') @Default(false) bool isPublished,
    @JsonKey(name: 'published_at') DateTime? publishedAt,
    @JsonKey(name: 'due_at') DateTime? dueAt,
    @JsonKey(name: 'available_from') DateTime? availableFrom,
    @JsonKey(name: 'time_limit_minutes') int? timeLimitMinutes,
    @JsonKey(name: 'allow_late') @Default(true) bool allowLate,
    @JsonKey(name: 'total_points') double? totalPoints,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Assignment;

  factory Assignment.fromJson(Map<String, dynamic> json) =>
      _$AssignmentFromJson(json);
}

