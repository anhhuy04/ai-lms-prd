import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:ai_mls/presentation/providers/class_notifier.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_preview_assignment_screen.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình chi tiết bài tập đã giao cho 1 lớp cụ thể (teacher view).
/// Hiển thị stat cards, action buttons, cấu hình, top 3, cần chú ý.
class TeacherAssignmentDetailScreen extends ConsumerWidget {
  final String classId;
  final String distributionId;
  final String assignmentTitle;
  final String className;

  const TeacherAssignmentDetailScreen({
    super.key,
    required this.classId,
    required this.distributionId,
    this.assignmentTitle = '',
    this.className = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(distributionDetailProvider(distributionId));
    final submissionsAsync = ref.watch(
      distributionSubmissionsProvider(distributionId),
    );
    final classState = ref.watch(classNotifierProvider);

    int totalStudents = 0;
    if (classState.hasValue) {
      final selectedClass = classState.value!
          .where((c) => c.id == classId)
          .firstOrNull;
      totalStudents = selectedClass?.studentCount ?? 0;
    }

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: _buildAppBar(context),
      body: detailAsync.when(
        loading: () => const ShimmerAssignmentDetailLoading(),
        error: (error, _) => _buildErrorState(context, ref, error),
        data: (detail) {
          final assignment =
              detail['assignments'] as Map<String, dynamic>? ?? {};
          return submissionsAsync.when(
            loading: () => _buildBodyWithShimmerSubmissions(
              context,
              detail,
              assignment,
              totalStudents,
            ),
            error: (error, _) => _buildErrorState(context, ref, error),
            data: (submissions) => _buildBody(
              context,
              ref,
              detail,
              assignment,
              submissions,
              totalStudents,
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final title = assignmentTitle.isNotEmpty
        ? '$assignmentTitle - $className'
        : className;
    return AppBar(
      backgroundColor: DesignColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: DesignIcons.smSize),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: DesignTypography.bodyMediumSize,
          fontWeight: DesignTypography.bold,
          color: DesignColors.textPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () {
            // TODO: Show more options menu
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: DesignIcons.xxlSize,
              color: DesignColors.error,
            ),
            const SizedBox(height: DesignSpacing.lg),
            Text('Không thể tải dữ liệu', style: DesignTypography.titleMedium),
            const SizedBox(height: DesignSpacing.sm),
            Text(
              error.toString(),
              style: DesignTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(distributionDetailProvider(distributionId));
                ref.invalidate(distributionSubmissionsProvider(distributionId));
              },
              icon: const Icon(Icons.refresh, size: DesignIcons.smSize),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyWithShimmerSubmissions(
    BuildContext context,
    Map<String, dynamic> detail,
    Map<String, dynamic> assignment,
    int totalStudents,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: DesignSpacing.xxxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(context, detail, assignment, [], totalStudents),
          _buildActionButtons(context, assignment, detail, classId),
          _buildConfigCard(context, detail, assignment),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
            child: ShimmerAssignmentListLoading(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> detail,
    Map<String, dynamic> assignment,
    List<Map<String, dynamic>> submissions,
    int totalStudents,
  ) {
    return RefreshIndicator(
      color: DesignColors.refreshIndicator,
      onRefresh: () async {
        ref.invalidate(distributionDetailProvider(distributionId));
        ref.invalidate(distributionSubmissionsProvider(distributionId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: DesignSpacing.xxxxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCards(
              context,
              detail,
              assignment,
              submissions,
              totalStudents,
            ),
            _buildActionButtons(context, assignment, detail, classId),
            _buildConfigCard(context, detail, assignment),
            _buildTopSubmitters(context, submissions),
            _buildWarningSection(context, detail, submissions),
          ],
        ),
      ),
    );
  }

  // ==================== STAT CARDS (2x2 Grid) ====================
  Widget _buildStatCards(
    BuildContext context,
    Map<String, dynamic> detail,
    Map<String, dynamic> assignment,
    List<Map<String, dynamic>> submissions,
    int totalStudents,
  ) {
    final submitted = submissions
        .where((s) => s['submitted_at'] != null)
        .length;
    final notSubmitted = (totalStudents > submitted)
        ? totalStudents - submitted
        : 0;
    final avgScore = _calculateAvgScore(submissions);

    return Padding(
      padding: const EdgeInsets.all(DesignSpacing.lg),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: DesignSpacing.md,
        crossAxisSpacing: DesignSpacing.md,
        childAspectRatio: 2.0,
        children: [
          _StatCard(
            label: 'Sĩ số',
            value: '$totalStudents',
            icon: Icons.groups,
            iconColor: DesignColors.primary,
            iconBgColor: DesignColors.primary.withValues(alpha: 0.1),
          ),
          _StatCard(
            label: 'Đã nộp',
            value: '$submitted',
            icon: Icons.check_circle,
            iconColor: DesignColors.success,
            iconBgColor: DesignColors.success.withValues(alpha: 0.1),
          ),
          _StatCard(
            label: 'Chưa nộp',
            value: '$notSubmitted',
            icon: Icons.pending,
            iconColor: DesignColors.textSecondary,
            iconBgColor: DesignColors.moonMedium,
          ),
          _StatCard(
            label: 'Điểm TB',
            value: avgScore,
            icon: Icons.analytics,
            iconColor: DesignColors.primary,
            iconBgColor: DesignColors.primary.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }

  // ==================== ACTION BUTTONS ====================
  Widget _buildActionButtons(
    BuildContext context,
    Map<String, dynamic> assignment,
    Map<String, dynamic> detail,
    String classId,
  ) {
    final assignmentId = assignment['id'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.only(bottom: DesignSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.visibility,
                label: 'Xem đề bài',
                onTap: () {
                  if (assignmentId != null) {
                    final questions = _parseQuestions(assignment);
                    final title = assignment['title'] as String? ?? 'Bài tập';
                    final description = assignment['description'] as String?;
                    final totalPoints =
                        (assignment['total_points'] as num?)?.toDouble() ?? 0.0;

                    final dueAtStr = detail['due_at'] as String?;
                    DateTime? dueDate;
                    TimeOfDay? dueTime;
                    if (dueAtStr != null) {
                      dueDate = DateTime.tryParse(dueAtStr);
                      if (dueDate != null) {
                        dueTime = TimeOfDay.fromDateTime(dueDate);
                      }
                    }

                    final timeLimitMinutes =
                        detail['time_limit_minutes'] as int?;
                    final timeLimit = timeLimitMinutes?.toString();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherPreviewAssignmentScreen(
                          title: title,
                          description: description,
                          questions: questions,
                          totalPoints: totalPoints,
                          dueDate: dueDate,
                          dueTime: dueTime,
                          timeLimit: timeLimit,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: DesignSpacing.md),
            Expanded(
              child: _ActionButton(
                icon: Icons.edit_document,
                label: 'Sửa đề',
                onTap: () {
                  if (assignmentId != null) {
                    context.pushNamed(
                      AppRoute.teacherEditAssignment,
                      pathParameters: {'assignmentId': assignmentId},
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: DesignSpacing.md),
            Expanded(
              child: _ActionButton(
                icon: Icons.settings,
                label: 'Cấu hình',
                onTap: () {
                  if (assignmentId != null) {
                    context.pushNamed(
                      AppRoute.teacherDistributeAssignment,
                      extra: {
                        'assignmentId': assignmentId,
                        'selectedClassId': classId,
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to parse questions for Preview screen
  List<Map<String, dynamic>> _parseQuestions(Map<String, dynamic> assignment) {
    final aqList = assignment['assignment_questions'] as List? ?? [];
    return aqList.map((aqRaw) {
      if (aqRaw is! Map) return <String, dynamic>{};
      final aq = Map<String, dynamic>.from(aqRaw);

      final points = (aq['points'] as num?)?.toDouble() ?? 1.0;
      final qRaw = aq['questions'];
      final q = qRaw is Map
          ? Map<String, dynamic>.from(qRaw)
          : <String, dynamic>{};

      final typeStr = q['type'] as String? ?? 'multiple_choice';
      QuestionType qType;
      switch (typeStr) {
        case 'short_answer':
          qType = QuestionType.shortAnswer;
          break;
        case 'essay':
          qType = QuestionType.essay;
          break;
        case 'math':
          qType = QuestionType.math;
          break;
        default:
          qType = QuestionType.multipleChoice;
      }

      final content = q['content'] is Map
          ? Map<String, dynamic>.from(q['content'])
          : {};
      final text = content['text'] as String? ?? '';

      // Attempt to parse options from custom_content or fall back to empty
      final customContent = aq['custom_content'] is Map
          ? Map<String, dynamic>.from(aq['custom_content'])
          : {};
      // Format mới: ưu tiên choices, fallback options
      final optionsRaw = customContent['choices'] ?? customContent['options'];

      List<Map<String, dynamic>> options = [];
      if (optionsRaw is List && optionsRaw.isNotEmpty) {
        if (optionsRaw.first is String) {
          final correctAnswerIndex =
              customContent['correctAnswer'] as int? ?? 0;
          options = optionsRaw.asMap().entries.map((entry) {
            return {
              'text': entry.value.toString(),
              'isCorrect': entry.key == correctAnswerIndex,
            };
          }).toList();
        } else if (optionsRaw.first is Map) {
          options = optionsRaw
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      }

      // Format mới: ưu tiên override_text, fallback text
      final questionText = customContent['override_text'] as String? ?? text;

      return {
        'type': qType,
        'text': questionText,
        'points': points,
        'options': options,
      };
    }).toList();
  }

  // ==================== CONFIG CARD ====================
  Widget _buildConfigCard(
    BuildContext context,
    Map<String, dynamic> detail,
    Map<String, dynamic> assignment,
  ) {
    final dueAt = detail['due_at'] as String?;
    final timeLimitMinutes = detail['time_limit_minutes'] as int?;
    final maxScore = assignment['max_score'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.only(bottom: DesignSpacing.lg),
        child: Container(
          decoration: BoxDecoration(
            color: DesignColors.white,
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            boxShadow: [DesignElevation.level1],
          ),
          padding: const EdgeInsets.all(DesignSpacing.lg + 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cấu hình bài tập',
                    style: TextStyle(
                      fontSize: DesignTypography.titleLargeSize,
                      fontWeight: DesignTypography.bold,
                      color: DesignColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Edit config
                    },
                    child: Text(
                      'Chỉnh sửa',
                      style: TextStyle(
                        fontSize: DesignTypography.bodySmallSize,
                        fontWeight: DesignTypography.semiBold,
                        color: DesignColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignSpacing.lg),
              // Hạn nộp bài
              _ConfigRow(
                icon: Icons.calendar_month,
                iconColor: DesignColors.primary,
                iconBgColor: DesignColors.primary.withValues(alpha: 0.1),
                label: 'Hạn nộp bài',
                value: _formatDueDate(dueAt),
                subtitle: _formatCountdown(dueAt),
                subtitleColor: DesignColors.warning,
              ),
              const Divider(
                height: DesignSpacing.xxl,
                color: DesignColors.dividerLight,
              ),
              // Thời gian + Thang điểm
              Row(
                children: [
                  Expanded(
                    child: _ConfigRow(
                      icon: Icons.timer,
                      iconColor: const Color(0xFF7C3AED),
                      iconBgColor: const Color(
                        0xFF7C3AED,
                      ).withValues(alpha: 0.1),
                      label: 'Thời gian',
                      value: timeLimitMinutes != null
                          ? '$timeLimitMinutes phút'
                          : 'Không giới hạn',
                    ),
                  ),
                  Expanded(
                    child: _ConfigRow(
                      icon: Icons.stars,
                      iconColor: DesignColors.success,
                      iconBgColor: DesignColors.success.withValues(alpha: 0.1),
                      label: 'Thang điểm',
                      value: maxScore != null ? '$maxScore' : '10.0',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TOP 3 SUBMITTERS ====================
  Widget _buildTopSubmitters(
    BuildContext context,
    List<Map<String, dynamic>> submissions,
  ) {
    final submitted = submissions
        .where((s) => s['submitted_at'] != null)
        .toList();
    if (submitted.isEmpty) return const SizedBox.shrink();

    // Top 3 sớm nhất (đã sort by submitted_at ASC)
    final top3 = submitted.take(3).toList();
    final badgeColors = [
      const Color(0xFFFBBF24), // Vàng
      const Color(0xFFD1D5DB), // Bạc
      const Color(0xFFFB923C), // Đồng
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.only(bottom: DesignSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Color(0xFFFBBF24),
                      size: DesignIcons.smSize,
                    ),
                    const SizedBox(width: DesignSpacing.sm),
                    Text(
                      'Nộp bài sớm nhất',
                      style: TextStyle(
                        fontSize: DesignTypography.bodySmallSize + 2,
                        fontWeight: DesignTypography.bold,
                        color: DesignColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // TODO: View all submissions
                  },
                  child: Text(
                    'Xem tất cả',
                    style: TextStyle(
                      fontSize: DesignTypography.captionSize,
                      fontWeight: DesignTypography.medium,
                      color: DesignColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSpacing.md),
            Row(
              children: [
                for (var i = 0; i < top3.length; i++) ...[
                  if (i > 0) const SizedBox(width: DesignSpacing.md),
                  Expanded(
                    child: _TopSubmitterItem(
                      submission: top3[i],
                      rank: i + 1,
                      badgeColor: badgeColors[i],
                    ),
                  ),
                ],
                if (top3.length < 4) ...[
                  const SizedBox(width: DesignSpacing.md),
                  Expanded(child: _buildAddMoreButton()),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: DesignColors.dividerMedium,
              width: 1.5,
              style: BorderStyle.solid,
            ),
            color: DesignColors.moonLight,
          ),
          child: Icon(
            Icons.add,
            size: DesignIcons.smSize,
            color: DesignColors.textTertiary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Thêm',
          style: TextStyle(
            fontSize: DesignTypography.captionSize,
            fontWeight: DesignTypography.medium,
            color: DesignColors.textTertiary,
          ),
        ),
      ],
    );
  }

  // ==================== WARNING SECTION ====================
  Widget _buildWarningSection(
    BuildContext context,
    Map<String, dynamic> detail,
    List<Map<String, dynamic>> submissions,
  ) {
    final warnings = <Map<String, dynamic>>[];

    // HS chưa nộp bài
    final notSubmitted = submissions
        .where((s) => s['submitted_at'] == null)
        .toList();
    for (final s in notSubmitted) {
      final profile = s['profiles'] as Map<String, dynamic>?;
      warnings.add({
        'name': profile?['full_name'] ?? 'Không rõ tên',
        'avatar_url': profile?['avatar_url'],
        'subtitle': 'Chưa nộp bài',
        'action': 'Nhắc nhở',
        'actionColor': DesignColors.primary,
        'isReminder': true,
      });
    }

    // HS điểm thấp (< 5)
    final lowScore = submissions
        .where((s) => s['total_score'] != null && (s['total_score'] as num) < 5)
        .toList();
    for (final s in lowScore) {
      final profile = s['profiles'] as Map<String, dynamic>?;
      warnings.add({
        'name': profile?['full_name'] ?? 'Không rõ tên',
        'avatar_url': profile?['avatar_url'],
        'subtitle': 'Điểm thấp (${s['total_score']}) - Cần hỗ trợ',
        'action': 'Chi tiết',
        'actionColor': DesignColors.textSecondary,
        'isReminder': false,
      });
    }

    if (warnings.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.only(bottom: DesignSpacing.lg),
        child: Container(
          decoration: BoxDecoration(
            color: DesignColors.error.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            border: Border.all(
              color: DesignColors.error.withValues(alpha: 0.15),
            ),
          ),
          padding: const EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: DesignColors.error,
                    size: DesignIcons.smSize,
                  ),
                  const SizedBox(width: DesignSpacing.sm),
                  Text(
                    'Cần chú ý',
                    style: TextStyle(
                      fontSize: DesignTypography.bodySmallSize + 2,
                      fontWeight: DesignTypography.bold,
                      color: DesignColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignSpacing.md),
              ...warnings
                  .take(5)
                  .map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(bottom: DesignSpacing.sm),
                      child: _WarningItem(warning: w),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HELPERS ====================

  String _calculateAvgScore(List<Map<String, dynamic>> submissions) {
    final graded = submissions.where((s) => s['total_score'] != null).toList();
    if (graded.isEmpty) return '-';
    final sum = graded.fold<double>(
      0,
      (acc, s) => acc + (s['total_score'] as num).toDouble(),
    );
    return (sum / graded.length).toStringAsFixed(1);
  }

  String _formatDueDate(String? dueAt) {
    if (dueAt == null) return 'Không có hạn';
    try {
      final dt = DateTime.parse(dueAt).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}, '
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return dueAt;
    }
  }

  String? _formatCountdown(String? dueAt) {
    if (dueAt == null) return null;
    try {
      final dt = DateTime.parse(dueAt).toLocal();
      final diff = dt.difference(DateTime.now());
      if (diff.isNegative) return 'Đã hết hạn';
      if (diff.inDays > 0) {
        return 'Còn ${diff.inDays} ngày ${diff.inHours % 24} giờ';
      }
      if (diff.inHours > 0) {
        return 'Còn ${diff.inHours} giờ ${diff.inMinutes % 60} phút';
      }
      return 'Còn ${diff.inMinutes} phút';
    } catch (_) {
      return null;
    }
  }
}

// ==================== PRIVATE WIDGETS ====================

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.md,
      ),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        boxShadow: [DesignElevation.level1],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: DesignTypography.bold,
                  color: DesignColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: DesignTypography.headlineMediumSize,
                  fontWeight: DesignTypography.bold,
                  color: iconColor == DesignColors.textSecondary
                      ? DesignColors.textSecondary
                      : DesignColors.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBgColor,
            ),
            child: Icon(icon, size: DesignIcons.smSize, color: iconColor),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: DesignSpacing.md),
        decoration: BoxDecoration(
          color: DesignColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(
            color: DesignColors.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DesignColors.white,
                boxShadow: [DesignElevation.level1],
              ),
              child: Icon(
                icon,
                size: DesignIcons.mdSize,
                color: DesignColors.primary,
              ),
            ),
            const SizedBox(height: DesignSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: DesignTypography.captionSize,
                fontWeight: DesignTypography.medium,
                color: DesignColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final String value;
  final String? subtitle;
  final Color? subtitleColor;

  const _ConfigRow({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.value,
    this.subtitle,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignRadius.md),
            color: iconBgColor,
          ),
          child: Icon(icon, size: DesignIcons.mdSize, color: iconColor),
        ),
        const SizedBox(width: DesignSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: DesignTypography.captionSize,
                  fontWeight: DesignTypography.semiBold,
                  color: DesignColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: DesignTypography.bodyMediumSize + 2,
                  fontWeight: DesignTypography.bold,
                  color: DesignColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: DesignTypography.captionSize,
                    fontWeight: DesignTypography.medium,
                    color: subtitleColor ?? DesignColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TopSubmitterItem extends StatelessWidget {
  final Map<String, dynamic> submission;
  final int rank;
  final Color badgeColor;

  const _TopSubmitterItem({
    required this.submission,
    required this.rank,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final profile = submission['profiles'] as Map<String, dynamic>?;
    final name = profile?['full_name'] as String? ?? '?';
    final avatarUrl = profile?['avatar_url'] as String?;
    final score = submission['total_score'];
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: DesignColors.moonMedium,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? Text(
                      initial,
                      style: TextStyle(
                        fontSize: DesignTypography.titleLargeSize,
                        fontWeight: DesignTypography.bold,
                        color: DesignColors.primary,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeColor,
                  border: Border.all(color: DesignColors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: DesignTypography.bold,
                      color: DesignColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: TextStyle(
            fontSize: DesignTypography.captionSize,
            fontWeight: DesignTypography.medium,
            color: DesignColors.textSecondary,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
        if (score != null) ...[
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: DesignColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.full),
            ),
            child: Text(
              '$score',
              style: TextStyle(
                fontSize: 10,
                fontWeight: DesignTypography.bold,
                color: DesignColors.success,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _WarningItem extends StatelessWidget {
  final Map<String, dynamic> warning;

  const _WarningItem({required this.warning});

  @override
  Widget build(BuildContext context) {
    final name = warning['name'] as String;
    final subtitle = warning['subtitle'] as String;
    final action = warning['action'] as String;
    final actionColor = warning['actionColor'] as Color;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(DesignSpacing.sm + 2),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        boxShadow: [DesignElevation.level1],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: DesignColors.moonMedium,
            child: Text(
              initial,
              style: TextStyle(
                fontSize: DesignTypography.captionSize,
                fontWeight: DesignTypography.bold,
                color: DesignColors.primary,
              ),
            ),
          ),
          const SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: DesignTypography.captionSize,
                    fontWeight: DesignTypography.bold,
                    color: DesignColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: DesignColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Handle action
            },
            style: TextButton.styleFrom(
              backgroundColor: actionColor.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              action,
              style: TextStyle(
                fontSize: DesignTypography.captionSize,
                fontWeight: DesignTypography.semiBold,
                color: actionColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
