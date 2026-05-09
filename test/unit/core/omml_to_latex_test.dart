import 'package:ai_mls/core/utils/omml_to_latex.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OmmlToLatex', () {
    test('fraction 1/2', () {
      final input = '<m:oMath><m:f><m:num><m:r><m:t>1</m:t></m:r></m:num><m:den><m:r><m:t>2</m:t></m:r></m:den></m:f></m:oMath>';
      final out = OmmlToLatex.preprocessDocxXml(input);
      expect(out.trim(), r'$\frac{1}{2}$');
    });

    test('superscript x^2', () {
      final input = '<m:oMath><m:sSup><m:e><m:r><m:t>x</m:t></m:r></m:e><m:sup><m:r><m:t>2</m:t></m:r></m:sup></m:sSup></m:oMath>';
      final out = OmmlToLatex.preprocessDocxXml(input);
      expect(out.trim(), r'$x^{2}$');
    });

    test('subscript a_i', () {
      final input = '<m:oMath><m:sSub><m:e><m:r><m:t>a</m:t></m:r></m:e><m:sub><m:r><m:t>i</m:t></m:r></m:sub></m:sSub></m:oMath>';
      final out = OmmlToLatex.preprocessDocxXml(input);
      expect(out.trim(), r'$a_{i}$');
    });

    test('sqrt without degree', () {
      final input = '<m:oMath><m:rad><m:deg/><m:e><m:r><m:t>x</m:t></m:r></m:e></m:rad></m:oMath>';
      final out = OmmlToLatex.preprocessDocxXml(input);
      expect(out.trim(), r'$\sqrt{x}$');
    });

    test('sum from i=1 to n', () {
      final input = '<m:oMath><m:nary><m:naryPr><m:chr m:val="∑"/></m:naryPr><m:sub><m:r><m:t>i=1</m:t></m:r></m:sub><m:sup><m:r><m:t>n</m:t></m:r></m:sup><m:e><m:r><m:t>i</m:t></m:r></m:e></m:nary></m:oMath>';
      final out = OmmlToLatex.preprocessDocxXml(input);
      expect(out.trim(), contains(r'\sum'));
      expect(out.trim(), contains(r'_{i=1}'));
      expect(out.trim(), contains(r'^{n}'));
    });

    test('display math wrapper', () {
      final input = '<m:oMathPara><m:r><m:t>x+1=0</m:t></m:r></m:oMathPara>';
      final out = OmmlToLatex.preprocessDocxXml(input);
      expect(out.trim(), r'$$x+1=0$$');
    });

    test('empty oMath produces no output', () {
      final input = '<m:oMath></m:oMath>';
      final out = OmmlToLatex.preprocessDocxXml(input);
      expect(out.trim(), '');
    });

    test('non-OMML text passes through unchanged', () {
      final input = '<w:p><w:r><w:t>Câu 1: 1+1 = ?</w:t></w:r></w:p>';
      final out = OmmlToLatex.preprocessDocxXml(input);
      expect(out, input); // Không có OMML → không đổi
    });
  });
}
