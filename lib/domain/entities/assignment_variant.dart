// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment_variant.freezed.dart';
part 'assignment_variant.g.dart';

/// Entity cho bảng `assignment_variants`.
@freezed
class AssignmentVariant with _$AssignmentVariant {
  const factory AssignmentVariant({
    required String id,
    @JsonKey(name: 'assignment_id') required String assignmentId,
    @JsonKey(name: 'variant_type') required String variantType,
    @JsonKey(name: 'student_id') String? studentId,
    @JsonKey(name: 'group_id') String? groupId,
    @JsonKey(name: 'due_at_override') DateTime? dueAtOverride,
    @JsonKey(name: 'custom_questions') Map<String, dynamic>? customQuestions,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _AssignmentVariant;

  factory AssignmentVariant.fromJson(Map<String, dynamic> json) =>
      _$AssignmentVariantFromJson(json);
}

