import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/domain/entities/assignment_distribution.dart';
import 'package:flutter/material.dart';

/// Bottom sheet chọn lớp để xem bài nộp - đồng bộ với app style:
/// - Rounded top corners (DesignRadius.lg * 1.5)
/// - Teal header icon
/// - Card-style class items
class ClassBottomSheet extends StatelessWidget {
  final List<AssignmentDistribution> distributions;
  final Assignment assignment;
  final bool isDark;
  final void Function(AssignmentDistribution dist) onClassTap;

  const ClassBottomSheet({
    super.key,
    required this.distributions,
    required this.assignment,
    required this.isDark,
    required this.onClassTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DesignRadius.lg * 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: DesignSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(DesignSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: DesignColors.tealPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.md),
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    color: DesignColors.tealPrimary,
                    size: DesignIcons.mdSize,
                  ),
                ),
                const SizedBox(width: DesignSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chọn lớp',
                        style: DesignTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : DesignColors.textPrimary,
                        ),
                      ),
                      Text(
                        assignment.title,
                        style: DesignTypography.bodySmall.copyWith(
                          color: DesignColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? Colors.grey[700] : DesignColors.dividerLight,
          ),

          // Class list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(DesignSpacing.md),
              itemCount: distributions.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: DesignSpacing.sm),
              itemBuilder: (context, index) {
                final dist = distributions[index];
                return _ClassItem(
                  distribution: dist,
                  isDark: isDark,
                  onTap: () => onClassTap(dist),
                );
              },
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _ClassItem extends StatelessWidget {
  final AssignmentDistribution distribution;
  final bool isDark;
  final VoidCallback onTap;

  const _ClassItem({
    required this.distribution,
    required this.isDark,
    required this.onTap,
  });

  int get _submittedCount => distribution.submittedCount ?? 0;
  int get _recipientCount => distribution.recipientCount ?? 0;
  int get _ungradedCount =>
      (distribution.submittedCount ?? 0) - (distribution.gradedCount ?? 0);

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(DesignRadius.lg));

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: borderRadius,
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(DesignSpacing.md),
            child: Row(
              children: [
                // Class icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: DesignColors.tealPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.md),
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    color: DesignColors.tealPrimary,
                    size: DesignIcons.smSize,
                  ),
                ),
                const SizedBox(width: DesignSpacing.md),

                // Class info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        distribution.className ?? 'Lớp học',
                        style: DesignTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : DesignColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: DesignSpacing.xs),
                      Row(
                        children: [
                          _MiniStat(
                            icon: Icons.description_outlined,
                            text: '$_submittedCount/$_recipientCount nộp',
                            color: DesignColors.textSecondary,
                          ),
                          const SizedBox(width: DesignSpacing.md),
                          _MiniStat(
                            icon: Icons.edit_note_outlined,
                            text: '$_ungradedCount chưa chấm',
                            color: _ungradedCount > 0
                                ? DesignColors.warning
                                : DesignColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: DesignTypography.caption.copyWith(color: color),
        ),
      ],
    );
  }
}
