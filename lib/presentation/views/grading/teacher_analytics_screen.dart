import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/analytics/class_analytics.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/presentation/providers/analytics_providers.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Teacher Analytics Screen - Dual Mode Design
/// - If classId is null: Show list of classes → tap to view analytics
/// - If classId is provided: Show analytics for that specific class
class TeacherAnalyticsScreen extends ConsumerStatefulWidget {
  final String? classId;

  const TeacherAnalyticsScreen({
    super.key,
    this.classId,
  });

  @override
  ConsumerState<TeacherAnalyticsScreen> createState() =>
      _TeacherAnalyticsScreenState();
}

class _TeacherAnalyticsScreenState
    extends ConsumerState<TeacherAnalyticsScreen> {
  String? _selectedClassId;

  @override
  void initState() {
    super.initState();
    _selectedClassId = widget.classId;
  }

  @override
  Widget build(BuildContext context) {
    // If no class selected → show class list
    if (_selectedClassId == null) {
      return _buildClassListView();
    }

    // If class selected → show analytics dashboard
    return _buildAnalyticsDashboard(_selectedClassId!);
  }

  /// View 1: Class List (when no classId provided)
  Widget _buildClassListView() {
    final classesAsync = ref.watch(teacherClassesForAnalyticsProvider);

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        title: const Text('Phân tích Lớp học'),
        backgroundColor: DesignColors.moonLight,
        elevation: 0,
      ),
      body: classesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: DesignColors.error),
              SizedBox(height: DesignSpacing.md),
              Text('Không thể tải danh sách lớp', style: DesignTypography.titleMedium),
              SizedBox(height: DesignSpacing.sm),
              ElevatedButton(
                onPressed: () => ref.invalidate(teacherClassesForAnalyticsProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (classes) => _buildClassList(classes),
      ),
    );
  }

  Widget _buildClassList(List<SchoolClass> classes) {
    if (classes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.class_outlined, size: 64, color: DesignColors.textSecondary),
            SizedBox(height: DesignSpacing.md),
            Text('Bạn chưa có lớp nào', style: DesignTypography.titleMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(DesignSpacing.md),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final classItem = classes[index];
        return _buildClassCard(classItem);
      },
    );
  }

  Widget _buildClassCard(SchoolClass classItem) {
    final analyticsAsync = ref.watch(classAnalyticsProvider(classItem.id));

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedClassId = classItem.id;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: DesignSpacing.md),
        padding: EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: DesignColors.surface,
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          border: Border.all(color: DesignColors.dividerLight),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: DesignColors.primaryLight,
                borderRadius: BorderRadius.circular(DesignRadius.md),
              ),
              child: Center(
                child: analyticsAsync.when(
                  data: (analytics) => Text(
                    '${analytics.classAverage.toStringAsFixed(0)}%',
                    style: DesignTypography.titleMedium.copyWith(
                      color: DesignColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => Icon(Icons.error, color: DesignColors.error),
                ),
              ),
            ),
            SizedBox(width: DesignSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classItem.name ?? 'Lớp học',
                    style: DesignTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: DesignSpacing.xs),
                  analyticsAsync.when(
                    data: (analytics) => Text(
                      '${analytics.totalStudents} học sinh • ${analytics.totalSubmissions} bài nộp',
                      style: DesignTypography.bodySmall.copyWith(
                        color: DesignColors.textSecondary,
                      ),
                    ),
                    loading: () => Text(
                      'Đang tải...',
                      style: DesignTypography.bodySmall.copyWith(
                        color: DesignColors.textSecondary,
                      ),
                    ),
                    error: (_, __) => Text(
                      'Lỗi tải dữ liệu',
                      style: DesignTypography.bodySmall.copyWith(
                        color: DesignColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: DesignColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// View 2: Analytics Dashboard (when classId is provided)
  Widget _buildAnalyticsDashboard(String classId) {
    final analyticsAsync = ref.watch(classAnalyticsProvider(classId));
    final classInfo = ref.watch(teacherClassesForAnalyticsProvider);

    final className = classInfo.whenOrNull(
      data: (classes) => classes.firstWhere(
        (c) => c.id == classId,
        orElse: () => SchoolClass(),
      ).name,
    ) ?? 'Lớp học';

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        title: Text('Phân tích: $className'),
        backgroundColor: DesignColors.moonLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedClassId = null;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(classAnalyticsProvider(classId)),
          ),
        ],
      ),
      body: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: DesignColors.error),
              SizedBox(height: DesignSpacing.md),
              Text('Không thể tải dữ liệu', style: DesignTypography.titleMedium),
              SizedBox(height: DesignSpacing.sm),
              ElevatedButton(
                onPressed: () => ref.invalidate(classAnalyticsProvider(classId)),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (analytics) => _buildAnalyticsContent(analytics, classId),
      ),
    );
  }

  Widget _buildAnalyticsContent(ClassAnalytics analytics, String classId) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(classAnalyticsProvider(classId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Overview Card
            ClassOverviewCard(
              classAverage: analytics.classAverage,
              totalStudents: analytics.totalStudents,
              totalSubmissions: analytics.totalSubmissions,
              highestScore: analytics.topPerformers.isNotEmpty
                  ? analytics.topPerformers.first.score
                  : null,
              lowestScore: analytics.bottomPerformers.isNotEmpty
                  ? analytics.bottomPerformers.last.score
                  : null,
            ),
            SizedBox(height: DesignSpacing.lg),

            // Grade Distribution Chart
            _buildSectionTitle('Phân bố điểm số'),
            SizedBox(height: DesignSpacing.sm),
            GradeDistributionChart(distribution: analytics.distribution),
            SizedBox(height: DesignSpacing.lg),

            // Top Performers
            _buildSectionTitle('Top performers'),
            SizedBox(height: DesignSpacing.sm),
            TopPerformersList(
              performers: analytics.topPerformers,
              onTap: (studentId) {
                // Navigate to student detail
              },
            ),
            SizedBox(height: DesignSpacing.lg),

            // Bottom Performers (needs attention)
            _buildSectionTitle('Cần chú ý'),
            SizedBox(height: DesignSpacing.sm),
            BottomPerformersList(
              performers: analytics.bottomPerformers,
              onTap: (studentId) {
                // Navigate to student detail or send intervention
              },
            ),
            SizedBox(height: DesignSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: DesignTypography.titleMedium.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
