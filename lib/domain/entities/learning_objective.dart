// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'learning_objective.freezed.dart';
part 'learning_objective.g.dart';

/// Entity cho bảng `learning_objectives`.
@freezed
class LearningObjective with _$LearningObjective {
  const factory LearningObjective({
    required String id,
    @JsonKey(name: 'subject_code') required String subjectCode,
    required String code,
    required String description,
    int? difficulty,
    @JsonKey(name: 'parent_id') String? parentId,
    /// JSON metadata (bao gồm AI config nếu có)
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _LearningObjective;

  factory LearningObjective.fromJson(Map<String, dynamic> json) =>
      _$LearningObjectiveFromJson(json);
}

