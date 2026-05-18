import 'package:ai_mls/domain/entities/ghost_report.dart';
import 'package:ai_mls/domain/failures/question_failure.dart';
import 'package:ai_mls/domain/repositories/question_repository.dart';
import 'package:ai_mls/domain/usecases/question_bank_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQuestionRepository extends Mock implements QuestionRepository {}

void main() {
  late MockQuestionRepository repo;
  late DetectGhostQuestionsUseCase usecase;

  setUp(() {
    repo = MockQuestionRepository();
    usecase = DetectGhostQuestionsUseCase(repo);
  });

  test('returns GhostReport from repo', () async {
    when(() => repo.detectGhostQuestions('a1')).thenAnswer(
      (_) async => const GhostReport(ghostCount: 3, totalCount: 10),
    );
    final r = await usecase('a1');
    expect(r.ghostCount, 3);
    expect(r.totalCount, 10);
    expect(r.hasGhosts, true);
  });

  test('zero ghosts case', () async {
    when(() => repo.detectGhostQuestions('a1')).thenAnswer(
      (_) async => const GhostReport(ghostCount: 0, totalCount: 5),
    );
    final r = await usecase('a1');
    expect(r.hasGhosts, false);
  });

  test('propagates RpcLockTimeout', () {
    when(() => repo.detectGhostQuestions(any())).thenThrow(RpcLockTimeout());
    expect(() => usecase('a1'), throwsA(isA<RpcLockTimeout>()));
  });
}
