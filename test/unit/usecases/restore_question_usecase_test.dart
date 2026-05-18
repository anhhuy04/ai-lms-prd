import 'package:ai_mls/domain/failures/question_failure.dart';
import 'package:ai_mls/domain/repositories/question_repository.dart';
import 'package:ai_mls/domain/usecases/question_bank_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQuestionRepository extends Mock implements QuestionRepository {}

void main() {
  late MockQuestionRepository repo;
  late RestoreQuestionUseCase usecase;

  setUp(() {
    repo = MockQuestionRepository();
    usecase = RestoreQuestionUseCase(repo);
  });

  test('delegates to repo.restoreQuestion', () async {
    when(() => repo.restoreQuestion('q1')).thenAnswer((_) async {});
    await usecase('q1');
    verify(() => repo.restoreQuestion('q1')).called(1);
  });

  test('propagates QuestionNotFound', () {
    when(() => repo.restoreQuestion(any())).thenThrow(QuestionNotFound());
    expect(() => usecase('q1'), throwsA(isA<QuestionNotFound>()));
  });
}
