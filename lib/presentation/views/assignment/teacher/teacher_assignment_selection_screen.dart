import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_selection_card.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TeacherAssignmentSelectionScreen extends ConsumerStatefulWidget {
  final bool isSelectionOnly;
  final List<String> initialSelectedIds;
  final String? selectedClassId;

  const TeacherAssignmentSelectionScreen({
    super.key,
    this.isSelectionOnly = false,
    this.initialSelectedIds = const [],
    this.selectedClassId,
  });

  @override
  ConsumerState<TeacherAssignmentSelectionScreen> createState() =>
      _TeacherAssignmentSelectionScreenState();
}

class _TeacherAssignmentSelectionScreenState
    extends ConsumerState<TeacherAssignmentSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = [
    'Tất cả',
    'Toán',
    'Ngữ Văn',
    'Tiếng Anh',
    'Vật Lý',
    'Hóa học',
  ];
  String _selectedFilter = 'Tất cả';
  String _searchQuery = '';

  // State to hold IDs of checked assignments
  final Set<String> _selectedAssignmentIds = {};

  // State để lưu data đã load
  List<Assignment>? _cachedAssignments;
  bool _isLoadingInitial = true;

  // Track loading state cho filter và search
  bool _isFiltering = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _selectedAssignmentIds.addAll(widget.initialSelectedIds);
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    final teacherId = ref.read(currentUserIdProvider);
    if (teacherId == null) {
      setState(() {
        _isLoadingInitial = false;
        _isFiltering = false;
        _isSearching = false;
      });
      return;
    }

    try {
      final assignments = await ref
          .read(assignmentRepositoryProvider)
          .getAssignmentsByTeacher(teacherId);
      setState(() {
        _cachedAssignments = assignments;
        _isLoadingInitial = false;
        _isFiltering = false;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingInitial = false;
        _isFiltering = false;
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onAssignmentToggled(String id, bool? isSelected) {
    setState(() {
      if (isSelected == true) {
        _selectedAssignmentIds.add(id);
      } else {
        _selectedAssignmentIds.remove(id);
      }
    });
  }

  void _onProceedToDistribute() {
    if (_selectedAssignmentIds.isEmpty) return;

    if (widget.isSelectionOnly) {
      context.pop(_selectedAssignmentIds.toList());
      return;
    }

    final joinedIds = _selectedAssignmentIds.join(',');

    context.pushNamed(
      AppRoute.teacherDistributeAssignment,
      extra: {
        'assignmentId': joinedIds,
        if (widget.selectedClassId != null)
          'selectedClassId': widget.selectedClassId,
      },
    );
  }

  /// Lọc assignments dựa trên search và filter - KHÔNG gọi API
  List<Assignment> _filterAssignments(List<Assignment> assignments) {
    var filteredList = assignments.where((a) => a.isPublished).toList();

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredList = filteredList
          .where(
            (a) =>
                a.title.toLowerCase().contains(query) ||
                (a.description?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    // Apply subject filter
    if (_selectedFilter != 'Tất cả') {
      filteredList = filteredList
          .where(
            (a) =>
                a.title.toLowerCase().contains(_selectedFilter.toLowerCase()),
          )
          .toList();
    }

    // Sort by date
    filteredList.sort((a, b) {
      final aTime = a.updatedAt ?? a.createdAt ?? DateTime(1970);
      final bTime = b.updatedAt ?? b.createdAt ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tMain = isDark ? Colors.white : const Color(0xFF111418);
    final teacherId = ref.watch(currentUserIdProvider);

    if (teacherId == null) {
      return _buildScaffold(
        isDark: isDark,
        tMain: tMain,
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
      tMain: tMain,
      body: _buildContent(isDark, tMain),
    );
  }

  Widget _buildContent(bool isDark, Color tMain) {
    // Loading lần đầu HOẶC đang filter/search - hiển thị shimmer
    if (_isLoadingInitial || _isFiltering || _isSearching) {
      return Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: const ShimmerLoading(),
      );
    }

    // Đã có data - lọc trên cache KHÔNG load lại
    if (_cachedAssignments != null) {
      final filteredList = _filterAssignments(_cachedAssignments!);

      if (filteredList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: isDark ? Colors.grey[600] : Colors.grey[300],
              ),
              const SizedBox(height: DesignSpacing.md),
              Text(
                'Không tìm thấy bài tập nào',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.all(DesignSpacing.lg),
        itemCount: filteredList.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: DesignSpacing.md),
        itemBuilder: (context, index) {
          final assignment = filteredList[index];
          final isSelected = _selectedAssignmentIds.contains(assignment.id);
          return AssignmentSelectionCard(
            assignment: assignment,
            isSelected: isSelected,
            onChanged: (val) => _onAssignmentToggled(assignment.id, val),
          );
        },
      );
    }

    // Lỗi - hiển thị empty state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: DesignSpacing.md),
          Text(
            'Không thể tải dữ liệu',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: DesignSpacing.md),
          ElevatedButton(
            onPressed: _loadAssignments,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildScaffold({
    required bool isDark,
    required Color tMain,
    required Widget body,
  }) {
    return Scaffold(
      backgroundColor: isDark ? DesignColors.moonDark : DesignColors.moonLight,
      appBar: AppBar(
        title: Text(
          'Chọn bài tập',
          style: TextStyle(
            fontSize: DesignTypography.titleLargeSize,
            fontWeight: FontWeight.bold,
            color: tMain,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1A2632) : DesignColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
      ),
      body: Column(
        children: [
          // Header + Search + Filters - HIỆN NGAY, không load
          Container(
            padding: EdgeInsets.all(DesignSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2632) : DesignColors.white,
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
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
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? DesignColors.white
                                : DesignColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm bài tập...',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[500],
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
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
                            color: isDark ? Colors.grey[400] : Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignSpacing.md),
                // Filters Scroll
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = filter == _selectedFilter;
                      return GestureDetector(
                        onTap: () {
                          // Load lại để hiển thị shimmer
                          setState(() {
                            _selectedFilter = filter;
                            _isFiltering = true;
                          });
                          _loadAssignments();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? DesignColors.primary
                                : (isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[100]),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[700]),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // List bài tập - KHÔNG load lại khi filter/search thay đổi
          Expanded(child: body),
        ],
      ),
      // Bottom Bar
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(DesignSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2632) : DesignColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đã chọn',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${_selectedAssignmentIds.length} bài tập',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: tMain,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _selectedAssignmentIds.isEmpty
                    ? null
                    : _onProceedToDistribute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.primary,
                  disabledBackgroundColor: DesignColors.primary.withValues(
                    alpha: 0.5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Giao bài tập',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
