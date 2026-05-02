import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/group.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/group_providers.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình xem nhóm cho học sinh
/// Hiển thị tất cả nhóm trong lớp và nhóm mà học sinh đang tham gia
class StudentGroupScreen extends ConsumerWidget {
  final String classId;
  final String className;

  const StudentGroupScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final studentId = ref.watch(currentUserIdProvider);
    final groupsAsync = ref.watch(groupsByClassProvider(classId));
    final countsAsync = ref.watch(groupMemberCountsProvider(classId));
    final counts = countsAsync.valueOrNull ?? {};

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
              'Nhóm học',
              style: DesignTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : DesignColors.textPrimary,
              ),
            ),
            Text(
              className,
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      body: groupsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerListTileLoading(itemCount: 4),
        ),
        error: (e, _) => _buildError(context, ref, e),
        data: (groups) {
          if (groups.isEmpty) return _buildEmpty(context, isDark);
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(groupsByClassProvider(classId));
              ref.invalidate(groupMemberCountsProvider(classId));
            },
            child: ListView(
              padding: const EdgeInsets.all(DesignSpacing.lg),
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(DesignSpacing.md),
                  decoration: BoxDecoration(
                    color: DesignColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(DesignRadius.md),
                    border: Border.all(
                      color: DesignColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 18, color: DesignColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Nhóm có viền xanh là nhóm bạn đang tham gia. Nhấn vào nhóm để xem danh sách thành viên.',
                          style: DesignTypography.bodySmall.copyWith(
                            color: DesignColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignSpacing.md),
                ...groups.map((g) => Padding(
                      padding: const EdgeInsets.only(bottom: DesignSpacing.sm),
                      child: _GroupCard(
                        group: g,
                        studentId: studentId ?? '',
                        isDark: isDark,
                        counts: counts,
                        classId: classId,
                        className: className,
                      ),
                    )),
              ],
            ),
          );
        },
      ),
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
            'Lớp chưa có nhóm nào',
            style: DesignTypography.titleMedium.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: DesignSpacing.xs),
          Text(
            'Giáo viên sẽ tạo nhóm và thêm bạn vào sau khi lớp bắt đầu học',
            textAlign: TextAlign.center,
            style: DesignTypography.bodySmall.copyWith(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
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
            onPressed: () => ref.invalidate(groupsByClassProvider(classId)),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

// ── Group card — navigate đến StudentGroupDetailScreen khi tap ────────────

class _GroupCard extends ConsumerWidget {
  final Group group;
  final String studentId;
  final bool isDark;
  final Map<String, int> counts;
  final String classId;
  final String className;

  const _GroupCard({
    required this.group,
    required this.studentId,
    required this.isDark,
    required this.counts,
    required this.classId,
    required this.className,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersWithProfilesProvider(group.id));

    final isMember = membersAsync.whenOrNull(
          data: (members) =>
              members.any((m) => m['student_id'] == studentId),
        ) ??
        false;

    final isLeader = membersAsync.whenOrNull(
          data: (members) => members.any((m) =>
              m['student_id'] == studentId && m['role'] == 'leader'),
        ) ??
        false;

    final memberCount = counts[group.id] ?? membersAsync.valueOrNull?.length ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: isMember
            ? DesignColors.primary.withValues(alpha: 0.06)
            : (isDark ? const Color(0xFF1A2632) : Colors.white),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(
          color: isMember
              ? DesignColors.primary.withValues(alpha: 0.4)
              : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
          width: isMember ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRoute.studentGroupDetail,
          pathParameters: {'classId': classId, 'groupId': group.id},
          extra: {'groupName': group.name, 'className': className},
        ),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(DesignSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isMember
                      ? DesignColors.primary.withValues(alpha: 0.15)
                      : (isDark ? Colors.grey[800] : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
                child: Icon(
                  Icons.group_work_rounded,
                  color: isMember ? DesignColors.primary : Colors.grey[500],
                  size: 20,
                ),
              ),
              const SizedBox(width: DesignSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.name,
                            style: DesignTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isMember
                                  ? DesignColors.primary
                                  : (isDark ? Colors.white : DesignColors.textPrimary),
                            ),
                          ),
                        ),
                        if (isMember)
                          Wrap(
                            spacing: 4,
                            children: [
                              _buildMyGroupBadge(),
                              if (isLeader) _buildLeaderBadge(),
                            ],
                          ),
                      ],
                    ),
                    Text(
                      '$memberCount thành viên',
                      style: DesignTypography.bodySmall.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: isDark ? Colors.grey[500] : Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyGroupBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: DesignColors.primary,
        borderRadius: BorderRadius.circular(DesignRadius.full),
      ),
      child: const Text(
        'Nhóm của bạn',
        style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLeaderBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber[600],
        borderRadius: BorderRadius.circular(DesignRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.star_rounded, size: 10, color: Colors.white),
          SizedBox(width: 2),
          Text(
            'Trưởng nhóm',
            style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
