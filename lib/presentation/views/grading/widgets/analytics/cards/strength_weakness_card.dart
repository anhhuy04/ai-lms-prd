import 'package:flutter/material.dart';
import '../../../../../../core/constants/design_tokens.dart';
import '../../../../../../domain/entities/analytics/skill_mastery.dart';

class StrengthWeaknessCard extends StatelessWidget {
  final List<SkillMastery> strengths;
  final List<SkillMastery> weaknesses;
  final Function(String skillName)? onWeaknessTap;

  const StrengthWeaknessCard({
    super.key,
    required this.strengths,
    required this.weaknesses,
    this.onWeaknessTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Strengths section (shown first per UX requirement)
          if (strengths.isNotEmpty) ...[
            Text(
              'Strengths',
              style: DesignTypography.labelMedium.copyWith(
                color: DesignColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
            Wrap(
              spacing: DesignSpacing.sm,
              runSpacing: DesignSpacing.sm,
              children: strengths.map((skill) => _buildChip(
                skill.skillName,
                DesignColors.success.withValues(alpha: 0.1),
                DesignColors.success,
              )).toList(),
            ),
          ],

          // Weaknesses section with CTAs
          if (weaknesses.isNotEmpty) ...[
            SizedBox(height: DesignSpacing.md),
            Text(
              'Areas for Improvement',
              style: DesignTypography.labelMedium.copyWith(
                color: DesignColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
            Wrap(
              spacing: DesignSpacing.sm,
              runSpacing: DesignSpacing.sm,
              children: weaknesses.map((skill) => _buildWeaknessChip(
                skill.skillName,
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      child: Text(
        label,
        style: DesignTypography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildWeaknessChip(String skillName) {
    return GestureDetector(
      onTap: () => onWeaknessTap?.call(skillName),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.sm,
          vertical: DesignSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: DesignColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(color: DesignColors.warning),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              skillName,
              style: DesignTypography.caption.copyWith(
                color: DesignColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: DesignSpacing.xs),
            Icon(
              Icons.arrow_forward,
              size: DesignIcons.xsSize,
              color: DesignColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}
