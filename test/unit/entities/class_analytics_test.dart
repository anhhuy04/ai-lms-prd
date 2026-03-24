import 'package:ai_mls/domain/entities/analytics/class_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClassAnalytics', () {
    test('should create with default values', () {
      final analytics = ClassAnalytics();

      expect(analytics.classId, '');
      expect(analytics.className, '');
      expect(analytics.classAverage, 0.0);
      expect(analytics.totalStudents, 0);
      expect(analytics.totalSubmissions, 0);
      expect(analytics.submissionRate, 0.0);
      expect(analytics.lateSubmissionRate, 0.0);
      expect(analytics.lateSubmissionCount, 0);
      expect(analytics.worstOffender, isNull);
      expect(analytics.highestScore, isNull);
      expect(analytics.lowestScore, isNull);
      expect(analytics.distribution, isEmpty);
      expect(analytics.subjectDistributions, isEmpty);
      expect(analytics.topPerformers, isEmpty);
      expect(analytics.bottomPerformers, isEmpty);
    });

    test('should create with custom values', () {
      final analytics = ClassAnalytics(
        classId: 'class-123',
        className: 'Math 101',
        classAverage: 7.5,
        totalStudents: 30,
        totalSubmissions: 25,
        submissionRate: 0.83,
        lateSubmissionRate: 0.1,
        lateSubmissionCount: 3,
      );

      expect(analytics.classId, 'class-123');
      expect(analytics.className, 'Math 101');
      expect(analytics.classAverage, 7.5);
      expect(analytics.totalStudents, 30);
      expect(analytics.totalSubmissions, 25);
      expect(analytics.submissionRate, closeTo(0.83, 0.01));
    });

    test('should create with nested data', () {
      final worstOffender = WorstOffender(
        studentId: 'student-1',
        studentName: 'John Doe',
        lateCount: 5,
      );

      final distribution = [
        ClassDistribution(rangeStart: 0, rangeEnd: 10, count: 2),
        ClassDistribution(rangeStart: 10, rangeEnd: 20, count: 5),
        ClassDistribution(rangeStart: 90, rangeEnd: 100, count: 10),
      ];

      final subjectDist = [
        SubjectDistribution(
          subjectName: 'Algebra',
          below50Count: 3,
          below60Count: 5,
          below80Count: 8,
          above80Count: 12,
        ),
      ];

      final topPerf = [
        StudentPerformance(
          studentId: 's1',
          studentName: 'Top Student',
          score: 9.5,
          submissionCount: 10,
        ),
      ];

      final bottomPerf = [
        StudentPerformance(
          studentId: 's2',
          studentName: 'Bottom Student',
          score: 4.0,
          submissionCount: 8,
        ),
      ];

      final analytics = ClassAnalytics(
        worstOffender: worstOffender,
        distribution: distribution,
        subjectDistributions: subjectDist,
        topPerformers: topPerf,
        bottomPerformers: bottomPerf,
      );

      expect(analytics.worstOffender?.lateCount, 5);
      expect(analytics.distribution.length, 3);
      expect(analytics.subjectDistributions.length, 1);
      expect(analytics.topPerformers.length, 1);
      expect(analytics.bottomPerformers.length, 1);
    });

    test('should serialize and deserialize from JSON', () {
      final original = ClassAnalytics(
        classId: 'class-456',
        className: 'Science',
        classAverage: 8.0,
        totalStudents: 20,
        totalSubmissions: 18,
        highestScore: 10.0,
        lowestScore: 5.0,
      );

      final json = original.toJson();
      final restored = ClassAnalytics.fromJson(json);

      expect(restored.classId, original.classId);
      expect(restored.className, original.className);
      expect(restored.classAverage, original.classAverage);
      expect(restored.totalStudents, original.totalStudents);
      expect(restored.highestScore, original.highestScore);
      expect(restored.lowestScore, original.lowestScore);
    });
  });

  group('ClassDistribution', () {
    test('should create with values', () {
      final dist = ClassDistribution(
        rangeStart: 80,
        rangeEnd: 90,
        count: 15,
      );

      expect(dist.rangeStart, 80);
      expect(dist.rangeEnd, 90);
      expect(dist.count, 15);
    });

    test('should serialize to JSON', () {
      final dist = ClassDistribution(
        rangeStart: 60,
        rangeEnd: 70,
        count: 8,
      );

      final json = dist.toJson();
      expect(json['rangeStart'], 60);
      expect(json['rangeEnd'], 70);
      expect(json['count'], 8);
    });
  });

  group('SubjectDistribution', () {
    test('should create with all counts', () {
      final subDist = SubjectDistribution(
        subjectName: 'Geometry',
        below50Count: 2,
        below60Count: 4,
        below80Count: 7,
        above80Count: 15,
      );

      expect(subDist.subjectName, 'Geometry');
      expect(subDist.below50Count, 2);
      expect(subDist.below60Count, 4);
      expect(subDist.below80Count, 7);
      expect(subDist.above80Count, 15);
    });

    test('should default to zero counts', () {
      final subDist = SubjectDistribution(subjectName: 'Empty');
      expect(subDist.below50Count, 0);
      expect(subDist.below60Count, 0);
      expect(subDist.below80Count, 0);
      expect(subDist.above80Count, 0);
    });
  });

  group('StudentPerformance', () {
    test('should create with required fields', () {
      final perf = StudentPerformance(
        studentId: 'student-99',
        studentName: 'Jane Smith',
        score: 8.7,
        submissionCount: 12,
      );

      expect(perf.studentId, 'student-99');
      expect(perf.studentName, 'Jane Smith');
      expect(perf.score, 8.7);
      expect(perf.submissionCount, 12);
    });
  });

  group('WorstOffender', () {
    test('should create with all fields', () {
      final offender = WorstOffender(
        studentId: 'worst-1',
        studentName: 'Late Larry',
        lateCount: 10,
      );

      expect(offender.studentId, 'worst-1');
      expect(offender.studentName, 'Late Larry');
      expect(offender.lateCount, 10);
    });
  });
}
