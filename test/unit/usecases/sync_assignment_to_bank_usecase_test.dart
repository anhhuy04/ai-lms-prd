import 'package:ai_mls/domain/entities/sync_result.dart';
import 'package:ai_mls/domain/failures/question_failure.dart';
import 'package:ai_mls/domain/repositories/question_repository.dart';
import 'package:ai_mls/domain/usecases/question_bank_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQuestionRepository extends Mock implements QuestionRepository {}

void main() {
  late MockQuestionRepository repo;
  late SyncAssignmentToBankUseCase usecase;

  setUp(() {
    repo = MockQuestionRepository();
    usecase = SyncAssignmentToBankUseCase(repo);
  });

  test('returns SyncResult from repo', () async {
    when(() => repo.syncAssignmentToBank('a1')).thenAnswer(
      (_) async => const SyncResult(created: 3, linked: 2, total: 5),
    );
    final r = await usecase('a1');
    expect(r.created, 3);
    expect(r.linked, 2);
    expect(r.total, 5);
  });

  test('propagates RpcLockTimeout', () {
    when(() => repo.syncAssignmentToBank(any())).thenThrow(RpcLockTimeout());
    expect(() => usecase('a1'), throwsA(isA<RpcLockTimeout>()));
  });

  test('propagates PermissionDenied', () {
    when(() => repo.syncAssignmentToBank(any())).thenThrow(PermissionDenied());
    expect(() => usecase('a1'), throwsA(isA<PermissionDenied>()));
  });
}
