// Verify isTemplateStyleDoc detects various marker styles correctly.
import 'package:ai_mls/core/services/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isTemplateStyleDoc', () {
    test('detects "Câu N:" markers', () {
      final t = '''Câu 1: 2+2 = ?
Câu 2: 3*5 = ?
Câu 3: 10-7 = ?''';
      expect(AiService.isTemplateStyleDoc(t), isTrue);
    });

    test('detects "Bài tập N." markers', () {
      final t = '''Bài tập 1. Tính diện tích.
Bài tập 2. Tính chu vi.''';
      expect(AiService.isTemplateStyleDoc(t), isTrue);
    });

    test('does NOT detect numbered theory list', () {
      final t = '''1. Quang hợp
Quang hợp là quá trình thực vật...
2. Hô hấp tế bào
Hô hấp diễn ra ở ti thể...
3. Phân bào
Phân bào gồm các pha...''';
      expect(AiService.isTemplateStyleDoc(t), isFalse);
    });

    test('detects "Exercise N:" with MCQ choices', () {
      final t = '''Exercise 1: What is 2+2?
A. 3
B. 4
C. 5
D. 6
Exercise 2: What is the capital of Vietnam?
A. Hanoi
B. Saigon
C. Hue
D. Danang''';
      expect(AiService.isTemplateStyleDoc(t), isTrue);
    });

    test('detects MCQ structure + answer marker without explicit Q markers', () {
      final t = '''Question text 1?
A. choice1
B. choice2
C. choice3
D. choice4
Đáp án: B
Question text 2?
A. choice1
B. choice2
C. choice3
D. choice4
Đáp án: A''';
      expect(AiService.isTemplateStyleDoc(t), isTrue);
    });

    test('returns false for empty / whitespace', () {
      expect(AiService.isTemplateStyleDoc(''), isFalse);
      expect(AiService.isTemplateStyleDoc('   \n  \t  '), isFalse);
    });

    test('does NOT detect theory with single Q marker', () {
      final t = '''Chương 3: Quang hợp
Quang hợp là quá trình thực vật chuyển đổi ánh sáng thành năng lượng hoá học.
Câu 1: Có thể tham khảo bài tập sau (không phải đề chính)
Phần lý thuyết tiếp tục với chu trình Calvin và các giai đoạn khác.''';
      expect(AiService.isTemplateStyleDoc(t), isFalse);
    });

    test('detects "Q1:" shorthand', () {
      final t = '''Q1: Define DNA.
Q2: What is RNA?
Q3: Explain transcription.''';
      expect(AiService.isTemplateStyleDoc(t), isTrue);
    });

    test('detects "Bài N)" closing paren', () {
      final t = '''Bài 1) Tính tổng.
Bài 2) Tính hiệu.''';
      expect(AiService.isTemplateStyleDoc(t), isTrue);
    });

    test('detects "Ví dụ N:" markers', () {
      final t = '''Ví dụ 1: Cho hàm số y = 2x.
Ví dụ 2: Cho hàm số y = x^2.''';
      expect(AiService.isTemplateStyleDoc(t), isTrue);
    });
  });
}
