import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/utils/score_display_utils.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/domain/entities/analytics/class_analytics.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/presentation/providers/analytics_providers.dart';
import 'package:ai_mls/presentation/views/grading/widgets/analytics/teacher/cards/class_overview_card.dart';
import 'package:ai_mls/presentation/views/grading/widgets/analytics/teacher/charts/grade_distribution_heatmap.dart';
import 'package:ai_mls/presentation/views/grading/widgets/analytics/teacher/lists/top_performers_list.dart';
import 'package:ai_mls/presentation/views/grading/widgets/analytics/teacher/lists/bottom_performers_list.dart';
import 'package:ai_mls/presentation/views/grading/teacher_student_analytics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Teacher Analytics Screen - Dual Mode Design
/// - If classId is null: Show list of classes → tap to view analytics
/// - If classId is provided: Show analytics for that specific class
class TeacherAnalyticsScreen extends ConsumerStatefulWidget {
  final String? classId;

  const TeacherAnalyticsScreen({super.key, this.classId});

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
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (e, st) {
          AppLogger.error(
            '[TeacherAnalytics] Lỗi tải danh sách lớp',
            error: e,
            stackTrace: st,
          );
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: DesignColors.error),
                SizedBox(height: DesignSpacing.md),
                Text(
                  'Không thể tải danh sách lớp',
                  style: DesignTypography.titleMedium,
                ),
                SizedBox(height: DesignSpacing.sm),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(teacherClassesForAnalyticsProvider),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        },
        data: (classes) => _buildClassListRefresh(classes),
      ),
    );
  }

  Widget _buildClassListRefresh(List<Class> classes) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(teacherClassesForAnalyticsProvider);
      },
      child: _buildClassList(classes),
    );
  }

  Widget _buildClassList(List<Class> classes) {
    if (classes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.class_outlined,
              size: 64,
              color: DesignColors.textSecondary,
            ),
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

  Widget _buildClassCard(Class classItem) {
    final analyticsAsync = ref.watch(classAnalyticsProvider(classItem.id));

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedClassId = classItem.id;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: DesignSpacing.md),
        decoration: BoxDecoration(
          color: DesignColors.white,
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header - Avatar + Info
            Container(
              padding: EdgeInsets.all(DesignSpacing.md),
              child: Row(
                children: [
                  // Avatar vuông màu xanh lá
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: DesignColors.info,
                      borderRadius: BorderRadius.circular(DesignRadius.md),
                    ),
                    child: Center(
                      child: analyticsAsync.when(
                        data: (analytics) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ScoreDisplayUtils.toRawString(analytics.classAverage),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const Text(
                              '/10',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        loading: () => const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        error: (_, __) => const Icon(
                          Icons.error,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: DesignSpacing.md),
                  // Tên lớp + số HS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classItem.name,
                          style: DesignTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: DesignSpacing.xs),
                        analyticsAsync.when(
                          data: (analytics) => Text(
                            '${analytics.totalStudents} HỌC SINH',
                            style: DesignTypography.bodySmall.copyWith(
                              color: DesignColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
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
                  // Icon info
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: DesignColors.moonLight,
                      borderRadius: BorderRadius.circular(DesignRadius.sm),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: DesignColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Container(
              height: 1,
              color: DesignColors.dividerLight,
            ),
            // Bottom - Xem chi tiết button
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedClassId = classItem.id;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: DesignSpacing.sm + 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'XEM CHI TIẾT',
                      style: DesignTypography.bodySmall.copyWith(
                        color: DesignColors.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: DesignSpacing.xs),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: DesignColors.primary,
                    ),
                  ],
                ),
              ),
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

    final className =
        classInfo.whenOrNull(
          data: (classes) {
            final found = classes.where((c) => c.id == classId).firstOrNull;
            return found?.name;
          },
        ) ??
        'Lớp học';

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
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (e, st) {
          AppLogger.error(
            '[TeacherAnalytics] Lỗi tải phân tích lớp: $classId',
            error: e,
            stackTrace: st,
          );
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: DesignColors.error),
                SizedBox(height: DesignSpacing.md),
                Text(
                  'Không thể tải dữ liệu',
                  style: DesignTypography.titleMedium,
                ),
                SizedBox(height: DesignSpacing.sm),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(classAnalyticsProvider(classId)),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        },
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
              highestScore: analytics.highestScore,
              lowestScore: analytics.lowestScore,
              totalStudents: analytics.totalStudents,
              totalSubmissions: analytics.totalSubmissions,
              submissionRate: analytics.submissionRate,
              lateSubmissionRate: analytics.lateSubmissionRate,
              lateSubmissionCount: analytics.lateSubmissionCount,
              lateSubmissionTotal: analytics.totalSubmissions,
              worstOffenderName: analytics.worstOffender?.studentName,
              worstOffenderCount: analytics.worstOffender?.lateCount,
            ),
            SizedBox(height: DesignSpacing.lg),

            // Grade Distribution Chart (Heatmap)
            _buildSectionTitle('Phân bố điểm số theo môn'),
            SizedBox(height: DesignSpacing.sm),
            GradeDistributionHeatmap(
              subjects: analytics.subjectDistributions,
            ),
            SizedBox(height: DesignSpacing.lg),

            // Top Performers
            _buildSectionTitle('Học sinh xuất sắc'),
            SizedBox(height: DesignSpacing.sm),
            TopPerformersList(
              performers: analytics.topPerformers,
              onTap: (studentId) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TeacherStudentAnalyticsScreen(
                      studentId: studentId,
                      classId: classId,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: DesignSpacing.lg),

            // Bottom Performers (needs attention)
            _buildSectionTitle('Cần chú ý'),
            SizedBox(height: DesignSpacing.sm),
            BottomPerformersList(
              performers: analytics.bottomPerformers,
              onTap: (studentId) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TeacherStudentAnalyticsScreen(
                      studentId: studentId,
                      classId: classId,
                    ),
                  ),
                );
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
      style: DesignTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
