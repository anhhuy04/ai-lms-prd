import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// DataSource cho submissions - các thao tác với bảng submissions.
class SubmissionDataSource {
  SupabaseClient get _client => SupabaseService.client;

  /// Lấy hoặc tạo submission draft cho 1 student + distribution.
  Future<Map<String, dynamic>?> getOrCreateSubmission(
    String distributionId,
    String studentId,
  ) async {
    // Kiểm tra đã có submission chưa
    final existingRes = await _client
        .from('submissions')
        .select()
        .eq('distribution_id', distributionId)
        .eq('student_id', studentId)
        .maybeSingle();

    if (existingRes != null) {
      return Map<String, dynamic>.from(existingRes);
    }

    // Tạo mới submission draft
    final now = DateTime.now().toUtc().toIso8601String();
    final newSubmission = await _client.from('submissions').insert({
      'distribution_id': distributionId,
      'student_id': studentId,
      'status': 'draft',
      'answers': {},
      'uploaded_files': [],
      'created_at': now,
      'updated_at': now,
    }).select().single();

    return Map<String, dynamic>.from(newSubmission);
  }

  /// Lưu bản nháp submission.
  Future<void> saveDraft(
    String distributionId,
    String studentId,
    Map<String, dynamic> answers,
    List<String> uploadedFiles,
  ) async {
    // Tìm submission hiện có
    final existing = await _client
        .from('submissions')
        .select()
        .eq('distribution_id', distributionId)
        .eq('student_id', studentId)
        .maybeSingle();

    if (existing != null) {
      // Update
      await _client.from('submissions').update({
        'answers': answers,
        'uploaded_files': uploadedFiles,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', existing['id']);
    } else {
      // Insert mới
      final now = DateTime.now().toUtc().toIso8601String();
      await _client.from('submissions').insert({
        'distribution_id': distributionId,
        'student_id': studentId,
        'status': 'draft',
        'answers': answers,
        'uploaded_files': uploadedFiles,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  /// Nộp bài - cập nhật status và submitted_at.
  Future<Map<String, dynamic>> submitAssignment(
    String distributionId,
    String studentId,
  ) async {
    final now = DateTime.now().toUtc().toIso8601String();

    // Update submission status
    final result = await _client
        .from('submissions')
        .update({
          'status': 'submitted',
          'submitted_at': now,
          'updated_at': now,
        })
        .eq('distribution_id', distributionId)
        .eq('student_id', studentId)
        .select()
        .single();

    return Map<String, dynamic>.from(result);
  }

  /// Lấy lịch sử nộp bài của student.
  Future<List<Map<String, dynamic>>> getStudentSubmissionHistory(
    String studentId,
  ) async {
    final result = await _client
        .from('submissions')
        .select('''
          *,
          assignment_distributions(
            *,
            assignments(*)
          )
        ''')
        .eq('student_id', studentId)
        .order('submitted_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  /// Lấy danh sách submissions cho 1 distribution (teacher view).
  Future<List<Map<String, dynamic>>> getSubmissionsByDistribution(
    String distributionId,
  ) async {
    final result = await _client
        .from('submissions')
        .select('''
          *,
          profiles!submissions_student_id_fkey(
            id,
            full_name,
            avatar_url
          )
        ''')
        .eq('distribution_id', distributionId)
        .order('submitted_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  /// Lấy chi tiết một submission.
  Future<Map<String, dynamic>> getSubmissionById(String submissionId) async {
    final result = await _client
        .from('submissions')
        .select('''
          *,
          assignment_distributions(
            *,
            assignments(*)
          ),
          profiles!submissions_student_id_fkey(
            id,
            full_name,
            avatar_url
          )
        ''')
        .eq('id', submissionId)
        .single();

    return Map<String, dynamic>.from(result);
  }

  /// Cập nhật điểm và phản hồi (teacher grading).
  Future<void> updateSubmissionGrade(
    String submissionId, {
    required double score,
    String? feedback,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await _client.from('submissions').update({
      'score': score,
      'feedback': feedback,
      'status': 'graded',
      'graded_at': now,
      'updated_at': now,
    }).eq('id', submissionId);
  }
}
