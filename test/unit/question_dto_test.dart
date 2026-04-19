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
        expect(insert['is_public'], false);
        // author_id NOT included — added server-side by RPC
        expect(insert.containsKey('author_id'), false);
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
}
