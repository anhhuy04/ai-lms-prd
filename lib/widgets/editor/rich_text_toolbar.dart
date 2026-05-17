import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/text/math_text.dart';
import 'package:flutter/material.dart';

/// Toolbar nhập rich text + ký tự toán/hoá học cho [TextEditingController].
///
/// Khi user bấm Σ (functions), mở bottom sheet 5 tab (Toán cơ bản / Đại số
/// & Giải tích / Lượng giác & Hình học / Hoá học / Hy Lạp & Vector). Mỗi tile
/// hiển thị **rendered math** (qua [MathText]) để user nhìn thấy kết quả ngay.
///
/// Output luôn là LaTeX wrap `$...$` để đồng nhất với format AI generate
/// (`Giải phương trình: $\frac{2x+1}{3} = \frac{x-2}{2}$`). Smart wrap: nếu
/// cursor đang ở giữa `$...$` thì chèn raw LaTeX (không wrap thêm).
///
/// Template phức tạp (phân số, mũ, tích phân, ma trận, công thức hoá...) mở
/// dialog phụ với ô nhập theo tên thông thường (`Tử số`/`Mẫu số`) + preview
/// live → user KHÔNG cần biết LaTeX syntax.
class RichTextToolbar extends StatelessWidget {
  const RichTextToolbar({
    super.key,
    required this.controller,
    this.onPickImage,
  });

  final TextEditingController controller;

  /// Callback khi user nhấn nút image. `null` → ẩn nút image.
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
            () => _showMathBottomSheet(context, isDark),
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

  /// Public helper: mở math bottom sheet cho 1 controller (icon Σ rời lẻ).
  static void showMathPickerFor(
    BuildContext context,
    TextEditingController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final widget = RichTextToolbar(controller: controller);
    widget._showMathBottomSheet(context, isDark);
  }

  // ── Math bottom sheet (5 tab) ────────────────────────────────────────────
  void _showMathBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _MathBottomSheet(
        isDark: isDark,
        onInsert: (latex, {bool isComplete = false}) {
          if (isComplete) {
            // Template từ builder dialog đã wrap sẵn → insert nguyên xi
            _insertAtCursor(latex);
          } else {
            // Symbol đơn — smart wrap
            _insertLatex(latex);
          }
        },
      ),
    );
  }

  // ── Smart LaTeX insert ───────────────────────────────────────────────────

  /// Chèn LaTeX [latex] vào cursor. Nếu cursor đang ở giữa `$...$` thì chèn
  /// raw (không wrap thêm); ngược lại wrap `$...$`.
  void _insertLatex(String latex) {
    final text = controller.text;
    final sel = controller.selection;
    final hasValidSel = sel.isValid && sel.start >= 0;
    final pos = hasValidSel ? sel.start.clamp(0, text.length) : text.length;

    final inside = _isInsideMathBlock(text, pos);
    final payload = inside ? latex : '\$$latex\$';
    _insertAtCursor(payload);
  }

  /// Đếm số `$` không escape trước [pos]; lẻ = đang trong block math.
  static bool _isInsideMathBlock(String text, int pos) {
    var count = 0;
    for (var i = 0; i < pos && i < text.length; i++) {
      if (text[i] == r'$' && (i == 0 || text[i - 1] != r'\')) count++;
    }
    return count.isOdd;
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

// ═══════════════════════════════════════════════════════════════════════════
// MATH BOTTOM SHEET (5 categorized tabs)
// ═══════════════════════════════════════════════════════════════════════════

/// Callback chèn LaTeX. Khi [isComplete] = `true`, [latex] đã wrap đủ `$...$`
/// (do builder dialog tạo) → insert nguyên xi. Ngược lại smart-wrap ở caller.
typedef _InsertCallback = void Function(String latex, {bool isComplete});

class _MathBottomSheet extends StatelessWidget {
  const _MathBottomSheet({required this.isDark, required this.onInsert});

  final bool isDark;
  final _InsertCallback onInsert;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
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
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.functions_rounded,
                      size: 20,
                      color: DesignColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Chèn công thức toán & hoá học',
                        style: DesignTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : DesignColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Hướng dẫn',
                      onPressed: () => _showMathHelpDialog(context, isDark),
                      icon: Icon(
                        Icons.help_outline_rounded,
                        size: 20,
                        color: DesignColors.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Help banner
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: DesignColors.info.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(DesignRadius.md),
                    border: Border.all(
                      color: DesignColors.info.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 16,
                        color: DesignColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bấm vào ô để chèn — KHÔNG cần gõ LaTeX. '
                          'Công thức phức tạp sẽ mở ô nhập tử/mẫu/cận tự động.',
                          style: DesignTypography.bodySmall.copyWith(
                            color: DesignColors.info,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // TabBar
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                ),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: DesignColors.primary,
                  unselectedLabelColor: isDark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                  indicatorColor: DesignColors.primary,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Toán cơ bản'),
                    Tab(text: 'Đại số / Giải tích'),
                    Tab(text: 'Lượng giác / Hình'),
                    Tab(text: 'Hoá học'),
                    Tab(text: 'Hy Lạp / Vector'),
                  ],
                ),
              ),
              // TabBarView
              Flexible(
                child: TabBarView(
                  children: [
                    _BasicMathTab(isDark: isDark, onInsert: onInsert),
                    _AlgebraCalculusTab(isDark: isDark, onInsert: onInsert),
                    _GeometryTab(isDark: isDark, onInsert: onInsert),
                    _ChemistryTab(isDark: isDark, onInsert: onInsert),
                    _GreekVectorTab(isDark: isDark, onInsert: onInsert),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tile types: SimpleTile (1-tap insert) | BuilderTile (open dialog)
// ═══════════════════════════════════════════════════════════════════════════

sealed class _MathTile {
  const _MathTile(this.label, this.preview);
  final String label;
  final String preview; // LaTeX để render preview tile (đã có $...$)
}

class _SimpleTile extends _MathTile {
  const _SimpleTile({
    required String label,
    required String preview,
    required this.latex,
  }) : super(label, preview);

  /// LaTeX raw (KHÔNG `$...$` — sẽ được smart-wrap bởi caller).
  final String latex;
}

class _BuilderTile extends _MathTile {
  const _BuilderTile({
    required String label,
    required String preview,
    required this.openBuilder,
  }) : super(label, preview);

  final void Function(BuildContext, bool isDark, _InsertCallback) openBuilder;
}

Widget _buildTileGrid({
  required bool isDark,
  required List<_MathTile> tiles,
  required _InsertCallback onInsert,
}) {
  return Padding(
    padding: const EdgeInsets.all(12),
    child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 110,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: tiles.length,
      itemBuilder: (ctx, i) {
        final t = tiles[i];
        final isBuilder = t is _BuilderTile;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (isBuilder) {
                Navigator.pop(ctx);
                t.openBuilder(ctx, isDark, onInsert);
              } else {
                final s = t as _SimpleTile;
                onInsert(s.latex);
                Navigator.pop(ctx);
              }
            },
            borderRadius: BorderRadius.circular(DesignRadius.md),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isBuilder
                    ? DesignColors.primary.withValues(alpha: 0.08)
                    : (isDark
                        ? Colors.grey[800]!.withValues(alpha: 0.5)
                        : Colors.grey[100]),
                borderRadius: BorderRadius.circular(DesignRadius.md),
                border: Border.all(
                  color: isBuilder
                      ? DesignColors.primary.withValues(alpha: 0.3)
                      : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
                  width: isBuilder ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: MathText(
                        t.preview,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? Colors.white
                              : DesignColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: isBuilder
                          ? DesignColors.primary
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      fontWeight: isBuilder
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 1: Toán cơ bản
// ═══════════════════════════════════════════════════════════════════════════

class _BasicMathTab extends StatelessWidget {
  const _BasicMathTab({required this.isDark, required this.onInsert});
  final bool isDark;
  final _InsertCallback onInsert;

  @override
  Widget build(BuildContext context) {
    final tiles = <_MathTile>[
      _BuilderTile(
        label: 'Phân số',
        preview: r'$\frac{a}{b}$',
        openBuilder: _openFractionBuilder,
      ),
      _BuilderTile(
        label: 'Căn bậc n',
        preview: r'$\sqrt[n]{x}$',
        openBuilder: _openSqrtBuilder,
      ),
      _BuilderTile(
        label: 'Mũ',
        preview: r'$x^{n}$',
        openBuilder: (ctx, dark, cb) => _openPowerBuilder(
          ctx,
          dark,
          cb,
          isSubscript: false,
        ),
      ),
      _BuilderTile(
        label: 'Chỉ số dưới',
        preview: r'$x_{i}$',
        openBuilder: (ctx, dark, cb) => _openPowerBuilder(
          ctx,
          dark,
          cb,
          isSubscript: true,
        ),
      ),
      _BuilderTile(
        label: 'Logarit',
        preview: r'$\log_{a}{x}$',
        openBuilder: _openLogBuilder,
      ),
      // Symbols 1-tap
      _SimpleTile(label: 'pi', preview: r'$\pi$', latex: r'\pi'),
      _SimpleTile(label: 'e', preview: r'$e$', latex: 'e'),
      _SimpleTile(label: 'vô cực', preview: r'$\infty$', latex: r'\infty'),
      _SimpleTile(label: '±', preview: r'$\pm$', latex: r'\pm'),
      _SimpleTile(label: '∓', preview: r'$\mp$', latex: r'\mp'),
      _SimpleTile(label: '×', preview: r'$\times$', latex: r'\times'),
      _SimpleTile(label: '÷', preview: r'$\div$', latex: r'\div'),
      _SimpleTile(label: '·', preview: r'$\cdot$', latex: r'\cdot'),
      _SimpleTile(label: '≤', preview: r'$\leq$', latex: r'\leq'),
      _SimpleTile(label: '≥', preview: r'$\geq$', latex: r'\geq'),
      _SimpleTile(label: '≠', preview: r'$\neq$', latex: r'\neq'),
      _SimpleTile(label: '≈', preview: r'$\approx$', latex: r'\approx'),
      _SimpleTile(label: '≡', preview: r'$\equiv$', latex: r'\equiv'),
    ];
    return _buildTileGrid(isDark: isDark, tiles: tiles, onInsert: onInsert);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 2: Đại số / Giải tích
// ═══════════════════════════════════════════════════════════════════════════

class _AlgebraCalculusTab extends StatelessWidget {
  const _AlgebraCalculusTab({required this.isDark, required this.onInsert});
  final bool isDark;
  final _InsertCallback onInsert;

  @override
  Widget build(BuildContext context) {
    final tiles = <_MathTile>[
      _BuilderTile(
        label: 'Sigma Σ',
        preview: r'$\sum_{i=1}^{n}$',
        openBuilder: (ctx, dark, cb) =>
            _openLimitsBuilder(ctx, dark, cb, latex: r'\sum', label: 'Sigma'),
      ),
      _BuilderTile(
        label: 'Tích phân',
        preview: r'$\int_{a}^{b}$',
        openBuilder: (ctx, dark, cb) =>
            _openLimitsBuilder(ctx, dark, cb, latex: r'\int', label: 'Tích phân'),
      ),
      _BuilderTile(
        label: 'Tích Π',
        preview: r'$\prod_{i=1}^{n}$',
        openBuilder: (ctx, dark, cb) =>
            _openLimitsBuilder(ctx, dark, cb, latex: r'\prod', label: 'Tích'),
      ),
      _BuilderTile(
        label: 'Giới hạn',
        preview: r'$\lim_{x \to 0}$',
        openBuilder: _openLimitBuilder,
      ),
      _BuilderTile(
        label: 'Hệ phương trình',
        preview: r'$\begin{cases} x \\ y \end{cases}$',
        openBuilder: _openCasesBuilder,
      ),
      _SimpleTile(label: '∂', preview: r'$\partial$', latex: r'\partial'),
      _SimpleTile(label: '∇', preview: r'$\nabla$', latex: r'\nabla'),
      _SimpleTile(label: '∀', preview: r'$\forall$', latex: r'\forall'),
      _SimpleTile(label: '∃', preview: r'$\exists$', latex: r'\exists'),
      _SimpleTile(label: '∈', preview: r'$\in$', latex: r'\in'),
      _SimpleTile(label: '∉', preview: r'$\notin$', latex: r'\notin'),
      _SimpleTile(label: '⊂', preview: r'$\subset$', latex: r'\subset'),
      _SimpleTile(label: '⊆', preview: r'$\subseteq$', latex: r'\subseteq'),
      _SimpleTile(label: '∪', preview: r'$\cup$', latex: r'\cup'),
      _SimpleTile(label: '∩', preview: r'$\cap$', latex: r'\cap'),
      _SimpleTile(label: '∅', preview: r'$\emptyset$', latex: r'\emptyset'),
      _SimpleTile(label: 'ℝ', preview: r'$\mathbb{R}$', latex: r'\mathbb{R}'),
      _SimpleTile(label: 'ℕ', preview: r'$\mathbb{N}$', latex: r'\mathbb{N}'),
      _SimpleTile(label: 'ℤ', preview: r'$\mathbb{Z}$', latex: r'\mathbb{Z}'),
    ];
    return _buildTileGrid(isDark: isDark, tiles: tiles, onInsert: onInsert);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 3: Lượng giác / Hình học
// ═══════════════════════════════════════════════════════════════════════════

class _GeometryTab extends StatelessWidget {
  const _GeometryTab({required this.isDark, required this.onInsert});
  final bool isDark;
  final _InsertCallback onInsert;

  @override
  Widget build(BuildContext context) {
    final tiles = <_MathTile>[
      _SimpleTile(label: 'sin', preview: r'$\sin$', latex: r'\sin'),
      _SimpleTile(label: 'cos', preview: r'$\cos$', latex: r'\cos'),
      _SimpleTile(label: 'tan', preview: r'$\tan$', latex: r'\tan'),
      _SimpleTile(label: 'cot', preview: r'$\cot$', latex: r'\cot'),
      _SimpleTile(label: 'arcsin', preview: r'$\arcsin$', latex: r'\arcsin'),
      _SimpleTile(label: 'arccos', preview: r'$\arccos$', latex: r'\arccos'),
      _SimpleTile(label: 'arctan', preview: r'$\arctan$', latex: r'\arctan'),
      _BuilderTile(
        label: 'Góc ABC',
        preview: r'$\angle ABC$',
        openBuilder: (ctx, dark, cb) => _openAngleBuilder(
          ctx,
          dark,
          cb,
          symbol: r'\angle',
          title: 'Góc',
        ),
      ),
      _BuilderTile(
        label: 'Tam giác ABC',
        preview: r'$\triangle ABC$',
        openBuilder: (ctx, dark, cb) => _openAngleBuilder(
          ctx,
          dark,
          cb,
          symbol: r'\triangle',
          title: 'Tam giác',
        ),
      ),
      _SimpleTile(label: '∠', preview: r'$\angle$', latex: r'\angle'),
      _SimpleTile(label: '△', preview: r'$\triangle$', latex: r'\triangle'),
      _SimpleTile(label: '⊥', preview: r'$\perp$', latex: r'\perp'),
      _SimpleTile(label: '∥', preview: r'$\parallel$', latex: r'\parallel'),
      _SimpleTile(label: '°', preview: r'$^\circ$', latex: r'^\circ'),
      _SimpleTile(label: '→', preview: r'$\rightarrow$', latex: r'\rightarrow'),
      _SimpleTile(label: '⇒', preview: r'$\Rightarrow$', latex: r'\Rightarrow'),
      _SimpleTile(
        label: '⇔',
        preview: r'$\Leftrightarrow$',
        latex: r'\Leftrightarrow',
      ),
    ];
    return _buildTileGrid(isDark: isDark, tiles: tiles, onInsert: onInsert);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 4: Hoá học
// ═══════════════════════════════════════════════════════════════════════════

class _ChemistryTab extends StatelessWidget {
  const _ChemistryTab({required this.isDark, required this.onInsert});
  final bool isDark;
  final _InsertCallback onInsert;

  @override
  Widget build(BuildContext context) {
    final tiles = <_MathTile>[
      _BuilderTile(
        label: 'Công thức hoá',
        preview: r'$H_2SO_4$',
        openBuilder: _openChemistryBuilder,
      ),
      _BuilderTile(
        label: 'Ion',
        preview: r'$Cu^{2+}$',
        openBuilder: _openIonBuilder,
      ),
      // Hợp chất phổ biến (1-tap, đã wrap sẵn → isComplete=true)
      _SimpleTile(label: 'H₂O', preview: r'$H_2O$', latex: 'H_2O'),
      _SimpleTile(label: 'CO₂', preview: r'$CO_2$', latex: 'CO_2'),
      _SimpleTile(label: 'O₂', preview: r'$O_2$', latex: 'O_2'),
      _SimpleTile(label: 'N₂', preview: r'$N_2$', latex: 'N_2'),
      _SimpleTile(label: 'H₂', preview: r'$H_2$', latex: 'H_2'),
      _SimpleTile(label: 'HCl', preview: r'$HCl$', latex: 'HCl'),
      _SimpleTile(label: 'H₂SO₄', preview: r'$H_2SO_4$', latex: 'H_2SO_4'),
      _SimpleTile(label: 'HNO₃', preview: r'$HNO_3$', latex: 'HNO_3'),
      _SimpleTile(label: 'NaOH', preview: r'$NaOH$', latex: 'NaOH'),
      _SimpleTile(label: 'NaCl', preview: r'$NaCl$', latex: 'NaCl'),
      _SimpleTile(label: 'CaCO₃', preview: r'$CaCO_3$', latex: 'CaCO_3'),
      _SimpleTile(label: 'NH₃', preview: r'$NH_3$', latex: 'NH_3'),
      _SimpleTile(label: 'CH₄', preview: r'$CH_4$', latex: 'CH_4'),
      _SimpleTile(
        label: 'C₂H₅OH',
        preview: r'$C_2H_5OH$',
        latex: 'C_2H_5OH',
      ),
      // Mũi tên phản ứng
      _SimpleTile(
        label: 'Mũi tên →',
        preview: r'$\rightarrow$',
        latex: r'\rightarrow',
      ),
      _SimpleTile(
        label: 'Cân bằng ⇌',
        preview: r'$\rightleftharpoons$',
        latex: r'\rightleftharpoons',
      ),
      _SimpleTile(label: 'Bay hơi ↑', preview: r'$\uparrow$', latex: r'\uparrow'),
      _SimpleTile(
        label: 'Kết tủa ↓',
        preview: r'$\downarrow$',
        latex: r'\downarrow',
      ),
    ];
    return _buildTileGrid(isDark: isDark, tiles: tiles, onInsert: onInsert);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 5: Hy Lạp / Vector / Ma trận
// ═══════════════════════════════════════════════════════════════════════════

class _GreekVectorTab extends StatelessWidget {
  const _GreekVectorTab({required this.isDark, required this.onInsert});
  final bool isDark;
  final _InsertCallback onInsert;

  @override
  Widget build(BuildContext context) {
    final tiles = <_MathTile>[
      _BuilderTile(
        label: 'Vector',
        preview: r'$\vec{a}$',
        openBuilder: (ctx, dark, cb) =>
            _openVectorBuilder(ctx, dark, cb, isOverrightarrow: false),
      ),
      _BuilderTile(
        label: 'Vector AB',
        preview: r'$\overrightarrow{AB}$',
        openBuilder: (ctx, dark, cb) =>
            _openVectorBuilder(ctx, dark, cb, isOverrightarrow: true),
      ),
      _BuilderTile(
        label: 'Ma trận',
        preview: r'$\begin{pmatrix}a & b \\ c & d\end{pmatrix}$',
        openBuilder: (ctx, dark, cb) => _openMatrixBuilder(
          ctx,
          dark,
          cb,
          envName: 'pmatrix',
          title: 'Ma trận',
        ),
      ),
      _BuilderTile(
        label: 'Định thức',
        preview: r'$\begin{vmatrix}a & b \\ c & d\end{vmatrix}$',
        openBuilder: (ctx, dark, cb) => _openMatrixBuilder(
          ctx,
          dark,
          cb,
          envName: 'vmatrix',
          title: 'Định thức',
        ),
      ),
      // Hy Lạp
      _SimpleTile(label: 'α', preview: r'$\alpha$', latex: r'\alpha'),
      _SimpleTile(label: 'β', preview: r'$\beta$', latex: r'\beta'),
      _SimpleTile(label: 'γ', preview: r'$\gamma$', latex: r'\gamma'),
      _SimpleTile(label: 'δ', preview: r'$\delta$', latex: r'\delta'),
      _SimpleTile(label: 'ε', preview: r'$\varepsilon$', latex: r'\varepsilon'),
      _SimpleTile(label: 'θ', preview: r'$\theta$', latex: r'\theta'),
      _SimpleTile(label: 'λ', preview: r'$\lambda$', latex: r'\lambda'),
      _SimpleTile(label: 'μ', preview: r'$\mu$', latex: r'\mu'),
      _SimpleTile(label: 'ρ', preview: r'$\rho$', latex: r'\rho'),
      _SimpleTile(label: 'σ', preview: r'$\sigma$', latex: r'\sigma'),
      _SimpleTile(label: 'φ', preview: r'$\varphi$', latex: r'\varphi'),
      _SimpleTile(label: 'ω', preview: r'$\omega$', latex: r'\omega'),
      _SimpleTile(label: 'Γ', preview: r'$\Gamma$', latex: r'\Gamma'),
      _SimpleTile(label: 'Δ', preview: r'$\Delta$', latex: r'\Delta'),
      _SimpleTile(label: 'Θ', preview: r'$\Theta$', latex: r'\Theta'),
      _SimpleTile(label: 'Λ', preview: r'$\Lambda$', latex: r'\Lambda'),
      _SimpleTile(label: 'Σ', preview: r'$\Sigma$', latex: r'\Sigma'),
      _SimpleTile(label: 'Φ', preview: r'$\Phi$', latex: r'\Phi'),
      _SimpleTile(label: 'Ψ', preview: r'$\Psi$', latex: r'\Psi'),
      _SimpleTile(label: 'Ω', preview: r'$\Omega$', latex: r'\Omega'),
    ];
    return _buildTileGrid(isDark: isDark, tiles: tiles, onInsert: onInsert);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SLOT DIALOG — Generic builder dialog với input có nhãn + preview live
// ═══════════════════════════════════════════════════════════════════════════

class _SlotSpec {
  const _SlotSpec({
    required this.label,
    required this.hint,
    this.required = true,
    this.autofocus = false,
    this.initial = '',
  });
  final String label;
  final String hint;
  final bool required;
  final bool autofocus;
  final String initial;
}

/// Mở dialog builder generic. [buildLatex] nhận list giá trị từ slots
/// (theo thứ tự) và trả về LaTeX hoàn chỉnh (đã wrap `$...$` nếu cần).
void _showSlotDialog({
  required BuildContext context,
  required bool isDark,
  required String title,
  required List<_SlotSpec> slots,
  required String Function(List<String> values) buildLatex,
  required _InsertCallback onInsert,
  bool wrapWithDollars = true,
}) {
  final controllers = slots
      .map((s) => TextEditingController(text: s.initial))
      .toList();

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        ),
        title: Row(
          children: [
            Icon(
              Icons.functions_rounded,
              size: 20,
              color: DesignColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: DesignTypography.titleMedium.copyWith(
                  color: isDark ? Colors.white : DesignColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < slots.length; i++) ...[
                Text(
                  slots[i].label,
                  style: DesignTypography.bodySmall.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controllers[i],
                  autofocus: slots[i].autofocus,
                  style: DesignTypography.bodyMedium.copyWith(
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: slots[i].hint,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.grey[800]!.withValues(alpha: 0.5)
                        : Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignRadius.md),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                if (i < slots.length - 1) const SizedBox(height: 12),
              ],
              const SizedBox(height: 16),
              // Preview live
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DesignColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(DesignRadius.md),
                  border: Border.all(
                    color: DesignColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'XEM TRƯỚC',
                      style: DesignTypography.labelSmall.copyWith(
                        color: DesignColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: Listenable.merge(controllers),
                      builder: (_, __) {
                        final values = controllers.map((c) => c.text).toList();
                        final latex = buildLatex(values);
                        final display = wrapWithDollars && !latex.contains(r'$')
                            ? '\$$latex\$'
                            : latex;
                        return Center(
                          child: MathText(
                            display,
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark
                                  ? Colors.white
                                  : DesignColors.textPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              for (final c in controllers) {
                c.dispose();
              }
              Navigator.pop(ctx);
            },
            child: Text(
              'Hủy',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final values = controllers.map((c) => c.text.trim()).toList();
              // Validate required
              for (var i = 0; i < slots.length; i++) {
                if (slots[i].required && values[i].isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text('Vui lòng nhập ${slots[i].label}'),
                      backgroundColor: DesignColors.error,
                    ),
                  );
                  return;
                }
              }
              final latex = buildLatex(values);
              final payload = wrapWithDollars && !latex.contains(r'$')
                  ? '\$$latex\$'
                  : latex;
              onInsert(payload, isComplete: true);
              for (final c in controllers) {
                c.dispose();
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Chèn'),
          ),
        ],
      );
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// Builders cụ thể
// ═══════════════════════════════════════════════════════════════════════════

void _openFractionBuilder(
  BuildContext ctx,
  bool isDark,
  _InsertCallback onInsert,
) {
  _showSlotDialog(
    context: ctx,
    isDark: isDark,
    title: 'Phân số',
    slots: const [
      _SlotSpec(
        label: 'Tử số',
        hint: 'Ví dụ: 2x + 1',
        autofocus: true,
      ),
      _SlotSpec(label: 'Mẫu số', hint: 'Ví dụ: 3'),
    ],
    buildLatex: (v) {
      final num = v[0].isEmpty ? '?' : v[0];
      final den = v[1].isEmpty ? '?' : v[1];
      return '\\frac{$num}{$den}';
    },
    onInsert: onInsert,
  );
}

void _openSqrtBuilder(
  BuildContext ctx,
  bool isDark,
  _InsertCallback onInsert,
) {
  _showSlotDialog(
    context: ctx,
    isDark: isDark,
    title: 'Căn',
    slots: const [
      _SlotSpec(
        label: 'Số trong căn',
        hint: 'Ví dụ: x + 1',
        autofocus: true,
      ),
      _SlotSpec(
        label: 'Bậc (để trống = căn 2)',
        hint: 'Ví dụ: 3 (căn bậc 3)',
        required: false,
      ),
    ],
    buildLatex: (v) {
      final content = v[0].isEmpty ? '?' : v[0];
      final n = v[1].trim();
      return n.isEmpty ? '\\sqrt{$content}' : '\\sqrt[$n]{$content}';
    },
    onInsert: onInsert,
  );
}

void _openPowerBuilder(
  BuildContext ctx,
  bool isDark,
  _InsertCallback onInsert, {
  required bool isSubscript,
}) {
  final symbol = isSubscript ? '_' : '^';
  _showSlotDialog(
    context: ctx,
    isDark: isDark,
    title: isSubscript ? 'Chỉ số dưới' : 'Số mũ',
    slots: [
      const _SlotSpec(
        label: 'Cơ số',
        hint: 'Ví dụ: x',
        autofocus: true,
        initial: 'x',
      ),
      _SlotSpec(
        label: isSubscript ? 'Chỉ số' : 'Số mũ',
        hint: 'Ví dụ: 2',
      ),
    ],
    buildLatex: (v) {
      final base = v[0].isEmpty ? 'x' : v[0];
      final exp = v[1].isEmpty ? '?' : v[1];
      return '$base$symbol{$exp}';
    },
    onInsert: onInsert,
  );
}

void _openLogBuilder(
  BuildContext ctx,
  bool isDark,
  _InsertCallback onInsert,
) {
  _showSlotDialog(
    context: ctx,
    isDark: isDark,
    title: 'Logarit',
    slots: const [
      _SlotSpec(
        label: 'Cơ số (để trống = log thường)',
        hint: 'Ví dụ: 2, 10, e',
        required: false,
      ),
      _SlotSpec(label: 'Biểu thức', hint: 'Ví dụ: x', autofocus: true),
    ],
    buildLatex: (v) {
      final base = v[0].trim();
      final x = v[1].isEmpty ? '?' : v[1];
      return base.isEmpty ? '\\log{$x}' : '\\log_{$base}{$x}';
    },
    onInsert: onInsert,
  );
}

void _openLimitsBuilder(
  BuildContext ctx,
  bool isDark,
  _InsertCallback onInsert, {
  required String latex, // \sum, \int, \prod
  required String label,
}) {
  _showSlotDialog(
    context: ctx,
    isDark: isDark,
    title: label,
    slots: const [
      _SlotSpec(
        label: 'Cận dưới',
        hint: 'Ví dụ: i=1 (Sigma) hoặc 0 (Tích phân)',
        autofocus: true,
      ),
      _SlotSpec(label: 'Cận trên', hint: 'Ví dụ: n hoặc 1'),
      _SlotSpec(
        label: 'Biểu thức',
        hint: 'Ví dụ: a_i hoặc x^2 dx',
        required: false,
      ),
    ],
    buildLatex: (v) {
      final lo = v[0].isEmpty ? '?' : v[0];
      final hi = v[1].isEmpty ? '?' : v[1];
      final body = v[2].trim();
      final stem = '${latex}_{$lo}^{$hi}';
      return body.isEmpty ? stem : '$stem $body';
    },
    onInsert: onInsert,
  );
}

void _openLimitBuilder(
  BuildContext ctx,
  bool isDark,
  _InsertCallback onInsert,
) {
  _showSlotDialog(
    context: ctx,
    isDark: isDark,
    title: 'Giới hạn',
    slots: const [
      _SlotSpec(
        label: 'Biến (vd: x)',
        hint: 'Ví dụ: x',
        autofocus: true,
        initial: 'x',
      ),
      _SlotSpec(label: 'Tiến tới', hint: 'Ví dụ: 0, \\infty, a'),
      _SlotSpec(
        label: 'Biểu thức',
        hint: 'Ví dụ: \\frac{\\sin x}{x}',
        required: false,
      ),
    ],
    buildLatex: (v) {
      final variable = v[0].isEmpty ? 'x' : v[0];
      final target = v[1].isEmpty ? '?' : v[1];
      final body = v[2].trim();
      final stem = '\\lim_{$variable \\to $target}';
      return body.isEmpty ? stem : '$stem $body';
    },
    onInsert: onInsert,
  );
}

void _openCasesBuilder(
  BuildContext ctx,
  bool isDark,
  _InsertCallback onInsert,
) {
  showDialog(
    context: ctx,
    builder: (dctx) => _CasesDialog(isDark: isDark, onInsert: onInsert),
  );
}

void _openAngleBuilder(
  BuildContext ctx,
  bool isDark,
  _InsertCallback onInsert, {
  required String symbol, // \angle | \triangle
  required String title,
}) {
  _showSlotDialog(
    context: ctx,
    isDark: isDark,
    title: title,
    slots: const [
      _SlotSpec(
        label: 'Đỉnh / điểm (vd: ABC)',
        hint: 'Ví dụ: ABC',
        autofocus: true,
      ),
    ],
    buildLatex: (v) {
      final pts = v[0].isEmpty ? 'ABC' : v[0];
      return '$symbol $pts';
    },
    onInsert: onInsert,
  );
}

void _openChemistryBuilder(
  BuildContext ctx,
  bool isDark,
  _InsertCallback onInsert,
) {
  _showSlotDialog(
    context: ctx,
    isDark: isDark,
    title: 'Công thức hoá học',
    slots: const [
      _SlotSpec(
        label: 'Nguyên tố / Hợp chất',
        hint: 'Ví dụ: H, Na, CO',
        autofocus: true,
      ),
      _SlotSpec(
        label: 'Chỉ số dưới (số nguyên tử)',
        hint: 'Ví dụ: 2 (cho H₂)',
        required: false,
      ),
      _SlotSpec(
        label: 'Điện tích (kèm dấu, vd: 2+, -)',
        hint: 'Để trống nếu trung hoà',
        required: false,
      ),
    ],
    buildLatex: (v) {
      final symbol = v[0].isEmpty ? '?' : v[0];
      final sub = v[1].trim();
      final charge = v[2].trim();
      final body = sub.isEmpty ? symbol : '${symbol}_{$sub}';
      return charge.isEmpty ? body : '$body^{$charge}';
    },
    onInsert: onInsert,
  );
}

void _openIonBuilder(
  BuildContext ctx,
  bool isDark,
  _InsertCallback onInsert,
) {
  _showSlotDialog(
    context: ctx,
    isDark: isDark,
    title: 'Ion',
    slots: const [
      _SlotSpec(
        label: 'Ký hiệu',
        hint: 'Ví dụ: Cu, SO_4, Cl',
        autofocus: true,
      ),
      _SlotSpec(
        label: 'Điện tích',
        hint: 'Ví dụ: 2+, 3+, -, 2-',
      ),
    ],
    buildLatex: (v) {
      final symbol = v[0].isEmpty ? '?' : v[0];
      final charge = v[1].isEmpty ? '?' : v[1];
      return '$symbol^{$charge}';
    },
    onInsert: onInsert,
  );
}

void _openVectorBuilder(
  BuildContext ctx,
  bool isDark,
  _InsertCallback onInsert, {
  required bool isOverrightarrow,
}) {
  final macro = isOverrightarrow ? r'\overrightarrow' : r'\vec';
  _showSlotDialog(
    context: ctx,
    isDark: isDark,
    title: isOverrightarrow ? 'Vector AB' : 'Vector',
    slots: [
      _SlotSpec(
        label: isOverrightarrow ? 'Ký hiệu (vd: AB)' : 'Ký hiệu (vd: a)',
        hint: isOverrightarrow ? 'AB' : 'a',
        autofocus: true,
      ),
    ],
    buildLatex: (v) {
      final sym = v[0].isEmpty ? 'a' : v[0];
      return '$macro{$sym}';
    },
    onInsert: onInsert,
  );
}

void _openMatrixBuilder(
  BuildContext ctx,
  bool isDark,
  _InsertCallback onInsert, {
  required String envName, // pmatrix, vmatrix, bmatrix
  required String title,
}) {
  showDialog(
    context: ctx,
    builder: (dctx) => _MatrixDialog(
      isDark: isDark,
      envName: envName,
      title: title,
      onInsert: onInsert,
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// Hệ phương trình dialog (dynamic số dòng)
// ═══════════════════════════════════════════════════════════════════════════

class _CasesDialog extends StatefulWidget {
  const _CasesDialog({required this.isDark, required this.onInsert});
  final bool isDark;
  final _InsertCallback onInsert;

  @override
  State<_CasesDialog> createState() => _CasesDialogState();
}

class _CasesDialogState extends State<_CasesDialog> {
  final _controllers = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String _buildLatex() {
    final rows = _controllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (rows.isEmpty) return r'\begin{cases} ? \\ ? \end{cases}';
    return r'\begin{cases} ' + rows.join(r' \\ ') + r' \end{cases}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
      ),
      title: Text(
        'Hệ phương trình',
        style: DesignTypography.titleMedium.copyWith(
          color: isDark ? Colors.white : DesignColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < _controllers.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        '${i + 1}.',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controllers[i],
                        autofocus: i == 0,
                        style: DesignTypography.bodyMedium.copyWith(
                          color: isDark
                              ? Colors.white
                              : DesignColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ví dụ: x + y = 5',
                          filled: true,
                          fillColor: isDark
                              ? Colors.grey[800]!.withValues(alpha: 0.5)
                              : Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(DesignRadius.md),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    if (_controllers.length > 2)
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline_rounded,
                          color: DesignColors.error,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _controllers[i].dispose();
                            _controllers.removeAt(i);
                          });
                        },
                      ),
                  ],
                ),
              ),
            TextButton.icon(
              onPressed: () {
                setState(() => _controllers.add(TextEditingController()));
              },
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Thêm dòng'),
              style: TextButton.styleFrom(
                foregroundColor: DesignColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DesignColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(DesignRadius.md),
                border: Border.all(
                  color: DesignColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'XEM TRƯỚC',
                    style: DesignTypography.labelSmall.copyWith(
                      color: DesignColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: Listenable.merge(_controllers),
                    builder: (_, __) => Center(
                      child: MathText(
                        '\$${_buildLatex()}\$',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark
                              ? Colors.white
                              : DesignColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Hủy',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final rows = _controllers
                .map((c) => c.text.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            if (rows.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vui lòng nhập ít nhất 1 phương trình'),
                  backgroundColor: DesignColors.error,
                ),
              );
              return;
            }
            widget.onInsert(
              '\$${_buildLatex()}\$',
              isComplete: true,
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Chèn'),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Matrix dialog (chọn kích thước → grid input)
// ═══════════════════════════════════════════════════════════════════════════

class _MatrixDialog extends StatefulWidget {
  const _MatrixDialog({
    required this.isDark,
    required this.envName,
    required this.title,
    required this.onInsert,
  });
  final bool isDark;
  final String envName;
  final String title;
  final _InsertCallback onInsert;

  @override
  State<_MatrixDialog> createState() => _MatrixDialogState();
}

class _MatrixDialogState extends State<_MatrixDialog> {
  int _rows = 2;
  int _cols = 2;
  List<List<TextEditingController>> _cells = [];

  @override
  void initState() {
    super.initState();
    _rebuildCells();
  }

  void _rebuildCells() {
    for (final row in _cells) {
      for (final c in row) {
        c.dispose();
      }
    }
    _cells = List.generate(
      _rows,
      (_) => List.generate(_cols, (_) => TextEditingController()),
    );
  }

  @override
  void dispose() {
    for (final row in _cells) {
      for (final c in row) {
        c.dispose();
      }
    }
    super.dispose();
  }

  String _buildLatex() {
    final rowStrs = _cells
        .map((row) => row.map((c) {
              final v = c.text.trim();
              return v.isEmpty ? '?' : v;
            }).join(' & '))
        .toList();
    final env = widget.envName;
    final body = rowStrs.join(r' \\ ');
    return '\\begin{$env} $body \\end{$env}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final allControllers =
        _cells.expand((row) => row).toList();
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
      ),
      title: Text(
        widget.title,
        style: DesignTypography.titleMedium.copyWith(
          color: isDark ? Colors.white : DesignColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Size selectors
            Row(
              children: [
                Text(
                  'Hàng:',
                  style: DesignTypography.bodySmall.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _rows,
                  items: [1, 2, 3, 4]
                      .map(
                        (n) => DropdownMenuItem(
                          value: n,
                          child: Text('$n'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _rows = v;
                      _rebuildCells();
                    });
                  },
                ),
                const SizedBox(width: 20),
                Text(
                  'Cột:',
                  style: DesignTypography.bodySmall.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _cols,
                  items: [1, 2, 3, 4]
                      .map(
                        (n) => DropdownMenuItem(
                          value: n,
                          child: Text('$n'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _cols = v;
                      _rebuildCells();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Grid inputs
            for (var r = 0; r < _rows; r++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    for (var c = 0; c < _cols; c++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: TextField(
                            controller: _cells[r][c],
                            style: DesignTypography.bodySmall.copyWith(
                              color: isDark
                                  ? Colors.white
                                  : DesignColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: '?',
                              isDense: true,
                              filled: true,
                              fillColor: isDark
                                  ? Colors.grey[800]!.withValues(alpha: 0.5)
                                  : Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(DesignRadius.sm),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DesignColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(DesignRadius.md),
                border: Border.all(
                  color: DesignColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'XEM TRƯỚC',
                    style: DesignTypography.labelSmall.copyWith(
                      color: DesignColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: Listenable.merge(allControllers),
                    builder: (_, __) => Center(
                      child: MathText(
                        '\$${_buildLatex()}\$',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark
                              ? Colors.white
                              : DesignColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Hủy',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onInsert('\$${_buildLatex()}\$', isComplete: true);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Chèn'),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELP DIALOG — Hướng dẫn sử dụng math picker
// ═══════════════════════════════════════════════════════════════════════════

void _showMathHelpDialog(BuildContext context, bool isDark) {
  showDialog(
    context: context,
    builder: (_) => _MathHelpDialog(isDark: isDark),
  );
}

class _MathHelpDialog extends StatelessWidget {
  const _MathHelpDialog({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final isWide = screenW >= 720;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWide ? 24 : 12,
        vertical: 24,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isWide ? 720 : double.infinity,
          maxHeight: screenH * 0.88,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1923) : Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isWide ? 20 : 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _stepSimpleTile(isWide),
                    SizedBox(height: isWide ? 18 : 14),
                    _stepBuilderTile(isWide),
                    SizedBox(height: isWide ? 18 : 14),
                    _stepSmartWrap(isWide),
                    SizedBox(height: isWide ? 18 : 14),
                    _stepPreviewLive(isWide),
                    SizedBox(height: isWide ? 18 : 14),
                    _stepCategories(),
                  ],
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
      decoration: BoxDecoration(
        color: DesignColors.primary.withValues(alpha: isDark ? 0.18 : 0.08),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DesignRadius.lg * 1.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DesignColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignRadius.md),
            ),
            child: Icon(
              Icons.help_outline_rounded,
              size: 20,
              color: DesignColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hướng dẫn chèn công thức',
                  style: DesignTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Không cần biết LaTeX — chỉ cần bấm chọn',
                  style: DesignTypography.bodySmall.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1923) : Colors.white,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(DesignRadius.lg * 1.5),
        ),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Đã hiểu'),
        ),
      ),
    );
  }

  // ─── STEP 1: Simple tile (1-tap) ─────────────────────────────────────────
  Widget _stepSimpleTile(bool isWide) {
    return _stepCard(
      number: '1',
      title: 'Ô xám: bấm 1 lần → chèn ngay',
      description:
          'Các ô có nền xám là ký hiệu đơn giản. Bấm → công thức được chèn '
          'vào ô nhập với định dạng \$...\$ đồng nhất.',
      child: _flowExample(
        isWide: isWide,
        steps: [
          _mockSimpleTile(label: 'pi', preview: r'$\pi$'),
          _arrowWidget(label: 'Bấm', isWide: isWide),
          _mockResultCard(
            inputText: r'Giá trị $\pi$ ≈ 3.14',
            label: 'Kết quả trong ô nhập',
          ),
        ],
      ),
    );
  }

  // ─── STEP 2: Builder tile (compound) ─────────────────────────────────────
  Widget _stepBuilderTile(bool isWide) {
    return _stepCard(
      number: '2',
      title: 'Ô viền xanh: mở ô nhập tử/mẫu/cận',
      description:
          'Phân số, căn, mũ, tích phân, ma trận, hoá học... mở dialog phụ '
          'với ô nhập có nhãn tiếng Việt + xem trước trực tiếp. KHÔNG cần '
          'gõ LaTeX.',
      child: _flowExample(
        isWide: isWide,
        steps: [
          _mockBuilderTile(label: 'Phân số', preview: r'$\frac{a}{b}$'),
          _arrowWidget(label: 'Bấm', isWide: isWide),
          _mockSlotDialog(),
          _arrowWidget(label: 'Chèn', isWide: isWide),
          _mockResultCard(
            inputText: r'$\frac{2x+1}{3}$',
            label: 'Kết quả',
          ),
        ],
      ),
    );
  }

  // ─── STEP 3: Smart wrap ──────────────────────────────────────────────────
  Widget _stepSmartWrap(bool isWide) {
    return _stepCard(
      number: '3',
      title: 'Smart wrap: tự thêm hoặc bỏ qua \$...\$',
      description:
          'Hệ thống tự nhận biết bạn đang ở trong hay ngoài khối math:',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _smartWrapRow(
            isWide: isWide,
            label: 'Cursor NGOÀI math',
            before: 'Diện tích = |',
            insert: r'$\pi r^2$',
            after: r'Diện tích = $\pi r^2$',
            cleanWrap: true,
          ),
          const SizedBox(height: 10),
          _smartWrapRow(
            isWide: isWide,
            label: 'Cursor TRONG math',
            before: r'$\frac{x|}{y}$',
            insert: r'\pi',
            after: r'$\frac{x\pi}{y}$',
            cleanWrap: false,
          ),
        ],
      ),
    );
  }

  // ─── STEP 4: Preview live ────────────────────────────────────────────────
  Widget _stepPreviewLive(bool isWide) {
    return _stepCard(
      number: '4',
      title: 'Xem trước trực tiếp',
      description:
          'Phía dưới ô nhập có panel "XEM TRƯỚC". Khi bạn gõ hoặc chèn, '
          'preview cập nhật ngay để bạn thấy kết quả render giống AI.',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey[800]!.withValues(alpha: 0.4)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn gõ:',
              style: DesignTypography.labelSmall.copyWith(
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                ),
              ),
              child: Text(
                r'Giải $x^2 - 4x + 4 = 0$',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: isDark ? Colors.white : DesignColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.arrow_downward_rounded,
                  size: 16,
                  color: DesignColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'XEM TRƯỚC (live)',
                  style: DesignTypography.labelSmall.copyWith(
                    color: DesignColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: DesignColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: DesignColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: MathText(
                r'Giải $x^2 - 4x + 4 = 0$',
                style: DesignTypography.bodyMedium.copyWith(
                  color: isDark ? Colors.white : DesignColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STEP 5: 5 categories ────────────────────────────────────────────────
  Widget _stepCategories() {
    final cats = const [
      ('Toán cơ bản', 'phân số, căn, mũ, log, π, ≤, ≠...'),
      ('Đại số / Giải tích', 'Σ, ∫, ∏, lim, hệ pt, ∈, ∪...'),
      ('Lượng giác / Hình', 'sin, cos, ∠ABC, △ABC, ⊥, ∥...'),
      ('Hoá học', 'H₂O, CO₂, H₂SO₄, Cu²⁺, →, ⇌...'),
      ('Hy Lạp / Vector', 'α, β, Δ, Ω, vec{a}, ma trận...'),
    ];
    return _stepCard(
      number: '5',
      title: '5 nhóm công thức',
      description:
          'Tab ở đầu bottom sheet phân loại theo môn. Mỗi nhóm có cả ô đơn '
          'giản (1-tap) lẫn ô builder (viền xanh).',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: cats.map((c) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: DesignColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(DesignRadius.full),
              border: Border.all(
                color: DesignColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  c.$1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DesignColors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  c.$2,
                  style: DesignTypography.bodySmall.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Reusable building blocks ────────────────────────────────────────────

  Widget _stepCard({
    required String number,
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[900]!.withValues(alpha: 0.4)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: DesignColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: DesignTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: DesignTypography.bodySmall.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  /// Wrap thành Row (wide) hoặc Column (mobile).
  Widget _flowExample({required bool isWide, required List<Widget> steps}) {
    if (isWide) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: steps,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: steps,
    );
  }

  Widget _mockSimpleTile({required String label, required String preview}) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 32,
            child: Center(
              child: MathText(
                preview,
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white : DesignColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mockBuilderTile({required String label, required String preview}) {
    return Container(
      width: 86,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: DesignColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(
          color: DesignColors.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 36,
            child: Center(
              child: MathText(
                preview,
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white : DesignColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: DesignColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrowWidget({required String label, required bool isWide}) {
    final icon = isWide
        ? Icons.arrow_forward_rounded
        : Icons.arrow_downward_rounded;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 10 : 0,
        vertical: isWide ? 0 : 6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: DesignColors.primary),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: DesignColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mockResultCard({required String inputText, required String label}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240, minWidth: 180),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: DesignColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(
          color: DesignColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: DesignColors.success,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            inputText,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: isDark ? Colors.grey[200] : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: MathText(
              inputText,
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.white : DesignColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mockSlotDialog() {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(
          color: DesignColors.primary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.functions_rounded,
                size: 12,
                color: DesignColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Phân số',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : DesignColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _mockMiniField('Tử số', '2x+1'),
          const SizedBox(height: 4),
          _mockMiniField('Mẫu số', '3'),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: DesignColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.visibility_rounded,
                  size: 10,
                  color: DesignColors.primary,
                ),
                const SizedBox(width: 4),
                MathText(
                  r'$\frac{2x+1}{3}$',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mockMiniField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey[800]!.withValues(alpha: 0.5)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: isDark ? Colors.white : DesignColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _smartWrapRow({
    required bool isWide,
    required String label,
    required String before,
    required String insert,
    required String after,
    required bool cleanWrap,
  }) {
    final beforeCard = _codeCard(before, label: 'Trước (| = cursor)');
    final actionCard = Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: cleanWrap
            ? DesignColors.info.withValues(alpha: 0.1)
            : Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Chèn $insert',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: cleanWrap ? DesignColors.info : Colors.amber[900],
        ),
      ),
    );
    final afterCard = _codeCard(
      after,
      label: cleanWrap ? 'Sau (tự bọc \$...\$)' : 'Sau (chèn raw)',
      success: true,
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]!.withValues(alpha: 0.3)
            : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: DesignTypography.labelSmall.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          if (isWide)
            Row(
              children: [
                Flexible(child: beforeCard),
                const SizedBox(width: 8),
                actionCard,
                const SizedBox(width: 8),
                Flexible(child: afterCard),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                beforeCard,
                const SizedBox(height: 6),
                Center(child: actionCard),
                const SizedBox(height: 6),
                afterCard,
              ],
            ),
        ],
      ),
    );
  }

  Widget _codeCard(String text, {required String label, bool success = false}) {
    final color = success ? DesignColors.success : DesignColors.textSecondary;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: success
            ? DesignColors.success.withValues(alpha: 0.06)
            : (isDark ? Colors.black26 : Colors.grey[50]),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: success
              ? DesignColors.success.withValues(alpha: 0.3)
              : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: isDark ? Colors.grey[200] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
