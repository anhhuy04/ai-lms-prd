import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
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
        .select('*')
        .eq('submission_answer_id', submissionAnswerId)
        .order('created_at', ascending: false);

    final overrides = List<Map<String, dynamic>>.from(result);
    return await _populateProfiles(overrides);
  }

  /// Lấy tất cả overrides của một distribution (cho báo cáo).
  Future<List<Map<String, dynamic>>> getOverridesByDistribution(
    String distributionId,
  ) async {
    try {
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
                id,
                question_id(
                  content
                ),
                custom_content
              )
            )
          ''')
          .eq(
            'submission_answers.session_id.assignment_distribution_id',
            distributionId,
          )
          .order('created_at', ascending: false);

      final overrides = List<Map<String, dynamic>>.from(result);
      return await _populateProfiles(overrides);
    } catch (e, st) {
      AppLogger.error(
        '[GradeOverrideDataSource] getOverridesByDistribution error: $e',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _populateProfiles(List<Map<String, dynamic>> overrides) async {
    if (overrides.isEmpty) return overrides;

    final teacherIds = overrides
        .map((o) => o['overridden_by'] as String?)
        .where((id) => id != null)
        .toSet()
        .toList();

    if (teacherIds.isEmpty) return overrides;

    try {
      final profilesResp = await _client
          .from('profiles')
          .select('id, full_name')
          .inFilter('id', teacherIds);

      final profiles = List<Map<String, dynamic>>.from(profilesResp);
      final profileMap = {for (var p in profiles) p['id']: p};

      for (var o in overrides) {
        if (o['overridden_by'] != null) {
          o['profiles'] = profileMap[o['overridden_by']];
        }
      }
    } catch (e) {
      AppLogger.error('[GradeOverrideDataSource] Error fetching profiles: $e');
    }

    return overrides;
  }
}
