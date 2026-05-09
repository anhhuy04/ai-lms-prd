import 'package:ai_mls/core/utils/latex_to_omml.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LatexToOmml', () {
    test('plain text no math', () {
      final out = LatexToOmml.convertParagraphContent('Câu 1: Hello');
      expect(out, contains('<w:r><w:t'));
      expect(out, contains('Câu 1: Hello'));
      expect(out, isNot(contains('<m:oMath')));
    });

    test('inline frac 1/2', () {
      final out = LatexToOmml.convertParagraphContent(r'Tính $\frac{1}{2}$ là?');
      expect(out, contains('<m:oMath>'));
      expect(out, contains('<m:f>'));
      expect(out, contains('<m:num>'));
      expect(out, contains('<m:den>'));
    });

    test('display math', () {
      final out = LatexToOmml.convertParagraphContent(r'$$x+1=0$$');
      expect(out, contains('<m:oMathPara>'));
    });

    test('sup x^2', () {
      final out = LatexToOmml.convertParagraphContent(r'$x^{2}$');
      expect(out, contains('<m:sSup>'));
    });

    test('sqrt x', () {
      final out = LatexToOmml.convertParagraphContent(r'$\sqrt{x}$');
      expect(out, contains('<m:rad>'));
      expect(out, contains('<m:deg/>'));
    });

    test('sum with limits', () {
      final out = LatexToOmml.convertParagraphContent(r'$\sum_{i=1}^{n} i$');
      expect(out, contains('<m:nary>'));
      expect(out, contains(r'm:val="∑"'));
    });

    test('greek alpha', () {
      final out = LatexToOmml.convertParagraphContent(r'$\alpha$');
      expect(out, contains('α'));
    });

    test('xml escape ampersand', () {
      final out = LatexToOmml.convertParagraphContent('A & B');
      expect(out, contains('&amp;'));
      expect(out, isNot(contains('A & B')));
    });
  });
}
