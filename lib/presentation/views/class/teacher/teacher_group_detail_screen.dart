import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/providers/group_providers.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TeacherGroupDetailScreen extends ConsumerStatefulWidget {
  final String classId;
  final String groupId;
  final String groupName;
  final String className;

  const TeacherGroupDetailScreen({
    super.key,
    required this.classId,
    required this.groupId,
    required this.groupName,
    required this.className,
  });

  @override
  ConsumerState<TeacherGroupDetailScreen> createState() =>
      _TeacherGroupDetailScreenState();
}

class _TeacherGroupDetailScreenState
    extends ConsumerState<TeacherGroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final membersAsync =
        ref.watch(groupMembersWithProfilesProvider(widget.groupId));

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1923) : DesignColors.moonLight,
      appBar: _buildAppBar(context, isDark, membersAsync),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddMemberSheet(context, membersAsync),
              backgroundColor: DesignColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Thêm thành viên'),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          _MembersTab(
            groupId: widget.groupId,
            isDark: isDark,
            onRemove: (id, name) => _removeMember(context, id, name),
            onToggleLeader: (id, isLeader) =>
                _toggleLeader(context, id, isLeader),
          ),
          _ProgressTab(groupId: widget.groupId, isDark: isDark),
        ],
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    bool isDark,
    AsyncValue<List<Map<String, dynamic>>> membersAsync,
  ) {
    final count = membersAsync.whenOrNull(data: (m) => m.length) ?? 0;

    return AppBar(
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
            count == 0 ? 'Chưa có thành viên' : '$count thành viên',
            style: DesignTypography.bodySmall.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline, color: DesignColors.error),
          tooltip: 'Xóa nhóm',
          onPressed: () => _confirmAndDeleteGroup(context),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        labelColor: DesignColors.primary,
        unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
        indicatorColor: DesignColors.primary,
        tabs: const [
          Tab(icon: Icon(Icons.people_outline, size: 18), text: 'Thành viên'),
          Tab(
              icon: Icon(Icons.assignment_outlined, size: 18),
              text: 'Bài tập & Tiến độ'),
        ],
      ),
    );
  }

  // ── Add member ────────────────────────────────────────────────────────────

  void _showAddMemberSheet(
    BuildContext context,
    AsyncValue<List<Map<String, dynamic>>> membersAsync,
  ) {
    final existingMembers = membersAsync.valueOrNull ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => _AddMemberSheet(
        classId: widget.classId,
        groupId: widget.groupId,
        existingMembers: existingMembers,
        onAdded: () =>
            ref.invalidate(groupMembersWithProfilesProvider(widget.groupId)),
      ),
    );
  }

  // ── Toggle leader ─────────────────────────────────────────────────────────

  Future<void> _toggleLeader(
    BuildContext context,
    String studentId,
    bool currentlyLeader,
  ) async {
    await ref
        .read(groupNotifierProvider.notifier)
        .setLeader(widget.groupId, studentId, !currentlyLeader);
    if (!context.mounted) return;
    /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — AppToast.success(context, ok
            ? (currentlyLeader
                ? 'Đã gỡ vai trò trưởng nhóm'
                : 'Đã đặt làm trưởng nhóm'); */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */;
  }

  // ── Remove member ─────────────────────────────────────────────────────────

  Future<void> _removeMember(
    BuildContext context,
    String studentId,
    String fullName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa khỏi nhóm?'),
        content: Text('Bạn có chắc muốn xóa "$fullName" khỏi nhóm này?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.error,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final ok = await ref
        .read(groupNotifierProvider.notifier)
        .removeMember(widget.groupId, studentId, classId: widget.classId);
    if (!context.mounted) return;
    AppToast.success(context, ok ? 'Đã xóa $fullName khỏi nhóm' : 'Không thể xóa thành viên');
  }

  // ── Delete group ──────────────────────────────────────────────────────────

  Future<void> _confirmAndDeleteGroup(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa nhóm?'),
        content: Text(
          'Nhóm "${widget.groupName}" và toàn bộ thành viên sẽ bị xóa vĩnh viễn.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.error,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa nhóm'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final ok = await ref
        .read(groupNotifierProvider.notifier)
        .deleteGroup(widget.groupId, widget.classId);
    if (!context.mounted) return;
    if (ok) {
      context.pop();
      AppToast.success(context, 'Đã xóa nhóm "${widget.groupName}"');
    } else {
      AppToast.error(context, 'Không thể xóa nhóm');
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Tab 1: Danh sách thành viên
// ══════════════════════════════════════════════════════════════════════════

class _MembersTab extends ConsumerWidget {
  final String groupId;
  final bool isDark;
  final void Function(String studentId, String name) onRemove;
  final void Function(String studentId, bool isLeader) onToggleLeader;

  const _MembersTab({
    required this.groupId,
    required this.isDark,
    required this.onRemove,
    required this.onToggleLeader,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersWithProfilesProvider(groupId));

    return membersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: ShimmerListTileLoading(itemCount: 5),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: DesignColors.error),
            const SizedBox(height: DesignSpacing.md),
            Text('Không thể tải thành viên',
                style: DesignTypography.bodyMedium),
            const SizedBox(height: DesignSpacing.sm),
            ElevatedButton(
              onPressed: () =>
                  ref.invalidate(groupMembersWithProfilesProvider(groupId)),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
      data: (members) => members.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline,
                      size: 64,
                      color: isDark ? Colors.grey[700] : Colors.grey[300]),
                  const SizedBox(height: DesignSpacing.md),
                  Text(
                    'Nhóm chưa có thành viên',
                    style: DesignTypography.titleMedium.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: DesignSpacing.xs),
                  Text(
                    'Thêm học sinh để bắt đầu',
                    style: DesignTypography.bodySmall.copyWith(
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(groupMembersWithProfilesProvider(groupId)),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                    DesignSpacing.lg, DesignSpacing.lg, DesignSpacing.lg, 100),
                itemCount: members.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: DesignSpacing.sm),
                itemBuilder: (_, i) =>
                    _buildMemberTile(context, members[i], i),
              ),
            ),
    );
  }

  Widget _buildMemberTile(
      BuildContext context, Map<String, dynamic> member, int index) {
    final studentId = member['student_id'] as String;
    final fullName = (member['full_name'] as String?) ?? 'Học sinh';
    final avatarUrl = member['avatar_url'] as String?;
    final isLeader = (member['role'] as String?) == 'leader';
    final joinedRaw = member['joined_at'] as String?;
    final joinedAt = joinedRaw != null ? DateTime.tryParse(joinedRaw) : null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(
          color: isLeader
              ? Colors.amber.withValues(alpha: 0.5)
              : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
          width: isLeader ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: DesignSpacing.md, vertical: DesignSpacing.md),
        child: Row(
          children: [
            // Avatar + số thứ tự
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isLeader
                      ? Colors.amber.withValues(alpha: 0.15)
                      : DesignColors.primary.withValues(alpha: 0.12),
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Text(
                          fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                          style: TextStyle(
                              color: isLeader
                                  ? Colors.amber[800]
                                  : DesignColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16))
                      : null,
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F1923) : Colors.grey[100],
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: DesignSpacing.md),
            // Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          fullName,
                          style: DesignTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : DesignColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isLeader)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(DesignRadius.full),
                            border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 11, color: Colors.amber),
                              const SizedBox(width: 3),
                              Text(
                                'Trưởng nhóm',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.amber[800],
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 11,
                          color: isDark ? Colors.grey[500] : Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        joinedAt != null
                            ? 'Tham gia: ${joinedAt.day.toString().padLeft(2, '0')}/${joinedAt.month.toString().padLeft(2, '0')}/${joinedAt.year}'
                            : 'Thành viên',
                        style: TextStyle(
                            fontSize: 11,
                            color:
                                isDark ? Colors.grey[500] : Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Tooltip(
              message: isLeader ? 'Gỡ trưởng nhóm' : 'Đặt làm trưởng nhóm',
              child: IconButton(
                icon: Icon(
                  isLeader ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 20,
                  color: isLeader ? Colors.amber[600] : Colors.grey[400],
                ),
                onPressed: () => onToggleLeader(studentId, isLeader),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 20),
              color: DesignColors.error,
              tooltip: 'Xóa khỏi nhóm',
              onPressed: () => onRemove(studentId, fullName),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Tab 2: Bài tập & Tiến độ nộp bài
// ══════════════════════════════════════════════════════════════════════════

class _ProgressTab extends ConsumerWidget {
  final String groupId;
  final bool isDark;

  const _ProgressTab({required this.groupId, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync =
        ref.watch(groupAssignmentProgressProvider(groupId));

    return progressAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: ShimmerListTileLoading(itemCount: 4),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: DesignColors.error),
            const SizedBox(height: DesignSpacing.md),
            Text('Không thể tải bài tập', style: DesignTypography.bodyMedium),
            const SizedBox(height: DesignSpacing.sm),
            ElevatedButton(
              onPressed: () =>
                  ref.invalidate(groupAssignmentProgressProvider(groupId)),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
      data: (assignments) => assignments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 64,
                      color: isDark ? Colors.grey[700] : Colors.grey[300]),
                  const SizedBox(height: DesignSpacing.md),
                  Text(
                    'Chưa có bài tập nào',
                    style: DesignTypography.titleMedium.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: DesignSpacing.xs),
                  Text(
                    'Giao bài tập cho nhóm này từ trang Bài tập',
                    textAlign: TextAlign.center,
                    style: DesignTypography.bodySmall.copyWith(
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(groupAssignmentProgressProvider(groupId)),
              child: ListView.separated(
                padding: const EdgeInsets.all(DesignSpacing.lg),
                itemCount: assignments.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: DesignSpacing.sm),
                itemBuilder: (_, i) =>
                    _buildProgressCard(assignments[i]),
              ),
            ),
    );
  }

  Widget _buildProgressCard(Map<String, dynamic> item) {
    final title = (item['title'] as String?) ?? 'Bài tập';
    final submitted = (item['submitted_count'] as int?) ?? 0;
    final total = (item['total_members'] as int?) ?? 0;
    final dueRaw = item['distribution_due_at'] as String?;
    final due = dueRaw != null ? DateTime.tryParse(dueRaw) : null;
    final isExpired = due != null && due.isBefore(DateTime.now());
    final progress = total > 0 ? submitted / total : 0.0;
    final pct = (progress * 100).round();

    Color progressColor;
    if (pct == 100) {
      progressColor = DesignColors.success;
    } else if (pct >= 50) {
      progressColor = Colors.orange;
    } else {
      progressColor = DesignColors.error;
    }

    return Container(
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
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
                padding: const EdgeInsets.all(6),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.full),
                  border: Border.all(
                      color: progressColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 12,
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSpacing.sm),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  isDark ? Colors.grey[800] : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: DesignSpacing.xs),
          Row(
            children: [
              Icon(Icons.people_outline,
                  size: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[600]),
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
                  isExpired
                      ? Icons.event_busy_outlined
                      : Icons.access_time_outlined,
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
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Bottom sheet thêm thành viên
// ══════════════════════════════════════════════════════════════════════════

class _AddMemberSheet extends ConsumerStatefulWidget {
  final String classId;
  final String groupId;
  final List<Map<String, dynamic>> existingMembers;
  final VoidCallback onAdded;

  const _AddMemberSheet({
    required this.classId,
    required this.groupId,
    required this.existingMembers,
    required this.onAdded,
  });

  @override
  ConsumerState<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends ConsumerState<_AddMemberSheet> {
  String _search = '';
  final Set<String> _selected = {};
  bool _isAdding = false;

  Set<String> get _existingMemberIds => widget.existingMembers
      .map((e) => e['student_id'] as String)
      .toSet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final classStudents =
        ref.watch(classStudentsWithProfilesProvider(widget.classId));

    // Build membershipMap: studentId → [groupName, ...] for OTHER groups
    final groups =
        ref.watch(groupsByClassProvider(widget.classId)).valueOrNull ?? [];
    final membershipMap = <String, List<String>>{};
    for (final group in groups) {
      if (group.id == widget.groupId) continue;
      final members =
          ref.watch(groupMembersWithProfilesProvider(group.id)).valueOrNull ??
              [];
      for (final m in members) {
        final sid = m['student_id'] as String?;
        if (sid != null) {
          membershipMap.putIfAbsent(sid, () => []).add(group.name);
        }
      }
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Thêm thành viên',
                    style: DesignTypography.titleMedium
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (_isAdding)
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (_selected.isNotEmpty)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: DesignColors.primary,
                        foregroundColor: Colors.white),
                    onPressed: () => _addSelected(context),
                    child: Text('Thêm (${_selected.length})'),
                  ),
              ],
            ),
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm học sinh...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.md)),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
          ),
          // Content
          Expanded(
            child: classStudents.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Lỗi: $e')),
              data: (allStudents) {
                final currentIds = _existingMemberIds;

                // Filter by search across all students
                final filtered = _search.isEmpty
                    ? allStudents
                    : allStudents
                        .where((s) => (s['full_name'] as String? ?? '')
                            .toLowerCase()
                            .contains(_search))
                        .toList();

                // Split into 3 sections
                final inThisGroup = <Map<String, dynamic>>[];
                final inOtherGroup = <Map<String, dynamic>>[];
                final notInAnyGroup = <Map<String, dynamic>>[];

                for (final s in filtered) {
                  final sid = s['student_id'] as String?;
                  if (sid == null) continue;
                  if (currentIds.contains(sid)) {
                    inThisGroup.add(s);
                  } else if (membershipMap.containsKey(sid)) {
                    inOtherGroup.add(s);
                  } else {
                    notInAnyGroup.add(s);
                  }
                }

                // All empty → single empty message
                if (notInAnyGroup.isEmpty &&
                    inOtherGroup.isEmpty &&
                    inThisGroup.isEmpty) {
                  return Center(
                    child: Text(
                      'Không còn học sinh nào để thêm',
                      style: DesignTypography.bodyMedium.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  );
                }

                return CustomScrollView(
                  controller: controller,
                  slivers: [
                    // Section 1: Not in any group
                    if (notInAnyGroup.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: _buildSectionHeader(
                          'CHƯA VÀO NHÓM NÀO',
                          notInAnyGroup.length,
                          trailing: TextButton(
                            onPressed: () => setState(() {
                              for (final s in notInAnyGroup) {
                                final sid = s['student_id'] as String?;
                                if (sid != null) _selected.add(sid);
                              }
                            }),
                            child: const Text('Chọn tất cả',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            final s = notInAnyGroup[i];
                            final id = s['student_id'] as String;
                            final name =
                                (s['full_name'] as String?) ?? 'Học sinh';
                            final avatarUrl = s['avatar_url'] as String?;
                            return CheckboxListTile(
                              value: _selected.contains(id),
                              onChanged: (v) => setState(() {
                                if (v == true) {
                                  _selected.add(id);
                                } else {
                                  _selected.remove(id);
                                }
                              }),
                              secondary: _buildAvatar(name, avatarUrl),
                              title: Text(
                                name,
                                style: DesignTypography.bodyMedium
                                    .copyWith(fontWeight: FontWeight.w500),
                              ),
                              activeColor: DesignColors.primary,
                            );
                          },
                          childCount: notInAnyGroup.length,
                        ),
                      ),
                    ],

                    // Section 2: In other groups
                    if (inOtherGroup.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: _buildSectionHeader(
                            'ĐANG TRONG NHÓM KHÁC', inOtherGroup.length),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            final s = inOtherGroup[i];
                            final id = s['student_id'] as String;
                            final name =
                                (s['full_name'] as String?) ?? 'Học sinh';
                            final avatarUrl = s['avatar_url'] as String?;
                            final groupNames = membershipMap[id] ?? [];
                            return CheckboxListTile(
                              value: _selected.contains(id),
                              onChanged: (v) => setState(() {
                                if (v == true) {
                                  _selected.add(id);
                                } else {
                                  _selected.remove(id);
                                }
                              }),
                              secondary: _buildAvatar(name, avatarUrl),
                              title: Text(
                                name,
                                style: DesignTypography.bodyMedium
                                    .copyWith(fontWeight: FontWeight.w500),
                              ),
                              subtitle: groupNames.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: groupNames
                                            .map((gn) =>
                                                _buildGroupBadge(gn))
                                            .toList(),
                                      ),
                                    )
                                  : null,
                              activeColor: DesignColors.primary,
                            );
                          },
                          childCount: inOtherGroup.length,
                        ),
                      ),
                    ],

                    // Section 3: Already in this group
                    if (inThisGroup.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: _buildSectionHeader(
                            'ĐÃ TRONG NHÓM NÀY', inThisGroup.length),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            final s = inThisGroup[i];
                            final id = s['student_id'] as String;
                            final name =
                                (s['full_name'] as String?) ?? 'Học sinh';
                            final avatarUrl = s['avatar_url'] as String?;
                            // Find role from existingMembers
                            final memberData = widget.existingMembers
                                .where((m) => m['student_id'] == id)
                                .firstOrNull;
                            final role = memberData?['role'] as String?;
                            final isLeader = role == 'leader';

                            return ListTile(
                              leading: _buildAvatar(name, avatarUrl,
                                  greyed: true),
                              title: Text(
                                name,
                                style: DesignTypography.bodyMedium.copyWith(
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: isLeader
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.amber
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(
                                            DesignRadius.full),
                                        border: Border.all(
                                            color: Colors.amber
                                                .withValues(alpha: 0.4)),
                                      ),
                                      child: Text(
                                        '★ Trưởng nhóm',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.amber[800],
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(
                                            DesignRadius.full),
                                        border: Border.all(
                                            color: Colors.grey
                                                .withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        '✓ Thành viên',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                            );
                          },
                          childCount: inThisGroup.length,
                        ),
                      ),
                    ],

                    // Bottom padding
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, int count, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey[500],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, String? avatarUrl, {bool greyed = false}) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: greyed
          ? Colors.grey.withValues(alpha: 0.15)
          : DesignColors.primary.withValues(alpha: 0.15),
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      child: avatarUrl == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: greyed ? Colors.grey[400] : DesignColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            )
          : null,
    );
  }

  Widget _buildGroupBadge(String groupName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Text(
        groupName,
        style: TextStyle(
          fontSize: 10,
          color: Colors.orange[800],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Add selected ───────────────────────────────────────────────────────────

  Future<void> _addSelected(BuildContext context) async {
    if (_isAdding || _selected.isEmpty) return;
    setState(() => _isAdding = true);

    final notifier = ref.read(groupNotifierProvider.notifier);
    final total = _selected.length;
    final results = await Future.wait(
      _selected.map(
          (id) => notifier.addMember(widget.groupId, id, classId: widget.classId)),
    );
    final added = results.where((ok) => ok).length;

    widget.onAdded();
    if (!context.mounted) return;
    Navigator.pop(context);
    AppToast.success(context, added == total
        ? 'Đã thêm $added học sinh vào nhóm'
        : 'Thêm $added/$total học sinh (${total - added} thất bại)');
  }
}
