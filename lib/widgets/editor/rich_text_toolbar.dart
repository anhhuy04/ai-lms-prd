import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Toolbar nhập rich text + ký tự toán học cho TextEditingController.
///
/// Tái sử dụng đúng pattern UI ở màn `teacher_create_question_screen.dart`:
///   B (đậm) / I (nghiêng) / Link / [Image] / Σ (ký tự toán)
///
/// Ký tự toán chèn TRỰC TIẾP (Unicode) vào text — không cần `$...$` wrapper.
///
/// Usage:
/// ```dart
/// RichTextToolbar(
///   controller: _topicController,
///   onPickImage: () => _showImagePicker(),  // null = ẩn nút image
/// )
/// ```
class RichTextToolbar extends StatelessWidget {
  const RichTextToolbar({
    super.key,
    required this.controller,
    this.onPickImage,
  });

  final TextEditingController controller;

  /// Callback khi user nhấn nút image. `null` → ẩn nút image.
  /// Parent tự quản lý image list + preview.
  final VoidCallback? onPickImage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.format_bold_rounded, () => _applyBold(), isDark),
          _btn(Icons.format_italic_rounded, () => _applyItalic(), isDark),
          _btn(
            Icons.link_rounded,
            () => _showLinkDialog(context, isDark),
            isDark,
          ),
          if (onPickImage != null)
            _btn(Icons.image_rounded, onPickImage!, isDark),
          _btn(
            Icons.functions_rounded,
            () => _showMathSymbolDialog(context, isDark),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onPressed, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  // ── Bold / Italic ─────────────────────────────────────────────────────────
  void _applyBold() => _wrapOrInsert('**', '**');
  void _applyItalic() => _wrapOrInsert('*', '*');

  void _wrapOrInsert(String prefix, String suffix) {
    final text = controller.text;
    final selection = controller.selection;
    final hasValidSel = selection.isValid && selection.start >= 0;
    final start = hasValidSel
        ? selection.start.clamp(0, text.length)
        : text.length;
    final end = hasValidSel
        ? selection.end.clamp(0, text.length)
        : text.length;

    if (hasValidSel && start != end) {
      final selectedText = text.substring(start, end);
      final formatted = '$prefix$selectedText$suffix';
      controller.value = TextEditingValue(
        text: text.replaceRange(start, end, formatted),
        selection: TextSelection.collapsed(offset: start + formatted.length),
      );
    } else {
      final insert = '$prefix$suffix';
      controller.value = TextEditingValue(
        text: text.replaceRange(start, end, insert),
        selection: TextSelection.collapsed(offset: start + prefix.length),
      );
    }
  }

  // ── Link dialog ───────────────────────────────────────────────────────────
  void _showLinkDialog(BuildContext context, bool isDark) {
    final linkTextCtrl = TextEditingController();
    final linkUrlCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        ),
        title: Text(
          'Chèn Liên Kết',
          style: DesignTypography.titleMedium.copyWith(
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Văn bản hiển thị',
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            _dlgField(linkTextCtrl, 'Ví dụ: Xem thêm', isDark, autofocus: true),
            const SizedBox(height: 16),
            Text(
              'URL',
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            _dlgField(
              linkUrlCtrl,
              'https://example.com',
              isDark,
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final t = linkTextCtrl.text.trim();
              final u = linkUrlCtrl.text.trim();
              if (t.isEmpty || u.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập đầy đủ văn bản và URL'),
                    backgroundColor: DesignColors.error,
                  ),
                );
                return;
              }
              _insertAtCursor('[$t]($u)');
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Chèn'),
          ),
        ],
      ),
    );
  }

  Widget _dlgField(
    TextEditingController c,
    String hint,
    bool isDark, {
    bool autofocus = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: c,
      autofocus: autofocus,
      keyboardType: keyboardType,
      style: DesignTypography.bodyMedium.copyWith(
        color: isDark ? Colors.white : DesignColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark
            ? Colors.grey[800]!.withValues(alpha: 0.5)
            : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }

  /// Public helper: mở math symbol sheet cho 1 controller (dùng cho icon Σ
  /// đặt rời lẻ — vd nút Σ nhỏ bên cạnh từng đáp án MCQ).
  static void showMathPickerFor(
    BuildContext context,
    TextEditingController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final widget = RichTextToolbar(controller: controller);
    widget._showMathSymbolDialog(context, isDark);
  }

  // ── Math symbol bottom sheet ──────────────────────────────────────────────
  void _showMathSymbolDialog(BuildContext context, bool isDark) {
    // Mở rộng từ list gốc, thêm vài ký tự LaTeX thường gặp ở dạng Unicode.
    const mathSymbols = <Map<String, String>>[
      // Mũ / chỉ số
      {'symbol': '²', 'label': 'x²'},
      {'symbol': '³', 'label': 'x³'},
      {'symbol': 'ⁿ', 'label': 'xⁿ'},
      // Căn
      {'symbol': '√', 'label': '√'},
      {'symbol': '∛', 'label': '∛'},
      {'symbol': '∜', 'label': '∜'},
      // Phân số
      {'symbol': '½', 'label': '½'},
      {'symbol': '⅓', 'label': '⅓'},
      {'symbol': '¼', 'label': '¼'},
      // Tập hợp / quan hệ
      {'symbol': '∈', 'label': '∈'},
      {'symbol': '∉', 'label': '∉'},
      {'symbol': '⊂', 'label': '⊂'},
      {'symbol': '∪', 'label': '∪'},
      {'symbol': '∩', 'label': '∩'},
      {'symbol': '∅', 'label': '∅'},
      // Hằng số / phép tính giải tích
      {'symbol': 'π', 'label': 'π'},
      {'symbol': 'e', 'label': 'e'},
      {'symbol': '∑', 'label': '∑'},
      {'symbol': '∫', 'label': '∫'},
      {'symbol': '∏', 'label': '∏'},
      {'symbol': '∂', 'label': '∂'},
      {'symbol': '∞', 'label': '∞'},
      {'symbol': '∇', 'label': '∇'},
      // Phép toán
      {'symbol': '±', 'label': '±'},
      {'symbol': '∓', 'label': '∓'},
      {'symbol': '×', 'label': '×'},
      {'symbol': '÷', 'label': '÷'},
      {'symbol': '·', 'label': '·'},
      // So sánh
      {'symbol': '≤', 'label': '≤'},
      {'symbol': '≥', 'label': '≥'},
      {'symbol': '≠', 'label': '≠'},
      {'symbol': '≈', 'label': '≈'},
      {'symbol': '≡', 'label': '≡'},
      // Logic / mũi tên
      {'symbol': '→', 'label': '→'},
      {'symbol': '⇒', 'label': '⇒'},
      {'symbol': '⇔', 'label': '⇔'},
      {'symbol': '∀', 'label': '∀'},
      {'symbol': '∃', 'label': '∃'},
      // Hy Lạp
      {'symbol': 'α', 'label': 'α'},
      {'symbol': 'β', 'label': 'β'},
      {'symbol': 'γ', 'label': 'γ'},
      {'symbol': 'δ', 'label': 'δ'},
      {'symbol': 'θ', 'label': 'θ'},
      {'symbol': 'λ', 'label': 'λ'},
      {'symbol': 'μ', 'label': 'μ'},
      {'symbol': 'σ', 'label': 'σ'},
      {'symbol': 'φ', 'label': 'φ'},
      {'symbol': 'ω', 'label': 'ω'},
      {'symbol': 'Δ', 'label': 'Δ'},
      {'symbol': 'Σ', 'label': 'Σ'},
      {'symbol': 'Ω', 'label': 'Ω'},
      // Góc
      {'symbol': '°', 'label': '°'},
      {'symbol': '∠', 'label': '∠'},
      {'symbol': '⊥', 'label': '⊥'},
      {'symbol': '∥', 'label': '∥'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2632) : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DesignRadius.lg * 1.5),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Text(
                  'Chèn Ký Tự Toán Học',
                  style: DesignTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: mathSymbols.length + 1,
                      itemBuilder: (gridCtx, index) {
                        if (index == mathSymbols.length) {
                          return _customExponentTile(gridCtx, isDark);
                        }
                        final s = mathSymbols[index];
                        return _symbolTile(gridCtx, s['symbol']!, isDark);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customExponentTile(BuildContext gridCtx, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(gridCtx);
          _showCustomExponentDialog(gridCtx, isDark);
        },
        borderRadius: BorderRadius.circular(DesignRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: DesignColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignRadius.md),
            border: Border.all(
              color: DesignColors.primary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Icon(
                  Icons.edit_rounded,
                  size: 32,
                  color: DesignColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  'Nhập mũ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    color: DesignColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _symbolTile(BuildContext gridCtx, String symbol, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _insertAtCursor(symbol);
          Navigator.pop(gridCtx);
        },
        borderRadius: BorderRadius.circular(DesignRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey[800]!.withValues(alpha: 0.5)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(DesignRadius.md),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  symbol,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Custom exponent dialog ────────────────────────────────────────────────
  void _showCustomExponentDialog(BuildContext context, bool isDark) {
    final baseCtrl = TextEditingController(text: 'x');
    final expCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        ),
        title: Text(
          'Nhập Số Mũ Tùy Chỉnh',
          style: DesignTypography.titleMedium.copyWith(
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cơ số (mặc định: x)',
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            _dlgField(baseCtrl, 'x', isDark),
            const SizedBox(height: 16),
            Text(
              'Số mũ (ví dụ: 10, 100, 2n)',
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            _dlgField(expCtrl, 'Nhập số mũ...', isDark, autofocus: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final base = baseCtrl.text.trim();
              final exp = expCtrl.text.trim();
              if (exp.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập số mũ'),
                    backgroundColor: DesignColors.error,
                  ),
                );
                return;
              }
              _insertAtCursor('${base.isEmpty ? 'x' : base}^$exp');
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Chèn'),
          ),
        ],
      ),
    );
  }

  // ── Cursor insert helper ──────────────────────────────────────────────────
  void _insertAtCursor(String insert) {
    final text = controller.text;
    final sel = controller.selection;
    final hasValidSel = sel.isValid && sel.start >= 0;
    final start = hasValidSel ? sel.start.clamp(0, text.length) : text.length;
    final end = hasValidSel ? sel.end.clamp(0, text.length) : text.length;
    controller.value = TextEditingValue(
      text: text.replaceRange(start, end, insert),
      selection: TextSelection.collapsed(offset: start + insert.length),
    );
  }
}
