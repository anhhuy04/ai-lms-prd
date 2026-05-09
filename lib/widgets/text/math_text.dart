import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Widget render text có chứa LaTeX math.
///
/// Hỗ trợ các delimiter:
/// - `$...$` inline math (single dollar, không escape)
/// - `$$...$$` display math
/// - `\(...\)` inline math (alternate)
/// - `\[...\]` display math (alternate)
///
/// Plain text vẫn render bình thường. Nếu LaTeX parse lỗi, hiển thị literal
/// `$...$` với màu đỏ + monospace để dễ debug.
class MathText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const MathText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
  });

  static final RegExp _pattern = RegExp(
    r'\$\$([\s\S]+?)\$\$'
    r'|\\\[([\s\S]+?)\\\]'
    r'|(?<!\\)\$([^\$\n]+?)\$'
    r'|\\\(([\s\S]+?)\\\)',
  );

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final segments = <Widget>[];
    var cursor = 0;

    for (final match in _pattern.allMatches(text)) {
      if (match.start > cursor) {
        final plain = text.substring(cursor, match.start);
        if (plain.isNotEmpty) {
          segments.add(Text(plain, style: style, textAlign: textAlign));
        }
      }

      final displayDollar = match.group(1);
      final displayBracket = match.group(2);
      final inlineDollar = match.group(3);
      final inlineParen = match.group(4);

      final isDisplay = displayDollar != null || displayBracket != null;
      final content =
          displayDollar ?? displayBracket ?? inlineDollar ?? inlineParen ?? '';

      if (content.trim().isEmpty) {
        // Empty math like `$$` → render literal
        segments.add(Text(match.group(0) ?? '', style: style));
      } else {
        segments.add(
          Math.tex(
            content,
            mathStyle: isDisplay ? MathStyle.display : MathStyle.text,
            textStyle: style,
            onErrorFallback: (err) => Text(
              '\$$content\$',
              style: (style ?? const TextStyle()).copyWith(
                color: Colors.red,
                fontFamily: 'monospace',
              ),
            ),
          ),
        );
      }

      cursor = match.end;
    }

    if (cursor < text.length) {
      final tail = text.substring(cursor);
      if (tail.isNotEmpty) {
        segments.add(Text(tail, style: style, textAlign: textAlign));
      }
    }

    if (segments.isEmpty) return const SizedBox.shrink();
    if (segments.length == 1) return segments.first;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 2,
      children: segments,
    );
  }
}
