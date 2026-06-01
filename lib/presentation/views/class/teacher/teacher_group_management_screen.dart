import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/create_group_params.dart';
import 'package:ai_mls/domain/entities/group.dart';
import 'package:ai_mls/presentation/providers/group_providers.dart';
import 'package:flutter/material.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TeacherGroupManagementScreen extends ConsumerStatefulWidget {
  final String classId;
  final String className;

  const TeacherGroupManagementScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  ConsumerState<TeacherGroupManagementScreen> createState() =>
      _TeacherGroupManagementScreenState();
}

class _TeacherGroupManagementScreenState
    extends ConsumerState<TeacherGroupManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupsAsync = ref.watch(groupsByClassProvider(widget.classId));
    final countsAsync = ref.watch(groupMemberCountsProvider(widget.classId));
    final studentCount = ref
            .watch(classStudentsWithProfilesProvider(widget.classId))
            .whenOrNull(data: (s) => s.length) ??
        0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1923) : DesignColors.moonLight,
      appBar: _buildAppBar(context, isDark),
      endDrawer: _buildEndDrawer(context, isDark, studentCount),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGroupDialog(context),
        backgroundColor: DesignColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.group_add_rounded),
        label: const Text('Tạo nhóm'),
      ),
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildError(context, e),
        data: (groups) => groups.isEmpty
            ? _buildEmpty(context, isDark)
            : _buildGroupList(context, groups, isDark,
                counts: countsAsync.whenOrNull(data: (c) => c) ?? {}),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isDark) {
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
            'Quản lý nhóm',
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
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: 'Thao tác',
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupList(
    BuildContext context,
    List<Group> groups,
    bool isDark, {
    Map<String, int> counts = const {},
  }) {
    final totalMembers = counts.values.fold<int>(0, (sum, c) => sum + c);

    return Column(
      children: [
        // Stats summary banner
        Padding(
          padding: const EdgeInsets.fromLTRB(
              DesignSpacing.lg, DesignSpacing.lg, DesignSpacing.lg, 0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DesignColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(DesignRadius.md),
              border: Border.all(
                  color: DesignColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.insights_outlined,
                    size: 18, color: DesignColors.primary),
                const SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: Text(
                    '${groups.length} nhóm  •  $totalMembers thành viên',
                    style: DesignTypography.bodySmall.copyWith(
                      color: DesignColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Group list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(groupsByClassProvider(widget.classId));
              ref.invalidate(groupMemberCountsProvider(widget.classId));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(DesignSpacing.lg),
              itemCount: groups.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: DesignSpacing.sm),
              itemBuilder: (context, index) => _buildGroupCard(
                  context, groups[index], isDark, counts[groups[index].id] ?? 0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(
      BuildContext context, Group group, bool isDark, int memberCount) {
    final createdAt = group.createdAt;
    final dateStr =
        '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';

    return Dismissible(
      key: ValueKey(group.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context, group.name),
      onDismissed: (_) => _deleteGroup(context, group),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: DesignSpacing.lg),
        decoration: BoxDecoration(
          color: DesignColors.error,
          borderRadius: BorderRadius.circular(DesignRadius.lg),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRoute.teacherGroupDetail,
          pathParameters: {
            'classId': widget.classId,
            'groupId': group.id,
          },
          extra: {
            'groupName': group.name,
            'className': widget.className,
          },
        ),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(DesignSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2632) : Colors.white,
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon nhóm
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: DesignColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.md),
                ),
                child: Icon(
                  Icons.group_work_rounded,
                  color: DesignColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: DesignSpacing.md),
              // Thông tin nhóm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: DesignTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : DesignColors.textPrimary,
                      ),
                    ),
                    if (group.description != null &&
                        group.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        group.description!,
                        style: DesignTypography.bodySmall.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    // Stats row
                    Row(
                      children: [
                        _buildStatChip(
                          icon: Icons.people_outline,
                          label: '$memberCount thành viên',
                          isDark: isDark,
                        ),
                        const SizedBox(width: DesignSpacing.sm),
                        _buildStatChip(
                          icon: Icons.calendar_today_outlined,
                          label: dateStr,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DesignSpacing.xs),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 12,
            color: isDark ? Colors.grey[500] : Colors.grey[500]),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[500] : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 64,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: DesignSpacing.md),
          Text(
            'Chưa có nhóm nào',
            style: DesignTypography.titleMedium.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: DesignSpacing.sm),
          Text(
            'Tạo nhóm để phân công bài tập cho từng nhóm học sinh',
            textAlign: TextAlign.center,
            style: DesignTypography.bodySmall.copyWith(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: DesignSpacing.xl),
          ElevatedButton.icon(
            onPressed: () => _showCreateGroupDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSpacing.xl,
                vertical: DesignSpacing.md,
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Tạo nhóm đầu tiên'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: DesignColors.error),
          const SizedBox(height: DesignSpacing.md),
          Text('Không thể tải danh sách nhóm',
              style: DesignTypography.bodyMedium),
          const SizedBox(height: DesignSpacing.sm),
          ElevatedButton(
            onPressed: () =>
                ref.invalidate(groupsByClassProvider(widget.classId)),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  // ── End drawer (bên phải) ─────────────────────────────────────────────────

  Widget _buildEndDrawer(BuildContext context, bool isDark, int studentCount) {
    return Drawer(
      width: 280,
      backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Thao tác nhóm',
                      style: DesignTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : DesignColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(
                color: isDark ? Colors.grey[800] : Colors.grey[200], height: 1),
            const SizedBox(height: 8),
            // Actions
            _buildDrawerAction(
              context: context,
              isDark: isDark,
              icon: Icons.auto_awesome_rounded,
              iconColor: DesignColors.primary,
              title: 'Phân nhóm tự động',
              subtitle: 'Chia ngẫu nhiên học sinh',
              onTap: () {
                Navigator.pop(context);
                _showAutoGroupDialog(context, studentCount: studentCount);
              },
            ),
            // Thêm các action khác tại đây
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerAction({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignRadius.md),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: DesignSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DesignTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : DesignColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: DesignTypography.bodySmall.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                size: 18,
                color: isDark ? Colors.grey[600] : Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Tạo nhóm mới'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên nhóm *',
                  hintText: 'Nhóm 1, Nhóm A...',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nhập tên nhóm' : null,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: DesignSpacing.md),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả (tuỳ chọn)',
                  hintText: 'Nhóm làm dự án...',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(dialogCtx);
              await _createGroup(
                context,
                nameController.text.trim(),
                descController.text.trim().isEmpty
                    ? null
                    : descController.text.trim(),
              );
            },
            child: const Text('Tạo nhóm'),
          ),
        ],
      ),
    );
  }

  Future<void> _createGroup(
    BuildContext context,
    String name,
    String? description,
  ) async {
    final notifier = ref.read(groupNotifierProvider.notifier);
    final group = await notifier.createGroup(
      CreateGroupParams(
        classId: widget.classId,
        name: name,
        description: description,
      ),
    );
    if (!context.mounted) return;
    if (group != null) {
      AppToast.success(context, 'Đã tạo nhóm "${group.name}"');
    } else {
      AppToast.error(context, 'Không thể tạo nhóm');
    }
  }

  void _showAutoGroupDialog(BuildContext context, {int studentCount = 0}) {
    // Cần ít nhất 2 học sinh để tạo nhóm
    if (studentCount > 0 && studentCount < 2) {
      AppToast.error(context, 'Cần ít nhất 2 học sinh để phân nhóm tự động');
      return;
    }

    final prefixCtrl = TextEditingController(text: 'Nhóm');
    final sliderMax = studentCount >= 2 ? studentCount.clamp(2, 10) : 10;
    // Gợi ý ~5 HS/nhóm, clamp vào [2, sliderMax]
    final suggested = studentCount > 0
        ? ((studentCount / 5).ceil()).clamp(2, sliderMax)
        : 4;
    int numGroups = suggested;
    final formKey = GlobalKey<FormState>();

    String distributionText(int n) {
      if (studentCount == 0) return 'Học sinh sẽ được chia ngẫu nhiên thành $n nhóm';
      final base = studentCount ~/ n;
      final remainder = studentCount % n;
      if (remainder == 0) {
        return '$n nhóm × $base học sinh';
      }
      return '$remainder nhóm ${base + 1} người + ${n - remainder} nhóm $base người';
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 20),
              const SizedBox(width: 8),
              const Flexible(child: Text('Phân nhóm tự động')),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (studentCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '$studentCount học sinh trong lớp',
                      style: DesignTypography.bodySmall.copyWith(
                          color: Colors.grey[600]),
                    ),
                  ),
                TextFormField(
                  controller: prefixCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tiền tố tên nhóm',
                    hintText: 'Nhóm, Team, Đội...',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nhập tiền tố' : null,
                ),
                const SizedBox(height: 16),
                Text('Số nhóm: $numGroups',
                    style: DesignTypography.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Slider(
                  value: numGroups.toDouble(),
                  min: 2,
                  max: sliderMax.toDouble(),
                  divisions: (sliderMax - 2).clamp(1, 8),
                  label: '$numGroups nhóm',
                  activeColor: DesignColors.primary,
                  onChanged: (v) => setDlgState(() => numGroups = v.round()),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: DesignColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: DesignColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: DesignColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          distributionText(numGroups),
                          style: DesignTypography.bodySmall.copyWith(
                              color: DesignColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.primary,
                  foregroundColor: Colors.white),
              icon: const Icon(Icons.auto_awesome_rounded, size: 16),
              label: const Text('Phân nhóm'),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                await _autoAssignGroups(
                    context, numGroups, prefixCtrl.text.trim());
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _autoAssignGroups(
    BuildContext context,
    int numGroups,
    String prefix,
  ) async {
    await ref.read(groupNotifierProvider.notifier).autoAssignGroups(
          classId: widget.classId,
          numGroups: numGroups,
          groupPrefix: prefix,
        );
    if (!context.mounted) return;
    /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — AppToast.success(context, ok
            ? 'Đã tạo $numGroups nhóm và phân công học sinh'
            : 'Không thể phân nhóm tự động'); */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */;
  }

  Future<bool> _confirmDelete(BuildContext context, String groupName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa nhóm?'),
        content: Text(
          'Nhóm "$groupName" và toàn bộ thành viên sẽ bị xóa. Bài tập đã giao cho nhóm này sẽ không bị ảnh hưởng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _deleteGroup(BuildContext context, Group group) async {
    final notifier = ref.read(groupNotifierProvider.notifier);
    final ok = await notifier.deleteGroup(group.id, widget.classId);
    if (!context.mounted) return;
    AppToast.success(context, ok ? 'Đã xóa nhóm "${group.name}"' : 'Không thể xóa nhóm');
  }
}
