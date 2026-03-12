import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/error_translation_utils.dart';
import 'package:ai_mls/data/datasources/submission_datasource.dart';
import 'package:ai_mls/domain/repositories/submission_repository.dart';

class SubmissionRepositoryImpl implements SubmissionRepository {
  final SubmissionDataSource _ds;

  SubmissionRepositoryImpl(this._ds);

  @override
  Future<Map<String, dynamic>?> getOrCreateSubmission(
    String distributionId,
    String studentId,
  ) async {
    try {
      return await _ds.getOrCreateSubmission(distributionId, studentId);
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
  Future<Map<String, dynamic>> submitAssignment(
    String distributionId,
    String studentId,
  ) async {
    try {
      return await _ds.submitAssignment(distributionId, studentId);
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
  Future<List<Map<String, dynamic>>> getStudentSubmissionHistory(
    String studentId,
  ) async {
    try {
      return await _ds.getStudentSubmissionHistory(studentId);
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
  Future<List<Map<String, dynamic>>> getSubmissionAnswers(String submissionId) async {
    try {
      return await _ds.getSubmissionAnswers(submissionId);
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
