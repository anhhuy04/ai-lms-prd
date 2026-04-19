// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';

// W0 stub — QuestionDTO will be part of AI generate question screen refactor
// import 'package:ai_mls/data/models/question_dto.dart';

void main() {
  group('QuestionDTO', () {
    group('fromJson', () {
      test(
        'parses multiple_choice question with 4 choices',
        skip: 'W0 stub — implement in Plan 07',
        () {},
      );
      test(
        'parses true_false question',
        skip: 'W0 stub — implement in Plan 07',
        () {},
      );
      test(
        'parses short_answer question',
        skip: 'W0 stub — implement in Plan 07',
        () {},
      );
      test(
        'returns null for malformed JSON',
        skip: 'W0 stub — implement in Plan 07',
        () {},
      );
    });

    group('toAssignmentQuestionInsert', () {
      test(
        'maps QuestionDTO to custom_content jsonb format',
        skip: 'W0 stub — implement in Plan 07',
        () {},
      );
    });

    group('Pipeline agnosticism', () {
      test(
        'extraction pipeline and generation pipeline produce identical DTO schema',
        skip: 'W0 stub — implement in Plan 07',
        () {},
      );
    });
  });
}
