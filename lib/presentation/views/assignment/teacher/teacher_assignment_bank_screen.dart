import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_card_config.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_empty_state.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_error_state.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_filter_sort_bar.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_list_view.dart';
import 'package:ai_mls/widgets/dialogs/assignment_filter_bottom_sheet.dart';
import 'package:ai_mls/widgets/dialogs/assignment_sort_bottom_sheet.dart';
import 'package:ai_mls/widgets/dialogs/delete_dialog.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Ngân hàng đề bài tập của giáo viên — màn hình chung cho cả "Bản nháp",
/// "Đã xuất bản" và "Tất cả". [initialStatus] do entry point quyết định
/// (thẻ "Đang tạo" → draft, thẻ "Đã tạo" → published). User có thể đổi
/// trạng thái trong bộ lọc.
class TeacherAssignmentBankScreen extends ConsumerStatefulWidget {
  final AssignmentStatusFilter initialStatus;

  const TeacherAssignmentBankScreen({
    super.key,
    this.initialStatus = AssignmentStatusFilter.all,
  });

  @override
  ConsumerState<TeacherAssignmentBankScreen> createState() =>
      _TeacherAssignmentBankScreenState();
}

class _TeacherAssignmentBankScreenState
    extends ConsumerState<TeacherAssignmentBankScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  AssignmentSortOption _sortOption = AssignmentSortOption.recentlyUpdated;
  late AssignmentFilter _filter;

  @override
  void initState() {
    super.initState();
    // Init filter từ entry point — chip status đầu tiên tự chọn theo thẻ
    // người dùng vừa bấm.
    _filter = AssignmentFilter(status: widget.initialStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAssignments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshAssignments() async {
    if (mounted) setState(() {});
  }

  /// Tiêu đề động theo trạng thái đang lọc.
  String get _screenTitle {
    switch (_filter.status) {
      case AssignmentStatusFilter.draft:
        return 'Kho bài tập nháp';
      case AssignmentStatusFilter.published:
        return 'Kho bài tập đã tạo';
      case AssignmentStatusFilter.all:
        return 'Ngân hàng bài tập';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teacherId = ref.watch(currentUserIdProvider);

    if (teacherId == null) {
      return Scaffold(
        backgroundColor:
            isDark ? DesignColors.moonDark : DesignColors.moonLight,
        appBar: _buildAppBar(isDark),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: DesignIcons.xxlSize, color: DesignColors.error),
              const SizedBox(height: DesignSpacing.lg),
              Text(
                'Người dùng chưa đăng nhập',
                style: DesignTypography.titleMedium.copyWith(
                  color:
                      isDark ? DesignColors.white : DesignColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? DesignColors.moonDark : DesignColors.moonLight,
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          AssignmentFilterSortBar(
            searchController: _searchController,
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            currentSort: _sortOption,
            onSortChanged: (s) => setState(() => _sortOption = s),
            currentFilter: _filter,
            onFilterChanged: (f) => setState(() => _filter = f),
            listLabel: _filter.status.label,
          ),
          Expanded(
            child: FutureBuilder<List<Assignment>>(
              future: ref
                  .read(assignmentRepositoryProvider)
                  .getAssignmentsByTeacher(teacherId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(DesignSpacing.lg),
                    child: ShimmerLoading(),
                  );
                }
                if (snapshot.hasError) {
                  return AssignmentErrorState(
                    error: snapshot.error.toString(),
                    onRetry: _refreshAssignments,
                  );
                }

                final all = snapshot.data ?? [];
                // Search theo title/description (case-insensitive)
                var list = all;
                if (_searchQuery.trim().isNotEmpty) {
                  final q = _searchQuery.trim().toLowerCase();
                  list = list
                      .where((a) =>
                          a.title.toLowerCase().contains(q) ||
                          (a.description?.toLowerCase().contains(q) ?? false))
                      .toList();
                }
                // Filter (status + tiêu chí phụ)
                list = applyAssignmentFilter(list, _filter);
                // Sort
                list = sortAssignments(list, _sortOption);

                if (list.isEmpty) {
                  return _emptyOrNoMatch(_searchQuery, _filter);
                }

                // Per-card config — đặc biệt cần ở mode "Tất cả" vì list
                // trộn cả bài nháp lẫn đã xuất bản. Builder trả config theo
                // chính trạng thái của từng item, không phụ thuộc filter.
                AssignmentBadgeConfig badgeFor(Assignment a) => a.isPublished
                    ? AssignmentBadgeConfig.published
                    : AssignmentBadgeConfig.draft;
                AssignmentMetadataConfig metaFor(Assignment a) => a.isPublished
                    ? AssignmentMetadataConfig.published
                    : AssignmentMetadataConfig.draft;

                return AssignmentListView(
                  assignments: list,
                  // Default config (fallback) — builder dưới đây sẽ thắng.
                  badgeConfig: AssignmentBadgeConfig.draft,
                  metadataConfig: AssignmentMetadataConfig.draft,
                  badgeConfigBuilder: badgeFor,
                  metadataConfigBuilder: metaFor,
                  actionBuilder: (assignment) => AssignmentActionConfig(
                    label:
                        assignment.isPublished ? 'Xem chi tiết' : 'Chỉnh sửa',
                    icon: assignment.isPublished
                        ? Icons.visibility_outlined
                        : Icons.edit_outlined,
                    onPressed: () async {
                      await context.pushNamed(
                        AppRoute.teacherCreateAssignment,
                        extra: {'assignmentId': assignment.id},
                      );
                      if (!context.mounted) return;
                      await _refreshAssignments();
                    },
                  ),
                  emptyState:
                      _filter.status == AssignmentStatusFilter.published
                          ? AssignmentEmptyState.published()
                          : AssignmentEmptyState.draft(),
                  onRefresh: _refreshAssignments,
                  onTap: (assignment) async {
                    await context.pushNamed(
                      AppRoute.teacherCreateAssignment,
                      extra: {'assignmentId': assignment.id},
                    );
                    if (!context.mounted) return;
                    await _refreshAssignments();
                  },
                  // Chỉ cho swipe-xoá item là bài nháp.
                  onDelete: (assignment) => _confirmAndDelete(assignment),
                  canDelete: (assignment) => !assignment.isPublished,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _filter.status == AssignmentStatusFilter.published
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await context.pushNamed(AppRoute.teacherCreateAssignment);
                if (!context.mounted) return;
                await _refreshAssignments();
              },
              backgroundColor: DesignColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add, size: 24),
              label: Text(
                'Tạo bài mới',
                style: DesignTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: DesignIcons.smSize,
          color:
              isDark ? DesignColors.textTertiary : DesignColors.textSecondary,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        _screenTitle,
        style: TextStyle(
          fontSize: DesignTypography.titleLargeSize,
          fontWeight: FontWeight.bold,
          color: isDark ? DesignColors.white : DesignColors.textPrimary,
        ),
      ),
      backgroundColor: isDark ? const Color(0xFF1A2632) : DesignColors.white,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    );
  }

  Future<bool> _confirmAndDelete(Assignment assignment) async {
    final confirmed = await DeleteDialog.showSimple(
      context: context,
      title: 'Xóa bài tập nháp',
      message: 'Bạn có chắc chắn muốn xóa bài tập "${assignment.title}"?',
      confirmText: 'Xóa',
      cancelText: 'Hủy',
      barrierDismissible: true,
    );
    if (confirmed != true) return false;
    try {
      await ref
          .read(assignmentRepositoryProvider)
          .deleteAssignment(assignment.id);
      if (mounted) {
        AppToast.success(context, 'Đã xóa bài tập "${assignment.title}"');
      }
      await _refreshAssignments();
      return true;
    } catch (e) {
      if (mounted) {
        /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — AppToast.error(context, e.toString(); */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */;
      }
      return false;
    }
  }

  /// Empty state phân biệt: list rỗng tự nhiên vs filter/search rỗng.
  Widget _emptyOrNoMatch(String query, AssignmentFilter filter) {
    final isFiltering = query.trim().isNotEmpty || !filter.isEmpty;
    if (!isFiltering) {
      return filter.status == AssignmentStatusFilter.draft
          ? AssignmentEmptyState.draft()
          : AssignmentEmptyState.published();
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: DesignSpacing.md),
            const Text(
              'Không tìm thấy bài tập phù hợp',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: DesignSpacing.sm),
            Text(
              'Thử thay đổi từ khóa hoặc bộ lọc',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
