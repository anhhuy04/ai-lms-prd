import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:ai_mls/presentation/providers/class_notifier.dart';
import 'package:ai_mls/presentation/views/class/teacher/widgets/drawers/class_settings_drawer.dart';
import 'package:ai_mls/widgets/drawers/action_end_drawer.dart';
import 'package:ai_mls/widgets/list/class_detail_assignment_list.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:ai_mls/widgets/search/dialogs/quick_search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Filter bài tập theo loại phân phối
enum AssignmentDistributionFilter {
  all('Tất cả', Icons.list_alt),
  byClass('Cả lớp', Icons.class_),
  byGroup('Theo nhóm', Icons.group),
  byIndividual('Cá nhân', Icons.person);

  final String label;
  final IconData icon;
  const AssignmentDistributionFilter(this.label, this.icon);
}

/// Màn hình chi tiết lớp học dành cho giáo viên
/// Thiết kế theo chuẩn Design System với đầy đủ thông tin lớp học
class TeacherClassDetailScreen extends ConsumerStatefulWidget {
  final String classId;
  final String className;
  final String semesterInfo;

  const TeacherClassDetailScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.semesterInfo,
  });

  @override
  ConsumerState<TeacherClassDetailScreen> createState() =>
      _TeacherClassDetailScreenState();
}

class _TeacherClassDetailScreenState
    extends ConsumerState<TeacherClassDetailScreen> {
  // State cho filter bài tập
  AssignmentDistributionFilter _selectedFilter =
      AssignmentDistributionFilter.all;

  @override
  void initState() {
    super.initState();
    // Load class details khi màn hình khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          ref
              .read(classNotifierProvider.notifier)
              .loadClassDetails(widget.classId)
              .catchError((error, stackTrace) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Lỗi khi tải thông tin lớp học: ${error.toString()}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              });
        } catch (_) {}
      }
    });
  }

  Future<void> _onRefresh() async {
    await ref
        .read(classNotifierProvider.notifier)
        .loadClassDetails(widget.classId);
  }

  @override
  Widget build(BuildContext context) {
    // Watch ClassNotifier state để rebuild khi state thay đổi
    // Khi loadClassDetails() gọi state = state, nó sẽ trigger rebuild
    ref.watch(classNotifierProvider);

    // Lấy notifier và các giá trị hiện tại
    final classNotifier = ref.read(classNotifierProvider.notifier);
    final selectedClass = classNotifier.selectedClass;
    final isDetailLoading = classNotifier.isDetailLoading;
    final detailErrorMessage = classNotifier.detailErrorMessage;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      endDrawer: selectedClass == null
          ? null
          : ActionEndDrawer(
              title: 'Tùy chọn Lớp học',
              child: ClassSettingsDrawer(classItem: selectedClass),
            ),
      body: Builder(
        builder: (context) {
          // Loading state
          if (isDetailLoading && selectedClass == null) {
            return SafeArea(child: const ShimmerClassDetailLoading());
          }

          // Error state
          if (detailErrorMessage != null && selectedClass == null) {
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      detailErrorMessage,
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _onRefresh(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (selectedClass == null) {
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text('Không tìm thấy lớp học', style: textTheme.bodyMedium),
                    if (detailErrorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        detailErrorMessage,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _onRefresh(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: Column(
                children: [
                  // Top App Bar
                  _buildAppBar(context, selectedClass),
                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Quick Stats & Actions
                          _buildQuickStatsSection(context),
                          const SizedBox(height: 16),
                          // Assignment List Section
                          _buildAssignmentListSection(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// App Bar với nút quay lại và thông tin lớp
  Widget _buildAppBar(BuildContext context, dynamic classItem) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                // Fallback: navigate về class list nếu không thể pop
                context.goNamed(AppRoute.teacherClassList);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 22,
                color: theme.iconTheme.color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classItem.name,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  classItem.subject ?? classItem.academicYear ?? '',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.search,
                  size: 22,
                  color: theme.iconTheme.color,
                ),
                onPressed: () {
                  _showSmartSearchDialog(context);
                },
              ),
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    size: 22,
                    color: theme.iconTheme.color,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Phần thống kê nhanh và hành động
  Widget _buildQuickStatsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Row
          _buildQuickStatsRow(context),
          const SizedBox(height: 16),
          // Create New Action
          _buildCreateAssignmentCard(context),
        ],
      ),
    );
  }

  /// Hàng thống kê nhanh
  Widget _buildQuickStatsRow(BuildContext context) {
    // Watch assignments provider để tính stats
    final assignmentsAsync = ref.watch(
      classDistributedAssignmentsProvider(widget.classId),
    );
    final approvedCount = 0; // TODO: từ getClassMembers

    // Tính số bài tập đang mở từ real data
    final openCount =
        assignmentsAsync.whenOrNull(
          data: (assignments) {
            final now = DateTime.now();
            return assignments.where((a) {
              final dueAt = a['distribution_due_at'] as String?;
              if (dueAt == null) return true; // Không có hạn → đang mở
              final due = DateTime.tryParse(dueAt);
              return due == null || due.isAfter(now);
            }).length;
          },
        ) ??
        0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context: context,
            icon: Icons.groups,
            iconColor: Theme.of(context).colorScheme.primary,
            value: '$approvedCount',
            label: 'Học sinh',
            onTap: () {
              context.goNamed(
                AppRoute.teacherStudentList,
                pathParameters: {'classId': widget.classId},
                extra: widget.className,
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context: context,
            icon: Icons.assignment,
            iconColor: Colors.orange,
            value: '$openCount',
            label: 'Bài tập đang mở',
            onTap: () {
              context.go(AppRoute.teacherAssignmentListPath);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context: context,
            icon: Icons.check_circle,
            iconColor: Colors.green,
            value: '0%',
            label: 'Tỷ lệ nộp bài',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Chức năng thống kê nộp bài đang được phát triển',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Card thống kê đơn lẻ
  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 28, color: iconColor),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card tạo bài tập mới
  Widget _buildCreateAssignmentCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary.withValues(alpha: 0.1), colorScheme.surface],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
            child: Icon(Icons.add_task, size: 22, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tạo bài tập mới',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Giao bài về nhà hoặc bài kiểm tra',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
            onPressed: () {
              // Navigate to assignment selection for distribution
              context.pushNamed(
                AppRoute.teacherAssignmentSelection,
                extra: {'selectedClassId': widget.classId},
              );
            },
            child: const Text('Tạo ngay'),
          ),
        ],
      ),
    );
  }

  /// Phần danh sách bài tập
  Widget _buildAssignmentListSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header danh sách
          _buildAssignmentListHeader(),
          const SizedBox(height: 8),
          // Filter chips
          _buildFilterChipBar(),
          const SizedBox(height: 12),
          // Danh sách bài tập
          _buildAssignmentList(context),
        ],
      ),
    );
  }

  /// Header danh sách bài tập
  Widget _buildAssignmentListHeader() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Danh sách bài tập',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            context.goNamed(AppRoute.teacherAssignmentList);
          },
          child: Text(
            'Xem tất cả',
            style: textTheme.labelMedium?.copyWith(color: colorScheme.primary),
          ),
        ),
      ],
    );
  }

  /// Filter chip bar cho loại phân phối bài tập
  Widget _buildFilterChipBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: AssignmentDistributionFilter.values.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter.icon,
                    size: 16,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(filter.label),
                ],
              ),
              labelStyle: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              selectedColor: colorScheme.primary,
              checkmarkColor: colorScheme.onPrimary,
              backgroundColor: colorScheme.surface,
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              showCheckmark: false,
              onSelected: (_) {
                setState(() => _selectedFilter = filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Danh sách bài tập — real data từ Supabase với shimmer loading
  Widget _buildAssignmentList(BuildContext context) {
    final assignmentsAsync = ref.watch(
      classDistributedAssignmentsProvider(widget.classId),
    );

    return assignmentsAsync.when(
      loading: () => const ShimmerAssignmentListLoading(),
      error: (error, _) => _buildAssignmentErrorState(context, error),
      data: (rawAssignments) {
        // Apply filter
        final assignments = _applyDistributionFilter(rawAssignments);

        return ClassDetailAssignmentList(
          assignments: assignments,
          viewMode: AssignmentViewMode.teacher,
          onItemTap: (assignment) {
            final distributionId = assignment['distribution_id'] as String?;
            if (distributionId == null) return;
            context.pushNamed(
              AppRoute.teacherAssignmentDetail,
              pathParameters: {
                'classId': widget.classId,
                'distributionId': distributionId,
              },
              extra: {
                'assignmentTitle': assignment['title'] as String? ?? '',
                'className': widget.className,
              },
            );
          },
        );
      },
    );
  }

  /// Filter assignments theo distribution_type
  List<Map<String, dynamic>> _applyDistributionFilter(
    List<Map<String, dynamic>> assignments,
  ) {
    if (_selectedFilter == AssignmentDistributionFilter.all) {
      return assignments;
    }
    final typeMap = {
      AssignmentDistributionFilter.byClass: 'class',
      AssignmentDistributionFilter.byGroup: 'group',
      AssignmentDistributionFilter.byIndividual: 'individual',
    };
    final targetType = typeMap[_selectedFilter];
    return assignments
        .where((a) => a['distribution_type'] == targetType)
        .toList();
  }

  /// Error state cho danh sách bài tập
  Widget _buildAssignmentErrorState(BuildContext context, Object error) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Không thể tải danh sách bài tập',
              style: TextStyle(fontSize: 14, color: colorScheme.error),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(
                  classDistributedAssignmentsProvider(widget.classId),
                );
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị Smart Search Dialog V2 — dùng real data từ provider
  void _showSmartSearchDialog(BuildContext context) {
    // Lấy real assignments data (nếu đã load)
    final assignmentsAsync = ref.read(
      classDistributedAssignmentsProvider(widget.classId),
    );
    final searchAssignments =
        assignmentsAsync.whenOrNull(
          data: (list) => list
              .map(
                (a) => <String, dynamic>{
                  'id': a['id'],
                  'title': a['title'] ?? 'Không có tiêu đề',
                  'subtitle':
                      '${widget.className} • ${a['distribution_due_at'] ?? 'Không hạn'}',
                },
              )
              .toList(),
        ) ??
        <Map<String, dynamic>>[];

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) => QuickSearchDialog(
        initialQuery: '',
        assignments: searchAssignments,
        students: const [], // TODO: kết nối student data sau
        classes: const [], // Đang ở trong chi tiết 1 lớp, không cần search lớp
        onItemSelected: (item) {
          if (dialogContext.canPop()) {
            dialogContext.pop();
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Đã chọn: ${item['title']}')));
        },
      ),
    );
  }
}
