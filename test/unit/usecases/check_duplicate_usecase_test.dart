import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/domain/failures/question_failure.dart';
import 'package:ai_mls/domain/repositories/question_repository.dart';
import 'package:ai_mls/domain/usecases/question_bank_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQuestionRepository extends Mock implements QuestionRepository {}

void main() {
  late MockQuestionRepository repo;
  late CheckDuplicateUseCase usecase;

  setUp(() {
    repo = MockQuestionRepository();
    usecase = CheckDuplicateUseCase(repo);
  });

  const existing = Question(
    id: 'q1',
    authorId: 'u1',
    type: QuestionType.multipleChoice,
    content: {'text': 'Q'},
    source: 'teacher',
  );

  test('returns Question when match', () async {
    when(() => repo.checkDuplicate('u1', 'hash1'))
        .thenAnswer((_) async => existing);
    final r = await usecase('u1', 'hash1');
    expect(r?.id, 'q1');
  });

  test('returns null when no match', () async {
    when(() => repo.checkDuplicate(any(), any())).thenAnswer((_) async => null);
    final r = await usecase('u1', 'hash');
    expect(r, isNull);
  });

  test('propagates NetworkFailure', () {
    when(() => repo.checkDuplicate(any(), any())).thenThrow(NetworkFailure());
    expect(() => usecase('u1', 'h'), throwsA(isA<NetworkFailure>()));
  });
}
