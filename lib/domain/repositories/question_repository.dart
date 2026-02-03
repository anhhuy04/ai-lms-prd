import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_choice.dart';
import 'package:ai_mls/domain/entities/question_type.dart';

/// Contract cho Question Bank.
abstract class QuestionRepository {
  /// Tạo câu hỏi (kèm choices/objectives nếu có).
  Future<Question> createQuestion(CreateQuestionParams params);

  /// Cập nhật câu hỏi (kèm replace choices/objectives nếu có).
  /// Lưu ý: update sẽ "replace" toàn bộ choices/objectives hiện tại của câu hỏi.
  Future<Question> updateQuestion(String id, CreateQuestionParams params);

  /// Lấy câu hỏi theo id.
  Future<Question?> getQuestionById(String id);

  /// Lấy danh sách câu hỏi của 1 giáo viên (option include public).
  Future<List<Question>> getQuestionsByAuthor(
    String authorId, {
    bool includePublic = true,
    QuestionType? type,
    int? difficulty,
    List<String>? tags,
    int page = 0,
    int pageSize = 20,
  });

  /// Lấy choices cho 1 câu hỏi (order by id asc).
  Future<List<QuestionChoice>> getChoicesByQuestionId(String questionId);

  /// Xóa câu hỏi (teacher own / admin).
  Future<void> deleteQuestion(String id);
}
