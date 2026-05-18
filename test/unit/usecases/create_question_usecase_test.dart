import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_source.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/domain/failures/question_failure.dart';
import 'package:ai_mls/domain/repositories/question_repository.dart';
import 'package:ai_mls/domain/usecases/question_bank_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQuestionRepository extends Mock implements QuestionRepository {}

class _FakeCreateParams extends Fake implements CreateQuestionParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeCreateParams());
  });

  late MockQuestionRepository repo;
  late CreateQuestionUseCase usecase;

  setUp(() {
    repo = MockQuestionRepository();
    usecase = CreateQuestionUseCase(repo);
  });

  final params = CreateQuestionParams(
    type: QuestionType.multipleChoice,
    content: const {'text': 'Q'},
    source: QuestionSource.teacher,
  );

  const question = Question(
    id: 'q1',
    authorId: 'u1',
    type: QuestionType.multipleChoice,
    content: {'text': 'Q'},
    source: 'teacher',
  );

  test('delegates to repo.createQuestion with params', () async {
    when(() => repo.createQuestion(any())).thenAnswer((_) async => question);
    final result = await usecase(params);
    expect(result.id, 'q1');
    verify(() => repo.createQuestion(params)).called(1);
  });

  test('propagates DuplicateContentDetected', () {
    when(() => repo.createQuestion(any()))
        .thenThrow(DuplicateContentDetected());
    expect(() => usecase(params), throwsA(isA<DuplicateContentDetected>()));
  });
}
