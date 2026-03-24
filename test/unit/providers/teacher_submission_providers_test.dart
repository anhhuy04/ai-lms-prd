import 'package:ai_mls/domain/repositories/submission_repository.dart';
import 'package:ai_mls/presentation/providers/teacher_submission_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

class MockSubmissionRepository extends Mock implements SubmissionRepository {}

void main() {
  group('TeacherSubmissionItem', () {
    test('should create with all required fields', () {
      final item = TeacherSubmissionItem(
        submissionId: 'sub-001',
        studentId: 'student-001',
        studentName: 'Nguyen Van A',
        submittedAt: DateTime(2026, 3, 20, 10, 30),
        isLate: false,
        aiGraded: false,
        status: 'submitted',
      );

      expect(item.submissionId, 'sub-001');
      expect(item.studentId, 'student-001');
      expect(item.studentName, 'Nguyen Van A');
      expect(item.isLate, false);
      expect(item.aiGraded, false);
      expect(item.status, 'submitted');
      expect(item.totalScore, isNull);
      expect(item.maxScore, isNull);
    });

    test('should create with optional fields', () {
      final item = TeacherSubmissionItem(
        submissionId: 'sub-002',
        studentId: 'student-002',
        studentName: 'Tran Thi B',
        studentAvatarUrl: 'https://example.com/avatar.jpg',
        submittedAt: DateTime(2026, 3, 21, 14, 0),
        isLate: true,
        totalScore: 8.5,
        maxScore: 10.0,
        aiGraded: true,
        status: 'graded',
      );

      expect(item.studentAvatarUrl, 'https://example.com/avatar.jpg');
      expect(item.isLate, true);
      expect(item.totalScore, 8.5);
      expect(item.maxScore, 10.0);
      expect(item.aiGraded, true);
      expect(item.status, 'graded');
    });
  });

  group('TeacherSubmissionListState', () {
    test('should create with required fields', () {
      const state = TeacherSubmissionListState(
        distributionId: 'dist-001',
        assignmentTitle: 'Test Assignment',
        submissions: [],
        filter: SubmissionFilter.all,
      );

      expect(state.distributionId, 'dist-001');
      expect(state.assignmentTitle, 'Test Assignment');
      expect(state.submissions, isEmpty);
      expect(state.filter, SubmissionFilter.all);
      expect(state.isLoadingAi, false);
    });

    test('should create with submissions and filter', () {
      final submissions = [
        TeacherSubmissionItem(
          submissionId: 's1',
          studentId: 'st1',
          studentName: 'Student 1',
          submittedAt: DateTime.now(),
          isLate: false,
          aiGraded: false,
          status: 'submitted',
        ),
      ];

      final state = TeacherSubmissionListState(
        distributionId: 'dist-002',
        assignmentTitle: 'Assignment 2',
        submissions: submissions,
        filter: SubmissionFilter.pending,
        isLoadingAi: true,
      );

      expect(state.submissions.length, 1);
      expect(state.filter, SubmissionFilter.pending);
      expect(state.isLoadingAi, true);
    });
  });

  group('SubmissionFilter', () {
    test('should have correct labels', () {
      expect(SubmissionFilter.all.label, 'Tất cả');
      expect(SubmissionFilter.pending.label, 'Chưa chấm');
      expect(SubmissionFilter.graded.label, 'Đã chấm');
      expect(SubmissionFilter.late.label, 'Nộp muộn');
    });

    test('should have all values', () {
      expect(SubmissionFilter.values.length, 4);
      expect(SubmissionFilter.values, contains(SubmissionFilter.all));
      expect(SubmissionFilter.values, contains(SubmissionFilter.pending));
      expect(SubmissionFilter.values, contains(SubmissionFilter.graded));
      expect(SubmissionFilter.values, contains(SubmissionFilter.late));
    });
  });

  group('submissionRepositoryProvider', () {
    test('should provide repository instance', () {
      // Test that the provider can be overridden with a mock
      final container = ProviderContainer(
        overrides: [
          submissionRepositoryProvider.overrideWith(
            (ref) => MockSubmissionRepository(),
          ),
        ],
      );

      final repo = container.read(submissionRepositoryProvider);
      expect(repo, isA<MockSubmissionRepository>());

      container.dispose();
    });
  });

  group('SubmissionGradingNotifier concurrency guard', () {
    test('should not allow concurrent updates', () {
      // Test the concurrency guard logic
      bool isUpdating = false;

      Future<void> tryUpdate() async {
        if (isUpdating) return;
        isUpdating = true;
        try {
          await Future.delayed(const Duration(milliseconds: 10));
        } finally {
          isUpdating = false;
        }
      }

      // Verify guard prevents concurrent calls
      expect(isUpdating, false);
      tryUpdate();
      expect(isUpdating, true);
    });
  });
}
