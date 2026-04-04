import 'package:ai_mls/domain/entities/submission.dart';
import 'package:ai_mls/domain/entities/submission_answer.dart';

/// Contract cho Submissions - quản lý bài nộp của học sinh.
abstract class SubmissionRepository {
  /// Lấy hoặc tạo bài nộp draft cho một distribution.
  Future<Submission?> getOrCreateSubmission(
    String distributionId,
    String studentId,
  );

  /// Lưu bản nháp bài nộp (học sinh).
  Future<void> saveSubmissionDraft(
    String distributionId,
    String studentId,
    Map<String, dynamic> answers,
    List<String> uploadedFiles,
  );

  /// Nộp bài tập.
  Future<Submission> submitAssignment(
    String distributionId,
    String studentId,
  );

  /// Lấy lịch sử nộp bài của học sinh.
  Future<List<Submission>> getStudentSubmissionHistory(String studentId);

  /// Lấy danh sách submissions cho 1 distribution (teacher view).
  Future<List<Map<String, dynamic>>> getSubmissionsByDistribution(
    String distributionId,
  );

  /// Lấy chi tiết một submission.
  Future<Map<String, dynamic>> getSubmissionById(String submissionId);

  /// Cập nhật điểm và phản hồi (teacher grading).
  Future<void> updateSubmissionGrade(
    String submissionId, {
    required double score,
    String? feedback,
  });

  /// Lấy câu trả lời của một submission (cho teacher grading).
  Future<List<SubmissionAnswer>> getSubmissionAnswers(String submissionId);

  /// Cập nhật điểm cho một câu trả lời.
  Future<void> updateSubmissionAnswerGrade({
    required String answerId,
    required double finalScore,
    String? teacherFeedback,
    required String teacherId,
  });

  /// Publish grades cho một submission - cập nhật status thành 'graded'.
  /// Chỉ khi publish HS mới thấy điểm (Stage Curtain model).
  Future<void> publishGrades(String submissionId);

  /// Publish grades cho toàn bộ distribution - tất cả submissions.
  Future<void> publishAllGrades(String distributionId);
}
