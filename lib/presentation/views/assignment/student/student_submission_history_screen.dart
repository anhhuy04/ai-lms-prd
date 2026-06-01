import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/navigation_helper.dart';
import 'package:ai_mls/presentation/providers/student_assignment_providers.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Bộ lọc lịch sử theo trạng thái bài nộp.
enum _HistoryFilter { all, graded, pending, doing }

/// Kiểu sắp xếp lịch sử.
enum _HistorySort { newest, oldest, scoreHigh, scoreLow, title }

/// Màn hình lịch sử nộp bài của học sinh
class StudentSubmissionHistoryScreen extends ConsumerStatefulWidget {
  const StudentSubmissionHistoryScreen({super.key});

  @override
  ConsumerState<StudentSubmissionHistoryScreen> createState() =>
      _StudentSubmissionHistoryScreenState();
}

class _StudentSubmissionHistoryScreenState
    extends ConsumerState<StudentSubmissionHistoryScreen> {
  _HistoryFilter _filter = _HistoryFilter.all;
  _HistorySort _sort = _HistorySort.newest;

  static const Map<_HistoryFilter, String> _filterLabels = {
    _HistoryFilter.all: 'Tất cả',
    _HistoryFilter.graded: 'Đã chấm',
    _HistoryFilter.pending: 'Đang chờ chấm',
    _HistoryFilter.doing: 'Đang làm',
  };

  static const Map<_HistorySort, String> _sortLabels = {
    _HistorySort.newest: 'Mới nhất',
    _HistorySort.oldest: 'Cũ nhất',
    _HistorySort.scoreHigh: 'Điểm cao nhất',
    _HistorySort.scoreLow: 'Điểm thấp nhất',
    _HistorySort.title: 'Tên A–Z',
  };

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(studentSubmissionHistoryProvider);

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        backgroundColor: DesignColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: DesignIcons.smSize),
          onPressed: () => NavigationHelper.goBack(context),
        ),
        title: Text(
          'Lịch sử nộp bài',
          style: TextStyle(
            fontSize: DesignTypography.bodyMediumSize,
            fontWeight: DesignTypography.bold,
            color: DesignColors.textPrimary,
          ),
        ),
      ),
      body: historyAsync.when(
        loading: () => const ShimmerLoading(),
        error: (error, _) => _buildErrorState(context, error),
        data: (history) => _buildContent(context, history),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: DesignColors.error),
            const SizedBox(height: DesignSpacing.md),
            Text(
              'Lỗi khi tải lịch sử',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: DesignSpacing.sm),
            Text(
              error.toString(),
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, List<Map<String, dynamic>> history) {
    final processed = _applyFilterSort(history);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildControls(context, processed.length),
        Expanded(
          child: processed.isEmpty
              ? _buildEmptyState()
              : _buildGrid(context, processed),
        ),
      ],
    );
  }

  /// Lọc theo trạng thái + sắp xếp (client-side trên list đã tải).
  List<Map<String, dynamic>> _applyFilterSort(
      List<Map<String, dynamic>> history) {
    bool matches(Map<String, dynamic> s) {
      final st = s['status'] as String? ?? '';
      switch (_filter) {
        case _HistoryFilter.all:
          return true;
        case _HistoryFilter.graded:
          return st == 'graded';
        case _HistoryFilter.pending:
          return st == 'submitted' ||
              st == 'ai_processing' ||
              st == 'pending_review';
        case _HistoryFilter.doing:
          return st == 'in_progress' || st == 'draft';
      }
    }

    final list = history.where(matches).toList();

    DateTime? dateOf(Map<String, dynamic> s) =>
        DateTime.tryParse(s['submitted_at'] as String? ?? '');
    double? scoreOf(Map<String, dynamic> s) =>
        (s['total_score'] as num?)?.toDouble();
    String titleOf(Map<String, dynamic> s) {
      final dist = s['assignment_distributions'] as Map<String, dynamic>?;
      final a = dist?['assignments'] as Map<String, dynamic>?;
      return (a?['title'] as String? ?? '').toLowerCase();
    }

    int cmpDate(Map<String, dynamic> a, Map<String, dynamic> b, bool asc) {
      final da = dateOf(a), db = dateOf(b);
      if (da == null && db == null) return 0;
      if (da == null) return 1; // null (chưa nộp) xuống cuối
      if (db == null) return -1;
      return asc ? da.compareTo(db) : db.compareTo(da);
    }

    int cmpScore(Map<String, dynamic> a, Map<String, dynamic> b, bool asc) {
      final sa = scoreOf(a), sb = scoreOf(b);
      if (sa == null && sb == null) return 0;
      if (sa == null) return 1; // chưa có điểm xuống cuối
      if (sb == null) return -1;
      return asc ? sa.compareTo(sb) : sb.compareTo(sa);
    }

    switch (_sort) {
      case _HistorySort.newest:
        list.sort((a, b) => cmpDate(a, b, false));
        break;
      case _HistorySort.oldest:
        list.sort((a, b) => cmpDate(a, b, true));
        break;
      case _HistorySort.scoreHigh:
        list.sort((a, b) => cmpScore(a, b, false));
        break;
      case _HistorySort.scoreLow:
        list.sort((a, b) => cmpScore(a, b, true));
        break;
      case _HistorySort.title:
        list.sort((a, b) => titleOf(a).compareTo(titleOf(b)));
        break;
    }
    return list;
  }

  /// Thanh điều khiển: chip lọc trạng thái + nút đổi kiểu sắp xếp (hiển thị rõ
  /// đang sắp theo kiểu nào) + số bài đang hiển thị.
  Widget _buildControls(BuildContext context, int shownCount) {
    return Container(
      color: DesignColors.white,
      padding: const EdgeInsets.fromLTRB(DesignSpacing.md, DesignSpacing.sm,
          DesignSpacing.md, DesignSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final f in _HistoryFilter.values) ...[
                  ChoiceChip(
                    label: Text(_filterLabels[f]!),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                    showCheckmark: false,
                    backgroundColor: DesignColors.moonLight,
                    selectedColor: DesignColors.primary.withValues(alpha: 0.12),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _filter == f
                          ? DesignColors.primary
                          : DesignColors.textSecondary,
                    ),
                    side: BorderSide(
                      color: _filter == f
                          ? DesignColors.primary
                          : DesignColors.dividerLight,
                    ),
                  ),
                  const SizedBox(width: DesignSpacing.sm),
                ],
              ],
            ),
          ),
          const SizedBox(height: DesignSpacing.sm),
          Row(
            children: [
              const Icon(Icons.sort,
                  size: 16, color: DesignColors.textSecondary),
              const SizedBox(width: 4),
              const Text('Sắp xếp:',
                  style: TextStyle(
                      fontSize: 13, color: DesignColors.textSecondary)),
              const SizedBox(width: 4),
              PopupMenuButton<_HistorySort>(
                initialValue: _sort,
                tooltip: 'Đổi kiểu sắp xếp',
                onSelected: (v) => setState(() => _sort = v),
                itemBuilder: (context) => [
                  for (final s in _HistorySort.values)
                    PopupMenuItem(
                      value: s,
                      child: Row(
                        children: [
                          Icon(
                            _sort == s
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 18,
                            color: _sort == s
                                ? DesignColors.primary
                                : DesignColors.textTertiary,
                          ),
                          const SizedBox(width: DesignSpacing.sm),
                          Text(_sortLabels[s]!),
                        ],
                      ),
                    ),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _sortLabels[_sort]!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: DesignColors.primary,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down,
                        size: 20, color: DesignColors.primary),
                  ],
                ),
              ),
              const Spacer(),
              Text('$shownCount bài',
                  style: const TextStyle(
                      fontSize: 12, color: DesignColors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }

  /// Lưới responsive: lấp đầy bề rộng bằng nhiều cột trên màn rộng (PC/web) thay
  /// vì 1 cột hẹp để trống 2 biên. Dùng Wrap (không GridView+childAspectRatio) vì
  /// card cao-thấp khác nhau — Wrap để mỗi card tự co, không bị cắt.
  Widget _buildGrid(BuildContext context, List<Map<String, dynamic>> history) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSpacing.md),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          const spacing = DesignSpacing.md;
          const targetCardWidth = 340.0; // bề rộng card mong muốn
          final columns = (w / targetCardWidth).floor().clamp(1, 4);
          final cardWidth =
              columns == 1 ? w : (w - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final submission in history)
                SizedBox(
                  width: cardWidth,
                  child: _buildSubmissionCard(context, submission),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: DesignSpacing.md),
            Text(
              'Chưa có lịch sử nộp bài',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: DesignSpacing.sm),
            Text(
              'Bạn chưa nộp bài tập nào',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(BuildContext context, Map<String, dynamic> submission) {
    final distribution = submission['assignment_distributions'] as Map<String, dynamic>?;
    final assignment = distribution?['assignments'] as Map<String, dynamic>?;
    final status = submission['status'] as String? ?? 'draft';
    final score = (submission['total_score'] as num?)?.toDouble();
    final maxScore = (assignment?['total_points'] as num?)?.toDouble();
    final submittedAt = submission['submitted_at'] as String?;
    final attempt = submission['attempt'] as int? ?? 1;
    final distributionId = (submission['assignment_distribution_id'] as String?) ??
        (distribution?['id'] as String?);
    final sessionId = submission['id'] as String?;

    final title = assignment?['title'] as String? ?? 'Bài tập';

    final submittedDateTime =
        submittedAt != null ? DateTime.tryParse(submittedAt) : null;

    final showScore = status == 'graded' && score != null;
    final canOpen = distributionId != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canOpen
              ? () => _openDetail(context, status, distributionId, sessionId)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(DesignSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: icon + tiêu đề (+ lần làm) + badge trạng thái
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(DesignSpacing.sm),
                      decoration: BoxDecoration(
                        color: DesignColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DesignRadius.sm),
                      ),
                      child: const Icon(Icons.assignment,
                          color: DesignColors.primary, size: 24),
                    ),
                    const SizedBox(width: DesignSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: DesignColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (attempt > 1) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Lần làm thứ $attempt',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: DesignSpacing.sm),
                    _buildStatusBadge(status),
                  ],
                ),

                const SizedBox(height: DesignSpacing.md),
                const Divider(height: 1),
                const SizedBox(height: DesignSpacing.md),

                _buildInfoRow(
                  icon: Icons.access_time,
                  label: 'Nộp lúc',
                  value: submittedDateTime != null
                      ? _formatDateTime(submittedDateTime)
                      : 'Chưa nộp',
                ),

                const SizedBox(height: DesignSpacing.sm),
                // Dòng điểm LUÔN hiển thị → mọi card cùng số dòng, cao đều nhau.
                Row(
                  children: [
                    Icon(Icons.star,
                        size: 16,
                        color: showScore
                            ? _getScoreColor(score, maxScore)
                            : Colors.grey[400]),
                    const SizedBox(width: DesignSpacing.sm),
                    Text('Điểm',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    const Spacer(),
                    if (showScore)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: DesignSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getScoreColor(score, maxScore)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(DesignRadius.sm),
                        ),
                        child: Text(
                          maxScore != null
                              ? '${_fmtNum(score)}/${_fmtNum(maxScore)}'
                              : _fmtNum(score),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(score, maxScore),
                          ),
                        ),
                      )
                    else
                      Text('Chưa chấm',
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ],
                ),

                // Affordance "Xem chi tiết" → nhấn cả thẻ để mở
                if (canOpen) ...[
                  const SizedBox(height: DesignSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        status == 'in_progress' ? 'Tiếp tục làm' : 'Xem chi tiết',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: DesignColors.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.chevron_right,
                          size: 18, color: DesignColors.primary),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mở chi tiết: bài đã nộp/đang chấm/chờ duyệt/đã chấm → màn xem lại bài làm
  /// (review) theo đúng lần nộp (sessionId); bài đang làm dở → màn chi tiết để
  /// tiếp tục làm.
  void _openDetail(
    BuildContext context,
    String status,
    String distributionId,
    String? sessionId,
  ) {
    const reviewable = {'submitted', 'ai_processing', 'pending_review', 'graded'};
    if (reviewable.contains(status)) {
      context.pushNamed(
        AppRoute.studentSubmissionReview,
        pathParameters: {'distributionId': distributionId},
        extra: sessionId != null ? {'sessionId': sessionId} : null,
      );
    } else {
      context.pushNamed(
        AppRoute.studentAssignmentDetail,
        pathParameters: {'distributionId': distributionId},
      );
    }
  }

  String _fmtNum(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'submitted':
        color = DesignColors.warning;
        label = 'Chờ giáo viên chấm';
        icon = Icons.hourglass_empty;
        break;
      case 'ai_processing':
        color = DesignColors.primary;
        label = 'Đang chấm tự động...';
        icon = Icons.auto_awesome;
        break;
      case 'pending_review':
        color = DesignColors.warning;
        label = 'Chờ giáo viên xét duyệt';
        icon = Icons.rate_review_outlined;
        break;
      case 'graded':
        color = DesignColors.success;
        label = 'Đã chấm';
        icon = Icons.check_circle;
        break;
      case 'draft':
        color = DesignColors.warning;
        label = 'Nháp';
        icon = Icons.edit_note;
        break;
      default:
        // D-16: graceful degradation — never show raw unknown status string
        color = DesignColors.textTertiary;
        label = 'Đang xử lý hệ thống...';
        icon = Icons.sync;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: DesignSpacing.sm),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: DesignColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score, double? maxScore) {
    // Màu theo TỶ LỆ (không giả định thang /10 — bài 2/2 phải là xanh, không phải đỏ).
    final ratio = (maxScore != null && maxScore > 0) ? score / maxScore : score / 10;
    if (ratio >= 0.8) return DesignColors.success;
    if (ratio >= 0.5) return DesignColors.warning;
    return DesignColors.error;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
