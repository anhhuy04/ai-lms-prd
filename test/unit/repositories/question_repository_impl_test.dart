import 'package:ai_mls/data/datasources/question_bank_datasource.dart';
import 'package:ai_mls/data/repositories/question_repository_impl.dart';
import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/ghost_report.dart';
import 'package:ai_mls/domain/entities/question_filter.dart';
import 'package:ai_mls/domain/entities/question_source.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/domain/entities/sync_result.dart';
import 'package:ai_mls/domain/failures/question_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockDataSource extends Mock implements QuestionBankDataSource {}

class _FakeQuestionFilter extends Fake implements QuestionFilter {}

void main() {
  late MockDataSource ds;
  late QuestionRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(_FakeQuestionFilter());
  });

  setUp(() {
    ds = MockDataSource();
    // Inject a stub currentUserId resolver to avoid depending on Supabase.init.
    repo = QuestionRepositoryImpl(
      ds,
      currentUserIdResolver: () => 'test-user-id',
    );
  });

  group('createQuestion error mapping', () {
    test('PostgrestException 23505 → DuplicateContentDetected', () {
      when(() => ds.insertQuestion(any())).thenThrow(
        const PostgrestException(message: 'dup', code: '23505'),
      );
      final params = CreateQuestionParams(
        type: QuestionType.multipleChoice,
        content: const {'text': 'Q'},
        source: QuestionSource.teacher,
      );
      expect(
        repo.createQuestion(params),
        throwsA(isA<DuplicateContentDetected>()),
      );
    });

    test('PostgrestException 42501 → PermissionDenied', () {
      when(() => ds.insertQuestion(any())).thenThrow(
        const PostgrestException(message: 'perm', code: '42501'),
      );
      final params = CreateQuestionParams(
        type: QuestionType.shortAnswer,
        content: const {'text': 'Q'},
        source: QuestionSource.teacher,
      );
      expect(
        repo.createQuestion(params),
        throwsA(isA<PermissionDenied>()),
      );
    });
  });

  group('softDeleteQuestion', () {
    test('success delegates to datasource', () async {
      when(() => ds.softDeleteQuestion('q1')).thenAnswer((_) async {});
      await repo.softDeleteQuestion('q1');
      verify(() => ds.softDeleteQuestion('q1')).called(1);
    });

    test('maps PostgrestException → QuestionFailure', () {
      when(() => ds.softDeleteQuestion(any())).thenThrow(
        const PostgrestException(message: 'perm', code: '42501'),
      );
      expect(
        repo.softDeleteQuestion('q1'),
        throwsA(isA<PermissionDenied>()),
      );
    });
  });

  group('restoreQuestion', () {
    test('delegates', () async {
      when(() => ds.restoreQuestion('q1')).thenAnswer((_) async {});
      await repo.restoreQuestion('q1');
      verify(() => ds.restoreQuestion('q1')).called(1);
    });
  });

  group('checkDuplicate', () {
    test('returns null when no match', () async {
      when(() => ds.findByContentHash(any(), any()))
          .thenAnswer((_) async => null);
      final result = await repo.checkDuplicate('u1', 'hash');
      expect(result, isNull);
    });
  });

  group('detectGhostQuestions', () {
    test('maps jsonb to GhostReport', () async {
      when(() => ds.detectGhostQuestions('a1')).thenAnswer(
        (_) async => {'ghost_count': 5, 'total_count': 10},
      );
      final r = await repo.detectGhostQuestions('a1');
      expect(r.ghostCount, 5);
      expect(r.totalCount, 10);
    });

    test('PostgrestException 55P03 → RpcLockTimeout', () {
      when(() => ds.detectGhostQuestions(any())).thenThrow(
        const PostgrestException(message: 'lock', code: '55P03'),
      );
      expect(
        repo.detectGhostQuestions('a1'),
        throwsA(isA<RpcLockTimeout>()),
      );
    });
  });

  group('syncAssignmentToBank', () {
    test('maps jsonb to SyncResult', () async {
      when(() => ds.syncAssignmentToBank('a1')).thenAnswer(
        (_) async => {'created': 3, 'linked': 2, 'total': 5},
      );
      final r = await repo.syncAssignmentToBank('a1');
      expect(r.created, 3);
      expect(r.linked, 2);
    });
  });

  group('getQuestions', () {
    test('passes filter to datasource and maps result', () async {
      when(() => ds.getQuestions(any())).thenAnswer(
        (_) async => [
          {
            'id': 'q1',
            'author_id': 'u1',
            'type': 'multiple_choice',
            'content': {'text': 'Q'},
            'is_global': false,
            'source': 'teacher',
          },
        ],
      );
      const filter = QuestionFilter(authorId: 'u1');
      final result = await repo.getQuestions(filter);
      expect(result.length, 1);
      expect(result.first.id, 'q1');
    });
  });
}
