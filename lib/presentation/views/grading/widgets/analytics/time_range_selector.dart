import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';

/// Represents a time range filter for analytics.
sealed class AnalyticsTimeRange {
  const AnalyticsTimeRange();
}

class AnalyticsTimeRangeWeek extends AnalyticsTimeRange {
  const AnalyticsTimeRangeWeek();
  String get label => 'Tuần';
  int get days => 7;
}

class AnalyticsTimeRangeMonth extends AnalyticsTimeRange {
  const AnalyticsTimeRangeMonth();
  String get label => 'Tháng';
  int get days => 30;
}

class AnalyticsTimeRangeAll extends AnalyticsTimeRange {
  const AnalyticsTimeRangeAll();
  String get label => 'Tất cả';
}

class AnalyticsTimeRangeCustom extends AnalyticsTimeRange {
  final DateTime startDate;
  final DateTime endDate;
  const AnalyticsTimeRangeCustom({
    required this.startDate,
    required this.endDate,
  });
  String get label => 'Tùy chỉnh';

  String get shortLabel {
    final start = '${startDate.day}/${startDate.month}';
    final end = '${endDate.day}/${endDate.month}';
    return '$start - $end';
  }
}

/// Filter option types for the bottom sheet.
enum _TimeFilterOption { thisWeek, thisMonth, all, custom }

/// Shows the analytics filter bottom sheet and returns the selected filter.
Future<({AnalyticsTimeRange timeRange, String? classId, String? className})?>
showAnalyticsFilterBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required AnalyticsTimeRange initialTimeRange,
  required String? initialClassId,
}) async {
  // Fetch classes directly using repository (bypass provider lifecycle issues)
  final studentId = ref.read(currentUserIdProvider);
  List<Class> classes = [];
  if (studentId != null) {
    try {
      final repo = ref.read(schoolClassRepositoryProvider);
      classes = await repo.getClassesByStudent(studentId);
    } catch (e) {
      classes = [];
    }
  }

  return showModalBottomSheet<
    ({AnalyticsTimeRange timeRange, String? classId, String? className})
  >(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AnalyticsFilterBottomSheet(
      initialTimeRange: initialTimeRange,
      initialClassId: initialClassId,
      classes: classes,
    ),
  );
}

class _AnalyticsFilterBottomSheet extends StatefulWidget {
  final AnalyticsTimeRange initialTimeRange;
  final String? initialClassId;
  final List<Class> classes;

  const _AnalyticsFilterBottomSheet({
    required this.initialTimeRange,
    required this.initialClassId,
    required this.classes,
  });

  @override
  State<_AnalyticsFilterBottomSheet> createState() =>
      _AnalyticsFilterBottomSheetState();
}

class _AnalyticsFilterBottomSheetState
    extends State<_AnalyticsFilterBottomSheet> {
  late AnalyticsTimeRange _selectedTimeRange;
  String? _selectedClassId;
  String? _selectedClassName;
  bool _showDatePicker = false;

  @override
  void initState() {
    super.initState();
    _selectedTimeRange = widget.initialTimeRange;
    _selectedClassId = widget.initialClassId;
    if (_selectedClassId != null) {
      final found = widget.classes.where((c) => c.id == _selectedClassId).toList();
      if (found.isNotEmpty) {
        _selectedClassName = found.first.name;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DesignRadius.lg),
          topRight: Radius.circular(DesignRadius.lg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: EdgeInsets.only(top: DesignSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DesignColors.dividerLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(DesignSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bộ lọc', style: DesignTypography.titleMedium),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          Divider(color: DesignColors.dividerLight, height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(DesignSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time Range Section
                  _buildSectionTitle('Thời gian'),
                  SizedBox(height: DesignSpacing.sm),
                  _buildTimeRangeSection(),
                  SizedBox(height: DesignSpacing.lg),

                  // Class Filter Section
                  _buildSectionTitle('Lớp học'),
                  SizedBox(height: DesignSpacing.sm),
                  _buildClassSection(),
                ],
              ),
            ),
          ),

          Divider(color: DesignColors.dividerLight, height: 1),

          // Apply Button
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, (
                    timeRange: _selectedTimeRange,
                    classId: _selectedClassId,
                    className: _selectedClassName,
                  )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.primary,
                    foregroundColor: DesignColors.white,
                    padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignRadius.md),
                    ),
                  ),
                  child: Text(
                    'Áp dụng',
                    style: DesignTypography.titleMedium.copyWith(
                      color: DesignColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: DesignTypography.titleSmall.copyWith(
        fontWeight: FontWeight.w600,
        color: DesignColors.textSecondary,
      ),
    );
  }

  Widget _buildTimeRangeSection() {
    if (_showDatePicker) {
      return _buildDateRangePicker();
    }

    return Column(
      children: [
        _buildTimeOption('Tuần này', _TimeFilterOption.thisWeek),
        _buildTimeOption('Tháng này', _TimeFilterOption.thisMonth),
        _buildTimeOption('Tất cả', _TimeFilterOption.all),
        _buildTimeOption('Tùy chỉnh...', _TimeFilterOption.custom),
      ],
    );
  }

  Widget _buildDateRangePicker() {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.moonLight,
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Chọn khoảng thời gian', style: DesignTypography.bodyMedium),
              TextButton(
                onPressed: () => setState(() => _showDatePicker = false),
                child: Text(
                  'Hủy',
                  style: DesignTypography.labelMedium.copyWith(
                    color: DesignColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _pickDateRange(context),
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(
                _selectedTimeRange is AnalyticsTimeRangeCustom
                    ? (_selectedTimeRange as AnalyticsTimeRangeCustom)
                          .shortLabel
                    : 'Chọn ngày',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignColors.textPrimary,
                side: BorderSide(color: DesignColors.dividerLight),
                padding: EdgeInsets.symmetric(vertical: DesignSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.md),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    DateTimeRange? initialRange;

    if (_selectedTimeRange is AnalyticsTimeRangeCustom) {
      final custom = _selectedTimeRange as AnalyticsTimeRangeCustom;
      initialRange = DateTimeRange(
        start: custom.startDate,
        end: custom.endDate,
      );
    } else {
      initialRange = DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      );
    }

    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: initialRange,
      helpText: 'Chọn khoảng thời gian',
      cancelText: 'Hủy',
      confirmText: 'Áp dụng',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: DesignColors.primary,
              onPrimary: DesignColors.white,
              surface: DesignColors.white,
              onSurface: DesignColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedTimeRange = AnalyticsTimeRangeCustom(
          startDate: DateTime(
            picked.start.year,
            picked.start.month,
            picked.start.day,
          ),
          endDate: DateTime(
            picked.end.year,
            picked.end.month,
            picked.end.day,
            23,
            59,
            59,
          ),
        );
      });
    }
  }

  Widget _buildTimeOption(String label, _TimeFilterOption option) {
    final isSelected = _isTimeOptionSelected(option);

    return InkWell(
      onTap: () {
        if (option == _TimeFilterOption.custom) {
          setState(() => _showDatePicker = true);
        } else {
          setState(() {
            _selectedTimeRange = _timeOptionToRange(option);
            _showDatePicker = false;
          });
        }
      },
      borderRadius: BorderRadius.circular(DesignRadius.md),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignColors.primary.withValues(alpha: 0.08)
              : null,
          borderRadius: BorderRadius.circular(DesignRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? DesignColors.primary
                      : DesignColors.dividerLight,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: DesignColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: DesignTypography.bodyMedium.copyWith(
                  color: isSelected
                      ? DesignColors.primary
                      : DesignColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isTimeOptionSelected(_TimeFilterOption option) {
    switch (option) {
      case _TimeFilterOption.thisWeek:
        return _selectedTimeRange is AnalyticsTimeRangeWeek;
      case _TimeFilterOption.thisMonth:
        return _selectedTimeRange is AnalyticsTimeRangeMonth;
      case _TimeFilterOption.all:
        return _selectedTimeRange is AnalyticsTimeRangeAll;
      case _TimeFilterOption.custom:
        return _selectedTimeRange is AnalyticsTimeRangeCustom;
    }
  }

  AnalyticsTimeRange _timeOptionToRange(_TimeFilterOption option) {
    switch (option) {
      case _TimeFilterOption.thisWeek:
        return const AnalyticsTimeRangeWeek();
      case _TimeFilterOption.thisMonth:
        return const AnalyticsTimeRangeMonth();
      case _TimeFilterOption.all:
        return const AnalyticsTimeRangeAll();
      case _TimeFilterOption.custom:
        return const AnalyticsTimeRangeAll();
    }
  }

  Widget _buildClassSection() {
    if (widget.classes.isEmpty) {
      return _buildClassEmpty();
    }
    return Column(
      children: [
        _buildClassOption(null, 'Tất cả lớp'),
        ...widget.classes.map((c) => _buildClassOption(c.id, c.name)),
      ],
    );
  }

  Widget _buildClassEmpty() {
    return Text(
      'Chưa có lớp học nào',
      style: DesignTypography.bodySmall.copyWith(
        color: DesignColors.textSecondary,
      ),
    );
  }

  Widget _buildClassOption(String? classId, String label) {
    final isSelected = _selectedClassId == classId;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedClassId = classId;
          _selectedClassName = classId != null ? label : null;
        });
      },
      borderRadius: BorderRadius.circular(DesignRadius.md),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignColors.primary.withValues(alpha: 0.08)
              : null,
          borderRadius: BorderRadius.circular(DesignRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? DesignColors.primary
                      : DesignColors.dividerLight,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: DesignColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: DesignTypography.bodyMedium.copyWith(
                  color: isSelected
                      ? DesignColors.primary
                      : DesignColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact filter chip button for use in the app bar or header area.
class AnalyticsFilterChip extends StatelessWidget {
  final bool hasActiveFilter;
  final String? className;
  final VoidCallback onTap;

  const AnalyticsFilterChip({
    super.key,
    required this.hasActiveFilter,
    required this.onTap,
    this.className,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignRadius.md),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.sm,
          vertical: DesignSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: hasActiveFilter
              ? DesignColors.primary.withValues(alpha: 0.1)
              : DesignColors.white,
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(
            color: hasActiveFilter
                ? DesignColors.primary
                : DesignColors.dividerLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list,
              size: 16,
              color: hasActiveFilter
                  ? DesignColors.primary
                  : DesignColors.textSecondary,
            ),
            SizedBox(width: DesignSpacing.xs),
            Text(
              'Lọc',
              style: DesignTypography.labelMedium.copyWith(
                color: hasActiveFilter
                    ? DesignColors.primary
                    : DesignColors.textPrimary,
              ),
            ),
            if (hasActiveFilter) ...[
              SizedBox(width: DesignSpacing.xs),
              Icon(Icons.check, size: 14, color: DesignColors.primary),
            ],
          ],
        ),
      ),
    );
  }
}
