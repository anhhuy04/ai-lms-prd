import 'package:ai_mls/domain/entities/question_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuestionSource', () {
    test('teacher → "teacher"', () {
      expect(QuestionSource.teacher.dbValue, 'teacher');
    });
    test('aiGenerated → "ai_generated"', () {
      expect(QuestionSource.aiGenerated.dbValue, 'ai_generated');
    });
    test('fromDb("ai_generated") → aiGenerated', () {
      expect(QuestionSource.fromDb('ai_generated'), QuestionSource.aiGenerated);
    });
    test('fromDb unknown value → teacher (default)', () {
      expect(QuestionSource.fromDb('xyz'), QuestionSource.teacher);
    });
    test('all 6 enum values map correctly', () {
      expect(QuestionSource.library.dbValue, 'library');
      expect(QuestionSource.imported.dbValue, 'imported');
      expect(QuestionSource.system.dbValue, 'system');
      expect(QuestionSource.admin.dbValue, 'admin');
    });
  });
}
