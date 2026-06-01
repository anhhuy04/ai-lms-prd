import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/data/datasources/assignment_datasource.dart';
import 'package:ai_mls/presentation/providers/teacher_assignment_providers.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:ai_mls/presentation/providers/teacher_submission_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/submission/submission_filter_chips.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/submission/submission_list_item.dart';
import 'package:flutter/material.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Teacher Submission List Screen - ATC Dashboard
/// Hiển thị danh sách submissions với "Air Traffic Control" model
class TeacherSubmissionListScreen extends ConsumerStatefulWidget {
  final String distributionId;
  final String? classId;
  final String assignmentTitle;
  final String? className;

  const TeacherSubmissionListScreen({
    super.key,
    required this.distributionId,
    this.classId,
    this.assignmentTitle = '',
    this.className,
  });

  @override
  ConsumerState<TeacherSubmissionListScreen> createState() =>
      _TeacherSubmissionListScreenState();
}

class _TeacherSubmissionListScreenState
    extends ConsumerState<TeacherSubmissionListScreen> {
  SubmissionFilter _currentFilter = SubmissionFilter.all;

  @override
  Widget build(BuildContext context) {
    final submissionState = ref.watch(teacherSubmissionListProvider(
      distributionId: widget.distributionId,
      filter: _currentFilter,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bài nộp'),
        actions: [
          // Track 2 — Chấm theo câu (cùng 1 câu cho tất cả HS)
          IconButton(
            key: const ValueKey('batch_grade_by_question_action'),
            icon: const Icon(Icons.grading),
            tooltip: 'Chấm theo câu',
            onPressed: () {
              context.pushNamed(
                AppRoute.teacherBatchGradeByQuestion,
                pathParameters: {'distributionId': widget.distributionId},
                extra: {'assignmentTitle': widget.assignmentTitle},
              );
            },
          ),
          // Nút xuất bản điểm - Stage Curtain
          IconButton(
            icon: const Icon(Icons.publish),
            tooltip: 'Xuất bản điểm',
            onPressed: () => _showPublishDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Bảng điểm cuối (aggregated scores — chỉ hiện khi có dữ liệu)
          _AggregatedScoreSection(distributionId: widget.distributionId),
          // Filter chips
          SubmissionFilterChips(
            currentFilter: _currentFilter,
            onFilterChanged: (filter) {
              setState(() => _currentFilter = filter);
            },
          ),

          // Submission list
          Expanded(
            child: submissionState.when(
              data: (state) {
                if (state.submissions.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(teacherSubmissionListProvider(
                      distributionId: widget.distributionId,
                      filter: _currentFilter,
                    ));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(DesignSpacing.md),
                    itemCount: state.submissions.length,
                    itemBuilder: (context, index) {
                      final submission = state.submissions[index];
                      return SubmissionListItem(
                        submission: submission,
                        onTap: () {
                          context.pushNamed(
                            'teacher-grade-submission',
                            pathParameters: {
                              'submissionId': submission.submissionId,
                            },
                            extra: {
                              'distributionId': widget.distributionId,
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const ShimmerListTileLoading(),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: DesignColors.error,
                    ),
                    const SizedBox(height: DesignSpacing.md),
                    Text(
                      'Lỗi tải danh sách',
                      style: DesignTypography.bodyMedium,
                    ),
                    const SizedBox(height: DesignSpacing.sm),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(teacherSubmissionListProvider(
                          distributionId: widget.distributionId,
                          filter: _currentFilter,
                        ));
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Nút xuất bản điểm toàn lớp
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPublishDialog(context),
        icon: const Icon(Icons.publish),
        label: const Text('Xuất bản điểm'),
        backgroundColor: DesignColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: DesignColors.textTertiary,
          ),
          const SizedBox(height: DesignSpacing.md),
          Text(
            'Chưa có bài nộp nào',
            style: DesignTypography.titleMedium.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
          const SizedBox(height: DesignSpacing.sm),
          Text(
            'Học sinh chưa nộp bài',
            style: DesignTypography.bodyMedium.copyWith(
              color: DesignColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showPublishDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xuất bản điểm'),
        content: const Text(
          'Sau khi xuất bản, học sinh sẽ nhìn thấy điểm số. '
          'Bạn có chắc chắn muốn xuất bản?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(submissionGradingNotifierProvider.notifier)
                  .publishAllGrades(widget.distributionId);

              if (context.mounted) {
                AppToast.info(context, 'Đã xuất bản điểm thành công');
              }
            },
            child: const Text('Xuất bản'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bảng điểm cuối — hiển thị aggregated score + expand để xem từng attempt
// ---------------------------------------------------------------------------

class _AggregatedScoreSection extends ConsumerStatefulWidget {
  final String distributionId;
  const _AggregatedScoreSection({required this.distributionId});

  @override
  ConsumerState<_AggregatedScoreSection> createState() =>
      _AggregatedScoreSectionState();
}

class _AggregatedScoreSectionState
    extends ConsumerState<_AggregatedScoreSection> {
  String? _expandedStudentId;
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final aggregatedAsync =
        ref.watch(aggregatedScoresProvider(widget.distributionId));
    // Watch submission list để lấy tên học sinh (filter=all để không bỏ sót)
    final submissionsAsync = ref.watch(teacherSubmissionListProvider(
      distributionId: widget.distributionId,
      filter: SubmissionFilter.all,
    ));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Build name map từ submissions — dùng kể cả khi submissionsAsync đang load
    final Map<String, String> nameMap = submissionsAsync.valueOrNull?.submissions
            .fold<Map<String, String>>({}, (map, item) {
          map[item.studentId] = item.studentName;
          return map;
        }) ??
        {};

    return aggregatedAsync.when(
      data: (scores) {
        if (scores.isEmpty) return const SizedBox.shrink();
        // Chỉ hiện khi có ít nhất 1 student làm > 1 lần
        final hasMultiple = scores.any((s) => s.attemptsCount > 1);
        if (!hasMultiple) return const SizedBox.shrink();
        return _buildCard(scores, isDark, nameMap);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCard(
    List<AggregatedScore> scores,
    bool isDark,
    Map<String, String> nameMap,
  ) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.grey.shade200;
    final tMain = isDark ? Colors.white : DesignColors.textPrimary;
    final tSec = isDark ? Colors.white54 : DesignColors.textSecondary;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            onTap: () => setState(() => _collapsed = !_collapsed),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.calculate_outlined,
                      color: DesignColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Điểm cuối',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: tMain,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: DesignColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${scores.where((s) => s.attemptsCount > 1).length} HS nhiều lần',
                      style: TextStyle(
                        fontSize: 11,
                        color: DesignColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _collapsed ? Icons.expand_more : Icons.expand_less,
                    color: tSec,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (!_collapsed) ...[
            Divider(height: 1, color: borderColor),
            // Student rows — chỉ show học sinh làm > 1 lần
            ...scores
                .where((s) => s.attemptsCount > 1)
                .map((score) {
              final isExpanded = _expandedStudentId == score.studentId;
              return _StudentScoreRow(
                score: score,
                distributionId: widget.distributionId,
                studentName: nameMap[score.studentId],
                isExpanded: isExpanded,
                isDark: isDark,
                tMain: tMain,
                tSec: tSec,
                onToggle: () {
                  setState(() {
                    _expandedStudentId =
                        isExpanded ? null : score.studentId;
                  });
                },
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _StudentScoreRow extends ConsumerWidget {
  final AggregatedScore score;
  final String distributionId;
  final String? studentName;
  final bool isExpanded;
  final bool isDark;
  final Color tMain;
  final Color tSec;
  final VoidCallback onToggle;

  const _StudentScoreRow({
    required this.score,
    required this.distributionId,
    this.studentName,
    required this.isExpanded,
    required this.isDark,
    required this.tMain,
    required this.tSec,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderColor = isDark ? Colors.white10 : Colors.grey.shade100;
    final displayName = studentName ?? 'Học sinh';
    final avatarChar = displayName[0].toUpperCase();
    final scoreText = score.finalScore != null
        ? score.finalScore!.toStringAsFixed(1)
        : '--';

    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Avatar placeholder
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      DesignColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    avatarChar,
                    style: TextStyle(
                      color: DesignColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    displayName,
                    style: TextStyle(fontSize: 13, color: tMain),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Attempts badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${score.attemptsCount} lần',
                    style: TextStyle(fontSize: 11, color: tSec),
                  ),
                ),
                const SizedBox(width: 8),
                // Score
                Text(
                  '$scoreText đ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: DesignColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: tSec,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          Divider(height: 1, color: borderColor),
          _StudentAttemptsDetail(
            distributionId: distributionId,
            studentId: score.studentId,
            isDark: isDark,
            tSec: tSec,
          ),
        ],
        Divider(height: 1, color: borderColor),
      ],
    );
  }
}

class _StudentAttemptsDetail extends ConsumerWidget {
  final String distributionId;
  final String studentId;
  final bool isDark;
  final Color tSec;

  const _StudentAttemptsDetail({
    required this.distributionId,
    required this.studentId,
    required this.isDark,
    required this.tSec,
  });

  String _formatDt(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attemptsAsync =
        ref.watch(studentAttemptsProvider((distributionId, studentId)));

    return attemptsAsync.when(
      data: (attempts) {
        if (attempts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Không có dữ liệu',
                style: TextStyle(fontSize: 12, color: tSec)),
          );
        }
        return Column(
          children: attempts.map((a) {
            final isVoided = a.isVoided;
            final scoreText =
                a.totalScore != null ? a.totalScore!.toStringAsFixed(1) : '--';
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: isVoided
                        ? Colors.grey.shade300
                        : DesignColors.primary.withValues(alpha: 0.12),
                    child: Text(
                      '${a.attempt}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isVoided ? Colors.grey : DesignColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lần ${a.attempt}${isVoided ? ' (đã hủy)' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isVoided ? tSec : null,
                            decoration: isVoided
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (a.submittedAt != null)
                          Text(
                            'Nộp: ${_formatDt(a.submittedAt!)}${a.isLate ? ' · muộn' : ''}',
                            style: TextStyle(fontSize: 11, color: tSec),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '$scoreText đ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isVoided
                          ? tSec
                          : DesignColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(12),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Lỗi tải lịch sử: $e',
          style: const TextStyle(fontSize: 12, color: DesignColors.error),
        ),
      ),
    );
  }
}
