import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_filter.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/domain/repositories/question_repository.dart';
import 'package:ai_mls/domain/usecases/question_bank_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQuestionRepository extends Mock implements QuestionRepository {}

class _FakeQuestionFilter extends Fake implements QuestionFilter {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeQuestionFilter());
  });

  late MockQuestionRepository repo;
  late GetQuestionBankUseCase usecase;

  setUp(() {
    repo = MockQuestionRepository();
    usecase = GetQuestionBankUseCase(repo);
  });

  const filter = QuestionFilter(authorId: 'u1');
  const list = [
    Question(
      id: 'q1',
      authorId: 'u1',
      type: QuestionType.multipleChoice,
      content: {'text': 'Q'},
      source: 'teacher',
    ),
  ];

  test('passes filter to repo and returns list', () async {
    when(() => repo.getQuestions(any())).thenAnswer((_) async => list);
    final r = await usecase(filter);
    expect(r.length, 1);
    expect(r.first.id, 'q1');
    verify(() => repo.getQuestions(filter)).called(1);
  });
}
