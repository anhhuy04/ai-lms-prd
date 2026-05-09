import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/providers/recommendation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// InterventionBadge: ATC Dashboard badge for teachers.
/// Shows count of urgent recommendations (priority <= 2).
/// Appears on TeacherGradingHub and TeacherHomeContent.
/// Tap navigates to teacher recommendations tab.
class InterventionBadge extends ConsumerWidget {
  const InterventionBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(interventionCountProvider);

    return countAsync.when(
      data: (count) {
        if (count == 0) return const SizedBox.shrink();

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                context.pushNamed(AppRoute.teacherRecommendationsTab),
            borderRadius: BorderRadius.circular(DesignRadius.full),
            child: Ink(
              padding: EdgeInsets.symmetric(
                horizontal: DesignSpacing.md,
                vertical: DesignSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DesignColors.error.withValues(alpha: 0.12),
                    DesignColors.error.withValues(alpha: 0.06),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(DesignRadius.full),
                border: Border.all(
                  color: DesignColors.error.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: DesignColors.error.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: DesignColors.error,
                      size: DesignIcons.smSize,
                    ),
                  ),
                  SizedBox(width: DesignSpacing.sm),
                  Text(
                    '$count học sinh cần chú ý',
                    style: DesignTypography.labelMedium.copyWith(
                      color: DesignColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: DesignSpacing.xs),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: DesignColors.error,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
