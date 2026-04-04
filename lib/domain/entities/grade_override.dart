// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'grade_override.freezed.dart';
part 'grade_override.g.dart';

/// Entity cho bảng `grade_overrides` - lưu trữ lịch sử ghi đè điểm của giáo viên.
/// Đây là audit trail để theo dõi mọi thay đổi điểm.
@freezed
class GradeOverride with _$GradeOverride {
  const factory GradeOverride({
    required String id,

    /// ID của câu trả lời được ghi đè (submission_answers.id)
    @JsonKey(name: 'submission_answer_id') required String submissionAnswerId,

    /// ID của giáo viên thực hiện ghi đè
    @JsonKey(name: 'overridden_by') required String overriddenBy,

    /// Tên của giáo viên (từ join query)
    @JsonKey(name: 'overridden_by_name') String? overriddenByName,

    /// Điểm trước khi ghi đè
    @JsonKey(name: 'old_score') required double oldScore,

    /// Điểm sau khi ghi đè
    @JsonKey(name: 'new_score') required double newScore,

    /// Lý do ghi đè (tùy chọn)
    String? reason,

    /// Thời điểm tạo bản ghi ghi đè
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _GradeOverride;

  factory GradeOverride.fromJson(Map<String, dynamic> json) =>
      _$GradeOverrideFromJson(json);
}
