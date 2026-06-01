import 'package:ai_mls/data/datasources/assignment_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bug 1 (Chấm theo câu) — kiểm tra pure transform [AssignmentDataSource.resolveGradingRow]
/// resolve đúng type/text/choices từ question bank vào custom_content, KHÔNG cần
/// mock Supabase. Đây là logic load-bearing của getAssignmentQuestionsForGrading.
void main() {
  group('AssignmentDataSource.resolveGradingRow', () {
    test('câu reuse từ kho (question_id != null, custom_content NULL) resolve từ bank', () {
      // Shape do embed `questions(...)` sản xuất.
      final row = <String, dynamic>{
        'id': 'aq-1',
        'assignment_id': 'assign-1',
        'question_id': 'q-bank-1',
        'points': 1,
        'order_idx': 0,
        'custom_content': null, // khế ước Delta Override: NULL cho câu bank
        'rubric': null,
        'questions': {
          'id': 'q-bank-1',
          'type': 'multipleChoice', // bank lưu camelCase
          'content': {'text': 'Thủ đô của Việt Nam?'},
          'answer': {'correct_choices': [0]},
          'question_choices': [
            {'id': 0, 'content': {'text': 'Hà Nội'}, 'is_correct': true},
            {'id': 1, 'content': {'text': 'Đà Nẵng'}, 'is_correct': false},
          ],
        },
      };

      final resolved = AssignmentDataSource.resolveGradingRow(row);
      final cc = resolved['custom_content'] as Map<String, dynamic>;

      // type: normalize camelCase -> snake_case từ bank.
      expect(cc['type'], 'multiple_choice');
      // text: từ bank content.text (không trắng).
      expect(cc['text'], isNotEmpty);
      expect(cc['text'], 'Thủ đô của Việt Nam?');
      // choices: normalize bank {id, content:{text}, is_correct} -> {id, text, isCorrect}.
      final choices = cc['choices'] as List<dynamic>;
      expect(choices, hasLength(2));
      expect(choices[0]['text'], 'Hà Nội');
      expect(choices[0]['isCorrect'], true);
      expect(choices[1]['text'], 'Đà Nẵng');
      expect(choices[1]['isCorrect'], false);
      // Nested bank đã được gỡ sau resolve.
      expect(resolved.containsKey('questions'), false);
      // Các cột entity bắt buộc vẫn còn để AssignmentQuestion.fromJson parse.
      expect(resolved['id'], 'aq-1');
      expect(resolved['assignment_id'], 'assign-1');
      expect(resolved['order_idx'], 0);
    });

    test('câu bank có override_text + override choices → override thắng', () {
      final row = <String, dynamic>{
        'id': 'aq-2',
        'assignment_id': 'assign-1',
        'question_id': 'q-bank-2',
        'points': 2,
        'order_idx': 1,
        'custom_content': {
          'override_text': 'Câu hỏi đã sửa',
          'choices': [
            {'id': 0, 'text': 'Đáp án sửa A', 'isCorrect': true},
            {'id': 1, 'text': 'Đáp án sửa B', 'isCorrect': false},
          ],
        },
        'questions': {
          'id': 'q-bank-2',
          'type': 'multipleChoice',
          'content': {'text': 'Câu gốc trong kho'},
          'question_choices': [
            {'id': 0, 'content': {'text': 'Gốc A'}, 'is_correct': true},
          ],
        },
      };

      final cc = AssignmentDataSource.resolveGradingRow(row)['custom_content']
          as Map<String, dynamic>;
      expect(cc['type'], 'multiple_choice'); // type vẫn từ bank
      expect(cc['text'], 'Câu hỏi đã sửa'); // override_text thắng
      final choices = cc['choices'] as List<dynamic>;
      expect(choices, hasLength(2));
      expect(choices[0]['text'], 'Đáp án sửa A');
      expect(choices[0]['isCorrect'], true);
    });

    test('câu inline (question_id NULL) lấy type/text từ custom_content', () {
      final row = <String, dynamic>{
        'id': 'aq-3',
        'assignment_id': 'assign-1',
        'question_id': null,
        'points': 2,
        'order_idx': 2,
        'custom_content': {
          'type': 'essay',
          'override_text': 'Giải thích quang hợp',
        },
        'questions': null, // inline không có bank
      };

      final cc = AssignmentDataSource.resolveGradingRow(row)['custom_content']
          as Map<String, dynamic>;
      expect(cc['type'], 'essay');
      expect(cc['text'], 'Giải thích quang hợp');
      expect(cc['choices'], isEmpty);
    });
  });
}
