import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// RubricSummaryButton — Small status indicator widget for essay/shortAnswer questions.
///
/// Shows rubric status in 3 visual states:
/// - Empty: no rubric configured → "Them Rubric" outlined button
/// - Configured: rubric set, editable → success-colored container with criteria count
/// - Locked: rubric set, read-only → muted container with lock icon
///
/// This is a dumb widget — it has no provider dependencies.
/// The caller decides whether to open the builder or viewer via [onTap].
class RubricSummaryButton extends StatelessWidget {
  /// The rubric data. If null, renders the empty "Them Rubric" state.
  final Map<String, dynamic>? rubric;

  /// When true, renders the locked read-only state instead of the editable state.
  final bool isLocked;

  /// Called when the button or container is tapped, regardless of state.
  final VoidCallback onTap;

  const RubricSummaryButton({
    super.key,
    required this.rubric,
    this.isLocked = false,
    required this.onTap,
  });

  int get _criteriaCount => (rubric?['criteria'] as List?)?.length ?? 0;

  @override
  Widget build(BuildContext context) {
    if (rubric == null) {
      return _buildEmpty();
    }
    if (isLocked) {
      return _buildLocked();
    }
    return _buildConfigured();
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.only(top: DesignSpacing.sm),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add, size: DesignIcons.smSize),
        label: const Text('Them Rubric'),
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignColors.primary,
          side: const BorderSide(color: DesignColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.sm),
          ),
          minimumSize: const Size(0, 40),
        ),
      ),
    );
  }

  Widget _buildConfigured() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: DesignSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: DesignColors.success.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          border: const Border(
            left: BorderSide(color: DesignColors.success, width: 3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              size: DesignIcons.smSize,
              color: DesignColors.success,
            ),
            const SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rubric: Da cau hinh $_criteriaCount tieu chi',
                    style: DesignTypography.bodyMedium,
                  ),
                  Text(
                    '(Nhan de sua)',
                    style: DesignTypography.caption.copyWith(
                      color: DesignColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: DesignIcons.smSize,
              color: DesignColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocked() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: DesignSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: DesignColors.disabledLight,
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.lock,
              size: DesignIcons.smSize,
              color: DesignColors.textTertiary,
            ),
            const SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Text(
                'Rubric: $_criteriaCount tieu chi (Chi xem)',
                style: DesignTypography.bodyMedium.copyWith(
                  color: DesignColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
