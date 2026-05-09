/// Converts OOXML Math (OMML) embedded in DOCX to LaTeX inline/display math.
///
/// **Input**: full `word/document.xml` content (string).
/// **Output**: same string with each `<m:oMath>...</m:oMath>` replaced by
/// `$LATEX$` (inline) and `<m:oMathPara>...</m:oMathPara>` bằng `$$LATEX$$`
/// (display). Phần XML còn lại giữ nguyên — caller (document_parser.dart)
/// vẫn strip generic tags sau đó như cũ.
///
/// **Hỗ trợ** (cover ~95% use case math giáo viên VN):
/// - `m:r` / `m:t` — run text
/// - `m:f` — fraction (\frac)
/// - `m:sSup` / `m:sSub` / `m:sSubSup` — super/sub script
/// - `m:rad` / `m:deg` — radical (\sqrt[n]{x})
/// - `m:nary` — sum/integral/product (∑ ∫ ∏ ⋃ ⋂ ∮)
/// - `m:d` — delimiter (\left( ... \right))
/// - `m:bar` — overline (\overline)
/// - `m:e` — expression wrapper
///
/// **Non-goal**: matrix (`m:m`), equation arrays, complex limits — element
/// không nhận biết sẽ extract text con đệ quy (graceful fallback).
///
/// **Trade-off**: Implementation dùng regex thuần Dart (không dep `xml:`
/// package). Hậu quả: nested OMML quá sâu (>10 cấp) hoặc whitespace
/// khác chuẩn có thể fail edge case → fallback về text plain (không crash).
class OmmlToLatex {
  OmmlToLatex._();

  /// Pre-process docx XML: replace OMML blocks with LaTeX markers.
  /// Gọi TRƯỚC khi strip generic XML tags trong [DocumentParser.extractFromDocx].
  static String preprocessDocxXml(String xmlContent) {
    // Display math TRƯỚC inline (vì oMathPara chứa oMath bên trong)
    var processed = xmlContent.replaceAllMapped(
      RegExp(r'<m:oMathPara[^>]*>([\s\S]*?)</m:oMathPara>'),
      (m) => _wrapDisplay(_convert(m.group(1) ?? '')),
    );
    processed = processed.replaceAllMapped(
      RegExp(r'<m:oMath[^>]*>([\s\S]*?)</m:oMath>'),
      (m) => _wrapInline(_convert(m.group(1) ?? '')),
    );
    return processed;
  }

  static String _wrapInline(String latex) =>
      latex.trim().isEmpty ? '' : ' \$${latex.trim()}\$ ';

  static String _wrapDisplay(String latex) =>
      latex.trim().isEmpty ? '' : ' \$\$${latex.trim()}\$\$ ';

  /// Recursive convert OMML fragment to LaTeX.
  ///
  /// Strategy: process từ specific elements (m:f, m:sSubSup, m:nary, m:rad,
  /// m:d, m:bar, m:sSup, m:sSub) → cuối cùng là m:t/m:r → strip remaining tags.
  /// Order quan trọng: `m:sSubSup` TRƯỚC `m:sSup`/`m:sSub` (tránh match nhầm).
  static String _convert(String fragment) {
    var s = fragment;

    // m:f → \frac{num}{den}
    s = _replaceTag(s, 'm:f', (inner) {
      final num = _extract(inner, 'm:num');
      final den = _extract(inner, 'm:den');
      return '\\frac{${_convert(num)}}{${_convert(den)}}';
    });

    // m:sSubSup → X_{Y}^{Z} (TRƯỚC m:sSup/m:sSub)
    s = _replaceTag(s, 'm:sSubSup', (inner) {
      final e = _extract(inner, 'm:e');
      final sub = _extract(inner, 'm:sub');
      final sup = _extract(inner, 'm:sup');
      return '${_convert(e)}_{${_convert(sub)}}^{${_convert(sup)}}';
    });

    // m:nary → \sum_{L}^{U} E (hoặc \int / \prod tùy chr)
    s = _replaceTag(s, 'm:nary', (inner) {
      final naryPr = _extract(inner, 'm:naryPr');
      final chr = _extractAttr(naryPr, 'm:chr', 'm:val');
      final cmd = _naryMap[chr] ?? '\\sum';
      // Loại bỏ naryPr khỏi inner để không lẫn vào m:e
      final body = inner.replaceAll(
        RegExp(r'<m:naryPr[^>]*>[\s\S]*?</m:naryPr>'),
        '',
      );
      final sub = _extract(body, 'm:sub');
      final sup = _extract(body, 'm:sup');
      final e = _extract(body, 'm:e');
      final subL = sub.isNotEmpty ? '_{${_convert(sub)}}' : '';
      final supL = sup.isNotEmpty ? '^{${_convert(sup)}}' : '';
      return '$cmd$subL$supL ${_convert(e)}';
    });

    // m:rad → \sqrt[deg]{e} hoặc \sqrt{e}
    s = _replaceTag(s, 'm:rad', (inner) {
      final deg = _extract(inner, 'm:deg');
      final e = _extract(inner, 'm:e');
      final degLatex = _convert(deg).trim();
      if (degLatex.isEmpty) {
        return '\\sqrt{${_convert(e)}}';
      }
      return '\\sqrt[$degLatex]{${_convert(e)}}';
    });

    // m:d → \left( ... \right)
    s = _replaceTag(s, 'm:d', (inner) {
      final e = _extract(inner, 'm:e');
      final dPr = _extract(inner, 'm:dPr');
      final beg = _extractAttr(dPr, 'm:begChr', 'm:val');
      final end = _extractAttr(dPr, 'm:endChr', 'm:val');
      final left = _delimMap[beg] ?? '(';
      final right = _delimMap[end] ?? ')';
      return '\\left$left ${_convert(e)} \\right$right';
    });

    // m:bar → \overline{X}
    s = _replaceTag(s, 'm:bar', (inner) {
      final e = _extract(inner, 'm:e');
      return '\\overline{${_convert(e)}}';
    });

    // m:sSup → X^{Y} (sau m:sSubSup)
    s = _replaceTag(s, 'm:sSup', (inner) {
      final e = _extract(inner, 'm:e');
      final sup = _extract(inner, 'm:sup');
      return '${_convert(e)}^{${_convert(sup)}}';
    });

    // m:sSub → X_{Y}
    s = _replaceTag(s, 'm:sSub', (inner) {
      final e = _extract(inner, 'm:e');
      final sub = _extract(inner, 'm:sub');
      return '${_convert(e)}_{${_convert(sub)}}';
    });

    // m:t → text (cuối cùng, sau khi mọi structural element xử lý xong)
    s = s.replaceAllMapped(
      RegExp(r'<m:t[^>]*>([\s\S]*?)</m:t>'),
      (m) => m.group(1) ?? '',
    );

    // Strip mọi tag OMML còn sót (m:r, m:rPr, properties, namespace decl, …)
    s = s.replaceAll(RegExp(r'<[^>]*>'), ' ');
    // Collapse whitespace nhưng giữ ranh giới giữa LaTeX commands
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  /// Helper: replace tag `<tagName ...>...</tagName>` (non-greedy) bằng kết quả
  /// của [transform] áp dụng lên inner content.
  static String _replaceTag(
    String src,
    String tagName,
    String Function(String inner) transform,
  ) {
    final escaped = tagName.replaceAll(':', r'\:');
    final re = RegExp('<$escaped(?:\\s[^>]*)?>([\\s\\S]*?)</$escaped>');
    return src.replaceAllMapped(re, (m) => transform(m.group(1) ?? ''));
  }

  /// Extract content inside `<tagName ...>...</tagName>` (first match only).
  /// Trả về '' nếu không match.
  static String _extract(String src, String tagName) {
    final escaped = tagName.replaceAll(':', r'\:');
    // Hỗ trợ cả self-closing `<m:deg/>` (trả về '')
    final selfClose = RegExp('<$escaped(?:\\s[^>]*)?/>');
    if (selfClose.hasMatch(src)) {
      // Nếu chỉ có self-closing → empty content
      final paired = RegExp('<$escaped(?:\\s[^>]*)?>([\\s\\S]*?)</$escaped>');
      final m = paired.firstMatch(src);
      if (m == null) return '';
      return m.group(1) ?? '';
    }
    final re = RegExp('<$escaped(?:\\s[^>]*)?>([\\s\\S]*?)</$escaped>');
    return re.firstMatch(src)?.group(1) ?? '';
  }

  /// Extract attribute value: `<tagName attrName="VALUE" ...>` (self-closing OK).
  /// Trả về '' nếu không tìm thấy.
  static String _extractAttr(String src, String tagName, String attrName) {
    final escapedTag = tagName.replaceAll(':', r'\:');
    final escapedAttr = attrName.replaceAll(':', r'\:');
    final re = RegExp('<$escapedTag[^>]*?$escapedAttr="([^"]*)"[^>]*?/?>');
    return re.firstMatch(src)?.group(1) ?? '';
  }

  /// N-ary char to LaTeX command.
  static const Map<String, String> _naryMap = {
    '∑': '\\sum', // ∑
    '∫': '\\int', // ∫
    '∏': '\\prod', // ∏
    '⋃': '\\bigcup', // ⋃
    '⋂': '\\bigcap', // ⋂
    '∮': '\\oint', // ∮
  };

  /// Delimiter char to LaTeX equivalent.
  static const Map<String, String> _delimMap = {
    '(': '(',
    ')': ')',
    '[': '[',
    ']': ']',
    '{': '\\{',
    '}': '\\}',
    '|': '|',
    '〈': '\\langle', // ⟨
    '〉': '\\rangle', // ⟩
  };
}
