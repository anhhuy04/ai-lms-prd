import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Toolbar chèn ký hiệu LaTeX vào TextEditingController.
///
/// Tái sử dụng được ở:
/// - Edit dialog câu hỏi AI gen
/// - Ô prompt Mode 1 / Lệnh hướng dẫn Mode 3
/// - Màn tạo câu hỏi thủ công (text, đáp án, options, explanation)
///
/// Usage:
/// ```dart
/// MathInputToolbar(
///   controller: _textCtrl,
///   compact: false,           // false = full (Σ ∫ ≤ ≥ ±), true = chỉ cơ bản
///   showFillBlank: false,     // true = thêm nút [___N]
/// )
/// ```
class MathInputToolbar extends StatelessWidget {
  const MathInputToolbar({
    super.key,
    required this.controller,
    this.compact = false,
    this.showFillBlank = false,
  });

  final TextEditingController controller;

  /// `true` = chỉ hiện 5 nút cơ bản ($, √, x², x_n, ½).
  /// `false` = thêm Σ, ∫, ≤, ≥, ±.
  final bool compact;

  /// Hiển thị nút `[___N]` cho fill_blank.
  final bool showFillBlank;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttons = <Widget>[
      _btn('f(x)', r'Bọc bằng $...$', () => _wrapMath(controller), isDark),
      _btn(
        '√',
        r'\sqrt{}',
        () => _insert(controller, r'\sqrt{}', cursorOffsetFromStart: 6),
        isDark,
      ),
      _btn(
        'x²',
        '^{}',
        () => _insert(controller, '^{}', cursorOffsetFromStart: 2),
        isDark,
      ),
      _btn(
        'x_n',
        '_{}',
        () => _insert(controller, '_{}', cursorOffsetFromStart: 2),
        isDark,
      ),
      _btn(
        '½',
        r'\frac{}{}',
        () => _insert(controller, r'\frac{}{}', cursorOffsetFromStart: 6),
        isDark,
      ),
      if (!compact) ...[
        _btn(
          'Σ',
          r'\sum_{}^{}',
          () => _insert(controller, r'\sum_{}^{}', cursorOffsetFromStart: 6),
          isDark,
        ),
        _btn(
          '∫',
          r'\int_{}^{}',
          () => _insert(controller, r'\int_{}^{}', cursorOffsetFromStart: 6),
          isDark,
        ),
        _btn('≤', r'\leq', () => _insert(controller, r'\leq '), isDark),
        _btn('≥', r'\geq', () => _insert(controller, r'\geq '), isDark),
        _btn('±', r'\pm', () => _insert(controller, r'\pm '), isDark),
      ],
      if (showFillBlank)
        _btn('[___N]', 'Thêm ô trống', () => _insertBlank(controller), isDark),
    ];
    return Wrap(spacing: 6, runSpacing: 6, children: buttons);
  }

  Widget _btn(String label, String tooltip, VoidCallback onTap, bool isDark) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isDark
            ? const Color(0xFF1A2632)
            : DesignColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
              border: Border.all(
                color: DesignColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : DesignColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _insert(
    TextEditingController c,
    String snippet, {
    int? cursorOffsetFromStart,
  }) {
    final sel = c.selection;
    final text = c.text;
    final hasValidSel = sel.isValid && sel.start >= 0;
    final start = hasValidSel ? sel.start.clamp(0, text.length) : text.length;
    final end = hasValidSel ? sel.end.clamp(0, text.length) : text.length;
    final newText = text.replaceRange(start, end, snippet);
    final newCursor = start + (cursorOffsetFromStart ?? snippet.length);
    c.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }

  /// Public helper: bọc selection bằng `$...$` cho 1 controller riêng lẻ.
  /// Dùng khi cần wrap nhanh từ icon button bên ngoài toolbar (vd: từng option choice).
  static void wrapMathInController(TextEditingController c) => _wrapMath(c);

  static void _wrapMath(TextEditingController c) {
    final sel = c.selection;
    if (!sel.isValid || sel.start < 0) {
      _insert(c, r'$  $', cursorOffsetFromStart: 2);
      return;
    }
    final selected = c.text.substring(sel.start, sel.end);
    final wrapped = selected.isEmpty ? r'$  $' : '\$$selected\$';
    c.value = TextEditingValue(
      text: c.text.replaceRange(sel.start, sel.end, wrapped),
      selection: TextSelection.collapsed(offset: sel.start + wrapped.length),
    );
  }

  static void _insertBlank(TextEditingController c) {
    final existing = RegExp(r'\[___(\d+)\]').allMatches(c.text);
    final n = existing.length + 1;
    _insert(c, '[___$n]');
  }
}
