/// Converts LaTeX inline math (`$...$`, `$$...$$`, `\(...\)`, `\[...\]`)
/// embedded trong text sang OMML XML để chèn vào `w:p` paragraph khi xuất Word.
///
/// **Đối ngẫu** với [OmmlToLatex] (`omml_to_latex.dart`).
///
/// **Input**: chuỗi text như `"Tính $\\frac{1}{2}+\\frac{1}{4}$ bằng?"`.
/// **Output**: chuỗi XML các `<w:r>...</w:r>` (plain) và `<m:oMath>...</m:oMath>`
/// hoặc `<m:oMathPara>...</m:oMathPara>` (math) embed thẳng vào paragraph.
///
/// **Hỗ trợ**:
/// - Delimiter: `$inline$`, `$$display$$`, `\(inline\)`, `\[display\]`.
/// - `\frac{A}{B}`, `\sqrt{X}`, `\sqrt[N]{X}`.
/// - `X^{Y}`, `X_{Y}`, `X_{Y}^{Z}` (sup/sub/subSup).
/// - `\sum`, `\int`, `\prod` với `_{L}^{U}`.
/// - Greek `\alpha..\omega`, symbol `\leq`, `\geq`, `\pm`, `\times`, ...
///
/// **Trade-off**: regex thuần Dart (no `xml:` package). Brace lồng xử lý
/// bằng walker char-by-char (depth counter). Matrix, equation array, nhiều
/// command hiếm bỏ qua → fallback render literal text trong `<m:t>`.
class LatexToOmml {
  LatexToOmml._();

  /// LaTeX command → Unicode (replace plain trong math context).
  static const Map<String, String> _commandToUnicode = {
    r'\leq': '≤', r'\geq': '≥', r'\neq': '≠', r'\pm': '±', r'\mp': '∓',
    r'\cdot': '·', r'\times': '×', r'\div': '÷', r'\approx': '≈',
    r'\equiv': '≡', r'\to': '→', r'\rightarrow': '→', r'\leftarrow': '←',
    r'\Rightarrow': '⇒', r'\Leftarrow': '⇐', r'\infty': '∞',
    r'\partial': '∂', r'\nabla': '∇',
    // Greek lowercase
    r'\alpha': 'α', r'\beta': 'β', r'\gamma': 'γ', r'\delta': 'δ',
    r'\epsilon': 'ε', r'\zeta': 'ζ', r'\eta': 'η', r'\theta': 'θ',
    r'\iota': 'ι', r'\kappa': 'κ', r'\lambda': 'λ', r'\mu': 'μ',
    r'\nu': 'ν', r'\xi': 'ξ', r'\pi': 'π', r'\rho': 'ρ',
    r'\sigma': 'σ', r'\tau': 'τ', r'\upsilon': 'υ', r'\phi': 'φ',
    r'\chi': 'χ', r'\psi': 'ψ', r'\omega': 'ω',
    // Greek uppercase
    r'\Gamma': 'Γ', r'\Delta': 'Δ', r'\Theta': 'Θ', r'\Lambda': 'Λ',
    r'\Xi': 'Ξ', r'\Pi': 'Π', r'\Sigma': 'Σ', r'\Phi': 'Φ',
    r'\Psi': 'Ψ', r'\Omega': 'Ω',
  };

  /// N-ary command → Unicode operator char.
  static const Map<String, String> _naryCommands = {
    r'\sum': '∑',
    r'\int': '∫',
    r'\prod': '∏',
    r'\bigcup': '⋃',
    r'\bigcap': '⋂',
    r'\oint': '∮',
  };

  /// Convert text có lẫn LaTeX delimiter sang OMML XML inline.
  static String convertParagraphContent(String text) {
    if (text.isEmpty) return '';

    // Order ưu tiên display TRƯỚC inline ($$ trước $, \[ trước \().
    final pattern = RegExp(
      r'\$\$([\s\S]+?)\$\$'
      r'|\\\[([\s\S]+?)\\\]'
      r'|(?<!\\)\$([^\$\n]+?)\$'
      r'|\\\(([\s\S]+?)\\\)',
    );

    final buffer = StringBuffer();
    var lastEnd = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > lastEnd) {
        buffer.write(_plainRun(text.substring(lastEnd, match.start)));
      }
      final isDisplay = match.group(1) != null || match.group(2) != null;
      final raw = match.group(1) ??
          match.group(2) ??
          match.group(3) ??
          match.group(4) ??
          '';
      if (raw.trim().isEmpty) {
        buffer.write(_plainRun(text.substring(match.start, match.end)));
      } else {
        final inner = _convertLatex(raw);
        buffer.write(
          isDisplay
              ? '<m:oMathPara><m:oMath>$inner</m:oMath></m:oMathPara>'
              : '<m:oMath>$inner</m:oMath>',
        );
      }
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      buffer.write(_plainRun(text.substring(lastEnd)));
    }
    return buffer.toString();
  }

  /// Plain text outside math → `<w:r><w:t xml:space="preserve">...</w:t></w:r>`.
  static String _plainRun(String text) {
    if (text.isEmpty) return '';
    return '<w:r><w:t xml:space="preserve">${_xmlEscape(text)}</w:t></w:r>';
  }

  static String _xmlEscape(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');

  /// Recursive LaTeX → OMML inner content (KHÔNG có wrapper `m:oMath`).
  /// Order: từ command đặc thù (frac/sqrt/nary) → script (subSup/sup/sub)
  /// → unicode mapping → text fallback.
  static String _convertLatex(String latex) {
    final buf = StringBuffer();
    var i = 0;
    while (i < latex.length) {
      final ch = latex[i];

      // Whitespace skip (LaTeX không quan tâm space giữa command)
      if (ch == ' ' || ch == '\t' || ch == '\n') {
        i++;
        continue;
      }

      // Backslash command
      if (ch == r'\') {
        final cmdMatch = RegExp(r'\\[a-zA-Z]+').matchAsPrefix(latex, i);
        if (cmdMatch != null) {
          final cmd = cmdMatch.group(0)!;
          final result = _handleCommand(cmd, latex, cmdMatch.end);
          buf.write(result.xml);
          i = result.nextIdx;
          continue;
        }
        // \\ unknown → skip
        i++;
        continue;
      }

      // Brace expression (đứng đơn): treat content as expr
      if (ch == '{') {
        final ext = _extractBraced(latex, i);
        if (ext != null) {
          buf.write(_convertLatex(ext.content));
          i = ext.endIdx;
          continue;
        }
      }

      // Subscript / superscript chỉ xử lý khi có `_{...}`/`^{...}` đứng RIÊNG
      // (subSup/sup/sub đã ưu tiên xử lý qua _maybeScript khi bắt đầu token).
      // Token thường: build từ sequence ký tự "thường" rồi kiểm sub/sup.
      final tokenEnd = _readToken(latex, i);
      final token = latex.substring(i, tokenEnd);
      final scriptResult = _maybeScript(token, latex, tokenEnd);
      if (scriptResult != null) {
        buf.write(scriptResult.xml);
        i = scriptResult.nextIdx;
        continue;
      }
      buf.write(_textRun(token));
      i = tokenEnd;
    }
    return buf.toString();
  }

  /// Đọc 1 token "base" cho sub/sup: 1 ký tự (chữ/số/ký hiệu) hoặc `\command`.
  static int _readToken(String s, int start) {
    if (start >= s.length) return start;
    return start + 1;
  }

  /// Xử lý `\command` tại vị trí sau command. Trả về (xml, nextIdx).
  static _CmdResult _handleCommand(String cmd, String src, int idx) {
    // \frac{A}{B}
    if (cmd == r'\frac') {
      final a = _extractBraced(src, _skipSpace(src, idx));
      if (a == null) return _CmdResult(_textRun(cmd), idx);
      final b = _extractBraced(src, _skipSpace(src, a.endIdx));
      if (b == null) return _CmdResult(_textRun(cmd), idx);
      final num = _convertLatex(a.content);
      final den = _convertLatex(b.content);
      return _CmdResult(
        '<m:f><m:num>$num</m:num><m:den>$den</m:den></m:f>',
        b.endIdx,
      );
    }

    // \sqrt[N]{X} hoặc \sqrt{X}
    if (cmd == r'\sqrt') {
      var p = _skipSpace(src, idx);
      String degXml = '<m:deg/>';
      if (p < src.length && src[p] == '[') {
        final degExt = _extractBracket(src, p);
        if (degExt != null) {
          degXml = '<m:deg>${_convertLatex(degExt.content)}</m:deg>';
          p = degExt.endIdx;
        }
      }
      final body = _extractBraced(src, _skipSpace(src, p));
      if (body == null) return _CmdResult(_textRun(cmd), idx);
      return _CmdResult(
        '<m:rad>$degXml<m:e>${_convertLatex(body.content)}</m:e></m:rad>',
        body.endIdx,
      );
    }

    // \sum, \int, \prod (n-ary). Có thể follow _{L}^{U} hoặc ^{U}_{L}.
    final naryChr = _naryCommands[cmd];
    if (naryChr != null) {
      return _handleNary(naryChr, src, idx);
    }

    // Unicode mapping
    final uni = _commandToUnicode[cmd];
    if (uni != null) return _CmdResult(_textRun(uni), idx);

    // Unknown command → render literal
    return _CmdResult(_textRun(cmd), idx);
  }

  /// Parse `_{L}` và `^{U}` (cả 2 thứ tự) sau n-ary command.
  static _CmdResult _handleNary(String chr, String src, int idx) {
    String? sub;
    String? sup;
    var p = _skipSpace(src, idx);
    for (var k = 0; k < 2; k++) {
      if (p >= src.length) break;
      if (src[p] == '_' && sub == null) {
        final ext = _extractScriptArg(src, p + 1);
        if (ext == null) break;
        sub = _convertLatex(ext.content);
        p = _skipSpace(src, ext.endIdx);
      } else if (src[p] == '^' && sup == null) {
        final ext = _extractScriptArg(src, p + 1);
        if (ext == null) break;
        sup = _convertLatex(ext.content);
        p = _skipSpace(src, ext.endIdx);
      } else {
        break;
      }
    }
    final subXml = sub == null ? '<m:sub></m:sub>' : '<m:sub>$sub</m:sub>';
    final supXml = sup == null ? '<m:sup></m:sup>' : '<m:sup>$sup</m:sup>';
    final xml =
        '<m:nary><m:naryPr><m:chr m:val="$chr"/></m:naryPr>$subXml$supXml<m:e></m:e></m:nary>';
    return _CmdResult(xml, p);
  }

  /// Sau khi đọc 1 base token (1 char), kiểm tra có `_{...}^{...}` /
  /// `^{...}_{...}` / `_{...}` / `^{...}` không. Nếu có → tạo sSubSup/sSup/sSub.
  /// KHÔNG đệ quy `_convertLatex(token)` vì token chỉ 1 char → tránh stack overflow.
  static _ScriptResult? _maybeScript(String token, String src, int idx) {
    var p = _skipSpace(src, idx);
    if (p >= src.length || (src[p] != '_' && src[p] != '^')) {
      return null;
    }
    final baseXml = _textRun(token);
    String? sub;
    String? sup;
    for (var k = 0; k < 2; k++) {
      if (p >= src.length) break;
      if (src[p] == '_' && sub == null) {
        final ext = _extractScriptArg(src, p + 1);
        if (ext == null) break;
        sub = _convertLatex(ext.content);
        p = ext.endIdx;
      } else if (src[p] == '^' && sup == null) {
        final ext = _extractScriptArg(src, p + 1);
        if (ext == null) break;
        sup = _convertLatex(ext.content);
        p = ext.endIdx;
      } else {
        break;
      }
    }
    if (sub == null && sup == null) return null;
    if (sub != null && sup != null) {
      return _ScriptResult(
        '<m:sSubSup><m:e>$baseXml</m:e><m:sub>$sub</m:sub><m:sup>$sup</m:sup></m:sSubSup>',
        p,
      );
    }
    if (sup != null) {
      return _ScriptResult(
        '<m:sSup><m:e>$baseXml</m:e><m:sup>$sup</m:sup></m:sSup>',
        p,
      );
    }
    return _ScriptResult(
      '<m:sSub><m:e>$baseXml</m:e><m:sub>$sub</m:sub></m:sSub>',
      p,
    );
  }

  /// Extract `{...}` balanced bắt đầu tại idx (phải là `{`).
  static _Braced? _extractBraced(String s, int idx) {
    if (idx >= s.length || s[idx] != '{') return null;
    var depth = 0;
    for (var i = idx; i < s.length; i++) {
      if (s[i] == '{') {
        depth++;
      } else if (s[i] == '}') {
        depth--;
        if (depth == 0) {
          return _Braced(s.substring(idx + 1, i), i + 1);
        }
      }
    }
    return null;
  }

  /// Extract `[...]` (cho `\sqrt[N]{X}`) bắt đầu tại idx (phải là `[`).
  static _Braced? _extractBracket(String s, int idx) {
    if (idx >= s.length || s[idx] != '[') return null;
    var depth = 0;
    for (var i = idx; i < s.length; i++) {
      if (s[i] == '[') {
        depth++;
      } else if (s[i] == ']') {
        depth--;
        if (depth == 0) return _Braced(s.substring(idx + 1, i), i + 1);
      }
    }
    return null;
  }

  /// Sau `_` hoặc `^`: arg có thể là `{...}` hoặc 1 char (vd `x^2`).
  static _Braced? _extractScriptArg(String s, int idx) {
    if (idx >= s.length) return null;
    if (s[idx] == '{') return _extractBraced(s, idx);
    // Single char (hoặc \command)
    if (s[idx] == r'\') {
      final m = RegExp(r'\\[a-zA-Z]+').matchAsPrefix(s, idx);
      if (m != null) return _Braced(m.group(0)!, m.end);
    }
    return _Braced(s[idx], idx + 1);
  }

  static int _skipSpace(String s, int idx) {
    var p = idx;
    while (p < s.length && (s[p] == ' ' || s[p] == '\t' || s[p] == '\n')) {
      p++;
    }
    return p;
  }

  /// Render text node trong math context: `<m:r><m:t>...</m:t></m:r>`.
  /// Empty → ''.
  static String _textRun(String text) {
    if (text.isEmpty) return '';
    return '<m:r><m:t>${_xmlEscape(text)}</m:t></m:r>';
  }
}

/// Result helper structs.
class _CmdResult {
  final String xml;
  final int nextIdx;
  const _CmdResult(this.xml, this.nextIdx);
}

class _ScriptResult {
  final String xml;
  final int nextIdx;
  const _ScriptResult(this.xml, this.nextIdx);
}

class _Braced {
  final String content;
  final int endIdx;
  const _Braced(this.content, this.endIdx);
}
