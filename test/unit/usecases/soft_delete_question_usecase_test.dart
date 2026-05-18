import 'package:ai_mls/domain/failures/question_failure.dart';
import 'package:ai_mls/domain/repositories/question_repository.dart';
import 'package:ai_mls/domain/usecases/question_bank_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQuestionRepository extends Mock implements QuestionRepository {}

void main() {
  late MockQuestionRepository repo;
  late SoftDeleteQuestionUseCase usecase;

  setUp(() {
    repo = MockQuestionRepository();
    usecase = SoftDeleteQuestionUseCase(repo);
  });

  test('delegates to repo.softDeleteQuestion', () async {
    when(() => repo.softDeleteQuestion('q1')).thenAnswer((_) async {});
    await usecase('q1');
    verify(() => repo.softDeleteQuestion('q1')).called(1);
  });

  test('propagates PermissionDenied', () {
    when(() => repo.softDeleteQuestion(any())).thenThrow(PermissionDenied());
    expect(() => usecase('q1'), throwsA(isA<PermissionDenied>()));
  });
}
