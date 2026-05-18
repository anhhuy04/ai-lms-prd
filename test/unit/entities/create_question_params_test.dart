import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/question_source.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('source.aiGenerated → dbValue "ai_generated"', () {
    final p = CreateQuestionParams(
      type: QuestionType.multipleChoice,
      content: const {'text': 'Q'},
      source: QuestionSource.aiGenerated,
    );
    expect(p.source.dbValue, 'ai_generated');
  });

  test('source.teacher → dbValue "teacher"', () {
    final p = CreateQuestionParams(
      type: QuestionType.shortAnswer,
      content: const {'text': 'Q'},
      source: QuestionSource.teacher,
    );
    expect(p.source.dbValue, 'teacher');
  });

  test('defaults: isGlobal=false, defaultPoints=1.0, tags=[]', () {
    final p = CreateQuestionParams(
      type: QuestionType.essay,
      content: const {'text': 'Q'},
      source: QuestionSource.teacher,
    );
    expect(p.isGlobal, false);
    expect(p.defaultPoints, 1.0);
    expect(p.tags, isEmpty);
  });

  test('objectiveIds + choices default empty list', () {
    final p = CreateQuestionParams(
      type: QuestionType.essay,
      content: const {'text': 'Q'},
      source: QuestionSource.teacher,
    );
    expect(p.objectiveIds, isEmpty);
    expect(p.choices, isEmpty);
  });
}
