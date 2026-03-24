import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
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
        .eq('assignment_distribution_id', distributionId)
        .eq('student_id', studentId)
        .maybeSingle();

    if (existingRes != null) {
      return Map<String, dynamic>.from(existingRes);
    }

    // Tạo mới submission draft
    final now = DateTime.now().toUtc().toIso8601String();
    final newSubmission = await _client.from('submissions').insert({
      'assignment_distribution_id': distributionId,
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
        .eq('assignment_distribution_id', distributionId)
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
        'assignment_distribution_id': distributionId,
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
        .eq('assignment_distribution_id', distributionId)
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
  /// Join work_sessions để lấy status (vì submissions table không có status column).
  Future<List<Map<String, dynamic>>> getSubmissionsByDistribution(
    String distributionId,
  ) async {
    final result = await _client
        .from('submissions')
        .select('''
          *,
          assignment_distributions(
            due_at
          ),
          profiles!submissions_student_id_fkey(
            id,
            full_name,
            avatar_url
          ),
          work_sessions(
            id,
            status,
            submitted_at
          )
        ''')
        .eq('assignment_distribution_id', distributionId)
        .order('submitted_at', ascending: false);

    final submissions = List<Map<String, dynamic>>.from(result);

    // Map work_sessions.status → status field for filter logic
    for (final sub in submissions) {
      final workSessions = sub['work_sessions'];
      if (workSessions is List && workSessions.isNotEmpty) {
        sub['status'] = (workSessions.first as Map<String, dynamic>)['status'] ?? 'submitted';
      } else {
        sub['status'] = 'submitted';
      }
      
      // Tính is_late dựa vào due_at của bài tập
      final dist = sub['assignment_distributions'] as Map<String, dynamic>?;
      final dueAtStr = dist?['due_at'] as String?;
      final submittedAtStr = sub['submitted_at'] as String?;
      
      if (dueAtStr != null && submittedAtStr != null) {
        final dueAt = DateTime.parse(dueAtStr);
        final submittedAt = DateTime.parse(submittedAtStr);
        sub['is_late'] = submittedAt.isAfter(dueAt);
      } else {
        sub['is_late'] = false; // Mặc định không muộn nếu không có hạn
      }
    }

    return submissions;
  }

  /// Lấy chi tiết một submission.
  /// submissions → work_sessions → submission_answers (2-level FK)
  /// Tách thành 2 query vì PostgREST không hỗ trợ join 2 cấp.
  Future<Map<String, dynamic>> getSubmissionById(String submissionId) async {
    // Query 1: submission + related data
    final result = await _client
        .from('submissions')
        .select('''
          *,
          assignment_distributions(
            *,
            assignments(*),
            classes(name)
          ),
          profiles!submissions_student_id_fkey(
            id,
            full_name,
            avatar_url
          ),
          work_sessions(
            id,
            status,
            submitted_at
          )
        ''')
        .eq('id', submissionId)
        .maybeSingle();

    if (result == null) {
      throw Exception('Submission not found: $submissionId');
    }

    final submission = Map<String, dynamic>.from(result);

    // Query 2: submission_answers qua work_sessions
    final sessionId = submission['session_id'] as String?;
    if (sessionId != null) {
      final answersRes = await _client
          .from('submission_answers')
          .select('''
            *,
            assignment_questions(
              id,
              question_id(
                type
              ),
              points,
              custom_content
            )
          ''')
          .eq('session_id', sessionId)
          .order('created_at', ascending: true);
      submission['submission_answers'] = answersRes;
    } else {
      submission['submission_answers'] = <Map<String, dynamic>>[];
    }

    return submission;
  }

  /// Cập nhật điểm và phản hồi (teacher grading).
  Future<void> updateSubmissionGrade(
    String submissionId, {
    required double score,
    String? feedback,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await _client.from('submissions').update({
      'total_score': score,
      'feedback': feedback,
      'status': 'graded',
      'updated_at': now,
    }).eq('id', submissionId);
  }

  /// Lấy danh sách câu trả lời của một submission (cho teacher grading).
  Future<List<Map<String, dynamic>>> getSubmissionAnswers(
    String submissionId,
  ) async {
    // Lấy session_id từ submission trước
    final submission = await _client
        .from('submissions')
        .select('session_id')
        .eq('id', submissionId)
        .single();

    final sessionId = submission['session_id'] as String?;

    if (sessionId == null) {
      AppLogger.warning(
        'getSubmissionAnswers: sessionId is null for submissionId=$submissionId',
      );
      return [];
    }

    final result = await _client
        .from('submission_answers')
        .select('''
          *,
          assignment_questions(
            id,
            question_id(
              type
            ),
            points,
            custom_content
          )
        ''')
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(result);
  }

  /// Cập nhật điểm cho một câu trả lời (final_score + teacher_feedback).
  Future<void> updateSubmissionAnswerGrade({
    required String answerId,
    required double finalScore,
    String? teacherFeedback,
    required String teacherId,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await _client.from('submission_answers').update({
      'final_score': finalScore,
      'teacher_feedback': teacherFeedback != null
          ? {'text': teacherFeedback}
          : null,
      'graded_by': teacherId,
      'graded_at': now,
      'updated_at': now,
    }).eq('id', answerId);
  }

  /// Chấp nhận điểm AI (dùng ai_score làm final_score).
  Future<void> approveAiScore(String answerId) async {
    final now = DateTime.now().toUtc().toIso8601String();

    // Lấy ai_score trước
    final answer = await _client
        .from('submission_answers')
        .select('ai_score')
        .eq('id', answerId)
        .single();

    await _client.from('submission_answers').update({
      'final_score': answer['ai_score'],
      'updated_at': now,
    }).eq('id', answerId);
  }

  /// Lấy chi tiết distribution để tính max_score.
  Future<Map<String, dynamic>?> getDistributionDetail(
    String distributionId,
  ) async {
    final result = await _client
        .from('assignment_distributions')
        .select('''
          *,
          assignments(
            id,
            title,
            total_points
          )
        ''')
        .eq('id', distributionId)
        .maybeSingle();

    return result != null ? Map<String, dynamic>.from(result) : null;
  }

  /// Publish grades - cập nhật work_sessions status thành 'graded'.
  Future<void> publishGrades(String submissionId) async {
    final now = DateTime.now().toUtc().toIso8601String();

    // Lấy session_id từ submission
    final submission = await _client
        .from('submissions')
        .select('session_id')
        .eq('id', submissionId)
        .single();

    if (submission['session_id'] != null) {
      await _client.from('work_sessions').update({
        'status': 'graded',
        'updated_at': now,
      }).eq('id', submission['session_id']);
    }

    // Cập nhật submission status
    await _client.from('submissions').update({
      'status': 'graded',
      'updated_at': now,
    }).eq('id', submissionId);
  }

  /// Publish grades cho toàn bộ distribution.
  Future<void> publishAllGrades(String distributionId) async {
    final now = DateTime.now().toUtc().toIso8601String();

    // Lấy tất cả submissions của distribution
    final submissions = await _client
        .from('submissions')
        .select('id, session_id')
        .eq('assignment_distribution_id', distributionId)
        .eq('status', 'submitted');

    for (final submission in submissions) {
      // Update work_sessions
      if (submission['session_id'] != null) {
        await _client.from('work_sessions').update({
          'status': 'graded',
          'updated_at': now,
        }).eq('id', submission['session_id']);
      }

      // Update submissions
      await _client.from('submissions').update({
        'status': 'graded',
        'updated_at': now,
      }).eq('id', submission['id']);
    }
  }
}
