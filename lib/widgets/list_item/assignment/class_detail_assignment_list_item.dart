import 'package:ai_mls/core/constants/design_tokens.dart';
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

  String? get _groupName => assignment['distribution_group_name'] as String?;

  List<dynamic>? get _studentIds =>
      assignment['distribution_student_ids'] as List<dynamic>?;

  int? get _timeLimitMinutes =>
      assignment['distribution_time_limit_minutes'] as int?;

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
  int? get _pendingActionCount => assignment['pending_action_count'] as int?;

  // ── Computed labels ───────────────────────────────────────────────────────

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

  /// Label rõ ràng "giao cho ai": tên nhóm / số HS / cả lớp
  String get _recipientLabel {
    switch (_distributionType) {
      case 'group':
        return _groupName != null ? 'Nhóm: $_groupName' : 'Theo nhóm';
      case 'individual':
        final count = _studentIds?.length ?? 0;
        return count > 0 ? '$count học sinh' : 'Cá nhân';
      default:
        return 'Cả lớp';
    }
  }

  Color get _recipientColor {
    switch (_distributionType) {
      case 'group':
        return const Color(0xFFE65100); // orange
      case 'individual':
        return const Color(0xFF00695C); // teal
      default:
        return const Color(0xFF1565C0); // blue
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

              const SizedBox(height: DesignSpacing.xs),

              // ── Recipient chip: giao cho ai ──
              _buildRecipientChip(),

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

  /// Chip hiển thị "giao cho ai": Cả lớp / Nhóm: X / N học sinh
  Widget _buildRecipientChip() {
    final color = _recipientColor;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignRadius.full),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_distTypeIcon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                _recipientLabel,
                style: DesignTypography.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Row metadata: hạn nộp (trái) + thời gian làm bài (phải)
  Widget _buildMetadataRow(bool isDark) {
    final metaColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final timeLimitText = _timeLimitMinutes != null
        ? (_timeLimitMinutes! >= 60
            ? '${_timeLimitMinutes! ~/ 60}g${_timeLimitMinutes! % 60 > 0 ? ' ${_timeLimitMinutes! % 60}p' : ''}'
            : '$_timeLimitMinutes phút')
        : 'Không giới hạn';

    return Row(
      children: [
        // Hạn nộp — căn trái
        Icon(
          _isExpired ? Icons.event_busy_outlined : Icons.access_time_outlined,
          size: 13,
          color: _isExpired ? Colors.red[400] : metaColor,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            _dueAt != null
                ? 'Hạn: ${_dueAt!.day.toString().padLeft(2, '0')}/${_dueAt!.month.toString().padLeft(2, '0')}/${_dueAt!.year} ${_dueAt!.hour.toString().padLeft(2, '0')}:${_dueAt!.minute.toString().padLeft(2, '0')}'
                : 'Không có hạn nộp',
            style: DesignTypography.bodySmall.copyWith(
              color: _isExpired ? Colors.red[400] : metaColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Thời gian làm bài — căn phải (luôn hiển thị)
        const SizedBox(width: 8),
        Icon(Icons.timer_outlined, size: 13, color: metaColor),
        const SizedBox(width: 4),
        Text(
          timeLimitText,
          style: DesignTypography.bodySmall.copyWith(color: metaColor),
        ),
      ],
    );
  }

  /// Teacher footer: Số học sinh đã mộp / Chấm bài & Badge Trạng thái
  Widget _buildTeacherFooter(bool isDark) {
    final metaColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final badge = _badgeStyle;

    final pendingAction = _pendingActionCount ?? 0;

    return Row(
      children: [
        // Bên trái: Thống kê tham gia (1 HS làm lại N lần chỉ đếm 1).
        Icon(Icons.how_to_reg_outlined, size: 16, color: metaColor),
        const SizedBox(width: 4),
        Text(
          '${_submissionCount ?? 0}/${_totalStudents ?? 0} đã nộp • ${_gradedCount ?? 0} đã chấm',
          style: DesignTypography.bodySmall.copyWith(
            color: metaColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Badge actionable queue: số HS có latest attempt chờ chấm.
        if (pendingAction > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(DesignRadius.full),
            ),
            child: Text(
              '$pendingAction chờ chấm',
              style: DesignTypography.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
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

  /// Student: status badge + điểm chip + action button
  Widget _buildStudentFooter() {
    final status = (assignment['submission_status'] as String?) ?? 'not_submitted';
    final settings = assignment['distribution_settings'] as Map<String, dynamic>? ?? {};
    final showScore = settings['show_score_immediately'] as bool? ?? true;
    final score = showScore ? assignment['score'] : null;
    final pts = _totalPoints > 0 ? _totalPoints.toStringAsFixed(_totalPoints % 1 == 0 ? 0 : 1) : null;

    // ── Badge trạng thái ──
    // P3 fix: dùng DesignColors thay hardcoded Colors.blue/orange/green
    // P1 fix: thêm 'pending_review' case (AI done, chờ GV duyệt → hiện như "Đã nộp")
    final ({String label, Color bg, Color border, Color text}) badge = switch (status) {
      'ai_processing' => (
        label: 'AI đang xử lý',
        bg: DesignColors.primary.withValues(alpha: 0.08),
        border: DesignColors.primary.withValues(alpha: 0.4),
        text: DesignColors.primary,
      ),
      'submitted' => (
        label: 'Đã nộp',
        bg: DesignColors.warning.withValues(alpha: 0.08),
        border: DesignColors.warning.withValues(alpha: 0.4),
        text: DesignColors.warning,
      ),
      'pending_review' => (
        // Student view: same as submitted — "đã nộp, đang chờ"
        label: 'Đã nộp',
        bg: DesignColors.warning.withValues(alpha: 0.08),
        border: DesignColors.warning.withValues(alpha: 0.4),
        text: DesignColors.warning,
      ),
      'graded' => (
        label: score != null ? '$score / $pts đ' : 'Đã chấm',
        bg: DesignColors.success.withValues(alpha: 0.08),
        border: DesignColors.success.withValues(alpha: 0.4),
        text: DesignColors.success,
      ),
      'in_progress' => (
        label: 'Đang làm',
        bg: DesignColors.primary.withValues(alpha: 0.08),
        border: DesignColors.primary.withValues(alpha: 0.4),
        text: DesignColors.primary,
      ),
      _ => (
        label: 'Chưa nộp',
        bg: DesignColors.error.withValues(alpha: 0.08),
        border: DesignColors.error.withValues(alpha: 0.4),
        text: DesignColors.error,
      ),
    };

    // ── Nút hành động ──
    final ({String label, IconData icon, Color bg, Color fg}) btn = switch ((status, showScore)) {
      ('graded', true) => (label: 'Xem điểm', icon: Icons.star_outline, bg: Colors.green[100]!, fg: Colors.green[800]!),
      ('graded', false) => (label: 'Xem bài làm', icon: Icons.visibility_outlined, bg: Colors.grey[200]!, fg: Colors.grey[700]!),
      ('ai_processing', _) => (label: 'Xem bài đã nộp', icon: Icons.visibility_outlined, bg: Colors.grey[200]!, fg: Colors.grey[700]!),
      ('submitted', _) => (label: 'Xem bài đã nộp', icon: Icons.visibility_outlined, bg: Colors.grey[200]!, fg: Colors.grey[700]!),
      ('in_progress', _) => (label: 'Tiếp tục làm', icon: Icons.play_circle_outline, bg: DesignColors.primary, fg: Colors.white),
      _ => (label: 'Làm bài ngay', icon: Icons.edit_outlined, bg: DesignColors.primary, fg: Colors.white),
    };

    return Row(children: [
      // Status badge
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: badge.bg,
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          border: Border.all(color: badge.border),
        ),
        child: Text(badge.label, style: DesignTypography.caption.copyWith(color: badge.text, fontWeight: FontWeight.bold)),
      ),
      // Tổng điểm (chỉ khi chưa nộp / đang làm)
      if (pts != null && (status == 'not_submitted' || status == 'in_progress')) ...[
        const SizedBox(width: 6),
        Text('/ $pts đ', style: DesignTypography.caption.copyWith(color: Colors.grey[500])),
      ],
      const Spacer(),
      // Action button
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: btn.bg,
          foregroundColor: btn.fg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.sm)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onTap,
        icon: Icon(btn.icon, size: 15),
        label: Text(btn.label, style: const TextStyle(fontSize: 12)),
      ),
    ]);
  }
}
