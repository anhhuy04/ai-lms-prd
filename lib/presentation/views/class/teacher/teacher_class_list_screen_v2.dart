import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/viewmodels/class_viewmodel.dart';
import 'package:ai_mls/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ai_mls/widgets/class_item_widget.dart';
import 'package:ai_mls/widgets/search/smart_search_dialog_v2.dart';
import 'create_class_screen.dart';
import 'teacher_class_detail_screen.dart';

/// Màn hình danh sách lớp học dành cho giáo viên (Version 2 với ViewModel)
/// Tích hợp với ClassViewModel và tuân thủ MVVM pattern
class TeacherClassListScreenV2 extends StatefulWidget {
  const TeacherClassListScreenV2({super.key});

  @override
  State<TeacherClassListScreenV2> createState() => _TeacherClassListScreenV2State();
}

class _TeacherClassListScreenV2State extends State<TeacherClassListScreenV2> {
  @override
  void initState() {
    super.initState();
    // Load dữ liệu khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClasses();
    });
  }

  /// Load danh sách lớp học từ ViewModel
  void _loadClasses() {
    final classViewModel = context.read<ClassViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    
    final teacherId = authViewModel.userProfile?.id;
    if (teacherId != null) {
      classViewModel.loadClasses(teacherId).catchError((error) {
        _showErrorSnackBar(error.toString());
      });
    }
  }

  /// Hiển thị thông báo lỗi
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DesignColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        margin: EdgeInsets.all(DesignSpacing.lg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            SizedBox(height: DesignSpacing.md),
            _buildCreateClassCard(context),
            SizedBox(height: DesignSpacing.lg),
            Expanded(
              child: _buildClassList(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Header với tiêu đề và actions
  Widget _buildHeader(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, _) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.md,
            vertical: DesignSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lớp học của tôi',
                      style: DesignTypography.titleLarge,
                    ),
                    SizedBox(height: DesignSpacing.xs),
                    Text(
                      'Năm học 2023 - 2024',
                      style: DesignTypography.bodySmall.copyWith(
                        color: DesignColors.textSecondary,
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
                      size: DesignIcons.mdSize,
                      color: DesignColors.textPrimary,
                    ),
                    onPressed: () => _showSearchDialog(context),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      size: DesignIcons.mdSize,
                      color: DesignColors.textPrimary,
                    ),
                    onPressed: () {
                      // TODO: Implement notifications
                    },
                  ),
                  SizedBox(width: DesignSpacing.xs),
                  _buildAvatar(authViewModel),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Avatar widget
  Widget _buildAvatar(AuthViewModel authViewModel) {
    final avatarUrl = authViewModel.userProfile?.avatarUrl;
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: DesignColors.dividerLight,
          width: 1,
        ),
      ),
      child: ClipOval(
        child: avatarUrl != null && avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: DesignIcons.smSize,
      color: DesignColors.textSecondary,
    );
  }

  /// Card tạo lớp học mới
  Widget _buildCreateClassCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(
          color: DesignColors.tealPrimary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [DesignElevation.level1],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DesignColors.tealAccent,
            ),
            child: Icon(
              Icons.add,
              size: DesignIcons.mdSize,
              color: DesignColors.tealPrimary,
            ),
          ),
          SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thêm Lớp học mới',
                  style: DesignTypography.titleMedium,
                ),
                SizedBox(height: DesignSpacing.xs),
                Text(
                  'Tạo không gian lớp học để quản lý',
                  style: DesignTypography.bodySmall.copyWith(
                    color: DesignColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: DesignSpacing.md),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.tealPrimary,
              foregroundColor: DesignColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignRadius.sm),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: DesignSpacing.md,
                vertical: DesignSpacing.sm,
              ),
            ),
            onPressed: () => _navigateToCreateClass(context),
            child: Text(
              'Tạo ngay',
              style: DesignTypography.labelMedium.copyWith(
                color: DesignColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Điều hướng đến màn hình tạo lớp học
  void _navigateToCreateClass(BuildContext context) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const CreateClassScreen(),
      ),
    )
        .then((newClass) {
      if (newClass != null && mounted) {
        // Reload danh sách lớp học
        _loadClasses();
        
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lớp học đã được tạo thành công!'),
            backgroundColor: DesignColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            margin: EdgeInsets.all(DesignSpacing.lg),
          ),
        );
      }
    });
  }

  /// Danh sách lớp học với Consumer để lắng nghe thay đổi từ ViewModel
  Widget _buildClassList(BuildContext context) {
    return Consumer<ClassViewModel>(
      builder: (context, viewModel, _) {
        // Hiển thị loading state
        if (viewModel.isLoading && viewModel.classes.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              color: DesignColors.tealPrimary,
            ),
          );
        }

        // Hiển thị error state
        if (viewModel.hasError && viewModel.classes.isEmpty) {
          return _buildErrorState(viewModel);
        }

        // Hiển thị empty state
        if (viewModel.classes.isEmpty) {
          return _buildEmptyState();
        }

        // Hiển thị danh sách lớp học
        return RefreshIndicator(
          onRefresh: () async {
            await viewModel.refresh();
          },
          color: DesignColors.tealPrimary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildListHeader(viewModel),
              SizedBox(height: DesignSpacing.sm),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
                  itemCount: viewModel.classes.length,
                  itemBuilder: (context, index) {
                    final classItem = viewModel.classes[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: DesignSpacing.md),
                      child: ClassItemWidget(
                        className: classItem.name,
                        roomInfo: classItem.subject ?? 'Chưa có môn học',
                        schedule: classItem.academicYear ?? 'Chưa có năm học',
                        studentCount: viewModel.approvedCount,
                        ungradedCount: viewModel.pendingCount,
                        iconName: 'school',
                        iconColor: DesignColors.tealPrimary,
                        hasAssignments: true,
                        onTap: () => _navigateToClassDetail(context, classItem),
                      ),
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

  /// Header danh sách với số lượng và actions
  Widget _buildListHeader(ClassViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Danh sách lớp (${viewModel.classCount})',
            style: DesignTypography.titleMedium,
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  size: DesignIcons.smSize,
                  color: DesignColors.textSecondary,
                ),
                onPressed: () {
                  // TODO: Implement filter
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.sort,
                  size: DesignIcons.smSize,
                  color: DesignColors.textSecondary,
                ),
                onPressed: () {
                  // TODO: Implement sort
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Error state widget
  Widget _buildErrorState(ClassViewModel viewModel) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: DesignIcons.xxlSize,
              color: DesignColors.error,
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              'Đã xảy ra lỗi',
              style: DesignTypography.titleMedium.copyWith(
                color: DesignColors.error,
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              viewModel.errorMessage ?? 'Không thể tải danh sách lớp học',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                viewModel.clearError();
                _loadClasses();
              },
              icon: Icon(Icons.refresh, size: DesignIcons.smSize),
              label: Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.tealPrimary,
                foregroundColor: DesignColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: DesignIcons.xxlSize,
              color: DesignColors.textTertiary,
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              'Chưa có lớp học nào',
              style: DesignTypography.titleMedium.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              'Tạo lớp học đầu tiên để bắt đầu quản lý',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Điều hướng đến màn hình chi tiết lớp học
  void _navigateToClassDetail(BuildContext context, classItem) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TeacherClassDetailScreen(
          classId: classItem.id,
          className: classItem.name,
          semesterInfo: classItem.academicYear ?? 'Chưa có năm học',
        ),
      ),
    );
  }

  /// Hiển thị dialog tìm kiếm
  void _showSearchDialog(BuildContext context) {
    final viewModel = context.read<ClassViewModel>();
    
    // Chuyển đổi classes thành format cho SmartSearchDialogV2
    final classes = viewModel.classes.map((classItem) {
      return {
        'id': classItem.id,
        'title': classItem.name,
        'subtitle': '${classItem.subject ?? "Chưa có môn học"} • ${classItem.academicYear ?? "Chưa có năm học"}',
        'type': 'class',
      };
    }).toList();

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => SmartSearchDialogV2(
        initialQuery: '',
        assignments: [],
        students: [],
        classes: classes,
        onItemSelected: (item) {
          Navigator.pop(context);
          final classItem = viewModel.classes.firstWhere(
            (c) => c.id == item['id'],
            orElse: () => viewModel.classes.first,
          );
          _navigateToClassDetail(context, classItem);
        },
      ),
    );
  }
}
