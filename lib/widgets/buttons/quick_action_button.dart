import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Widget hiển thị quick action button
class QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isGradient;

  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.isPrimary = false,
    this.isGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isGradient) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.xl,
            vertical: DesignSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9333EA), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(DesignRadius.full),
            boxShadow: [DesignElevation.level1],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: DesignIcons.mdSize,
                color: Colors.white,
              ),
              SizedBox(width: DesignSpacing.sm),
              Text(
                label,
                style: DesignTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isPrimary) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.xl,
            vertical: DesignSpacing.md,
          ),
          decoration: BoxDecoration(
            color: DesignColors.primary,
            borderRadius: BorderRadius.circular(DesignRadius.full),
            boxShadow: [DesignElevation.level1],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: DesignIcons.mdSize,
                color: Colors.white,
              ),
              SizedBox(width: DesignSpacing.sm),
              Text(
                label,
                style: DesignTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.lg,
          vertical: DesignSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A3844) : Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.full),
          border: Border.all(
            color: isDark
                ? Colors.grey[700]!
                : Colors.grey[100]!,
            width: 1,
          ),
          boxShadow: [DesignElevation.level1],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: DesignIcons.mdSize,
              color: isDark ? Colors.white : DesignColors.textPrimary,
            ),
            SizedBox(width: DesignSpacing.sm),
            Text(
              label,
              style: DesignTypography.labelMedium.copyWith(
                color: isDark ? Colors.white : DesignColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
