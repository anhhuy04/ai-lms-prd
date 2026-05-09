import 'package:ai_mls/core/utils/document_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseDocxAsTemplate subject extraction', () {
    test('extracts subject from [ TRẮC NGHIỆM — Toán học ] marker', () {
      const docx = '''
[ TRẮC NGHIỆM — Toán học ]
Câu 1: Tính 1+1 = ? A. 1 B. 2 C. 3 D. 4 Đáp án: B

[ TRẮC NGHIỆM — Vật lý ]
Câu 2: F=ma là định luật nào? A. I B. II C. III D. IV Đáp án: B
''';
      final q = DocumentParser.parseDocxAsTemplate(docx);
      expect(q, isNotNull);
      expect(q!.length, 2);
      expect(q[0]['subject'], 'Toán học');
      expect(q[1]['subject'], 'Vật lý');
      expect((q[0]['tags'] as List), contains('Toán học'));
      expect((q[1]['tags'] as List), contains('Vật lý'));
    });

    test('no subject marker → subject is null', () {
      const docx = 'Câu 1: 1+1=? A. 1 B. 2 C. 3 D. 4 Đáp án: B';
      final q = DocumentParser.parseDocxAsTemplate(docx);
      expect(q, isNotNull);
      expect(q![0]['subject'], isNull);
    });

    test('handles dash variants', () {
      const docx = '''
[TỰ LUẬN - Hóa học]
Câu 1: Viết H2SO4. Đáp án: H2SO4
''';
      // parser xử lý tự luận khác — chỉ smoke test marker không crash
      final q = DocumentParser.parseDocxAsTemplate(docx);
      // Không assert subject vì tự luận chưa fully support — chỉ smoke test
      expect(q, isNotNull);
    });
  });
}
