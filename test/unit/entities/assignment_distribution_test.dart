import 'package:ai_mls/domain/entities/assignment_distribution.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssignmentDistribution', () {
    test('should create with required fields only', () {
      final dist = AssignmentDistribution(
        id: 'dist-001',
        assignmentId: 'assign-001',
        distributionType: 'class',
      );

      expect(dist.id, 'dist-001');
      expect(dist.assignmentId, 'assign-001');
      expect(dist.distributionType, 'class');
      expect(dist.classId, isNull);
      expect(dist.groupId, isNull);
      expect(dist.studentIds, isNull);
      expect(dist.allowLate, true);
    });

    test('should create with all fields', () {
      final dist = AssignmentDistribution(
        id: 'dist-002',
        assignmentId: 'assign-002',
        distributionType: 'class',
        classId: 'class-101',
        groupId: null,
        studentIds: ['s1', 's2', 's3'],
        availableFrom: DateTime(2026, 3, 1),
        dueAt: DateTime(2026, 3, 15),
        timeLimitMinutes: 60,
        allowLate: true,
        latePolicy: {'penalty': 0.1, 'maxPenalty': 0.5},
        settings: {'shuffle': true, 'showScore': false},
        className: 'Math 101',
        assignmentTitle: 'Chapter 5 Test',
        recipientCount: 30,
        submittedCount: 25,
        gradedCount: 20,
        lateSubmissionCount: 3,
      );

      expect(dist.id, 'dist-002');
      expect(dist.classId, 'class-101');
      expect(dist.studentIds?.length, 3);
      expect(dist.timeLimitMinutes, 60);
      expect(dist.allowLate, true);
      expect(dist.latePolicy?['penalty'], 0.1);
      expect(dist.settings?['shuffle'], true);
      expect(dist.recipientCount, 30);
      expect(dist.submittedCount, 25);
      expect(dist.gradedCount, 20);
      expect(dist.lateSubmissionCount, 3);
    });

    test('should serialize to JSON correctly', () {
      final dist = AssignmentDistribution(
        id: 'dist-json',
        assignmentId: 'assign-json',
        distributionType: 'group',
        classId: 'c1',
        allowLate: false,
      );

      final json = dist.toJson();

      expect(json['id'], 'dist-json');
      expect(json['assignment_id'], 'assign-json');
      expect(json['distribution_type'], 'group');
      expect(json['class_id'], 'c1');
      expect(json['allow_late'], false);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'dist-from-json',
        'assignment_id': 'assign-from-json',
        'distribution_type': 'students',
        'class_id': 'class-json',
        'student_ids': ['st1', 'st2'],
        'allow_late': true,
        'late_policy': {'penalty': 0.2},
        'recipient_count': 10,
        'submitted_count': 8,
        'graded_count': 5,
        'late_submission_count': 2,
      };

      final dist = AssignmentDistribution.fromJson(json);

      expect(dist.id, 'dist-from-json');
      expect(dist.assignmentId, 'assign-from-json');
      expect(dist.distributionType, 'students');
      expect(dist.classId, 'class-json');
      expect(dist.studentIds, ['st1', 'st2']);
      expect(dist.allowLate, true);
      expect(dist.latePolicy?['penalty'], 0.2);
      expect(dist.recipientCount, 10);
      expect(dist.submittedCount, 8);
      expect(dist.gradedCount, 5);
      expect(dist.lateSubmissionCount, 2);
    });

    test('should handle null optional fields in JSON', () {
      final json = {
        'id': 'minimal',
        'assignment_id': 'assign-min',
        'distribution_type': 'class',
      };

      final dist = AssignmentDistribution.fromJson(json);

      expect(dist.id, 'minimal');
      expect(dist.classId, isNull);
      expect(dist.groupId, isNull);
      expect(dist.studentIds, isNull);
      expect(dist.availableFrom, isNull);
      expect(dist.dueAt, isNull);
      expect(dist.timeLimitMinutes, isNull);
    });
  });
}
