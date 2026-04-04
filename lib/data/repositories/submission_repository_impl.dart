import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/error_translation_utils.dart';
import 'package:ai_mls/data/datasources/submission_datasource.dart';
import 'package:ai_mls/domain/entities/submission.dart';
import 'package:ai_mls/domain/entities/submission_answer.dart';
import 'package:ai_mls/domain/repositories/submission_repository.dart';

class SubmissionRepositoryImpl implements SubmissionRepository {
  final SubmissionDataSource _ds;

  SubmissionRepositoryImpl(this._ds);

  @override
  Future<Submission?> getOrCreateSubmission(
    String distributionId,
    String studentId,
  ) async {
    try {
      final row = await _ds.getOrCreateSubmission(distributionId, studentId);
      if (row == null) return null;
      return Submission.fromJson(row);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getOrCreateSubmission: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy bài nộp');
    }
  }

  @override
  Future<void> saveSubmissionDraft(
    String distributionId,
    String studentId,
    Map<String, dynamic> answers,
    List<String> uploadedFiles,
  ) async {
    try {
      await _ds.saveDraft(distributionId, studentId, answers, uploadedFiles);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] saveSubmissionDraft: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lưu bản nháp');
    }
  }

  @override
  Future<Submission> submitAssignment(
    String distributionId,
    String studentId,
  ) async {
    try {
      final row = await _ds.submitAssignment(distributionId, studentId);
      return Submission.fromJson(row);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] submitAssignment: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Nộp bài tập');
    }
  }

  @override
  Future<List<Submission>> getStudentSubmissionHistory(
    String studentId,
  ) async {
    try {
      final rows = await _ds.getStudentSubmissionHistory(studentId);
      return rows.map(Submission.fromJson).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getStudentSubmissionHistory: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy lịch sử nộp bài');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSubmissionsByDistribution(
    String distributionId,
  ) async {
    try {
      return await _ds.getSubmissionsByDistribution(distributionId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getSubmissionsByDistribution: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy danh sách bài nộp');
    }
  }

  @override
  Future<Map<String, dynamic>> getSubmissionById(String submissionId) async {
    try {
      return await _ds.getSubmissionById(submissionId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getSubmissionById: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy chi tiết bài nộp');
    }
  }

  @override
  Future<void> updateSubmissionGrade(
    String submissionId, {
    required double score,
    String? feedback,
  }) async {
    try {
      await _ds.updateSubmissionGrade(
        submissionId,
        score: score,
        feedback: feedback,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] updateSubmissionGrade: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Cập nhật điểm');
    }
  }

  @override
  Future<List<SubmissionAnswer>> getSubmissionAnswers(String submissionId) async {
    try {
      final rows = await _ds.getSubmissionAnswers(submissionId);
      return rows.map((row) {
        // Extract extended fields from nested assignment_question object
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
          // Extended fields from joins
          assignmentQuestion: aq,
          questionId: question?['id'] as String?,
          questionType: question?['type'] as String?,
          points: (aq?['points'] as num?)?.toDouble(),
          customContent: aq?['custom_content'] as Map<String, dynamic>?,
        );
      }).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] getSubmissionAnswers: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Lấy câu trả lời');
    }
  }

  @override
  Future<void> updateSubmissionAnswerGrade({
    required String answerId,
    required double finalScore,
    String? teacherFeedback,
    required String teacherId,
  }) async {
    try {
      await _ds.updateSubmissionAnswerGrade(
        answerId: answerId,
        finalScore: finalScore,
        teacherFeedback: teacherFeedback,
        teacherId: teacherId,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] updateSubmissionAnswerGrade: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Cập nhật điểm câu trả lời');
    }
  }

  @override
  Future<void> publishGrades(String submissionId) async {
    try {
      await _ds.publishGrades(submissionId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] publishGrades: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Xuất bản điểm');
    }
  }

  @override
  Future<void> publishAllGrades(String distributionId) async {
    try {
      await _ds.publishAllGrades(distributionId);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [REPO ERROR] publishAllGrades: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Xuất bản tất cả điểm');
    }
  }
}
