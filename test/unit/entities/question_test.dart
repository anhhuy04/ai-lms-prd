import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Question.fromJson backward compat', () {
    test('v1 (only is_public=true) → isGlobal=true', () {
      final json = {
        'id': '00000000-0000-0000-0000-000000000001',
        'author_id': 'user1',
        'type': 'multiple_choice',
        'content': {'text': 'Test'},
        'is_public': true,
      };
      final q = Question.fromJson(json);
      expect(q.isGlobal, true);
    });

    test('v2 (is_global=false + is_public=true) → isGlobal=false (precedence)', () {
      final json = {
        'id': '00000000-0000-0000-0000-000000000002',
        'author_id': 'user1',
        'type': 'multiple_choice',
        'content': {'text': 'Test'},
        'is_global': false,
        'is_public': true,
      };
      final q = Question.fromJson(json);
      expect(q.isGlobal, false);
    });

    test('v2 deleted_at set → isDeleted=true', () {
      final json = {
        'id': '00000000-0000-0000-0000-000000000003',
        'author_id': 'user1',
        'type': 'multiple_choice',
        'content': {'text': 'Test'},
        'deleted_at': '2026-05-17T10:00:00Z',
      };
      final q = Question.fromJson(json);
      expect(q.isDeleted, true);
      expect(q.isActive, false);
    });

    test('defaultPoints reads numeric 2.5 from JSON', () {
      final json = {
        'id': '00000000-0000-0000-0000-000000000004',
        'author_id': 'user1',
        'type': 'multiple_choice',
        'content': {'text': 'Test'},
        'default_points': 2.5,
      };
      final q = Question.fromJson(json);
      expect(q.defaultPoints, 2.5);
    });

    test('source defaults to "teacher"', () {
      final json = {
        'id': '00000000-0000-0000-0000-000000000005',
        'author_id': 'user1',
        'type': 'multiple_choice',
        'content': {'text': 'Test'},
      };
      final q = Question.fromJson(json);
      expect(q.source, 'teacher');
    });

    test('isAiGenerated true when source = "ai_generated"', () {
      final json = {
        'id': '00000000-0000-0000-0000-000000000006',
        'author_id': 'user1',
        'type': 'multiple_choice',
        'content': {'text': 'Test'},
        'source': 'ai_generated',
      };
      final q = Question.fromJson(json);
      expect(q.isAiGenerated, true);
    });

    test('isOwnedBy returns true for matching authorId', () {
      final q = const Question(
        id: 'q1',
        authorId: 'user1',
        type: QuestionType.multipleChoice,
        content: {'text': 'Q'},
      );
      expect(q.isOwnedBy('user1'), true);
      expect(q.isOwnedBy('user2'), false);
    });
  });
}
