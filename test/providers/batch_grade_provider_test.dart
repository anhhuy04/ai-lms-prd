import 'package:ai_mls/data/datasources/submission_datasource.dart';
import 'package:ai_mls/presentation/providers/datasource_providers.dart';
import 'package:ai_mls/presentation/providers/teacher_submission_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// ignore: depend_on_referenced_packages — riverpod là dev dependency ở root package
import 'package:riverpod/riverpod.dart';

class MockSubmissionDataSource extends Mock implements SubmissionDataSource {}

void main() {
  late MockSubmissionDataSource mockDs;

  setUp(() {
    mockDs = MockSubmissionDataSource();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        // Override datasource (đúng target — provider gọi datasource trực tiếp,
        // KHÔNG qua repository, theo pattern approveAiScore/teacherSubmissionList).
        submissionDataSourceProviderProvider.overrideWith(
          () => _FakeSubmissionDataSourceNotifier(mockDs),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('distributionAnswersByQuestionProvider', () {
    test('trả về dữ liệu từ datasource', () async {
      final rows = <Map<String, dynamic>>[
        {
          'answer_id': 'a1',
          'student_name': 'Nguyễn Văn A',
          'answer': {'text': 'Bài làm 1'},
          'ai_score': 1.5,
          'ai_confidence': 0.8,
          'final_score': null,
        },
        {
          'answer_id': 'a2',
          'student_name': 'Trần Thị B',
          'answer': {'text': 'Bài làm 2'},
          'ai_score': 2.0,
          'ai_confidence': 0.9,
          'final_score': 2.0,
        },
      ];
      when(() => mockDs.getDistributionAnswersByQuestion(
            distributionId: 'dist-1',
            assignmentQuestionId: 'aq-1',
          )).thenAnswer((_) async => rows);

      final container = makeContainer();
      final result = await container.read(
        distributionAnswersByQuestionProvider(
          distributionId: 'dist-1',
          assignmentQuestionId: 'aq-1',
        ).future,
      );

      expect(result, hasLength(2));
      expect(result.first['student_name'], 'Nguyễn Văn A');
      verify(() => mockDs.getDistributionAnswersByQuestion(
            distributionId: 'dist-1',
            assignmentQuestionId: 'aq-1',
          )).called(1);
    });

    test('rethrow khi datasource lỗi', () async {
      when(() => mockDs.getDistributionAnswersByQuestion(
            distributionId: any(named: 'distributionId'),
            assignmentQuestionId: any(named: 'assignmentQuestionId'),
          )).thenThrow(Exception('boom'));

      final container = makeContainer();
      await expectLater(
        container.read(
          distributionAnswersByQuestionProvider(
            distributionId: 'dist-1',
            assignmentQuestionId: 'aq-1',
          ).future,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('SubmissionDataSource.batchApproveAiScores (qua mock)', () {
    test('chuyển answerIds + gradedBy xuống datasource và trả count', () async {
      when(() => mockDs.batchApproveAiScores(
            answerIds: ['a1', 'a2'],
            gradedBy: 'teacher-1',
          )).thenAnswer((_) async => 2);

      final count = await mockDs.batchApproveAiScores(
        answerIds: ['a1', 'a2'],
        gradedBy: 'teacher-1',
      );

      expect(count, 2);
      verify(() => mockDs.batchApproveAiScores(
            answerIds: ['a1', 'a2'],
            gradedBy: 'teacher-1',
          )).called(1);
    });
  });
}

/// Notifier giả để override [submissionDataSourceProviderProvider] (vốn là
/// một @riverpod class notifier build() => SubmissionDataSource()).
class _FakeSubmissionDataSourceNotifier extends SubmissionDataSourceProvider {
  _FakeSubmissionDataSourceNotifier(this._ds);
  final SubmissionDataSource _ds;

  @override
  SubmissionDataSource build() => _ds;
}
