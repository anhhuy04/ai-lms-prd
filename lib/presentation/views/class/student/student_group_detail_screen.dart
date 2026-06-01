import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/group_providers.dart';
import 'package:ai_mls/widgets/responsive/wide_content_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình chi tiết nhóm cho học sinh.
/// - Hiển thị danh sách thành viên + vai trò
/// - Cho phép học sinh tự bổ nhiệm làm trưởng nhóm (nếu nhóm chưa có trưởng)
/// - Hiển thị bài tập nhóm + tiến độ nộp bài
class StudentGroupDetailScreen extends ConsumerStatefulWidget {
  final String classId;
  final String groupId;
  final String groupName;
  final String className;

  const StudentGroupDetailScreen({
    super.key,
    required this.classId,
    required this.groupId,
    required this.groupName,
    required this.className,
  });

  @override
  ConsumerState<StudentGroupDetailScreen> createState() =>
      _StudentGroupDetailScreenState();
}

class _StudentGroupDetailScreenState
    extends ConsumerState<StudentGroupDetailScreen> {
  bool _isAppointing = false;

  Future<void> _appointSelf() async {
    final studentId = ref.read(currentUserIdProvider);
    if (studentId == null || _isAppointing) return;
    setState(() => _isAppointing = true);
    try {
      await ref
          .read(groupNotifierProvider.notifier)
          .setLeader(widget.groupId, studentId, true);
      if (!mounted) return;
      /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — AppToast.success(context, ok
              ? 'Bạn đã được bổ nhiệm làm Trưởng nhóm'
              : 'Không thể bổ nhiệm. Vui lòng thử lại.'); */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */;
    } finally {
      if (mounted) setState(() => _isAppointing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final studentId = ref.watch(currentUserIdProvider) ?? '';
    final membersAsync = ref.watch(groupMembersWithProfilesProvider(widget.groupId));
    final assignmentsAsync = ref.watch(groupAssignmentProgressProvider(widget.groupId));

    final members = membersAsync.valueOrNull ?? [];
    final isMember = members.any((m) => m['student_id'] == studentId);
    final hasLeader = members.any((m) => m['role'] == 'leader');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1923) : DesignColors.moonLight,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.groupName,
              style: DesignTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : DesignColors.textPrimary,
              ),
            ),
            Text(
              widget.className,
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(groupMembersWithProfilesProvider(widget.groupId));
              ref.invalidate(groupAssignmentProgressProvider(widget.groupId));
            },
          ),
        ],
      ),
      body: WideContentWrapper(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(groupMembersWithProfilesProvider(widget.groupId));
            ref.invalidate(groupAssignmentProgressProvider(widget.groupId));
          },
          child: ListView(
            padding: const EdgeInsets.all(DesignSpacing.lg),
            children: [
              _buildMembersSection(context, isDark, membersAsync, studentId, isMember, hasLeader),
              const SizedBox(height: DesignSpacing.xl),
              _buildAssignmentsSection(context, isDark, assignmentsAsync),
              const SizedBox(height: DesignSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  // ── Members section ────────────────────────────────────────────────────────

  Widget _buildMembersSection(
    BuildContext context,
    bool isDark,
    AsyncValue<List<Map<String, dynamic>>> membersAsync,
    String studentId,
    bool isMember,
    bool hasLeader,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Thành viên nhóm', Icons.people_rounded, isDark),
        const SizedBox(height: DesignSpacing.md),

        // Banner bổ nhiệm: chỉ hiện khi là thành viên và chưa có nhóm trưởng
        if (isMember && !hasLeader)
          _buildAppointBanner(isDark),

        const SizedBox(height: DesignSpacing.sm),

        membersAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => _buildError('Không thể tải thành viên', () {
            ref.invalidate(groupMembersWithProfilesProvider(widget.groupId));
          }),
          data: (members) {
            if (members.isEmpty) {
              return _buildEmptyHint('Nhóm chưa có thành viên nào', isDark);
            }
            return _buildMembersCard(members, studentId, isDark);
          },
        ),
      ],
    );
  }

  Widget _buildAppointBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.sm),
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: DesignColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: DesignColors.warning, size: 18),
          const SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: Text(
              'Nhóm chưa có trưởng nhóm. Bạn có thể tự đứng ra bổ nhiệm.',
              style: DesignTypography.bodySmall.copyWith(
                color: DesignColors.warning,
              ),
            ),
          ),
          const SizedBox(width: DesignSpacing.sm),
          _isAppointing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: DesignColors.warning,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: _appointSelf,
                  child: const Text('Bổ nhiệm tôi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
        ],
      ),
    );
  }

  Widget _buildMembersCard(List<Map<String, dynamic>> members, String studentId, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: members.asMap().entries.map((entry) {
          final i = entry.key;
          final m = entry.value;
          final isLast = i == members.length - 1;
          return Column(
            children: [
              _buildMemberRow(m, studentId, isDark),
              if (!isLast)
                Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[100]),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMemberRow(Map<String, dynamic> member, String studentId, bool isDark) {
    final name = (member['full_name'] as String?) ?? 'Học sinh';
    final avatarUrl = member['avatar_url'] as String?;
    final role = (member['role'] as String?) ?? 'member';
    final isLeader = role == 'leader';
    final isMe = member['student_id'] == studentId;

    return Container(
      color: isMe ? DesignColors.primary.withValues(alpha: 0.04) : null,
      padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isLeader
                ? Colors.amber.withValues(alpha: 0.15)
                : DesignColors.primary.withValues(alpha: 0.1),
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isLeader ? Colors.amber[700] : DesignColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe ? '$name (Bạn)' : name,
                  style: DesignTypography.bodyMedium.copyWith(
                    fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (isLeader)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(DesignRadius.full),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, size: 12, color: Colors.amber[700]),
                  const SizedBox(width: 3),
                  Text(
                    'Trưởng nhóm',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.amber[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(DesignRadius.full),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Text(
                'Thành viên',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Assignments section ────────────────────────────────────────────────────

  Widget _buildAssignmentsSection(
    BuildContext context,
    bool isDark,
    AsyncValue<List<Map<String, dynamic>>> assignmentsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Bài tập nhóm', Icons.assignment_outlined, isDark),
        const SizedBox(height: DesignSpacing.md),
        assignmentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildError('Không thể tải bài tập', () {
            ref.invalidate(groupAssignmentProgressProvider(widget.groupId));
          }),
          data: (assignments) {
            if (assignments.isEmpty) {
              return _buildEmptyHint('Nhóm chưa có bài tập nào', isDark);
            }
            return Column(
              children: assignments
                  .map((a) => _buildAssignmentCard(context, a, isDark))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAssignmentCard(BuildContext context, Map<String, dynamic> item, bool isDark) {
    final title = (item['title'] as String?) ?? 'Bài tập';
    final submitted = (item['submitted_count'] as int?) ?? 0;
    final total = (item['total_members'] as int?) ?? 0;
    final dueRaw = item['distribution_due_at'] as String?;
    final due = dueRaw != null ? DateTime.tryParse(dueRaw) : null;
    final isExpired = due != null && due.isBefore(DateTime.now());
    final progress = total > 0 ? submitted / total : 0.0;
    final pct = (progress * 100).round();
    final distributionId = item['distribution_id'] as String?;

    Color progressColor;
    if (pct == 100) {
      progressColor = DesignColors.success;
    } else if (pct >= 50) {
      progressColor = DesignColors.warning;
    } else {
      progressColor = DesignColors.error;
    }

    return GestureDetector(
      onTap: distributionId == null
          ? null
          : () => context.pushNamed(
                AppRoute.studentAssignmentDetail,
                pathParameters: {'distributionId': distributionId},
              ),
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignSpacing.md),
        padding: const EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2632) : Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: DesignColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                  child: Icon(Icons.assignment_outlined,
                      size: 16, color: DesignColors.primary),
                ),
                const SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: DesignTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : DesignColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.full),
                    border: Border.all(color: progressColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '$pct%',
                    style: TextStyle(
                        fontSize: 11,
                        color: progressColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: DesignSpacing.xs),
            Row(
              children: [
                Icon(Icons.people_outline,
                    size: 13, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '$submitted/$total thành viên đã nộp',
                  style: DesignTypography.bodySmall.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (due != null) ...[
                  Icon(
                    isExpired ? Icons.event_busy_outlined : Icons.access_time_outlined,
                    size: 13,
                    color: isExpired
                        ? DesignColors.error
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${due.day.toString().padLeft(2, '0')}/${due.month.toString().padLeft(2, '0')}/${due.year}',
                    style: DesignTypography.bodySmall.copyWith(
                      color: isExpired
                          ? DesignColors.error
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ],
                if (distributionId != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: DesignColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignRadius.sm),
          ),
          child: Icon(icon, size: 16, color: DesignColors.primary),
        ),
        const SizedBox(width: DesignSpacing.sm),
        Text(
          title,
          style: DesignTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyHint(String message, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignSpacing.xl),
      child: Center(
        child: Text(
          message,
          style: DesignTypography.bodyMedium.copyWith(
            color: isDark ? Colors.grey[500] : Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildError(String message, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignSpacing.lg),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: DesignColors.error, size: 32),
            const SizedBox(height: DesignSpacing.sm),
            Text(message, style: DesignTypography.bodySmall),
            const SizedBox(height: DesignSpacing.sm),
            TextButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
