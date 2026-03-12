import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// DataSource cho grade_overrides - lưu audit trail khi GV chỉnh sửa điểm.
class GradeOverrideDataSource {
  SupabaseClient get _client => SupabaseService.client;

  /// Tạo một grade override mới (khi GV sửa điểm AI).
  Future<Map<String, dynamic>> createGradeOverride({
    required String submissionAnswerId,
    required String overriddenBy,
    required double oldScore,
    required double newScore,
    String? reason,
  }) async {
    final result = await _client.from('grade_overrides').insert({
      'submission_answer_id': submissionAnswerId,
      'overridden_by': overriddenBy,
      'old_score': oldScore,
      'new_score': newScore,
      'reason': reason,
    }).select().single();

    return Map<String, dynamic>.from(result);
  }

  /// Lấy lịch sử override của một câu trả lời.
  Future<List<Map<String, dynamic>>> getOverrideHistory(
    String submissionAnswerId,
  ) async {
    final result = await _client
        .from('grade_overrides')
        .select('''
          *,
          profiles!grade_overrides_overridden_by_fkey(
            id,
            full_name
          )
        ''')
        .eq('submission_answer_id', submissionAnswerId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  /// Lấy tất cả overrides của một distribution (cho báo cáo).
  Future<List<Map<String, dynamic>>> getOverridesByDistribution(
    String distributionId,
  ) async {
    final result = await _client
        .from('grade_overrides')
        .select('''
          *,
          submission_answers(
            id,
            session_id(
              assignment_distribution_id
            ),
            assignment_questions(
              question_text
            )
          ),
          profiles!grade_overrides_overridden_by_fkey(
            id,
            full_name
          )
        ''')
        .eq(
          'submission_answers.session_id.assignment_distribution_id',
          distributionId,
        )
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }
}
