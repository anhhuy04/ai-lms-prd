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

        return GestureDetector(
          onTap: () => context.pushNamed(AppRoute.teacherRecommendationsTab),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignSpacing.md,
              vertical: DesignSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: DesignColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.full),
              border: Border.all(color: DesignColors.error),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber,
                  color: DesignColors.error,
                  size: DesignIcons.smSize,
                ),
                SizedBox(width: DesignSpacing.xs),
                Text(
                  '$count hoc sinh can chu y',
                  style: DesignTypography.labelMedium.copyWith(
                    color: DesignColors.error,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
