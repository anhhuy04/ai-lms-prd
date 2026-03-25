import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/providers/recommendation_providers.dart';
import 'package:ai_mls/presentation/views/recommendation/widgets/recommendation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

/// StudentRecommendationsTab: "Hop thuoc dau giuong" pillbox (REC-02).
/// Shows student recommendations (LIMIT 20).
/// Compact cards, quick access to learning resources.
class StudentRecommendationsTab extends ConsumerWidget {
  const StudentRecommendationsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(studentRecommendationNotifierProvider());

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Goi y hoc tap',
          style: DesignTypography.titleLarge,
        ),
        automaticallyImplyLeading: true,
      ),
      body: recsAsync.when(
        data: (recs) {
          if (recs.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(studentRecommendationNotifierProvider());
            },
            child: ListView.builder(
              padding: EdgeInsets.all(DesignSpacing.md),
              itemCount: recs.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: DesignSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Han che nhat',
                          style: DesignTypography.titleSmall.copyWith(
                            color: DesignColors.primary,
                          ),
                        ),
                        Text(
                          'Tap hop nhung goi y quan trong nhat dua tren ket qua hoc tap gan day.',
                          style: DesignTypography.bodySmall.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: DesignSpacing.md),
                      ],
                    ),
                  );
                }

                final rec = recs[index - 1];
                return RecommendationCard(
                  recommendation: rec,
                  compact: true,
                  onDismiss: () async {
                    await _dismiss(ref, rec.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Da xoa goi y'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
        loading: () => _buildLoadingState(),
        error: (e, _) => _buildErrorState(ref, e.toString()),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.thumb_up_outlined,
            size: 64,
            color: DesignColors.success,
          ),
          SizedBox(height: DesignSpacing.md),
          Text(
            'Khong co goi y nao',
            style: DesignTypography.titleMedium,
          ),
          SizedBox(height: DesignSpacing.sm),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DesignSpacing.xl),
            child: Text(
              'Ban dang hoc tot! Tiep tuc lam bai de cai thien.',
              style: DesignTypography.bodyMedium.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(DesignSpacing.md),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 80,
            margin: EdgeInsets.only(bottom: DesignSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DesignRadius.lg),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: DesignColors.error),
          SizedBox(height: DesignSpacing.md),
          Text('Loi tai du lieu', style: DesignTypography.titleMedium),
          Text(error, style: DesignTypography.bodySmall.copyWith(color: Colors.grey)),
          SizedBox(height: DesignSpacing.md),
          ElevatedButton(
            onPressed: () => ref.invalidate(studentRecommendationNotifierProvider()),
            child: Text('Thu lai'),
          ),
        ],
      ),
    );
  }

  Future<void> _dismiss(WidgetRef ref, String recommendationId) async {
    await ref.read(
      dismissRecommendationProvider(recommendationId: recommendationId).notifier,
    ).dismiss();
    // Also invalidate top3RecommendationsProvider so home dashboard updates
    ref.invalidate(top3RecommendationsProvider);
  }
}
