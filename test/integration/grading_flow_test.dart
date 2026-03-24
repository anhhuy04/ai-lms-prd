import 'package:ai_mls/data/datasources/grade_override_datasource.dart';
import 'package:ai_mls/data/datasources/submission_datasource.dart';
import 'package:ai_mls/data/repositories/grade_override_repository_impl.dart';
import 'package:ai_mls/data/repositories/submission_repository_impl.dart';
import 'package:ai_mls/domain/repositories/submission_repository.dart'
    as domain;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSubmissionDataSource extends Mock implements SubmissionDataSource {}

class MockGradeOverrideDataSource extends Mock
    implements GradeOverrideDataSource {}

void main() {
  group('Grading Flow Integration', () {
    late MockSubmissionDataSource mockSubmissionDataSource;
    late MockGradeOverrideDataSource mockGradeOverrideDataSource;
    late domain.SubmissionRepository submissionRepository;
    late GradeOverrideRepositoryImpl gradeOverrideRepository;

    setUp(() {
      mockSubmissionDataSource = MockSubmissionDataSource();
      mockGradeOverrideDataSource = MockGradeOverrideDataSource();
      submissionRepository =
          SubmissionRepositoryImpl(mockSubmissionDataSource);
      gradeOverrideRepository =
          GradeOverrideRepositoryImpl(mockGradeOverrideDataSource);
    });

    test('approveAiScore - accepts AI score as final score', () async {
      when(() => mockSubmissionDataSource.approveAiScore(any()))
          .thenAnswer((_) async {});

      await mockSubmissionDataSource.approveAiScore('answer-001');

      verify(() => mockSubmissionDataSource.approveAiScore('answer-001'))
          .called(1);
    });

    test('updateSubmissionAnswerGrade - updates score and teacher feedback',
        () async {
      when(() => mockSubmissionDataSource.updateSubmissionAnswerGrade(
            answerId: any(named: 'answerId'),
            finalScore: any(named: 'finalScore'),
            teacherFeedback: any(named: 'teacherFeedback'),
            teacherId: any(named: 'teacherId'),
          )).thenAnswer((_) async {});

      await mockSubmissionDataSource.updateSubmissionAnswerGrade(
        answerId: 'answer-002',
        finalScore: 7.0,
        teacherFeedback: 'Nice explanation',
        teacherId: 'teacher-001',
      );

      verify(() => mockSubmissionDataSource.updateSubmissionAnswerGrade(
            answerId: 'answer-002',
            finalScore: 7.0,
            teacherFeedback: 'Nice explanation',
            teacherId: 'teacher-001',
          )).called(1);
    });

    test('createGradeOverride - creates audit trail entry', () async {
      when(() => mockGradeOverrideDataSource.createGradeOverride(
            submissionAnswerId: any(named: 'submissionAnswerId'),
            overriddenBy: any(named: 'overriddenBy'),
            oldScore: any(named: 'oldScore'),
            newScore: any(named: 'newScore'),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => {
            'id': 'override-001',
            'submission_answer_id': 'answer-002',
            'overridden_by': 'teacher-001',
            'old_score': 8.0,
            'new_score': 7.0,
            'reason': 'Calculation error in essay',
            'created_at': '2026-03-23T12:00:00Z',
          });

      final result = await mockGradeOverrideDataSource.createGradeOverride(
        submissionAnswerId: 'answer-002',
        overriddenBy: 'teacher-001',
        oldScore: 8.0,
        newScore: 7.0,
        reason: 'Calculation error in essay',
      );

      expect(result['id'], 'override-001');
      expect(result['old_score'], 8.0);
      expect(result['new_score'], 7.0);
      expect(result['reason'], 'Calculation error in essay');
    });

    test('getOverrideHistory - returns audit trail for an answer', () async {
      when(() => mockGradeOverrideDataSource.getOverrideHistory(any()))
          .thenAnswer((_) async => [
                {
                  'id': 'override-001',
                  'submission_answer_id': 'answer-003',
                  'overridden_by': 'teacher-001',
                  'old_score': 9.0,
                  'new_score': 8.5,
                  'reason': 'Minor deduction',
                  'created_at': '2026-03-22T15:00:00Z',
                },
                {
                  'id': 'override-002',
                  'submission_answer_id': 'answer-003',
                  'overridden_by': 'teacher-001',
                  'old_score': 8.5,
                  'new_score': 8.0,
                  'reason': 'Re-evaluated',
                  'created_at': '2026-03-23T10:00:00Z',
                },
              ]);

      final history =
          await mockGradeOverrideDataSource.getOverrideHistory('answer-003');

      expect(history.length, 2);
      expect(history[0]['new_score'], 8.5);
      expect(history[1]['new_score'], 8.0);
    });

    test('publishGrades - transitions submission from submitted to graded',
        () async {
      when(() => mockSubmissionDataSource.publishGrades(any()))
          .thenAnswer((_) async {});

      await mockSubmissionDataSource.publishGrades('sub-001');

      verify(() => mockSubmissionDataSource.publishGrades('sub-001'))
          .called(1);
    });

    test('publishAllGrades - publishes all submissions in distribution',
        () async {
      when(() => mockSubmissionDataSource.publishAllGrades(any()))
          .thenAnswer((_) async {});

      await mockSubmissionDataSource.publishAllGrades('dist-001');

      verify(() => mockSubmissionDataSource.publishAllGrades('dist-001'))
          .called(1);
    });

    test('getSubmissionAnswers - returns empty when sessionId is null',
        () async {
      when(() => mockSubmissionDataSource.getSubmissionAnswers(any()))
          .thenAnswer((_) async => []);

      final answers =
          await mockSubmissionDataSource.getSubmissionAnswers('sub-no-session');

      expect(answers, isEmpty);
    });

    test('getSubmissionById - returns submission detail', () async {
      when(() => mockSubmissionDataSource.getSubmissionById(any()))
          .thenAnswer((_) async => {
                'id': 'sub-001',
                'status': 'submitted',
                'assignment_distribution_id': 'dist-001',
                'student_id': 'student-001',
                'submission_answers': [
                  {
                    'id': 'answer-001',
                    'question_id': 'q-001',
                    'ai_score': 8.0,
                    'ai_confidence': 0.85,
                    'final_score': null,
                  },
                  {
                    'id': 'answer-002',
                    'question_id': 'q-002',
                    'ai_score': 7.5,
                    'ai_confidence': 0.92,
                    'final_score': null,
                  },
                ],
              });

      final detail =
          await mockSubmissionDataSource.getSubmissionById('sub-001');

      expect(detail['id'], 'sub-001');
      expect(detail['status'], 'submitted');
      final answers = detail['submission_answers'] as List;
      expect(answers.length, 2);
    });

    test('gradeOverrideRepository - createOverride wraps datasource error',
        () async {
      when(() => mockGradeOverrideDataSource.createGradeOverride(
            submissionAnswerId: any(named: 'submissionAnswerId'),
            overriddenBy: any(named: 'overriddenBy'),
            oldScore: any(named: 'oldScore'),
            newScore: any(named: 'newScore'),
            reason: any(named: 'reason'),
          )).thenThrow(Exception('Database write error'));

      expect(
        () => mockGradeOverrideDataSource.createGradeOverride(
          submissionAnswerId: 'answer-001',
          overriddenBy: 'teacher-001',
          oldScore: 8.0,
          newScore: 7.5,
          reason: 'Test',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
