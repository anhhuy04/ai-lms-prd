import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/domain/entities/assignment_distribution.dart';
import 'package:flutter/material.dart';

/// Assignment card for Grading Hub - đồng bộ với AssignmentCard trong app:
/// - Border radius 18px (DesignRadius.lg * 1.5)
/// - White card, subtle shadow
/// - Blue icon square + title + subtitle
/// - Gray stats bar
/// - Action buttons: Xem đề (outlined) | Danh sách (filled)
class GradingAssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final List<AssignmentDistribution> distributions;
  final bool isDark;
  final VoidCallback onViewPrompt;
  final void Function(AssignmentDistribution dist) onViewList;

  const GradingAssignmentCard({
    super.key,
    required this.assignment,
    required this.distributions,
    required this.isDark,
    required this.onViewPrompt,
    required this.onViewList,
  });

  int get _totalSubmitted =>
      distributions.fold(0, (sum, d) => sum + (d.submittedCount ?? 0));

  int get _totalGraded =>
      distributions.fold(0, (sum, d) => sum + (d.gradedCount ?? 0));

  int get _totalUngraded => _totalSubmitted - _totalGraded;

  int get _totalStudents =>
      distributions.fold(0, (sum, d) => sum + (d.recipientCount ?? 0));

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(DesignRadius.lg * 1.5));

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: borderRadius,
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () {
            if (distributions.length == 1) {
              onViewList(distributions.first);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(DesignSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: icon + title + subtitle
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Blue clipboard icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: DesignColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DesignRadius.md),
                      ),
                      child: Icon(
                        Icons.assignment_outlined,
                        color: DesignColors.primary,
                        size: DesignIcons.mdSize,
                      ),
                    ),
                    const SizedBox(width: DesignSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment.title,
                            style: DesignTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : DesignColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: DesignSpacing.xs),
                          Text(
                            '${distributions.length} lớp đã giao',
                            style: DesignTypography.bodySmall.copyWith(
                              color: DesignColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: DesignSpacing.md),

                // Stats row: Nộp | Chưa chấm | Đã chấm
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSpacing.md,
                    vertical: DesignSpacing.sm + 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(DesignRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.description_outlined,
                        value: '$_totalSubmitted/$_totalStudents',
                        label: 'Nộp',
                        color: DesignColors.textSecondary,
                      ),
                      _Divider(isDark: isDark),
                      _StatItem(
                        icon: Icons.edit_note_outlined,
                        value: '$_totalUngraded',
                        label: 'Chưa chấm',
                        color: _totalUngraded > 0
                            ? DesignColors.warning
                            : DesignColors.textSecondary,
                      ),
                      _Divider(isDark: isDark),
                      _StatItem(
                        icon: Icons.check_circle_outline,
                        value: '$_totalGraded',
                        label: 'Đã chấm',
                        color: DesignColors.success,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: DesignSpacing.md),

                // Action buttons: Xem đề | Danh sách
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Xem đề',
                        icon: Icons.visibility_outlined,
                        isPrimary: false,
                        isDark: isDark,
                        onTap: onViewPrompt,
                      ),
                    ),
                    const SizedBox(width: DesignSpacing.md),
                    Expanded(
                      child: _ActionButton(
                        label: 'Danh sách',
                        icon: Icons.list_alt_outlined,
                        isPrimary: true,
                        isDark: isDark,
                        onTap: () =>
                            onViewList(distributions.first),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: DesignTypography.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: DesignTypography.caption.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      color: isDark ? Colors.grey[700] : Colors.grey[300],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: DesignSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: DesignColors.primary,
              borderRadius: BorderRadius.circular(DesignRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: DesignSpacing.xs),
                Text(
                  label,
                  style: DesignTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: DesignSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(DesignRadius.md),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : DesignColors.primary,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isDark ? Colors.grey[400] : DesignColors.primary,
              ),
              const SizedBox(width: DesignSpacing.xs),
              Text(
                label,
                style: DesignTypography.labelMedium.copyWith(
                  color: isDark ? Colors.grey[400] : DesignColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
