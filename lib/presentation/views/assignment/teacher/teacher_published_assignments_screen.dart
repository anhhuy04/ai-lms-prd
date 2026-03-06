import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_card_config.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_empty_state.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_error_state.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_list_view.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình kho bài tập đã tạo (published assignments)
/// Hiển thị danh sách các bài tập đã được publish (is_published = true)
class TeacherPublishedAssignmentsScreen extends ConsumerStatefulWidget {
  const TeacherPublishedAssignmentsScreen({super.key});

  @override
  ConsumerState<TeacherPublishedAssignmentsScreen> createState() =>
      _TeacherPublishedAssignmentsScreenState();
}

class _TeacherPublishedAssignmentsScreenState
    extends ConsumerState<TeacherPublishedAssignmentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshAssignments() async {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teacherId = ref.watch(currentUserIdProvider);

    if (teacherId == null) {
      return _buildScaffold(
        isDark: isDark,
        teacherId: null,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: DesignIcons.xxlSize,
                color: DesignColors.error,
              ),
              const SizedBox(height: DesignSpacing.lg),
              Text(
                'Người dùng chưa đăng nhập',
                style: DesignTypography.titleMedium.copyWith(
                  color: isDark ? DesignColors.white : DesignColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildScaffold(
      isDark: isDark,
      teacherId: teacherId,
      body: _AssignmentListSection(
        teacherId: teacherId,
        searchQuery: _searchQuery,
        onRefresh: _refreshAssignments,
        isDark: isDark,
      ),
    );
  }

  Widget _buildScaffold({
    required bool isDark,
    required String? teacherId,
    required Widget body,
  }) {
    return Scaffold(
      backgroundColor: isDark ? DesignColors.moonDark : DesignColors.moonLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: DesignIcons.smSize,
            color: isDark
                ? DesignColors.textTertiary
                : DesignColors.textSecondary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Kho bài tập đã tạo',
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              size: DesignIcons.mdSize,
              color: isDark
                  ? DesignColors.textTertiary
                  : DesignColors.textSecondary,
            ),
            onPressed: () => _showSearchBottomSheet(isDark),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header với search - KHÔNG bị load cùng
          Container(
            padding: EdgeInsets.all(DesignSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2632) : DesignColors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[800]!.withValues(alpha: 0.5)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: 20,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'Tìm kiếm bài tập...'
                                : _searchQuery,
                            style: TextStyle(
                              fontSize: 14,
                              color: _searchQuery.isEmpty
                                  ? (isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[500])
                                  : (isDark
                                        ? DesignColors.white
                                        : DesignColors.textPrimary),
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // List bài tập - CHỈ CÓ PHẦN NÀY ĐƯỢC LOAD
          Expanded(child: body),
        ],
      ),
    );
  }

  void _showSearchBottomSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2632) : DesignColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(DesignRadius.lg * 2),
            topRight: Radius.circular(DesignRadius.lg * 2),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(DesignSpacing.lg),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: TextStyle(
                        color: isDark
                            ? DesignColors.white
                            : DesignColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm bài tập...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                        ),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Đóng',
                      style: TextStyle(
                        color: DesignColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Kết quả tìm kiếm
            Expanded(
              child: _searchQuery.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: isDark ? Colors.grey[600] : Colors.grey[300],
                          ),
                          const SizedBox(height: DesignSpacing.md),
                          Text(
                            'Nhập từ khóa để tìm kiếm',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : _AssignmentListSection(
                      teacherId: ref.read(currentUserIdProvider) ?? '',
                      searchQuery: _searchQuery,
                      onRefresh: _refreshAssignments,
                      isDark: isDark,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section chỉ load danh sách bài tập (có shimmer)
class _AssignmentListSection extends ConsumerStatefulWidget {
  final String teacherId;
  final String searchQuery;
  final VoidCallback onRefresh;
  final bool isDark;

  const _AssignmentListSection({
    required this.teacherId,
    required this.searchQuery,
    required this.onRefresh,
    required this.isDark,
  });

  @override
  ConsumerState<_AssignmentListSection> createState() =>
      _AssignmentListSectionState();
}

class _AssignmentListSectionState
    extends ConsumerState<_AssignmentListSection> {
  Future<List<Assignment>>? _assignmentsFuture;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  @override
  void didUpdateWidget(covariant _AssignmentListSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.teacherId != oldWidget.teacherId) {
      _loadAssignments();
    }
  }

  void _loadAssignments() {
    _assignmentsFuture = ref
        .read(assignmentRepositoryProvider)
        .getAssignmentsByTeacher(widget.teacherId);
  }

  void _handleRefresh() {
    setState(() {
      _loadAssignments();
    });
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Assignment>>(
      future: _assignmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Chỉ shimmer cho phần list, không load header
          return Padding(
            padding: const EdgeInsets.all(DesignSpacing.lg),
            child: const ShimmerLoading(),
          );
        }

        if (snapshot.hasError) {
          return AssignmentErrorState(
            error: snapshot.error.toString(),
            onRetry: _handleRefresh,
          );
        }

        final allAssignments = snapshot.data ?? [];

        // Filter published assignments
        var publishedAssignments = allAssignments
            .where((a) => a.isPublished)
            .toList();

        // Filter theo search query nếu có
        if (widget.searchQuery.isNotEmpty) {
          final query = widget.searchQuery.toLowerCase();
          publishedAssignments = publishedAssignments.where((a) {
            return a.title.toLowerCase().contains(query) ||
                (a.description?.toLowerCase().contains(query) ?? false);
          }).toList();
        }

        // Sort by date descending
        publishedAssignments.sort((a, b) {
          final aTime = a.updatedAt ?? a.createdAt ?? DateTime(1970);
          final bTime = b.updatedAt ?? b.createdAt ?? DateTime(1970);
          return bTime.compareTo(aTime);
        });

        if (publishedAssignments.isEmpty) {
          return widget.searchQuery.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: widget.isDark
                            ? Colors.grey[600]
                            : Colors.grey[300],
                      ),
                      const SizedBox(height: DesignSpacing.md),
                      Text(
                        'Không tìm thấy bài tập nào',
                        style: TextStyle(
                          color: widget.isDark
                              ? Colors.grey[400]
                              : Colors.grey[500],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : AssignmentEmptyState.published();
        }

        return AssignmentListView(
          assignments: publishedAssignments,
          badgeConfig: AssignmentBadgeConfig.published,
          actionBuilder: (assignment) => AssignmentActionConfig(
            label: 'Xem chi tiết',
            icon: Icons.visibility_outlined,
            onPressed: () async {
              await context.pushNamed(
                AppRoute.teacherCreateAssignment,
                extra: {'assignmentId': assignment.id},
              );
              if (!context.mounted) return;
              _handleRefresh();
            },
          ),
          metadataConfig: AssignmentMetadataConfig.published,
          emptyState: AssignmentEmptyState.published(),
          onRefresh: _handleRefresh,
          onTap: (assignment) async {
            await context.pushNamed(
              AppRoute.teacherCreateAssignment,
              extra: {'assignmentId': assignment.id},
            );
            if (!context.mounted) return;
            _handleRefresh();
          },
        );
      },
    );
  }
}
