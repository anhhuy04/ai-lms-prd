import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/repositories/submission_repository_impl.dart';
import 'package:ai_mls/domain/entities/grade_override.dart';
import 'package:ai_mls/domain/entities/submission.dart';
import 'package:ai_mls/domain/entities/submission_answer.dart';
import 'package:ai_mls/domain/repositories/submission_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'datasource_providers.dart';

part 'teacher_submission_providers.g.dart';

/// Provider cho SubmissionRepository
@riverpod
SubmissionRepository submissionRepository(Ref ref) {
  final datasource = ref.watch(submissionDataSourceProviderProvider);
  return SubmissionRepositoryImpl(datasource);
}

/// Filter options cho submission list
enum SubmissionFilter {
  all('Tất cả'),
  pending('Chưa chấm'),
  graded('Đã chấm'),
  late('Nộp muộn');

  final String label;
  const SubmissionFilter(this.label);
}

/// Item trong submission list cho teacher
class TeacherSubmissionItem {
  final String submissionId;
  final String studentId;
  final String studentName;
  final String? studentAvatarUrl;
  final DateTime submittedAt;
  final bool isLate;
  final double? totalScore;
  final double? maxScore;
  final bool aiGraded;
  final String status;

  const TeacherSubmissionItem({
    required this.submissionId,
    required this.studentId,
    required this.studentName,
    this.studentAvatarUrl,
    required this.submittedAt,
    required this.isLate,
    this.totalScore,
    this.maxScore,
    required this.aiGraded,
    required this.status,
  });
}

/// State cho teacher submission list
class TeacherSubmissionListState {
  final String distributionId;
  final String assignmentTitle;
  final List<TeacherSubmissionItem> submissions;
  final SubmissionFilter filter;
  final bool isLoadingAi;

  const TeacherSubmissionListState({
    required this.distributionId,
    required this.assignmentTitle,
    required this.submissions,
    required this.filter,
    this.isLoadingAi = false,
  });
}

/// Provider lấy danh sách submissions cho teacher
@riverpod
Future<TeacherSubmissionListState> teacherSubmissionList(
  Ref ref, {
  required String distributionId,
  SubmissionFilter filter = SubmissionFilter.all,
}) async {
  final datasource = ref.watch(submissionDataSourceProviderProvider);

  try {
    // Lấy submissions từ database
    final submissions = await datasource.getSubmissionsByDistribution(distributionId);

    // Map sang TeacherSubmissionItem
    final items = submissions.map((s) {
      final profile = s['profiles'] as Map<String, dynamic>?;
      final isLate = s['is_late'] as bool? ?? false;
      final totalScore = s['total_score'] as double?;
      final aiGraded = s['ai_graded'] as bool? ?? false;

      return TeacherSubmissionItem(
        submissionId: s['id'] as String,
        studentId: s['student_id'] as String,
        studentName: profile?['full_name'] as String? ?? 'Học sinh',
        studentAvatarUrl: profile?['avatar_url'] as String?,
        submittedAt: s['submitted_at'] != null
            ? DateTime.parse(s['submitted_at'] as String)
            : DateTime.now(),
        isLate: isLate,
        totalScore: totalScore,
        maxScore: null, // TODO: Lấy từ assignment
        aiGraded: aiGraded,
        status: s['status'] as String? ?? 'submitted',
      );
    }).toList();

    // Apply filter
    // 'pending' = status == 'submitted' (chưa chấm = đã nộp nhưng chưa graded)
    // 'late'    = is_late == true (từ submissions.is_late, set tại thời điểm nộp)
    List<TeacherSubmissionItem> filteredItems;
    switch (filter) {
      case SubmissionFilter.pending:
        filteredItems = items.where((i) => i.status == 'submitted' || i.status == 'ai_processing').toList();
        break;
      case SubmissionFilter.graded:
        filteredItems = items.where((i) => i.status == 'graded').toList();
        break;
      case SubmissionFilter.late:
        filteredItems = items.where((i) => i.isLate).toList();
        break;
      case SubmissionFilter.all:
        filteredItems = items;
    }
    AppLogger.info(
      '[SUBMISSION_FILTER] filter=$filter, total=${items.length}, filtered=${filteredItems.length}',
    );

    // Kiểm tra có submission nào đang chờ AI không
    final isLoadingAi = items.any((i) => (i.status == 'submitted' || i.status == 'ai_processing') && !i.aiGraded);

    return TeacherSubmissionListState(
      distributionId: distributionId,
      assignmentTitle: '', // TODO: Lấy từ assignment
      submissions: filteredItems,
      filter: filter,
      isLoadingAi: isLoadingAi,
    );
  } catch (e, stackTrace) {
    AppLogger.error(
      '🔴 [TEACHER_SUBMISSION_LIST] Error loading submissions: $e',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

/// Provider lọc submissions
@riverpod
class SubmissionFilterNotifier extends _$SubmissionFilterNotifier {
  @override
  SubmissionFilter build() => SubmissionFilter.all;

  void setFilter(SubmissionFilter filter) {
    state = filter;
  }
}

/// Provider lấy grade override history cho audit trail
@riverpod
Future<List<GradeOverride>> gradeOverrideHistory(
  Ref ref, {
  required String submissionAnswerId,
}) async {
  final datasource = ref.watch(gradeOverrideDataSourceProviderProvider);
  try {
    final rows = await datasource.getOverrideHistory(submissionAnswerId);
    return rows.map((row) {
      final profile = row['profiles'] as Map<String, dynamic>?;
      return GradeOverride(
        id: row['id'] as String,
        submissionAnswerId: row['submission_answer_id'] as String,
        overriddenBy: row['overridden_by'] as String,
        overriddenByName: profile?['full_name'] as String?,
        oldScore: (row['old_score'] as num).toDouble(),
        newScore: (row['new_score'] as num).toDouble(),
        reason: row['reason'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
    }).toList();
  } catch (e, stackTrace) {
    AppLogger.error(
      '🔴 [GRADE_OVERRIDE_HISTORY] Error loading history: $e',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

/// Provider chi tiết một submission cho teacher
@riverpod
Future<Submission> teacherSubmissionDetail(
  Ref ref, {
  required String submissionId,
}) async {
  final datasource = ref.watch(submissionDataSourceProviderProvider);

  try {
    final row = await datasource.getSubmissionById(submissionId);
    return Submission.fromJson(row);
  } catch (e, stackTrace) {
    AppLogger.error(
      '🔴 [TEACHER_SUBMISSION_DETAIL] Error loading submission: $e',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

/// Provider lấy danh sách câu trả lời của một submission (cho teacher grading)
@riverpod
Future<List<SubmissionAnswer>> submissionAnswers(
  Ref ref, {
  required String submissionId,
}) async {
  final datasource = ref.watch(submissionDataSourceProviderProvider);

  try {
    final rows = await datasource.getSubmissionAnswers(submissionId);
    return rows.map((row) {
      final aq = row['assignment_questions'] as Map<String, dynamic>?;
      final question = aq?['question_id'] as Map<String, dynamic>?;
      return SubmissionAnswer(
        id: row['id'] as String,
        sessionId: row['session_id'] as String,
        assignmentQuestionId: aq?['id'] as String? ?? row['assignment_question_id'] as String,
        answer: row['answer'] as Map<String, dynamic>?,
        aiScore: (row['ai_score'] as num?)?.toDouble(),
        aiConfidence: (row['ai_confidence'] as num?)?.toDouble(),
        aiFeedback: row['ai_feedback'] as Map<String, dynamic>?,
        finalScore: (row['final_score'] as num?)?.toDouble(),
        gradedBy: row['graded_by'] as String?,
        gradedAt: row['graded_at'] != null
            ? DateTime.parse(row['graded_at'] as String)
            : null,
        teacherFeedback: row['teacher_feedback'] as Map<String, dynamic>?,
        createdAt: row['created_at'] != null
            ? DateTime.parse(row['created_at'] as String)
            : null,
        updatedAt: row['updated_at'] != null
            ? DateTime.parse(row['updated_at'] as String)
            : null,
        assignmentQuestion: aq,
        questionId: question?['id'] as String?,
        questionType: question?['type'] as String?,
        points: (aq?['points'] as num?)?.toDouble(),
        customContent: aq?['custom_content'] as Map<String, dynamic>?,
      );
    }).toList();
  } catch (e, stackTrace) {
    AppLogger.error(
      '🔴 [SUBMISSION_ANSWERS] Error loading answers: $e',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

/// Provider cập nhật điểm và feedback của submission
@riverpod
class SubmissionGradingNotifier extends _$SubmissionGradingNotifier {
  bool _isUpdating = false;

  @override
  Future<void> build() async {}

  /// Approve điểm AI - dùng điểm AI làm điểm cuối cùng
  Future<void> approveAiScore(String submissionAnswerId, {String? distributionId}) async {
    if (_isUpdating) return;
    _isUpdating = true;

    final datasource = ref.read(submissionDataSourceProviderProvider);

    try {
      await datasource.approveAiScore(submissionAnswerId);
      AppLogger.info('✅ Approved AI score for: $submissionAnswerId');

      // Refresh state
      if (distributionId != null) {
        ref.invalidate(teacherSubmissionListProvider(distributionId: distributionId));
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [APPROVE_AI_SCORE] Error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _isUpdating = false;
    }
  }

  /// Override điểm - teacher nhập điểm mới
  /// Lưu vào grade_overrides để audit trail
  Future<void> overrideScore({
    required String submissionAnswerId,
    required double newScore,
    required String reason,
    String? distributionId,
  }) async {
    if (_isUpdating) return;
    _isUpdating = true;

    final datasource = ref.read(submissionDataSourceProviderProvider);
    final gradeOverrideDatasource = ref.read(gradeOverrideDataSourceProviderProvider);

    try {
      // Lấy điểm cũ từ database
      final currentUser = SupabaseService.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Lấy câu trả lời hiện tại để biết điểm cũ
      final answer = await SupabaseService.client
          .from('submission_answers')
          .select('ai_score, final_score')
          .eq('id', submissionAnswerId)
          .single();

      final oldScore = (answer['final_score'] ?? answer['ai_score']) as double?;

      // Cập nhật điểm mới
      await datasource.updateSubmissionAnswerGrade(
        answerId: submissionAnswerId,
        finalScore: newScore,
        teacherId: currentUser.id,
      );

      // Tạo audit trail trong grade_overrides
      if (oldScore != null) {
        await gradeOverrideDatasource.createGradeOverride(
          submissionAnswerId: submissionAnswerId,
          overriddenBy: currentUser.id,
          oldScore: oldScore,
          newScore: newScore,
          reason: reason,
        );
      }

      AppLogger.info(
        '🔄 Override score for: $submissionAnswerId, newScore: $newScore, reason: $reason',
      );

      // Refresh state
      if (distributionId != null) {
        ref.invalidate(teacherSubmissionListProvider(distributionId: distributionId));
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [OVERRIDE_SCORE] Error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _isUpdating = false;
    }
  }

  /// Cập nhật teacher feedback
  Future<void> updateTeacherFeedback({
    required String submissionAnswerId,
    required String feedback,
  }) async {
    if (_isUpdating) return;
    _isUpdating = true;

    final datasource = ref.read(submissionDataSourceProviderProvider);

    try {
      final currentUser = SupabaseService.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Lấy score hiện tại để giữ nguyên
      final answer = await SupabaseService.client
          .from('submission_answers')
          .select('final_score, ai_score')
          .eq('id', submissionAnswerId)
          .single();

      final currentScore = (answer['final_score'] ?? answer['ai_score']) as double? ?? 0.0;

      await datasource.updateSubmissionAnswerGrade(
        answerId: submissionAnswerId,
        finalScore: currentScore,
        teacherFeedback: feedback,
        teacherId: currentUser.id,
      );

      AppLogger.info(
        '📝 Update feedback for: $submissionAnswerId, feedback: $feedback',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [UPDATE_TEACHER_FEEDBACK] Error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _isUpdating = false;
    }
  }

  /// Publish grades - chuyển status từ 'submitted' sang 'graded'
  /// Chỉ khi publish HS mới thấy điểm (Stage Curtain model)
  Future<void> publishGrades(String submissionId, {String? distributionId}) async {
    if (_isUpdating) return;
    _isUpdating = true;

    try {
      final repository = ref.read(submissionRepositoryProvider);
      await repository.publishGrades(submissionId);
      AppLogger.info('✅ Published grades for submission: $submissionId');

      // Refresh state
      if (distributionId != null) {
        ref.invalidate(teacherSubmissionListProvider(distributionId: distributionId));
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [PUBLISH_GRADES] Error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _isUpdating = false;
    }
  }

  /// Publish grades cho toàn bộ distribution
  Future<void> publishAllGrades(String distributionId) async {
    if (_isUpdating) return;
    _isUpdating = true;

    try {
      final repository = ref.read(submissionRepositoryProvider);
      await repository.publishAllGrades(distributionId);
      AppLogger.info('✅ Published all grades for distribution: $distributionId');

      // Refresh state
      ref.invalidate(teacherSubmissionListProvider(distributionId: distributionId));
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [PUBLISH_ALL_GRADES] Error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _isUpdating = false;
    }
  }
}
