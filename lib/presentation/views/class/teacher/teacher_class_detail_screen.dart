import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:ai_mls/presentation/providers/class_notifier.dart';
import 'package:ai_mls/presentation/views/class/teacher/widgets/drawers/class_settings_drawer.dart';
import 'package:ai_mls/widgets/drawers/action_end_drawer.dart';
import 'package:ai_mls/widgets/list/class_detail_assignment_list.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:ai_mls/widgets/search/dialogs/quick_search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';
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

/// Sắp xếp danh sách bài tập
enum AssignmentSortOption {
  newest('Mới nhất', Icons.access_time),
  oldest('Cũ nhất', Icons.history),
  deadlineSoonest('Deadline gần nhất', Icons.event_available),
  titleAZ('Tên A→Z', Icons.sort_by_alpha);

  final String label;
  final IconData icon;
  const AssignmentSortOption(this.label, this.icon);
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
  // State cho filter và sort bài tập
  AssignmentDistributionFilter _selectedFilter =
      AssignmentDistributionFilter.all;
  AssignmentSortOption _selectedSort = AssignmentSortOption.newest;

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
                  AppToast.error(context, 'Lỗi khi tải thông tin lớp học: ${error.toString()}');
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
    final assignmentsAsync = ref.watch(
      classDistributedAssignmentsProvider(widget.classId),
    );
    final isLoading = assignmentsAsync.isLoading;
    final assignments = assignmentsAsync.valueOrNull ?? [];

    // Số bài đang mở
    final now = DateTime.now();
    final openCount = assignments.where((a) {
      final dueAt = a['distribution_due_at'] as String?;
      if (dueAt == null) return true;
      final due = DateTime.tryParse(dueAt);
      return due == null || due.isAfter(now);
    }).length;

    // Số học sinh: lấy total_students từ distribution đầu tiên type 'class'
    int studentCount = 0;
    for (final a in assignments) {
      if ((a['distribution_type'] as String?) == 'class') {
        final n = a['total_students'] as int?;
        if (n != null && n > 0) { studentCount = n; break; }
      }
    }
    // Fallback: lấy max total_students nếu không có class-type
    if (studentCount == 0) {
      for (final a in assignments) {
        final n = a['total_students'] as int? ?? 0;
        if (n > studentCount) studentCount = n;
      }
    }

    // Tỷ lệ nộp bài: tổng submission / tổng có thể nộp
    int totalPossible = 0;
    int totalSubmitted = 0;
    for (final a in assignments) {
      totalPossible += a['total_students'] as int? ?? 0;
      totalSubmitted += a['submission_count'] as int? ?? 0;
    }
    final rateStr = isLoading
        ? '-'
        : totalPossible > 0
            ? '${(totalSubmitted / totalPossible * 100).toStringAsFixed(0)}%'
            : '0%';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context: context,
            icon: Icons.groups,
            iconColor: Theme.of(context).colorScheme.primary,
            value: isLoading ? '-' : '$studentCount',
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
            value: isLoading ? '-' : '$openCount',
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
            value: rateStr,
            label: 'Tỷ lệ nộp bài',
            onTap: () {},
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
          // Filter & sort bar
          _buildFilterSortBar(),
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

  /// Hàng 2 nút filter + sort mở bottom sheet
  Widget _buildFilterSortBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filterIsActive = _selectedFilter != AssignmentDistributionFilter.all;
    final sortIsActive = _selectedSort != AssignmentSortOption.newest;
    
    return Row(
      children: [
        _buildChipButton(
          icon: Icons.filter_list,
          label: filterIsActive ? _selectedFilter.label : 'Phân loại',
          isActive: filterIsActive,
          isDark: isDark,
          onTap: () => _showFilterSheet(context),
        ),
        const SizedBox(width: 12),
        _buildChipButton(
          icon: Icons.sort,
          label: sortIsActive ? _selectedSort.label : 'Sắp xếp',
          isActive: sortIsActive,
          isDark: isDark,
          onTap: () => _showSortSheet(context),
        ),
      ],
    );
  }

  Widget _buildChipButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final primaryColor = DesignColors.primary;
    final bgColor = isActive 
        ? primaryColor.withValues(alpha: 0.1) 
        : (isDark ? DesignColors.moonMedium : Colors.white);
    final borderColor = isActive
        ? primaryColor
        : (isDark ? DesignColors.moonMedium : DesignColors.moonLight);
    final textColor = isActive
        ? primaryColor
        : (isDark ? Colors.white70 : DesignColors.textSecondary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignRadius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(DesignRadius.full),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: isActive ? [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: DesignTypography.bodySmall.copyWith(
                  color: textColor,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              if (isActive)
                Icon(Icons.check_circle, size: 14, color: primaryColor)
              else
                Icon(Icons.keyboard_arrow_down, size: 16, color: textColor),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom sheet chọn phân loại
  void _showFilterSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Phân loại bài tập',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ...AssignmentDistributionFilter.values.map((f) {
                    final selected = _selectedFilter == f;
                    return ListTile(
                      leading: Icon(f.icon,
                          color: selected ? colorScheme.primary : null),
                      title: Text(f.label),
                      trailing: selected
                          ? Icon(Icons.check, color: colorScheme.primary)
                          : null,
                      onTap: () {
                        setState(() => _selectedFilter = f);
                        Navigator.of(ctx).pop();
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Bottom sheet chọn sắp xếp
  void _showSortSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sắp xếp bài tập',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ...AssignmentSortOption.values.map((s) {
                    final selected = _selectedSort == s;
                    return ListTile(
                      leading: Icon(s.icon,
                          color: selected ? colorScheme.primary : null),
                      title: Text(s.label),
                      trailing: selected
                          ? Icon(Icons.check, color: colorScheme.primary)
                          : null,
                      onTap: () {
                        setState(() => _selectedSort = s);
                        Navigator.of(ctx).pop();
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
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
        final assignments = _applyFilterAndSort(rawAssignments);

        return ClassDetailAssignmentList(
          assignments: assignments,
          viewMode: AssignmentViewMode.teacher,
          onItemTap: (assignment) {
            final distributionId = assignment['assignment_distribution_id'] as String?;
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

  /// Filter + sort assignments
  List<Map<String, dynamic>> _applyFilterAndSort(
    List<Map<String, dynamic>> assignments,
  ) {
    // Filter theo distribution_type
    List<Map<String, dynamic>> result;
    if (_selectedFilter == AssignmentDistributionFilter.all) {
      result = List.of(assignments);
    } else {
      const typeMap = {
        AssignmentDistributionFilter.byClass: 'class',
        AssignmentDistributionFilter.byGroup: 'group',
        AssignmentDistributionFilter.byIndividual: 'individual',
      };
      final targetType = typeMap[_selectedFilter];
      result = assignments
          .where((a) => a['distribution_type'] == targetType)
          .toList();
    }

    // Sort
    switch (_selectedSort) {
      case AssignmentSortOption.newest:
        result.sort((a, b) {
          final da = DateTime.tryParse(a['created_at'] as String? ?? '') ??
              DateTime(2000);
          final db = DateTime.tryParse(b['created_at'] as String? ?? '') ??
              DateTime(2000);
          return db.compareTo(da);
        });
      case AssignmentSortOption.oldest:
        result.sort((a, b) {
          final da = DateTime.tryParse(a['created_at'] as String? ?? '') ??
              DateTime(2000);
          final db = DateTime.tryParse(b['created_at'] as String? ?? '') ??
              DateTime(2000);
          return da.compareTo(db);
        });
      case AssignmentSortOption.deadlineSoonest:
        result.sort((a, b) {
          final da = DateTime.tryParse(a['due_date'] as String? ?? '') ??
              DateTime(9999);
          final db = DateTime.tryParse(b['due_date'] as String? ?? '') ??
              DateTime(9999);
          return da.compareTo(db);
        });
      case AssignmentSortOption.titleAZ:
        result.sort((a, b) {
          final ta = (a['title'] as String? ?? '').toLowerCase();
          final tb = (b['title'] as String? ?? '').toLowerCase();
          return ta.compareTo(tb);
        });
    }

    return result;
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
          AppToast.info(context, "Đã chọn: ${item['title'] ?? ''}");
        },
      ),
    );
  }
}
