import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_date_formatter.dart';
import 'package:flutter/material.dart';

/// Enum định nghĩa chế độ xem danh sách bài tập
enum AssignmentViewMode {
  /// Chế độ giáo viên: hiển thị thống kê và trạng thái chấm bài
  teacher,

  /// Chế độ học sinh: hiển thị trạng thái cá nhân và điểm số
  student,
}

/// Card hiển thị một bài tập trong class detail.
///
/// Đồng bộ style với [AssignmentCard] (white bg, grey border, large radius,
/// shadow, full-card InkWell, metadata row với icons).
///
/// Field mapping từ Supabase [getDistributedAssignmentsByClass]:
///   - `title`                  → tên bài tập
///   - `total_points`           → điểm tối đa
///   - `description`            → mô tả (nullable)
///   - `distribution_type`      → 'class' | 'group' | 'individual'
///   - `distribution_due_at`    → deadline ISO string (nullable)
///   - `submission_count`       → số bài đã nộp (datasource inject, nullable)
///   - `graded_count`           → số bài đã chấm (datasource inject, nullable)
///   - `total_students`         → sĩ số (datasource inject, nullable)
class ClassDetailAssignmentListItem extends StatelessWidget {
  final Map<String, dynamic> assignment;
  final AssignmentViewMode viewMode;
  final VoidCallback? onTap;

  const ClassDetailAssignmentListItem({
    super.key,
    required this.assignment,
    required this.viewMode,
    this.onTap,
  });

  // ── Getters ──────────────────────────────────────────────────────────────

  String get _title => (assignment['title'] as String?) ?? 'Không có tiêu đề';

  String? get _description => assignment['description'] as String?;

  double get _totalPoints =>
      (assignment['total_points'] as num?)?.toDouble() ?? 0;

  String get _distributionType =>
      (assignment['distribution_type'] as String?) ?? 'class';

  DateTime? get _dueAt {
    final raw = assignment['distribution_due_at'] as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  bool get _isExpired {
    final due = _dueAt;
    if (due == null) return false;
    return due.isBefore(DateTime.now());
  }

  int? get _submissionCount => assignment['submission_count'] as int?;
  int? get _gradedCount => assignment['graded_count'] as int?;
  int? get _totalStudents => assignment['total_students'] as int?;

  // ── Computed labels ───────────────────────────────────────────────────────

  String get _distTypeLabel {
    switch (_distributionType) {
      case 'group':
        return 'Theo nhóm';
      case 'individual':
        return 'Cá nhân';
      default:
        return 'Cả lớp';
    }
  }

  // Icon is no longer used since we use text on left and custom assignment icon
  // in the header. Removed _distTypeIcon.

  IconData get _distTypeIcon {
    switch (_distributionType) {
      case 'group':
        return Icons.group_outlined;
      case 'individual':
        return Icons.person_outline;
      default:
        return Icons.groups_outlined;
    }
  }

  /// Badge label + màu theo trạng thái
  ({String label, Color bg, Color border, Color text}) get _badgeStyle {
    if (_isExpired) {
      return (
        label: 'Đã đóng',
        bg: Colors.green.withValues(alpha: 0.08),
        border: Colors.green.withValues(alpha: 0.4),
        text: Colors.green[700]!,
      );
    }
    if (_dueAt == null) {
      return (
        label: 'Không hạn',
        bg: Colors.orange.withValues(alpha: 0.08),
        border: Colors.orange.withValues(alpha: 0.4),
        text: Colors.orange[700]!,
      );
    }
    return (
      label: 'Đang mở',
      bg: Colors.blue.withValues(alpha: 0.08),
      border: Colors.blue.withValues(alpha: 0.4),
      text: Colors.blue[700]!,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(DesignRadius.lg * 1.5);

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: borderRadius,
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: title ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon bên trái
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DesignColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(DesignRadius.sm),
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      color: DesignColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: DesignSpacing.md),
                  Expanded(
                    child: Text(
                      _title,
                      style: DesignTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : DesignColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: DesignSpacing.sm),
                  Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
                ],
              ),

              // ── Description (optional) ──
              if (_description != null && _description!.isNotEmpty) ...[
                const SizedBox(height: DesignSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSpacing.sm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(DesignRadius.xs),
                    border: Border(
                      left: BorderSide(
                        color: DesignColors.primary.withValues(alpha: 0.6),
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    _description!,
                    style: DesignTypography.bodySmall.copyWith(
                      color: isDark ? Colors.grey[300] : Colors.grey[800],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              const SizedBox(height: DesignSpacing.sm),

              // ── Metadata row ──
              _buildMetadataRow(isDark),

              const SizedBox(height: DesignSpacing.sm),

              // Divider phân định Header và Footer
              Divider(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                thickness: 1,
              ),

              const SizedBox(height: DesignSpacing.xs),

              // ── Footer: submission stats (teacher) hoặc action (student) ──
              if (viewMode == AssignmentViewMode.teacher)
                _buildTeacherFooter(isDark)
              else
                _buildStudentFooter(),
            ],
          ),
        ),
      ),
    );
  }

  /// Row metadata: hạn nộp & điểm
  Widget _buildMetadataRow(bool isDark) {
    final metaColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Row(
      children: [
        if (_dueAt != null) ...[
          Flexible(
            child: Text(
              'Hạn: ${AssignmentDateFormatter.formatDueDate(_dueAt!)} (${_dueAt!.hour.toString().padLeft(2, '0')}:${_dueAt!.minute.toString().padLeft(2, '0')} - ${_dueAt!.day.toString().padLeft(2, '0')}/${_dueAt!.month.toString().padLeft(2, '0')}/${_dueAt!.year})',
              style: DesignTypography.bodySmall.copyWith(color: metaColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ] else ...[
          Flexible(
            child: Text(
              'Không có hạn nộp',
              style: DesignTypography.bodySmall.copyWith(color: metaColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],

        if (_totalPoints > 0) ...[
          const SizedBox(width: DesignSpacing.md),
          Text(
            '• ${_totalPoints.toStringAsFixed(_totalPoints % 1 == 0 ? 0 : 1)} điểm',
            style: DesignTypography.bodySmall.copyWith(color: metaColor),
          ),
        ],
      ],
    );
  }

  /// Teacher footer: Số học sinh đã mộp / Chấm bài & Badge Trạng thái
  Widget _buildTeacherFooter(bool isDark) {
    final metaColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final badge = _badgeStyle;

    return Row(
      children: [
        // Bên trái: Thống kê nộp bài & phân phối
        Icon(_distTypeIcon, size: 16, color: metaColor),
        const SizedBox(width: 4),
        if (_submissionCount == null) ...[
          Text(
            _totalStudents != null
                ? '$_distTypeLabel - $_totalStudents học sinh'
                : _distTypeLabel,
            style: DesignTypography.bodySmall.copyWith(color: metaColor),
          ),
        ] else ...[
          Text(
            _totalStudents != null
                ? '$_distTypeLabel - $_submissionCount/$_totalStudents nộp'
                : '$_distTypeLabel - $_submissionCount đã nộp',
            style: DesignTypography.bodySmall.copyWith(
              color: metaColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_gradedCount != null && _gradedCount! > 0) ...[
            Text(
              ' • $_gradedCount đã chấm',
              style: DesignTypography.bodySmall.copyWith(color: metaColor),
            ),
          ],
        ],

        const Spacer(),

        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: badge.bg,
            borderRadius: BorderRadius.circular(DesignRadius.full),
            border: Border.all(color: badge.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badge.label == 'Đã đóng') ...[
                Icon(Icons.check_circle, size: 14, color: badge.text),
                const SizedBox(width: 4),
              ],
              Text(
                badge.label,
                style: DesignTypography.caption.copyWith(
                  color: badge.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Student: action button + status badge
  Widget _buildStudentFooter() {
    final studentStatus =
        (assignment['student_status'] as String?) ?? 'not_submitted';
    final score = assignment['score'];

    final Map<String, dynamic> btnConfig = switch (studentStatus) {
      'submitted' => {
        'label': 'Xem bài đã nộp',
        'icon': Icons.visibility_outlined,
        'bg': Colors.grey[200],
        'fg': Colors.grey[700],
      },
      'graded' => {
        'label': 'Xem điểm',
        'icon': Icons.star_outline,
        'bg': Colors.green[100],
        'fg': Colors.green[800],
      },
      _ => {
        'label': 'Làm bài ngay',
        'icon': Icons.edit_outlined,
        'bg': DesignColors.primary,
        'fg': Colors.white,
      },
    };

    final ({String label, Color bg, Color border, Color text}) statusBadge =
        switch (studentStatus) {
          'submitted' => (
            label: score != null ? 'Đã nộp • $score đ' : 'Đã nộp',
            bg: Colors.orange.withValues(alpha: 0.08),
            border: Colors.orange.withValues(alpha: 0.4),
            text: Colors.orange[700]!,
          ),
          'graded' => (
            label: score != null ? '$score điểm' : 'Đã chấm',
            bg: Colors.green.withValues(alpha: 0.08),
            border: Colors.green.withValues(alpha: 0.4),
            text: Colors.green[700]!,
          ),
          _ => (
            label: 'Chưa nộp',
            bg: Colors.red.withValues(alpha: 0.08),
            border: Colors.red.withValues(alpha: 0.4),
            text: Colors.red[700]!,
          ),
        };

    return Row(
      children: [
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusBadge.bg,
            borderRadius: BorderRadius.circular(DesignRadius.sm),
            border: Border.all(color: statusBadge.border),
          ),
          child: Text(
            statusBadge.label,
            style: DesignTypography.caption.copyWith(
              color: statusBadge.text,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        // Action button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: btnConfig['bg'] as Color?,
            foregroundColor: btnConfig['fg'] as Color?,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: onTap,
          icon: Icon(btnConfig['icon'] as IconData, size: 15),
          label: Text(
            btnConfig['label'] as String,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
