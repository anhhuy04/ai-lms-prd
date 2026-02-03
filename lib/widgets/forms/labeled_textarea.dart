import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Textarea với label và toolbar format (tùy chọn)
/// Tái sử dụng cho các form textarea
class LabeledTextarea extends StatefulWidget {
  final String label;
  final String? hintText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool enabled;
  final int? minLines;
  final bool showToolbar;
  final String? Function(String?)? validator;

  const LabeledTextarea({
    super.key,
    required this.label,
    this.hintText,
    this.initialValue,
    this.onChanged,
    this.controller,
    this.enabled = true,
    this.minLines = 3,
    this.showToolbar = false,
    this.validator,
  });

  @override
  State<LabeledTextarea> createState() => _LabeledTextareaState();
}

class _LabeledTextareaState extends State<LabeledTextarea> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                widget.label,
                style:
                    TextStyle(
                      fontSize: DesignTypography.labelSmallSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ).copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
              ),
            ),
            if (widget.showToolbar) _buildToolbar(isDark),
          ],
        ),
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          minLines: widget.minLines,
          maxLines: null,
          validator: widget.validator,
          style: DesignTypography.bodyMedium.copyWith(
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark
                ? Colors.grey[800]!.withValues(alpha: 0.5)
                : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
              borderSide: BorderSide(color: DesignColors.primary, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
              borderSide: BorderSide(color: DesignColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(bool isDark) {
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
          _buildToolbarButton(
            icon: Icons.format_bold,
            onPressed: () {},
            isDark: isDark,
          ),
          _buildToolbarButton(
            icon: Icons.format_italic,
            onPressed: () {},
            isDark: isDark,
          ),
          _buildToolbarButton(
            icon: Icons.link,
            onPressed: () {},
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
