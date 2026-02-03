import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_choice.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/domain/repositories/question_repository.dart';

/// Usecase: Tạo câu hỏi mới trong Question Bank.
class CreateQuestionUseCase {
  final QuestionRepository _questionRepository;

  CreateQuestionUseCase(this._questionRepository);

  Future<Question> call(CreateQuestionParams params) {
    return _questionRepository.createQuestion(params);
  }
}

/// Input cho GetQuestionBankUseCase.
class GetQuestionBankParams {
  final String authorId;
  final QuestionType? type;
  final int? difficulty;
  final List<String>? tags;
  final int page;
  final int pageSize;

  const GetQuestionBankParams({
    required this.authorId,
    this.type,
    this.difficulty,
    this.tags,
    this.page = 0,
    this.pageSize = 20,
  });
}

/// Usecase: Lấy danh sách câu hỏi trong Question Bank của giáo viên.
///
/// Hiện tại filter được xử lý ở client side sau khi lấy theo authorId.
class GetQuestionBankUseCase {
  final QuestionRepository _questionRepository;

  GetQuestionBankUseCase(this._questionRepository);

  Future<List<Question>> call(GetQuestionBankParams params) async {
    return _questionRepository.getQuestionsByAuthor(
      params.authorId,
      includePublic: true,
      type: params.type,
      difficulty: params.difficulty,
      tags: params.tags,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

/// DTO chi tiết câu hỏi (câu hỏi + choices).
class QuestionDetail {
  final Question question;
  final List<QuestionChoice> choices;

  const QuestionDetail({required this.question, required this.choices});
}

/// Usecase: Lấy chi tiết 1 câu hỏi (bao gồm choices).
class GetQuestionDetailUseCase {
  final QuestionRepository _questionRepository;

  GetQuestionDetailUseCase(this._questionRepository);

  Future<QuestionDetail?> call(String id) async {
    final question = await _questionRepository.getQuestionById(id);
    if (question == null) return null;

    // Load song song choices (và sau này có thể thêm objectives/stats).
    final choicesFuture = _questionRepository.getChoicesByQuestionId(
      question.id,
    );

    final choices = await choicesFuture;
    return QuestionDetail(question: question, choices: choices);
  }
}
