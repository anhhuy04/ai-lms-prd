import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:ai_mls/presentation/providers/student_assignment_providers.dart';
import 'package:ai_mls/widgets/list_item/assignment/class_detail_assignment_list_item.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình danh sách bài tập
/// Hỗ trợ cả chế độ giáo viên và học sinh
class AssignmentListScreen extends ConsumerStatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  ConsumerState<AssignmentListScreen> createState() =>
      _AssignmentListScreenState();
}

class _AssignmentListScreenState extends ConsumerState<AssignmentListScreen> {
  // Pagination state
  static const int _pageSize = 10;
  int _currentPageTeacher = 0;
  int _currentPageStudent = 0;
  List<Assignment> _displayedTeacherAssignments = [];
  List<Map<String, dynamic>> _displayedStudentAssignments = [];
  bool _isLoadingMore = false;
  final ScrollController _scrollControllerTeacher = ScrollController();
  final ScrollController _scrollControllerStudent = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load dữ liệu khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAssignments();
    });
  }

  @override
  void dispose() {
    _scrollControllerTeacher.dispose();
    _scrollControllerStudent.dispose();
    super.dispose();
  }

  Future<void> _loadAssignments() async {
    // Data sẽ được load thông qua provider
    // Chỉ cần trigger refresh nếu cần
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final profile = authState.value;

    if (authState.isLoading) {
      return const Scaffold(
        body: ShimmerLoading(),
      );
    }

    if (authState.hasError || profile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Danh sách bài tập'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: DesignColors.error),
              const SizedBox(height: 16),
              Text(
                'Không thể tải thông tin người dùng',
                style: TextStyle(
                  fontSize: DesignTypography.bodyLargeSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(authNotifierProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final userRole = profile.role;

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        title: const Text('Danh sách bài tập'),
        backgroundColor: DesignColors.white,
        elevation: 0,
        actions: [
          if (userRole == 'student')
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Lịch sử nộp bài',
              onPressed: () => context.pushNamed(AppRoute.studentSubmissionHistory),
            ),
        ],
      ),
      body: SafeArea(
        child: userRole == 'teacher'
            ? _buildTeacherView(profile.id)
            : _buildStudentView(profile.id),
      ),
    );
  }

  /// Xây dựng view cho giáo viên
  Widget _buildTeacherView(String teacherId) {
    return FutureBuilder<List<Assignment>>(
      future: ref.read(assignmentRepositoryProvider).getAssignmentsByTeacher(teacherId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerLoading();
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: DesignColors.error),
                const SizedBox(height: 16),
                Text(
                  'Lỗi khi tải danh sách bài tập: ${snapshot.error}',
                  style: TextStyle(fontSize: DesignTypography.bodyLargeSize),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _loadAssignments();
                    });
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final assignments = snapshot.data ?? [];

        if (assignments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: DesignColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có bài tập nào',
                  style: TextStyle(
                    fontSize: DesignTypography.bodyLargeSize,
                    color: DesignColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tạo bài tập mới từ Hub',
                  style: TextStyle(
                    fontSize: DesignTypography.bodyMediumSize,
                    color: DesignColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.goNamed(AppRoute.teacherAssignmentHub);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Đi đến Assignment Hub'),
                ),
              ],
            ),
          );
        }

        // Initialize pagination if needed
        if (_displayedTeacherAssignments.isEmpty && assignments.isNotEmpty) {
          final endIndex = _pageSize.clamp(0, assignments.length);
          _displayedTeacherAssignments = assignments.take(endIndex).toList();
          _currentPageTeacher = 0;
        }

        final hasMore = _displayedTeacherAssignments.length < assignments.length;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _loadAssignments();
              _displayedTeacherAssignments = [];
              _currentPageTeacher = 0;
            });
          },
          child: ListView.builder(
            controller: _scrollControllerTeacher,
            padding: const EdgeInsets.all(DesignSpacing.md),
            itemCount: _displayedTeacherAssignments.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Hiển thị loading indicator ở cuối list
              if (index == _displayedTeacherAssignments.length) {
                // Load more
                if (!_isLoadingMore && hasMore) {
                  _loadMoreTeacher(assignments);
                }
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final assignment = _displayedTeacherAssignments[index];
              return _buildAssignmentCard(assignment, isTeacher: true);
            },
          ),
        );
      },
    );
  }

  void _loadMoreTeacher(List<Assignment> allAssignments) {
    if (_isLoadingMore) return;

    final totalItems = allAssignments.length;
    final currentDisplayed = (_currentPageTeacher + 1) * _pageSize;

    if (currentDisplayed >= totalItems) return;

    _isLoadingMore = true;
    _currentPageTeacher++;

    final endIndex = ((_currentPageTeacher + 1) * _pageSize).clamp(0, totalItems);
    _displayedTeacherAssignments = allAssignments.take(endIndex).toList();
    _isLoadingMore = false;

    setState(() {});
  }

  /// Xây dựng view cho học sinh
  Widget _buildStudentView(String studentId) {
    // Sử dụng studentAssignmentListProvider để lấy danh sách bài tập
    final assignmentsAsync = ref.watch(studentAssignmentListProvider);

    return assignmentsAsync.when(
      loading: () => const ShimmerLoading(),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: DesignColors.error),
            const SizedBox(height: 16),
            Text(
              'Lỗi khi tải danh sách bài tập',
              style: TextStyle(
                fontSize: DesignTypography.bodyLargeSize,
                color: DesignColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.refresh(studentAssignmentListProvider),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
      data: (assignments) {
        if (assignments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: DesignColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có bài tập nào',
                  style: TextStyle(
                    fontSize: 16,
                    color: DesignColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bài tập sẽ hiển thị khi được giao',
                  style: TextStyle(
                    fontSize: DesignTypography.bodyMediumSize,
                    color: DesignColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.goNamed(AppRoute.studentClassList);
                  },
                  icon: const Icon(Icons.class_outlined),
                  label: const Text('Xem lớp học'),
                ),
              ],
            ),
          );
        }

        // Initialize pagination if needed
        if (_displayedStudentAssignments.isEmpty && assignments.isNotEmpty) {
          final endIndex = _pageSize.clamp(0, assignments.length);
          _displayedStudentAssignments = assignments.take(endIndex).toList();
          _currentPageStudent = 0;
        }

        final hasMore = _displayedStudentAssignments.length < assignments.length;

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(studentAssignmentListProvider);
            setState(() {
              _displayedStudentAssignments = [];
              _currentPageStudent = 0;
            });
          },
          child: ListView.builder(
            controller: _scrollControllerStudent,
            padding: const EdgeInsets.all(DesignSpacing.md),
            itemCount: _displayedStudentAssignments.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Hiển thị loading indicator ở cuối list
              if (index == _displayedStudentAssignments.length) {
                // Load more
                if (!_isLoadingMore && hasMore) {
                  _loadMoreStudent(assignments);
                }
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final assignment = _displayedStudentAssignments[index];
              return ClassDetailAssignmentListItem(
                assignment: assignment,
                viewMode: AssignmentViewMode.student,
                onTap: () {
                  final distributionId = assignment['assignment_distribution_id']?.toString();
                  if (distributionId != null) {
                    context.pushNamed(
                      AppRoute.studentAssignmentDetail,
                      pathParameters: {'assignmentId': distributionId},
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  void _loadMoreStudent(List<Map<String, dynamic>> allAssignments) {
    if (_isLoadingMore) return;

    final totalItems = allAssignments.length;
    final currentDisplayed = (_currentPageStudent + 1) * _pageSize;

    if (currentDisplayed >= totalItems) return;

    _isLoadingMore = true;
    _currentPageStudent++;

    final endIndex = ((_currentPageStudent + 1) * _pageSize).clamp(0, totalItems);
    _displayedStudentAssignments = allAssignments.take(endIndex).toList();
    _isLoadingMore = false;

    setState(() {});
  }

  /// Xây dựng card hiển thị một bài tập
  Widget _buildAssignmentCard(Assignment assignment, {required bool isTeacher}) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        boxShadow: [
          DesignElevation.level1,
        ],
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to assignment detail
          if (isTeacher) {
            // context.goNamed(AppRoute.teacherAssignmentDetail, pathParameters: {'assignmentId': assignment.id});
          } else {
            // context.goNamed(AppRoute.studentAssignmentDetail, pathParameters: {'assignmentId': assignment.id});
          }
        },
        borderRadius: BorderRadius.circular(DesignRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assignment,
                    color: DesignColors.primary,
                    size: DesignIcons.mdSize,
                  ),
                  const SizedBox(width: DesignSpacing.md),
                  Expanded(
                    child: Text(
                      assignment.title,
                      style: DesignTypography.titleMedium,
                    ),
                  ),
                  if (assignment.isPublished)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: DesignColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DesignRadius.sm),
                        border: Border.all(color: DesignColors.success),
                      ),
                      child: Text(
                        'Đã xuất bản',
                        style: TextStyle(
                          fontSize: DesignTypography.captionSize,
                          color: DesignColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignSpacing.sm,
                        vertical: DesignSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: DesignColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DesignRadius.sm),
                        border: Border.all(color: DesignColors.warning),
                      ),
                      child: Text(
                        'Bản nháp',
                        style: TextStyle(
                          fontSize: DesignTypography.captionSize,
                          color: DesignColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              if (assignment.description != null &&
                  assignment.description!.isNotEmpty) ...[
                const SizedBox(height: DesignSpacing.sm),
                Text(
                  assignment.description!,
                  style: TextStyle(
                    fontSize: DesignTypography.bodyMediumSize,
                    color: DesignColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: DesignSpacing.md),
              Row(
                children: [
                  if (assignment.dueAt != null) ...[
                    Icon(
                      Icons.access_time,
                      size: DesignIcons.smSize,
                      color: DesignColors.textSecondary,
                    ),
                    const SizedBox(width: DesignSpacing.xs),
                    Text(
                      'Hạn nộp: ${_formatDate(assignment.dueAt!)}',
                      style: TextStyle(
                        fontSize: DesignTypography.captionSize,
                        color: DesignColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: DesignSpacing.md),
                  ],
                  if (assignment.totalPoints != null) ...[
                    Icon(
                      Icons.star,
                      size: DesignIcons.smSize,
                      color: DesignColors.textSecondary,
                    ),
                    const SizedBox(width: DesignSpacing.xs),
                    Text(
                      '${assignment.totalPoints} điểm',
                      style: TextStyle(
                        fontSize: DesignTypography.captionSize,
                        color: DesignColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Format ngày tháng
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == 1) {
      return 'Ngày mai';
    } else if (difference.inDays > 1 && difference.inDays <= 7) {
      return '${difference.inDays} ngày nữa';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
