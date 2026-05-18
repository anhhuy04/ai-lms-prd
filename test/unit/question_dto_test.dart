// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_mls/data/models/question_dto.dart';

void main() {
  group('QuestionDTO', () {
    group('fromJson', () {
      test('parses multiple_choice question with 4 choices', () {
        final json = {
          'type': 'multiple_choice',
          'content': {'text': 'Câu hỏi trắc nghiệm?'},
          'choices': [
            {'id': 0, 'text': 'Đáp án A', 'isCorrect': false},
            {'id': 1, 'text': 'Đáp án B', 'isCorrect': true},
            {'id': 2, 'text': 'Đáp án C', 'isCorrect': false},
            {'id': 3, 'text': 'Đáp án D', 'isCorrect': false},
          ],
          'answer': {'correct_index': 1},
          'difficulty': 3,
          'tags': ['flutter', 'dart'],
          'defaultPoints': 2,
        };
        final dto = QuestionDTO.fromJson(json);
        expect(dto.type, 'multiple_choice');
        expect(dto.content['text'], 'Câu hỏi trắc nghiệm?');
        expect(dto.choices.length, 4);
        expect(dto.choices[1].text, 'Đáp án B');
        expect(dto.choices[1].isCorrect, true);
        expect(dto.answer['correct_index'], 1);
        expect(dto.difficulty, 3);
        expect(dto.tags, ['flutter', 'dart']);
        expect(dto.defaultPoints, 2);
      });

      test('parses true_false question', () {
        final json = {
          'type': 'true_false',
          'content': {'text': 'Flutter là framework của Google?'},
          'choices': <Map<String, dynamic>>[],
          'answer': {'correct_text': 'true'},
          'difficulty': 2,
          'tags': <String>[],
          'defaultPoints': 1,
        };
        final dto = QuestionDTO.fromJson(json);
        expect(dto.type, 'true_false');
        expect(dto.answer['correct_text'], 'true');
        expect(dto.choices, isEmpty);
      });

      test('parses short_answer question', () {
        final json = {
          'type': 'short_answer',
          'content': {'text': 'Giải thích ngắn gọn về Riverpod?'},
          'answer': {'sample_response': 'State management library...'},
        };
        final dto = QuestionDTO.fromJson(json);
        expect(dto.type, 'short_answer');
        expect(dto.content['text'], contains('Riverpod'));
        // Default values apply
        expect(dto.difficulty, 3);
        expect(dto.defaultPoints, 1);
        expect(dto.choices, isEmpty);
        expect(dto.tags, isEmpty);
      });

      test('uses default difficulty=3 when not provided', () {
        final json = {
          'type': 'multiple_choice',
          'content': {'text': 'Test?'},
          'answer': {'correct_index': 0},
        };
        final dto = QuestionDTO.fromJson(json);
        expect(dto.difficulty, 3);
      });
    });

    group('toDbInsert', () {
      test('maps QuestionDTO to questions table insert format', () {
        final dto = QuestionDTO(
          type: 'multiple_choice',
          content: {'text': 'Question text'},
          choices: [ChoiceDTO(id: 0, text: 'A', isCorrect: true)],
          answer: {'correct_index': 0},
          difficulty: 4,
          tags: ['tag1', 'tag2'],
          defaultPoints: 2,
        );
        final insert = dto.toDbInsert();
        expect(insert['type'], 'multiple_choice');
        expect(insert['content'], {'text': 'Question text'});
        expect(insert['answer'], {'correct_index': 0});
        expect(insert['difficulty'], 4);
        expect(insert['tags'], ['tag1', 'tag2']);
        expect(insert['default_points'], 2);
        expect(insert['is_global'], false);
        // author_id NOT included — added server-side by RPC
        expect(insert.containsKey('author_id'), false);
      });

      test('toDbInsert sets is_global=false (not is_public) and source from param', () {
        final dto = QuestionDTO(
          type: 'multiple_choice',
          content: const {'text': 'Q'},
          answer: const {'correct_index': 0},
          defaultPoints: 1,
          source: 'ai_generated',
          choices: const [],
        );
        final insert = dto.toDbInsert();
        expect(insert['is_global'], false);
        expect(insert['source'], 'ai_generated');
        expect(insert.containsKey('is_public'), false);
      });

      test('toDbInsert with source teacher default', () {
        final dto = QuestionDTO(
          type: 'short_answer',
          content: const {'text': 'Q2'},
          answer: const {'sample_response': ''},
          defaultPoints: 2,
          choices: const [],
        );
        final insert = dto.toDbInsert();
        expect(insert['source'], 'teacher');
      });
    });

    group('Pipeline agnosticism', () {
      test('extraction pipeline and generation pipeline produce identical DTO schema', () {
        // Extraction pipeline output (from Edge Function result.extraction.questions)
        final extractionJson = {
          'type': 'multiple_choice',
          'content': {'text': 'Extracted question from document'},
          'choices': [
            {'id': 0, 'text': 'A', 'isCorrect': false},
            {'id': 1, 'text': 'B', 'isCorrect': true},
          ],
          'answer': {'correct_index': 1},
          'difficulty': 2,
          'tags': ['chapter1'],
          'defaultPoints': 1,
        };
        // Generation pipeline output (from Gemini RAG + CO-STAR prompt)
        final generationJson = {
          'type': 'multiple_choice',
          'content': {'text': 'Generated question from topic'},
          'choices': [
            {'id': 0, 'text': 'X', 'isCorrect': true},
            {'id': 1, 'text': 'Y', 'isCorrect': false},
          ],
          'answer': {'correct_index': 0},
          'difficulty': 3,
          'tags': ['topic'],
          'defaultPoints': 1,
        };

        final extractionDto = QuestionDTO.fromJson(extractionJson);
        final generationDto = QuestionDTO.fromJson(generationJson);

        // Both produce QuestionDTO instances with the same field set
        expect(extractionDto.type, isNotEmpty);
        expect(generationDto.type, isNotEmpty);
        // Both can call toDbInsert with identical key structure
        final extractInsert = extractionDto.toDbInsert();
        final genInsert = generationDto.toDbInsert();
        expect(extractInsert.keys.toSet(), equals(genInsert.keys.toSet()),
            reason: 'Both pipelines must produce identical DB insert schema');
      });
    });
  });

  // ---------------------------------------------------------------------------
  // Edge cases (Phase 9 expansion)
  // ---------------------------------------------------------------------------
  group('QuestionDTO — edge cases', () {
    test('fromJson với content.text là null → content map có null value (no crash)', () {
      // content is a Map<String, dynamic> — text key can be null
      final json = {
        'type': 'multiple_choice',
        'content': {'text': null},
        'answer': {'correct_index': 0},
      };
      final dto = QuestionDTO.fromJson(json);
      expect(dto.content['text'], isNull);
    });

    test('fromJson với content là empty map không crash', () {
      final json = {
        'type': 'short_answer',
        'content': <String, dynamic>{},
        'answer': {'sample_response': ''},
      };
      final dto = QuestionDTO.fromJson(json);
      expect(dto.content, isEmpty);
      expect(dto.type, equals('short_answer'));
    });

    test('fromJson với choices là null → empty list (default applied)', () {
      // Generated code: (json['choices'] as List<dynamic>?)?.map(...)?.toList() ?? const []
      final json = {
        'type': 'multiple_choice',
        'content': {'text': 'Q?'},
        'answer': {'correct_index': 0},
        'choices': null,
      };
      final dto = QuestionDTO.fromJson(json);
      expect(dto.choices, isEmpty,
          reason: 'null choices should fallback to empty list via ?? const []');
    });

    test('fromJson với unknown type string không throw', () {
      // No enum validation — any string is accepted
      final json = {
        'type': 'essay_long_form',
        'content': {'text': 'Write an essay'},
        'answer': {'rubric': 'grade by teacher'},
      };
      final dto = QuestionDTO.fromJson(json);
      expect(dto.type, equals('essay_long_form'));
    });

    test('difficulty bounds: value 0 được accept (không có validation)', () {
      // NOTE: No min/max validation in QuestionDTO — caller must validate.
      // DB schema has difficulty INT 1-5, but DTO has no guard.
      final json = {
        'type': 'multiple_choice',
        'content': {'text': 'Q?'},
        'answer': {'correct_index': 0},
        'difficulty': 0,
      };
      final dto = QuestionDTO.fromJson(json);
      expect(dto.difficulty, equals(0),
          reason: 'BUG RISK: DTO accepts difficulty=0 but DB expects 1-5');
    });

    test('difficulty bounds: value 6 được accept (không có validation)', () {
      // NOTE: Same issue — no upper bound check.
      final json = {
        'type': 'multiple_choice',
        'content': {'text': 'Q?'},
        'answer': {'correct_index': 0},
        'difficulty': 6,
      };
      final dto = QuestionDTO.fromJson(json);
      expect(dto.difficulty, equals(6),
          reason: 'BUG RISK: DTO accepts difficulty=6 but DB expects 1-5');
    });

    test('toDbInsert không chứa choices field (DB questions table không có choices column)', () {
      final dto = QuestionDTO(
        type: 'multiple_choice',
        content: {'text': 'Q?'},
        choices: [ChoiceDTO(id: 0, text: 'A'), ChoiceDTO(id: 1, text: 'B')],
        answer: {'correct_index': 0},
      );
      final insert = dto.toDbInsert();
      expect(insert.containsKey('choices'), isFalse,
          reason: 'choices is not a column in questions table — RPC handles it separately');
    });

    // -------------------------------------------------------------------------
    // ChoiceDTO camelCase vs snake_case behavior (BUG DOCUMENTATION)
    // -------------------------------------------------------------------------
    test('ChoiceDTO.fromJson với isCorrect (camelCase) — works correctly', () {
      // Generated code uses json['isCorrect'] (camelCase) — the ONLY accepted key.
      final json = {'id': 0, 'text': 'Answer A', 'isCorrect': true};
      final choice = ChoiceDTO.fromJson(json);
      expect(choice.isCorrect, isTrue);
    });

    test('ChoiceDTO.fromJson với is_correct (snake_case) — BUG: silently ignored, falls back to false', () {
      // BUG: Edge Function may output snake_case JSON. The generated code reads
      // json['isCorrect'], so snake_case 'is_correct' is silently ignored.
      // This causes isCorrect to always be false when Edge Function uses snake_case.
      // Fix: Add @JsonKey(name: 'is_correct') to ChoiceDTO.isCorrect field.
      final jsonSnakeCase = {'id': 0, 'text': 'Answer A', 'is_correct': true};
      final choice = ChoiceDTO.fromJson(jsonSnakeCase);
      // Documents the BUG: is_correct is ignored → isCorrect defaults to false
      expect(choice.isCorrect, isFalse,
          reason: 'BUG CONFIRMED: snake_case is_correct is not read by generated code. '
              'Fix: add @JsonKey(name: "is_correct") to ChoiceDTO.isCorrect');
    });
  });

  // ---------------------------------------------------------------------------
  // Round-trip with Edge Function output (Fast Track pipeline)
  // ---------------------------------------------------------------------------
  group('QuestionDTO — round-trip với Edge Function output', () {
    test('parse output từ Fast Track pipeline — defaults apply for missing fields', () {
      // Simulate exact JSON from fastTrackMap() in Edge Function.
      // Fast Track does NOT include difficulty, tags, or defaultPoints.
      final edgeFunctionOutput = {
        'type': 'multiple_choice',
        'content': {'text': 'Question from fast track'},
        'answer': {'correct_index': 0},
        'choices': [
          {'id': 0, 'text': 'A'},
          {'id': 1, 'text': 'B'},
        ],
        // NOTE: 'difficulty', 'tags', 'defaultPoints' NOT present
      };
      final dto = QuestionDTO.fromJson(edgeFunctionOutput);
      expect(dto.difficulty, equals(3), reason: 'default difficulty applies');
      expect(dto.tags, isEmpty, reason: 'default tags (empty) applies');
      expect(dto.defaultPoints, equals(1), reason: 'default defaultPoints applies');
      expect(dto.choices.length, equals(2));
    });

    test('choices.isCorrect từ Edge Function Fast Track là false (isCorrect không được set)', () {
      // fastTrackMap() chỉ set answer.correct_index, KHÔNG set isCorrect trong choices.
      // StagingAreaWidget cần dùng answer.correct_index (không phải choice.isCorrect)
      // để hiển thị đúng đáp án.
      final edgeFunctionOutput = {
        'type': 'multiple_choice',
        'content': {'text': 'Q?'},
        'answer': {'correct_index': 1},
        'choices': [
          {'id': 0, 'text': 'Wrong'},
          {'id': 1, 'text': 'Correct'},
        ],
      };
      final dto = QuestionDTO.fromJson(edgeFunctionOutput);
      // All choices have isCorrect=false because Edge Function doesn't set it
      expect(dto.choices.every((c) => !c.isCorrect), isTrue,
          reason: 'Edge Function fastTrackMap does not set isCorrect in choices. '
              'StagingAreaWidget MUST rely on answer.correct_index for display');
      // Correct answer is conveyed through answer map
      expect(dto.answer['correct_index'], equals(1));
    });

    test('fromJson với content null → TypeError (không graceful fallback)', () {
      // content is required Map<String, dynamic> — generated code casts directly
      // without null-check: json['content'] as Map<String, dynamic>
      // This will throw TypeError if content is null.
      final json = {
        'type': 'multiple_choice',
        'content': null, // null required field
        'answer': {'correct_index': 0},
      };
      // Documents actual behavior: THROWS — there is no graceful fallback.
      expect(
        () => QuestionDTO.fromJson(json),
        throwsA(isA<TypeError>()),
        reason: 'BUG RISK: content is required — null content throws TypeError. '
            'Callers must ensure content is never null in Edge Function output.',
      );
    });
  });
}
