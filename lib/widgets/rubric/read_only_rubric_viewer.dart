import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// ReadOnlyRubricViewer — Dumb StatelessWidget that renders a rubric's
/// criteria and levels in read-only mode.
///
/// Used in:
/// - StudentAssignmentDetailScreen (compact + full mode)
/// - StudentWorkspaceScreen (inside bottom sheet)
/// - QuestionAnswerCard (replaces _buildRubric)
/// - Phase 6: AI feedback display (selectedLevels provided by AI)
class ReadOnlyRubricViewer extends StatelessWidget {
  /// The rubric JSONB map. Null or empty criteria → SizedBox.shrink().
  final Map<String, dynamic>? rubric;

  /// Optional: criterion_id → selected level index (Phase 6 fills this).
  final Map<String, int>? selectedLevels;

  /// Whether to show the "Tiêu chí chấm điểm" header. Default: true.
  final bool showHeader;

  /// Compact mode: only shows criterion name + max_points, no level cards.
  final bool compact;

  const ReadOnlyRubricViewer({
    super.key,
    required this.rubric,
    this.selectedLevels,
    this.showHeader = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Guard: null rubric or empty criteria
    final criteria = rubric?['criteria'];
    if (rubric == null || criteria == null || (criteria as List).isEmpty) {
      return const SizedBox.shrink();
    }

    final criteriaList = criteria.cast<Map<String, dynamic>>();

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: criteriaList
            .map((criterion) => _buildCompactCriterion(criterion))
            .toList(),
      );
    }

    return Container(
      padding: const EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Row(
              children: [
                const Icon(
                  Icons.grading,
                  size: DesignIcons.smSize,
                  color: DesignColors.tealPrimary,
                ),
                const SizedBox(width: DesignSpacing.sm),
                Text(
                  'Tiêu chí chấm điểm',
                  style: DesignTypography.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: DesignSpacing.md),
          ],
          ...criteriaList.asMap().entries.map((entry) {
            final idx = entry.key;
            final criterion = entry.value;
            final criterionId = criterion['id']?.toString();
            final selectedLevelIndex =
                (criterionId != null && selectedLevels != null)
                    ? selectedLevels![criterionId]
                    : null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCriterionSection(criterion, selectedLevelIndex),
                if (idx < criteriaList.length - 1)
                  const Divider(
                    color: DesignColors.dividerLight,
                    height: DesignSpacing.lg,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCriterionSection(
    Map<String, dynamic> criterion,
    int? selectedLevelIndex,
  ) {
    final levels = (criterion['levels'] as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                criterion['name']?.toString() ?? '',
                style: DesignTypography.titleMedium.copyWith(fontSize: 14),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: DesignColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(DesignRadius.full),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSpacing.sm,
                vertical: DesignSpacing.xs,
              ),
              child: Text(
                'Tối đa ${criterion['max_points']}đ',
                style: DesignTypography.caption.copyWith(
                  color: DesignColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignSpacing.sm),
        ...levels.asMap().entries.map((entry) {
          final levelIdx = entry.key;
          final level = entry.value as Map<String, dynamic>;
          return _buildLevelItem(
            level,
            isSelected: levelIdx == selectedLevelIndex,
          );
        }),
      ],
    );
  }

  Widget _buildLevelItem(
    Map<String, dynamic> level, {
    required bool isSelected,
  }) {
    return Semantics(
      label:
          '${level['points']} điểm - ${level['description']?.toString() ?? ''}',
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignColors.primary.withValues(alpha: 0.08)
              : DesignColors.white,
          border: Border.all(
            color: isSelected ? DesignColors.primary : DesignColors.dividerLight,
          ),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: DesignSpacing.xs),
              decoration: BoxDecoration(
                color: DesignColors.moonMedium,
                borderRadius: BorderRadius.circular(DesignRadius.xs),
              ),
              child: Text(
                '${level['points']}đ',
                style: DesignTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Text(
                level['description']?.toString() ?? '',
                style: DesignTypography.bodyMedium.copyWith(fontSize: 12),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: DesignColors.primary,
                size: DesignIcons.smSize,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCriterion(Map<String, dynamic> criterion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSpacing.xs),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: DesignIcons.xsSize,
            color: DesignColors.tealPrimary,
          ),
          const SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: Text(
              criterion['name']?.toString() ?? '',
              style: DesignTypography.bodyMedium,
            ),
          ),
          Text(
            '${criterion['max_points']}đ',
            style: DesignTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: DesignColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
