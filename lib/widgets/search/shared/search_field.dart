import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable search field widget with customizable size
/// Default size matches DesignComponents.inputFieldHeight
class SearchField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool autoFocus;

  // Customizable dimensions and styling
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? iconSize;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;

  const SearchField({
    super.key,
    this.hintText = 'Tìm kiếm...',
    required this.onChanged,
    this.onClear,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.autoFocus = false,
    this.height,
    this.width,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.horizontalPadding,
    this.verticalPadding,
    this.iconSize,
    this.hintStyle,
    this.textStyle,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildSearchBar();
  }

  /// Build search bar with customizable dimensions
  Widget _buildSearchBar() {
    // Dùng ScreenUtil để scale kích thước theo màn hình
    final height = (widget.height ?? DesignComponents.inputFieldHeight).h;
    final horizontalPadding = (widget.horizontalPadding ?? DesignSpacing.lg).w;
    final verticalPadding = (widget.verticalPadding ?? DesignSpacing.md).h;
    final backgroundColor = widget.backgroundColor ?? DesignColors.moonMedium;
    final borderRadius = (widget.borderRadius ?? DesignRadius.full).r;
    final iconSize = (widget.iconSize ?? DesignIcons.mdSize).sp;
    final hintStyle =
        widget.hintStyle ??
        DesignTypography.bodyMedium.copyWith(
          color: DesignColors.textSecondary,
          fontSize: (DesignTypography.bodyMediumSize).sp,
        );
    final textStyle = (widget.textStyle ?? DesignTypography.bodyMedium)
        .copyWith(fontSize: (DesignTypography.bodyMediumSize).sp);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: widget.boxShadow ?? [DesignElevation.level1],
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg.w),
              child: Icon(
                Icons.search,
                size: iconSize,
                color: DesignColors.textSecondary,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    _hasText = value.isNotEmpty;
                  });
                  widget.onChanged(value);
                },
                keyboardType: widget.keyboardType,
                autofocus: widget.autoFocus,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: hintStyle,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: DesignSpacing.md.h,
                  ),
                  suffixIcon: (widget.onClear != null && _hasText)
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: DesignIcons.smSize,
                            color: DesignColors.textSecondary,
                          ),
                          onPressed: () {
                            _controller.clear();
                            setState(() {
                              _hasText = false;
                            });
                            widget.onClear?.call();
                            widget.onChanged('');
                          },
                        )
                      : null,
                ),
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
