import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/providers/recommendation_providers.dart';
import 'package:ai_mls/presentation/views/recommendation/widgets/recommendation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

/// Filter mode for teacher recommendations
enum _FilterMode { all, urgent }

/// TeacherRecommendationsScreen: Full recommendations list for teachers (REC-01).
/// Shows all intervention suggestions across all classes.
/// Includes filter chips at top.
class TeacherRecommendationsScreen extends ConsumerStatefulWidget {
  const TeacherRecommendationsScreen({super.key});

  @override
  ConsumerState<TeacherRecommendationsScreen> createState() =>
      _TeacherRecommendationsScreenState();
}

class _TeacherRecommendationsScreenState
    extends ConsumerState<TeacherRecommendationsScreen> {
  String? _selectedClassId;
  _FilterMode _filterMode = _FilterMode.all;

  @override
  Widget build(BuildContext context) {
    final recsAsync = ref.watch(
      teacherRecommendationNotifierProvider(classId: _selectedClassId),
    );

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Goi y hoc tap',
          style: DesignTypography.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildFilterRow(),
          Expanded(
            child: recsAsync.when(
              data: (recs) {
                if (recs.isEmpty) {
                  return _buildEmptyState();
                }

                // Apply filter: urgent = priorityValue <= 2 (high + medium)
                final urgent = recs.where((r) => r.priorityValue <= 2).toList();
                final normal = recs.where((r) => r.priorityValue > 2).toList();

                // Filter display based on mode
                final showUrgent = _filterMode == _FilterMode.all || _filterMode == _FilterMode.urgent;
                final showNormal = _filterMode == _FilterMode.all;

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                      teacherRecommendationNotifierProvider(classId: _selectedClassId),
                    );
                  },
                  child: ListView(
                    padding: EdgeInsets.all(DesignSpacing.md),
                    children: [
                      if (showUrgent && urgent.isNotEmpty) ...[
                        _buildSectionHeader('Can chu y', DesignColors.error, urgent.length),
                        ...urgent.map((rec) => RecommendationCard(
                          recommendation: rec,
                          onDismiss: () => _dismiss(rec.id),
                        )),
                        SizedBox(height: DesignSpacing.lg),
                      ],
                      if (showNormal && normal.isNotEmpty) ...[
                        _buildSectionHeader('Goi y khac', DesignColors.primary, normal.length),
                        ...normal.map((rec) => RecommendationCard(
                          recommendation: rec,
                          onDismiss: () => _dismiss(rec.id),
                        )),
                      ],
                    ],
                  ),
                );
              },
              loading: () => _buildLoadingState(),
              error: (e, _) => _buildErrorState(e.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Tat ca', _filterMode == _FilterMode.all, _FilterMode.all),
            SizedBox(width: DesignSpacing.sm),
            _buildFilterChip('Khan cap', _filterMode == _FilterMode.urgent, _FilterMode.urgent),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, _FilterMode mode) {
    return FilterChip(
      label: Text(label, style: DesignTypography.labelMedium),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _filterMode = mode;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: DesignColors.primary.withValues(alpha: 0.1),
      checkmarkColor: DesignColors.primary,
      side: BorderSide(
        color: selected ? DesignColors.primary : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, int count) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: DesignSpacing.sm),
          Text(
            '$title ($count)',
            style: DesignTypography.titleSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: DesignColors.success,
          ),
          SizedBox(height: DesignSpacing.md),
          Text(
            'Khong co goi y nao',
            style: DesignTypography.titleMedium,
          ),
          SizedBox(height: DesignSpacing.sm),
          Text(
            'Cac goi y se xuat hien khi co hoc sinh\ncan ho tro them.',
            style: DesignTypography.bodyMedium.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
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
            height: 120,
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

  Widget _buildErrorState(String error) {
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
            onPressed: () => ref.invalidate(
              teacherRecommendationNotifierProvider(classId: _selectedClassId),
            ),
            child: Text('Thu lai'),
          ),
        ],
      ),
    );
  }

  Future<void> _dismiss(String recommendationId) async {
    // Use notifier dismiss → updates local state immediately for smooth UX
    await ref.read(teacherRecommendationNotifierProvider(classId: _selectedClassId).notifier).dismiss(recommendationId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa gợi ý'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
