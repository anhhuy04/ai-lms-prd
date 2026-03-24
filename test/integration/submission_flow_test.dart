import 'package:ai_mls/data/datasources/submission_datasource.dart';
import 'package:ai_mls/data/repositories/submission_repository_impl.dart';
import 'package:ai_mls/domain/repositories/submission_repository.dart'
    as domain;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSubmissionDataSource extends Mock implements SubmissionDataSource {}

void main() {
  group('Submission Flow Integration', () {
    late MockSubmissionDataSource mockDataSource;
    late domain.SubmissionRepository repository;

    setUp(() {
      mockDataSource = MockSubmissionDataSource();
      repository = SubmissionRepositoryImpl(mockDataSource);
    });

    test('getOrCreateSubmission - creates new submission when none exists', () async {
      when(() => mockDataSource.getOrCreateSubmission(any(), any()))
          .thenAnswer((_) async => {
                'id': 'new-sub-001',
                'assignment_distribution_id': 'dist-001',
                'student_id': 'student-001',
                'status': 'draft',
                'answers': <String, dynamic>{},
                'uploaded_files': <String>[],
              });

      final result = await repository.getOrCreateSubmission('dist-001', 'student-001');

      expect(result, isNotNull);
      expect(result!['id'], 'new-sub-001');
      expect(result['status'], 'draft');
      verify(() => mockDataSource.getOrCreateSubmission('dist-001', 'student-001'))
          .called(1);
    });

    test('getOrCreateSubmission - returns existing submission', () async {
      when(() => mockDataSource.getOrCreateSubmission(any(), any()))
          .thenAnswer((_) async => {
                'id': 'existing-sub-001',
                'assignment_distribution_id': 'dist-001',
                'student_id': 'student-001',
                'status': 'draft',
                'answers': {'q1': 'answer 1'},
                'uploaded_files': <String>[],
              });

      final result = await repository.getOrCreateSubmission('dist-001', 'student-001');

      expect(result, isNotNull);
      expect(result!['id'], 'existing-sub-001');
      expect(result['answers'], {'q1': 'answer 1'});
    });

    test('saveSubmissionDraft - saves answers correctly', () async {
      when(() => mockDataSource.saveDraft(
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((_) async {});

      await repository.saveSubmissionDraft(
        'dist-001',
        'student-001',
        {'q1': 'answer 1', 'q2': 'answer 2'},
        ['file1.pdf'],
      );

      verify(() => mockDataSource.saveDraft(
            'dist-001',
            'student-001',
            {'q1': 'answer 1', 'q2': 'answer 2'},
            ['file1.pdf'],
          )).called(1);
    });

    test('submitAssignment - changes status to submitted', () async {
      when(() => mockDataSource.submitAssignment(any(), any()))
          .thenAnswer((_) async => {
                'id': 'sub-001',
                'status': 'submitted',
                'submitted_at': '2026-03-23T10:00:00Z',
              });

      final result = await repository.submitAssignment('dist-001', 'student-001');

      expect(result['status'], 'submitted');
      expect(result['submitted_at'], isNotNull);
    });

    test('updateSubmissionGrade - updates score and feedback', () async {
      when(() => mockDataSource.updateSubmissionGrade(
            any(),
            score: any(named: 'score'),
            feedback: any(named: 'feedback'),
          )).thenAnswer((_) async {});

      await repository.updateSubmissionGrade(
        'sub-001',
        score: 8.5,
        feedback: 'Good work!',
      );

      verify(() => mockDataSource.updateSubmissionGrade(
            'sub-001',
            score: 8.5,
            feedback: 'Good work!',
          )).called(1);
    });

    test('publishGrades - changes submission status to graded', () async {
      when(() => mockDataSource.publishGrades(any()))
          .thenAnswer((_) async {});

      await repository.publishGrades('sub-001');

      verify(() => mockDataSource.publishGrades('sub-001')).called(1);
    });

    test('publishAllGrades - publishes all submissions in distribution',
        () async {
      when(() => mockDataSource.publishAllGrades(any()))
          .thenAnswer((_) async {});

      await repository.publishAllGrades('dist-001');

      verify(() => mockDataSource.publishAllGrades('dist-001')).called(1);
    });

    test('error propagation - repository throws on datasource errors', () async {
      when(() => mockDataSource.getOrCreateSubmission(any(), any()))
          .thenThrow(Exception('Database error'));

      // Repository wraps datasource errors with ErrorTranslationUtils.translateError
      expect(
        () => repository.getOrCreateSubmission('dist-001', 'student-001'),
        throwsA(anything),
      );
    });
  });
}
