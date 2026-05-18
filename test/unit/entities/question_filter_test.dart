import 'package:ai_mls/domain/entities/question_filter.dart';
import 'package:ai_mls/domain/entities/question_source.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuestionFilter', () {
    test('defaults: includeGlobal=true, includeDeleted=false, page=0, pageSize=20, sortBy=recentlyCreated', () {
      const f = QuestionFilter(authorId: 'u1');
      expect(f.includeGlobal, true);
      expect(f.includeDeleted, false);
      expect(f.page, 0);
      expect(f.pageSize, 20);
      expect(f.sortBy, QuestionSortKey.recentlyCreated);
    });

    test('copyWith updates fields', () {
      const f = QuestionFilter(authorId: 'u1');
      final f2 = f.copyWith(
        searchQuery: 'toán',
        sourceFilter: QuestionSource.aiGenerated,
        type: QuestionType.multipleChoice,
        difficulty: 3,
      );
      expect(f2.searchQuery, 'toán');
      expect(f2.sourceFilter, QuestionSource.aiGenerated);
      expect(f2.type, QuestionType.multipleChoice);
      expect(f2.difficulty, 3);
      expect(f2.authorId, 'u1');
    });

    test('QuestionSortKey has 4 values', () {
      expect(QuestionSortKey.values.length, 4);
      expect(QuestionSortKey.values, contains(QuestionSortKey.recentlyCreated));
      expect(QuestionSortKey.values, contains(QuestionSortKey.difficulty));
      expect(QuestionSortKey.values, contains(QuestionSortKey.type));
      expect(QuestionSortKey.values, contains(QuestionSortKey.totalAttempts));
    });

    test('equality (Freezed)', () {
      const f1 = QuestionFilter(authorId: 'u1', page: 2);
      const f2 = QuestionFilter(authorId: 'u1', page: 2);
      expect(f1, equals(f2));
    });
  });
}
