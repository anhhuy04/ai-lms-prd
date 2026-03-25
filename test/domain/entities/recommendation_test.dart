import 'package:flutter_test/flutter_test.dart';
import 'package:ai_mls/domain/entities/recommendation/recommendation.dart';

void main() {
  group('Recommendation', () {
    test('fromJson creates valid Recommendation', () {
      final json = {
        'id': 'test-id',
        'user_id': 'user-uuid',
        'role': 'student',
        'type': 'study_tip',
        'priority': 'high',
        'title': 'Hoc sinh can on tap',
        'description': 'Muc thanh thao thap',
        'action_label': 'Lam bai',
        'is_read': false,
        'is_dismissed': false,
        'unread_count': 1,
        'created_at': '2026-03-25T10:00:00Z',
        'metadata': {
          'exercises': ['uuid-1', 'uuid-2'],
          'videos': ['https://youtube.com/...'],
          'documents': [],
        },
      };

      final rec = Recommendation.fromJson(json);

      expect(rec.id, 'test-id');
      expect(rec.userId, 'user-uuid');
      expect(rec.role, RecommendationRole.student);
      expect(rec.type, RecommendationType.studyTip);
      expect(rec.priority, RecommendationPriority.high);
      expect(rec.title, 'Hoc sinh can on tap');
      expect(rec.isRead, false);
      expect(rec.isDismissed, false);
      expect(rec.exercises, ['uuid-1', 'uuid-2']);
      expect(rec.videos, ['https://youtube.com/...']);
      expect(rec.documents, isEmpty);
    });

    test('isUrgent returns true for high priority', () {
      expect(
        const Recommendation(id: '1', title: 'a', priority: RecommendationPriority.high).isUrgent,
        true,
      );
      expect(
        const Recommendation(id: '1', title: 'a', priority: RecommendationPriority.medium).isUrgent,
        false,
      );
      expect(
        const Recommendation(id: '1', title: 'a', priority: RecommendationPriority.low).isUrgent,
        false,
      );
    });

    test('priorityValue returns correct numeric values', () {
      expect(
        const Recommendation(id: '1', title: 'a', priority: RecommendationPriority.high).priorityValue,
        1,
      );
      expect(
        const Recommendation(id: '1', title: 'a', priority: RecommendationPriority.medium).priorityValue,
        2,
      );
      expect(
        const Recommendation(id: '1', title: 'a', priority: RecommendationPriority.low).priorityValue,
        3,
      );
    });

    test('exercises returns exercise UUIDs from metadata', () {
      final rec = Recommendation(
        id: '1',
        title: 'test',
        metadata: {'exercises': ['uuid-1', 'uuid-2'], 'videos': [], 'documents': []},
      );
      expect(rec.exercises, ['uuid-1', 'uuid-2']);
      expect(rec.videos, isEmpty);
      expect(rec.documents, isEmpty);
    });

    test('hasResources returns true when metadata has resources', () {
      expect(
        Recommendation(
          id: '1',
          title: 'a',
          metadata: {'exercises': ['x'], 'videos': [], 'documents': []},
        ).hasResources,
        true,
      );
      expect(
        const Recommendation(id: '1', title: 'a').hasResources,
        false,
      );
    });

    test('fromJson handles null fields gracefully', () {
      final rec = Recommendation.fromJson({});
      expect(rec.id, '');
      expect(rec.title, '');
      expect(rec.role, RecommendationRole.student);
      expect(rec.type, RecommendationType.studyTip);
      expect(rec.priority, RecommendationPriority.medium);
      expect(rec.exercises, isEmpty);
      expect(rec.hasResources, false);
    });
  });

  group('PeerComparison', () {
    test('fromJson creates valid PeerComparison', () {
      final json = {
        'class_average': 7.5,
        'percentile': 15.0,
        'rank': 3,
        'total_students': 20,
        'student_average': 8.2,
        'trend_direction': 'up',
        'trend_percentage': 10.5,
      };

      final pc = PeerComparison.fromJson(json);

      expect(pc.classAverage, 7.5);
      expect(pc.percentile, 15.0);
      expect(pc.rank, 3);
      expect(pc.totalStudents, 20);
      expect(pc.studentAverage, 8.2);
      expect(pc.trendDirection, 'up');
      expect(pc.trendPercentage, 10.5);
    });

    test('defaults to zero when fields are null', () {
      final pc = PeerComparison.fromJson({});
      expect(pc.classAverage, 0.0);
      expect(pc.percentile, 0.0);
      expect(pc.rank, 0);
      expect(pc.totalStudents, 0);
      expect(pc.studentAverage, 0.0);
      expect(pc.trendPercentage, 0.0);
    });
  });
}
