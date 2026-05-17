import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/editor/rich_text_toolbar.dart';
import 'package:ai_mls/widgets/text/math_text.dart';
import 'package:flutter/material.dart';

/// Ô nhập text có toolbar math + preview LaTeX live ngay bên dưới.
///
/// Tái sử dụng cho mọi nơi cần nhập câu hỏi / lời giải / giải thích có công
/// thức toán-hoá. Output text theo format `$...$` (đồng nhất với AI), render
/// preview qua [MathText].
///
/// Khi [readOnly] = `true`, ẩn toolbar và TextField, chỉ hiển thị preview —
/// tiện cho student xem lại lời giải sau khi nộp.
class MathInputField extends StatelessWidget {
  const MathInputField({
    super.key,
    required this.controller,
    this.hintText,
    this.minLines = 4,
    this.maxLines,
    this.showPreview = true,
    this.previewLabel = 'XEM TRƯỚC',
    this.onPickImage,
    this.readOnly = false,
    this.onChanged,
    this.fillColor,
    this.borderColor,
    this.validator,
    this.previewBackground,
  });

  final TextEditingController controller;
  final String? hintText;
  final int minLines;
  final int? maxLines;
  final bool showPreview;
  final String previewLabel;
  final VoidCallback? onPickImage;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final Color? fillColor;
  final Color? borderColor;

  /// Cho phép wrap bằng `Form` ở parent. Trả `null` = OK; trả chuỗi = error.
  final String? Function(String?)? validator;

  /// Màu nền của panel preview. Mặc định trong suốt với border nhẹ.
  final Color? previewBackground;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (readOnly) {
      return AnimatedBuilder(
        animation: controller,
        builder: (_, __) => _buildPreview(isDark, dim: false),
      );
    }

    final bc = borderColor ?? (isDark ? Colors.grey[700]! : Colors.grey[200]!);
    final fc = fillColor ??
        (isDark ? Colors.grey[800]!.withValues(alpha: 0.5) : Colors.grey[50]!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Toolbar
        RichTextToolbar(
          controller: controller,
          onPickImage: onPickImage,
        ),
        const SizedBox(height: 8),
        // TextField (hoặc TextFormField nếu có validator)
        if (validator != null)
          TextFormField(
            controller: controller,
            minLines: minLines,
            maxLines: maxLines,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            onChanged: onChanged,
            validator: validator,
            style: DesignTypography.bodyMedium.copyWith(
              color: isDark ? Colors.white : DesignColors.textPrimary,
              height: 1.5,
            ),
            decoration: _decoration(isDark, bc, fc),
          )
        else
          TextField(
            controller: controller,
            minLines: minLines,
            maxLines: maxLines,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            onChanged: onChanged,
            style: DesignTypography.bodyMedium.copyWith(
              color: isDark ? Colors.white : DesignColors.textPrimary,
              height: 1.5,
            ),
            decoration: _decoration(isDark, bc, fc),
          ),
        // Live preview
        if (showPreview)
          AnimatedBuilder(
            animation: controller,
            builder: (_, __) {
              if (controller.text.trim().isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _buildPreview(isDark, dim: true),
              );
            },
          ),
      ],
    );
  }

  InputDecoration _decoration(bool isDark, Color bc, Color fc) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: isDark ? Colors.grey[600] : Colors.grey[400],
      ),
      filled: true,
      fillColor: fc,
      contentPadding: const EdgeInsets.all(14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
        borderSide: BorderSide(color: bc),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
        borderSide: BorderSide(color: bc),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
        borderSide: BorderSide(color: DesignColors.primary, width: 2),
      ),
    );
  }

  Widget _buildPreview(bool isDark, {required bool dim}) {
    final bg = previewBackground ??
        (dim
            ? DesignColors.primary.withValues(alpha: 0.04)
            : (isDark ? Colors.grey[900] : Colors.grey[50]));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(
          color: dim
              ? DesignColors.primary.withValues(alpha: 0.15)
              : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dim) ...[
            Row(
              children: [
                Icon(
                  Icons.visibility_rounded,
                  size: 12,
                  color: DesignColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  previewLabel,
                  style: TextStyle(
                    fontSize: DesignTypography.labelSmallSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: DesignColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          MathText(
            controller.text.isEmpty ? '(chưa có nội dung)' : controller.text,
            style: DesignTypography.bodyMedium.copyWith(
              color: isDark ? Colors.white : DesignColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
