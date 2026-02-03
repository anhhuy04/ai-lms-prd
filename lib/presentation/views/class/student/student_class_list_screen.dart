import 'dart:async';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/filtering_utils.dart';
import 'package:ai_mls/core/utils/sorting_utils.dart';
import 'package:ai_mls/domain/entities/student_class_member_status.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/providers/class_notifier.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';
import 'package:ai_mls/presentation/utils/student_class_interaction_handler.dart';
import 'package:ai_mls/presentation/views/class/widgets/class_primary_action_card.dart';
import 'package:ai_mls/presentation/views/class/widgets/class_screen_header.dart';
import 'package:ai_mls/widgets/dialogs/class_sort_bottom_sheet.dart';
import 'package:ai_mls/widgets/list_item/class/class_item_widget.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình danh sách lớp học dành cho học sinh
/// Thiết kế tối giản với nền xám nhẹ, kích thước nhỏ gọn
/// Tích hợp với ClassViewModel và tuân thủ MVVM pattern
class StudentClassListScreen extends ConsumerStatefulWidget {
  const StudentClassListScreen({super.key});

  @override
  ConsumerState<StudentClassListScreen> createState() =>
      _StudentClassListScreenState();
}

class _StudentClassListScreenState
    extends ConsumerState<StudentClassListScreen> {
  /// Đánh dấu đã từng load danh sách ít nhất 1 lần (thành công hoặc thất bại).
  /// Dùng để phân biệt lần render đầu tiên (chưa gọi API) với trạng thái empty thực sự.
  bool _hasLoadedOnce = false;
  @override
  void initState() {
    super.initState();
    // Load dữ liệu khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClasses();
    });
  }

  /// Load danh sách lớp học từ ViewModel
  Future<void> _loadClasses() async {
    final auth = ref.read(authNotifierProvider);
    final studentId = auth.value?.id;
    if (studentId == null) return;
    await ref
        .read(classNotifierProvider.notifier)
        .loadClassesByStudent(studentId)
        .catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
                backgroundColor: Colors.red,
              ),
            );
          }
        })
        .whenComplete(() {
          if (mounted) {
            setState(() {
              _hasLoadedOnce = true;
            });
          } else {
            _hasLoadedOnce = true;
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final studentId = authState.value?.id;

    // Loading giống pattern ở TeacherClassListScreen
    if (authState.isLoading) {
      return const Scaffold(body: ShimmerLoading());
    }

    // Error state khi không lấy được thông tin học sinh
    if (authState.hasError || studentId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text(
                'Không tìm thấy thông tin học sinh',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

    return Scaffold(
      backgroundColor: Colors.grey[50], // Nền xám nhẹ như yêu cầu
      body: SafeArea(
        child: Column(
          children: [
            // Header với tiêu đề nhỏ gọn
            _buildHeader(context),
            const SizedBox(height: 12),
            // Card tham gia lớp học mới với thiết kế nhỏ hơn
            _buildJoinClassCard(context),
            const SizedBox(height: 16),
            // Danh sách lớp học với Consumer
            Expanded(child: _buildClassList(context)),
          ],
        ),
      ),
    );
  }

  /// Header nhỏ gọn với tiêu đề và avatar
  Widget _buildHeader(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final profile = auth.value;
    return ClassScreenHeader(
      onSearch: () {
        context.pushNamed(AppRoute.studentClassSearch);
      },
      onNotifications: () {
        // TODO: Implement notifications
      },
      profile: profile,
    );
  }

  void _showSortDialog(BuildContext context) {
    final currentSort = ref.read(studentClassSortOptionProvider);
    ClassSortBottomSheet.show(
      context,
      currentSortOption: currentSort,
      onSortOptionSelected: (option) {
        ref.read(studentClassSortOptionProvider.notifier).state = option;
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    final currentFilter = ref.read(studentClassFilterOptionProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Danh sách hiển thị',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
              const Divider(),
              _buildFilterOptionTile(
                context,
                title: 'Tất cả lớp (đã vào + đang chờ duyệt)',
                option: StudentClassFilterOption.all,
                icon: Icons.all_inbox,
                current: currentFilter,
              ),
              _buildFilterOptionTile(
                context,
                title: 'Chỉ lớp đã vào',
                option: StudentClassFilterOption.approved,
                icon: Icons.check_circle_outline,
                current: currentFilter,
              ),
              _buildFilterOptionTile(
                context,
                title: 'Chỉ lớp đang chờ duyệt',
                option: StudentClassFilterOption.pending,
                icon: Icons.hourglass_top,
                current: currentFilter,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _buildFilterOptionTile(
    BuildContext context, {
    required String title,
    required StudentClassFilterOption option,
    required IconData icon,
    required StudentClassFilterOption current,
  }) {
    final isSelected = current == option;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? DesignColors.primary : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? DesignColors.primary : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: DesignColors.primary)
          : null,
      onTap: () {
        ref.read(studentClassFilterOptionProvider.notifier).state = option;
        context.pop();
      },
    );
  }

  /// Card tham gia lớp học mới với thiết kế nhỏ gọn
  Widget _buildJoinClassCard(BuildContext context) {
    return ClassPrimaryActionCard.forStudent(
      onPressed: () async {
        // Điều hướng đến màn hình nhập mã lớp học
        final result = await context.pushNamed(AppRoute.studentJoinClass);
        if (!mounted) return;

        if (result is! Map) return;

        final status = result['status']?.toString();
        final classId = result['classId']?.toString();
        final className = result['className']?.toString();
        final academicYear = result['academicYear']?.toString();

        if (status == null) return;

        final statusEnum = StudentClassMemberStatus.fromString(status);
        final isApproved = statusEnum == StudentClassMemberStatus.approved;
        final message = isApproved
            ? 'Bạn đã tham gia lớp học thành công'
            : 'Đã gửi yêu cầu tham gia, vui lòng chờ giáo viên duyệt';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isApproved ? Colors.green : Colors.blue[800],
          ),
        );

        // Nếu được duyệt vào thẳng thì chuyển sang trang lớp học
        if (isApproved && classId != null && className != null) {
          final studentName =
              ref.read(authNotifierProvider).value?.fullName ?? 'Học sinh';
          context.pushNamed(
            AppRoute.studentClassDetail,
            pathParameters: {'classId': classId},
            extra: {
              'className': className,
              'semesterInfo': academicYear ?? 'Chưa có năm học',
              'studentName': studentName,
            },
          );
        }

        // Refresh danh sách lớp học trong nền, không chặn animation
        unawaited(_loadClasses());
      },
    );
  }

  /// Danh sách lớp học với Consumer để lắng nghe thay đổi từ ViewModel
  Widget _buildClassList(BuildContext context) {
    final classState = ref.watch(classNotifierProvider);
    final sortOption = ref.watch(studentClassSortOptionProvider);
    final filterOption = ref.watch(studentClassFilterOptionProvider);

    // Lần render đầu tiên sau khi auth đã sẵn sàng nhưng trước khi loadClassesByStudent
    // chuyển state sang loading: hiển thị shimmer dạng list tile (avatar + 2 dòng) giống pattern global.
    if (!_hasLoadedOnce && !classState.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: ShimmerListTileLoading(),
      );
    }

    return classState.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 8),
        child: ShimmerListTileLoading(),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Đã xảy ra lỗi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadClasses,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
      data: (classes) {
        // Áp dụng filter theo trạng thái tham gia
        final filtered = FilteringUtils.filterStudentClasses(
          classes,
          filterOption,
        );

        // Áp dụng sort giống teacher (mặc định mới nhất trước)
        final sorted = SortingUtils.sortClasses(filtered, sortOption);

        if (sorted.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa tham gia lớp học nào',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tham gia lớp học để bắt đầu học tập',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadClasses,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Danh sách lớp (${sorted.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.filter_list,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            _showFilterDialog(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.sort,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            _showSortDialog(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final classItem = sorted[index];
                    final studentName =
                        ref.read(authNotifierProvider).value?.fullName ??
                        'Học sinh';
                    return ClassItemWidget(
                      className: classItem.name,
                      roomInfo: classItem.subject ?? 'Chưa có môn học',
                      schedule: classItem.academicYear ?? 'Chưa có năm học',
                      teacherName: classItem.teacherName,
                      studentCount: classItem.studentCount ?? 0,
                      ungradedCount: null, // TODO: Lấy từ assignments
                      memberStatus: classItem.memberStatus,
                      iconName: 'school',
                      iconColor: Colors.blue,
                      hasAssignments: true,
                      onTap: () {
                        StudentClassInteractionHandler.handleClassTap(
                          context,
                          classItem,
                          onNavigate: () {
                            context.pushNamed(
                              AppRoute.studentClassDetail,
                              pathParameters: {'classId': classItem.id},
                              extra: {
                                'className': classItem.name,
                                'semesterInfo':
                                    classItem.academicYear ?? 'Chưa có năm học',
                                'studentName': studentName,
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
