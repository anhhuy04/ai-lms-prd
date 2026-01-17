import 'package:ai_mls/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ai_mls/presentation/viewmodels/class_viewmodel.dart';
import 'package:ai_mls/widgets/class_item_widget.dart';
import 'package:ai_mls/widgets/search/smart_search_dialog_v2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'join_class_screen.dart';
import 'student_class_detail_screen.dart';

/// Màn hình danh sách lớp học dành cho học sinh
/// Thiết kế tối giản với nền xám nhẹ, kích thước nhỏ gọn
/// Tích hợp với ClassViewModel và tuân thủ MVVM pattern
class StudentClassListScreen extends StatefulWidget {
  const StudentClassListScreen({super.key});

  @override
  State<StudentClassListScreen> createState() => _StudentClassListScreenState();
}

class _StudentClassListScreenState extends State<StudentClassListScreen> {
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
    final classViewModel = context.read<ClassViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    final studentId = authViewModel.userProfile?.id;
    if (studentId != null) {
      await classViewModel.loadStudentClasses(studentId).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lớp học của tôi',
                  style: TextStyle(
                    fontSize: 16, // Giảm từ 20 → 16
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Năm học 2023 - 2024',
                  style: TextStyle(
                    fontSize: 12, // Giảm từ 14 → 12
                    color: Colors.grey[600],
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
                  size: 20, // Giảm từ 24 → 20
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () {
                  _showSearchDialog(context);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  size: 20, // Giảm từ 24 → 20
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () {
                  // TODO: Implement notifications
                },
              ),
              const SizedBox(width: 6),
              Container(
                width: 28, // Giảm từ 32 → 28
                height: 28, // Giảm từ 32 → 28
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuA-iG40b1tmIe9rA2DkgKPE-hadnEvexC9hGqhf4sCPZ8TdvRh2VKw6r-XJ8-KItbRD6BJdbteNPNx96gD8PwvtIHdjP9sfWuFZFqxMip_HM63iTQQhjd_QvaZUf0y9TVAK-hCmOufCnvbtamVreHibLszZobUODWoElYWb_nfLsfg4I3sALmRG3-Jlo0_jWAIcc7uHkbc6ijrqgZ0T42DTha2cfCkzJ9ABSMQG98nTirIdJ-cTJGty_7doW5oVZySvBv02oKAYxg',
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: 16, // Giảm từ 20 → 16
                        color: Colors.grey[600],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card tham gia lớp học mới với thiết kế nhỏ gọn
  Widget _buildJoinClassCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, // Nền trắng thay vì gradient
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36, // Giảm từ 48 → 36
            height: 36, // Giảm từ 48 → 36
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[50],
            ),
            child: Icon(
              Icons.join_inner, // Thay đổi icon cho phù hợp với học sinh
              size: 18, // Giảm từ 26 → 18
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tham gia Lớp học',
                  style: TextStyle(
                    fontSize: 14, // Giảm từ 16 → 14
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Nhập mã lớp để tham gia',
                  style: TextStyle(
                    fontSize: 12, // Giảm từ 14 → 12
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 12, // Giảm từ 14 → 12
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              // Điều hướng đến màn hình nhập mã lớp học
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const JoinClassScreen(),
                ),
              );
            },
            child: const Text('Tham gia'),
          ),
        ],
      ),
    );
  }

  /// Danh sách lớp học với Consumer để lắng nghe thay đổi từ ViewModel
  Widget _buildClassList(BuildContext context) {
    return Consumer<ClassViewModel>(
      builder: (context, viewModel, _) {
        // Hiển thị loading state (chỉ khi đang loading và chưa có dữ liệu)
        if (viewModel.isLoading && viewModel.classes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Hiển thị error state (chỉ khi có lỗi thực sự, không phải empty list)
        // Kiểm tra: có errorMessage VÀ không đang loading (đã hoàn thành request)
        if (viewModel.hasError && !viewModel.isLoading) {
          return Center(
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
                    viewModel.errorMessage ?? 'Không thể tải danh sách lớp học',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      viewModel.clearError();
                      _loadClasses();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        // Hiển thị empty state (khi không có lỗi và danh sách rỗng)
        if (viewModel.classes.isEmpty && !viewModel.hasError) {
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

        // Hiển thị danh sách lớp học với pull-to-refresh
        return RefreshIndicator(
          onRefresh: () async {
            await _loadClasses();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header danh sách
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Danh sách lớp (${viewModel.classCount})',
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
                            // TODO: Implement filter
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.sort,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            // TODO: Implement sort
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Danh sách các lớp
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: viewModel.classes.length,
                  itemBuilder: (context, index) {
                    final classItem = viewModel.classes[index];
                    return ClassItemWidget(
                      className: classItem.name,
                      roomInfo: classItem.subject ?? 'Chưa có môn học',
                      schedule: classItem.academicYear ?? 'Chưa có năm học',
                      studentCount: 0, // TODO: Lấy từ class members
                      ungradedCount: null, // TODO: Lấy từ assignments
                      iconName: 'school',
                      iconColor: Colors.blue,
                      hasAssignments: true,
                      onTap: () {
                        // Navigate to student class detail screen
                        final authViewModel = context.read<AuthViewModel>();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => StudentClassDetailScreen(
                              classId: classItem.id,
                              className: classItem.name,
                              semesterInfo:
                                  classItem.academicYear ?? 'Chưa có năm học',
                              studentName:
                                  authViewModel.userProfile?.fullName ??
                                  'Học sinh',
                            ),
                          ),
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

  /// Hiển thị dialog tìm kiếm cho danh sách lớp học
  void _showSearchDialog(BuildContext context) {
    // Dữ liệu mẫu cho tìm kiếm
    final List<Map<String, dynamic>> classes = [
      {
        'id': '1',
        'title': 'Toán Học - Lớp 10A2',
        'subtitle': 'Phòng 302 • Thứ 2, 4, 6 • GV: Nguyễn Văn A',
        'type': 'class',
      },
      {
        'id': '2',
        'title': 'Vật Lý - Lớp 11B1',
        'subtitle': 'Phòng Lab 1 • Thứ 3, 5 • GV: Trần Thị B',
        'type': 'class',
      },
      {
        'id': '3',
        'title': 'Ngữ Văn - Lớp 12C3',
        'subtitle': 'Phòng 205 • Chiều thứ 4 • GV: Lê Minh C',
        'type': 'class',
      },
      {
        'id': '4',
        'title': 'Chủ nhiệm - Lớp 10A2',
        'subtitle': 'Sinh hoạt lớp • Sáng thứ 2 • GV: Nguyễn Văn A',
        'type': 'class',
      },
    ];

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => SmartSearchDialogV2(
        initialQuery: '',
        assignments: [], // Không có bài tập ở màn hình danh sách lớp
        students: [], // Không có học sinh ở màn hình danh sách lớp
        classes: classes,
        onItemSelected: (item) {
          Navigator.pop(context);
          // Tìm và điều hướng đến lớp được chọn
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StudentClassDetailScreen(
                classId: item['id'],
                className: item['title'],
                semesterInfo: 'Học kỳ 1 - 2023',
                studentName: 'Nguyễn Văn An', // TODO: Lấy từ profile thực tế
              ),
            ),
          );
        },
      ),
    );
  }
}
