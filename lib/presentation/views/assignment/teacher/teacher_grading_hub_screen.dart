import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/domain/entities/assignment_distribution.dart';
import 'package:ai_mls/presentation/providers/teacher_assignment_hub_notifier.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/grading_hub/grading_assignment_card.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/grading_hub/class_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Filter options cho Grading Hub (assignment-level)
enum GradingHubFilter {
  all('Tất cả'),
  pending('Chưa chấm'),
  graded('Đã chấm'),
  late('Nộp muộn');

  final String label;
  const GradingHubFilter(this.label);
}

/// Teacher Grading Hub Screen - "Kiểm tra bài"
/// Đồng bộ với TeacherPublishedAssignmentsScreen style:
/// - Background: moonLight
/// - Cards: white, borderRadius 18, subtle shadow
/// - AppBar: white, elevation 0
class TeacherGradingHubScreen extends ConsumerStatefulWidget {
  const TeacherGradingHubScreen({super.key});

  @override
  ConsumerState<TeacherGradingHubScreen> createState() =>
      _TeacherGradingHubScreenState();
}

class _TeacherGradingHubScreenState
    extends ConsumerState<TeacherGradingHubScreen> {
  GradingHubFilter _currentFilter = GradingHubFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teacherAssignmentHubNotifierProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hubState = ref.watch(teacherAssignmentHubNotifierProvider);

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: DesignColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Kiểm tra bài',
          style: const TextStyle(
            color: DesignColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: hubState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) {
          AppLogger.error('[TeacherGradingHub] Error loading data',
              error: e, stackTrace: st);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: DesignIcons.xxlSize, color: DesignColors.error),
                const SizedBox(height: DesignSpacing.lg),
                Text('Không thể tải dữ liệu',
                    style: DesignTypography.titleMedium),
                const SizedBox(height: DesignSpacing.lg),
                ElevatedButton(
                  onPressed: () => ref
                      .read(teacherAssignmentHubNotifierProvider.notifier)
                      .refresh(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        },
        data: (hubData) => _buildContent(context, hubData, isDark),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TeacherAssignmentHubState hubData,
    bool isDark,
  ) {
    // Group distributions by assignment_id
    final grouped = <String, List<AssignmentDistribution>>{};
    for (final dist in hubData.distributions) {
      grouped.putIfAbsent(dist.assignmentId, () => []).add(dist);
    }

    // Get published assignments that have been distributed
    var publishedAssignments = hubData.assignments
        .where((a) => a.isPublished && grouped.containsKey(a.id))
        .toList();

    // Apply filter
    publishedAssignments = _applyFilter(publishedAssignments, grouped);

    return RefreshIndicator(
      onRefresh: () => ref
          .read(teacherAssignmentHubNotifierProvider.notifier)
          .refresh(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignSpacing.md,
              DesignSpacing.md,
              DesignSpacing.md,
              0,
            ),
            child: _buildFilterChips(isDark),
          ),
          Expanded(
            child: publishedAssignments.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.separated(
                    padding: const EdgeInsets.all(DesignSpacing.md),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: publishedAssignments.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: DesignSpacing.md),
                    itemBuilder: (context, index) {
                      final assignment = publishedAssignments[index];
                      final distributions = grouped[assignment.id]!;
                      return GradingAssignmentCard(
                        assignment: assignment,
                        distributions: distributions,
                        isDark: isDark,
                        onViewPrompt: () {
                          context.pushNamed(
                            AppRoute.teacherAssignmentDetail,
                            pathParameters: {
                              'classId': distributions.first.classId ?? '',
                              'distributionId': distributions.first.id,
                            },
                            extra: {'assignment': assignment},
                          );
                        },
                        onViewList: (dist) {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => ClassBottomSheet(
                              distributions: distributions,
                              assignment: assignment,
                              isDark: isDark,
                              onClassTap: (selectedDist) {
                                Navigator.pop(context);
                                context.pushNamed(
                                  AppRoute.teacherSubmissionList,
                                  pathParameters: {
                                    'distributionId': selectedDist.id
                                  },
                                  extra: {
                                    'assignmentTitle': assignment.title,
                                    'className': selectedDist.className,
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Assignment> _applyFilter(
    List<Assignment> assignments,
    Map<String, List<AssignmentDistribution>> grouped,
  ) {
    switch (_currentFilter) {
      case GradingHubFilter.all:
        return assignments;
      case GradingHubFilter.pending:
        // Chỉ hiển thị assignments có submissions chưa chấm
        return assignments.where((a) {
          final dists = grouped[a.id]!;
          final totalSubmitted = dists.fold(0, (s, d) => s + (d.submittedCount ?? 0));
          final totalGraded = dists.fold(0, (s, d) => s + (d.gradedCount ?? 0));
          return totalSubmitted > 0 && totalGraded < totalSubmitted;
        }).toList();
      case GradingHubFilter.graded:
        // Chỉ hiển thị assignments đã chấm xong
        return assignments.where((a) {
          final dists = grouped[a.id]!;
          final totalSubmitted = dists.fold(0, (s, d) => s + (d.submittedCount ?? 0));
          final totalGraded = dists.fold(0, (s, d) => s + (d.gradedCount ?? 0));
          return totalSubmitted > 0 && totalGraded >= totalSubmitted;
        }).toList();
      case GradingHubFilter.late:
        // Chỉ hiển thị assignments có submissions muộn
        return assignments.where((a) {
          final dists = grouped[a.id]!;
          return dists.any((d) => (d.lateSubmissionCount ?? 0) > 0);
        }).toList();
    }
  }

  Widget _buildFilterChips(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: GradingHubFilter.values.map((filter) {
          final isSelected = filter == _currentFilter;
          return Padding(
            padding: const EdgeInsets.only(right: DesignSpacing.sm),
            child: FilterChip(
              label: Text(filter.label),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _currentFilter = filter);
              },
              backgroundColor: isDark ? Colors.grey[800] : Colors.white,
              selectedColor: DesignColors.primary.withValues(alpha: 0.2),
              checkmarkColor: DesignColors.primary,
              labelStyle: DesignTypography.labelMedium.copyWith(
                color: isSelected
                    ? DesignColors.primary
                    : DesignColors.textSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSpacing.xxxxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: DesignIcons.xxlSize,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: DesignSpacing.lg),
            Text(
              'Chưa có bài tập nào được giao',
              style: DesignTypography.titleMedium.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: DesignSpacing.sm),
            Text(
              'Giao bài tập cho lớp để bắt đầu kiểm tra.',
              style: DesignTypography.bodyMedium.copyWith(
                color: isDark ? Colors.grey[600] : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
