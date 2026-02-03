import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/dialogs/time_limit_picker_dialog.dart';
import 'package:flutter/material.dart';

/// Select dropdown field với label và icon
class SelectField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<SelectFieldOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;

  /// Nếu true, dùng bottom sheet picker thay vì DropdownButton.
  /// - Với label chứa 'THỜI GIAN LÀM BÀI' sẽ dùng TimeLimitPickerDialog chuyên biệt.
  /// - Các label khác sẽ dùng bottom sheet generic (áp dụng cho nhiều trường hợp).
  final bool useCustomPicker;

  const SelectField({
    super.key,
    required this.label,
    this.value,
    required this.options,
    this.onChanged,
    this.prefixIcon,
    this.validator,
    this.useCustomPicker = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Nếu useCustomPicker = true, dùng bottom sheet
    if (useCustomPicker) {
      // Trường hợp đặc biệt: thời gian làm bài dùng TimeLimitPickerDialog
      if (label.contains('THỜI GIAN LÀM BÀI')) {
        return _buildInkWellField(
          context: context,
          isDark: isDark,
          displayText: _getDisplayText(value),
          onTap: () async {
            final selected = await TimeLimitPickerDialog.show(
              context: context,
              currentValue: value?.toString(),
            );
            if (selected != null && onChanged != null) {
              onChanged!(selected as T);
            }
          },
        );
      }

      // Generic bottom sheet picker cho các SelectField khác (vd: chọn provider/model AI)
      return _buildInkWellField(
        context: context,
        isDark: isDark,
        displayText: _getSelectedLabel(),
        onTap: () async {
          final selected = await _showOptionBottomSheet(
            context: context,
            isDark: isDark,
          );
          if (selected != null && onChanged != null) {
            onChanged!(selected);
          }
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
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
        DropdownButtonFormField<T>(
          initialValue: value,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: 20,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  )
                : null,
            filled: true,
            fillColor: isDark
                ? Colors.grey[800]!.withValues(alpha: 0.5)
                : Colors.grey[50],
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
          ),
          dropdownColor: isDark ? const Color(0xFF111827) : Colors.white,
          style: DesignTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
          icon: Icon(
            Icons.expand_more,
            size: 20,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          items: options.map((option) {
            return DropdownMenuItem<T>(
              value: option.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (option.icon != null) ...[
                    Icon(
                      option.icon,
                      size: 18,
                      color: isDark
                          ? Colors.grey[300]
                          : DesignColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          option.label,
                          style: DesignTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : DesignColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (option.description != null &&
                            option.description!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              option.description!,
                              style: DesignTypography.bodySmall.copyWith(
                                color: isDark
                                    ? Colors.grey[400]
                                    : DesignColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getDisplayText(T? value) {
    if (value == null) return 'Chọn thời gian';
    if (value.toString() == 'unlimited') return 'Không giới hạn';

    final minutes = int.tryParse(value.toString());
    if (minutes == null) return value.toString();

    return '$minutes phút';
  }

  /// Lấy label hiển thị cho giá trị hiện tại từ danh sách options
  String _getSelectedLabel() {
    if (value == null) return 'Chọn $label';
    final found = options.firstWhere(
      (o) => o.value == value,
      orElse: () =>
          SelectFieldOption<T>(value: value as T, label: value.toString()),
    );
    return found.label;
  }

  /// Widget chung hiển thị 1 field dạng InkWell + border (giống time limit)
  Widget _buildInkWellField({
    required BuildContext context,
    required bool isDark,
    required String displayText,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
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
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey[800]!.withValues(alpha: 0.5)
                  : Colors.white,
              borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              ),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(
                    prefixIcon,
                    size: 20,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    displayText,
                    style: DesignTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : DesignColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  size: 20,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Generic bottom sheet hiển thị SelectFieldOption<T>
  Future<T?> _showOptionBottomSheet({
    required BuildContext context,
    required bool isDark,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2632) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(DesignRadius.lg * 2),
              topRight: Radius.circular(DesignRadius.lg * 2),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      if (prefixIcon != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: DesignColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              DesignRadius.lg,
                            ),
                          ),
                          child: Icon(
                            prefixIcon,
                            size: 24,
                            color: DesignColors.primary,
                          ),
                        ),
                      if (prefixIcon != null) const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: DesignTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : DesignColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Options list
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final isSelected = option.value == value;

                      return InkWell(
                        onTap: () => Navigator.pop<T>(context, option.value),
                        borderRadius: BorderRadius.circular(
                          DesignRadius.lg * 1.5,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? DesignColors.primary.withValues(alpha: 0.08)
                                : (isDark
                                      ? Colors.grey[800]!.withValues(alpha: 0.5)
                                      : Colors.grey[50]),
                            borderRadius: BorderRadius.circular(
                              DesignRadius.lg * 1.5,
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? DesignColors.primary
                                  : (isDark
                                        ? Colors.grey[700]!
                                        : Colors.grey[200]!),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (option.icon != null) ...[
                                Icon(
                                  option.icon,
                                  size: 20,
                                  color: isSelected
                                      ? DesignColors.primary
                                      : (isDark
                                            ? Colors.grey[300]
                                            : DesignColors.textSecondary),
                                ),
                                const SizedBox(width: 10),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      option.label,
                                      style: DesignTypography.bodyMedium
                                          .copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: isSelected
                                                ? DesignColors.primary
                                                : (isDark
                                                      ? Colors.white
                                                      : DesignColors
                                                            .textPrimary),
                                          ),
                                    ),
                                    if (option.description != null &&
                                        option.description!.trim().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          option.description!,
                                          style: DesignTypography.bodySmall
                                              .copyWith(
                                                color: isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: DesignColors.primary,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Option cho SelectField
class SelectFieldOption<T> {
  final T value;
  final String label;
  final String? description;
  final IconData? icon;

  const SelectFieldOption({
    required this.value,
    required this.label,
    this.description,
    this.icon,
  });
}
