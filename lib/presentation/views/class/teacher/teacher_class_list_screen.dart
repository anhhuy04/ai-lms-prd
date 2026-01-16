import 'package:flutter/material.dart';
import 'package:ai_mls/widgets/class_item_widget.dart';
import 'package:ai_mls/widgets/search/smart_search_dialog_v2.dart';
import 'teacher_class_detail_screen.dart';
import 'create_class_screen.dart';

/// Màn hình danh sách lớp học dành cho giáo viên
/// Thiết kế tối giản với nền trắng, kích thước nhỏ gọn
class TeacherClassListScreen extends StatelessWidget {
  const TeacherClassListScreen({super.key});

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
            // Card tạo lớp học mới với thiết kế nhỏ hơn
            _buildCreateClassCard(context),
            const SizedBox(height: 16),
            // Danh sách lớp học
            Expanded(
              child: _buildClassList(),
            ),
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
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
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

  /// Card tạo lớp học mới với thiết kế nhỏ gọn
  Widget _buildCreateClassCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, // Nền trắng thay vì gradient
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue[100]!,
          width: 1,
        ),
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
              Icons.domain_add,
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
                  'Thêm Lớp học mới',
                  style: TextStyle(
                    fontSize: 14, // Giảm từ 16 → 14
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tạo không gian lớp học để quản lý',
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
              // Điều hướng đến màn hình tạo lớp học mới
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateClassScreen(),
                ),
              ).then((newClassData) {
                // Xử lý dữ liệu lớp học mới được tạo
                if (newClassData != null) {
                  // Hiển thị thông báo thành công
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lớp ${newClassData['name']} đã được tạo thành công!'),
                      backgroundColor: Colors.green[600],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );

                  // TODO: Thêm logic để cập nhật danh sách lớp học với lớp mới
                  // Ví dụ: gọi API để lấy danh sách lớp học mới hoặc thêm lớp mới vào danh sách hiện tại
                }
              });
            },
            child: const Text('Tạo ngay'),
          ),
        ],
      ),
    );
  }

  /// Danh sách lớp học với thiết kế nhỏ gọn
  Widget _buildClassList() {
    // Dữ liệu mẫu cho danh sách lớp học
    final List<Map<String, dynamic>> sampleClasses = [
      {
        'id': '1',
        'name': 'Toán Học - Lớp 10A2',
        'room': 'Phòng 302',
        'schedule': 'Thứ 2, 4, 6',
        'studentCount': 32,
        'ungradedCount': 5,
        'icon': 'calculate',
        'color': Colors.blue,
      },
      {
        'id': '2',
        'name': 'Vật Lý - Lớp 11B1',
        'room': 'Phòng Lab 1',
        'schedule': 'Thứ 3, 5',
        'studentCount': 40,
        'ungradedCount': 0,
        'icon': 'science',
        'color': Colors.indigo,
      },
      {
        'id': '3',
        'name': 'Ngữ Văn - Lớp 12C3',
        'room': 'Phòng 205',
        'schedule': 'Chiều thứ 4',
        'studentCount': 35,
        'ungradedCount': 12,
        'icon': 'auto_stories',
        'color': Colors.pink,
      },
      {
        'id': '4',
        'name': 'Chủ nhiệm - Lớp 10A2',
        'room': 'Sinh hoạt lớp',
        'schedule': 'Sáng thứ 2',
        'studentCount': 32,
        'ungradedCount': null,
        'hasAssignments': false,
        'icon': 'meeting_room',
        'color': Colors.teal,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header danh sách
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh sách lớp (${sampleClasses.length})',
                style: TextStyle(
                  fontSize: 14, // Giảm từ 18 → 14
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      size: 18, // Giảm từ 20 → 18
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      // TODO: Implement filter
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.sort,
                      size: 18, // Giảm từ 20 → 18
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
            itemCount: sampleClasses.length,
            itemBuilder: (context, index) {
              final classData = sampleClasses[index];
              return ClassItemWidget(
                className: classData['name'],
                roomInfo: classData['room'],
                schedule: classData['schedule'],
                studentCount: classData['studentCount'],
                ungradedCount: classData['ungradedCount'],
                iconName: classData['icon'],
                iconColor: classData['color'],
                hasAssignments: classData['hasAssignments'] ?? true,
                onTap: () {
                  // Navigate to class detail screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TeacherClassDetailScreen(
                        classId: classData['id'],
                        className: classData['name'],
                        semesterInfo: 'Học kỳ 1 - 2023',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Hiển thị dialog tìm kiếm cho danh sách lớp học
  void _showSearchDialog(BuildContext context) {
    // Dữ liệu mẫu cho tìm kiếm
    final List<Map<String, dynamic>> classes = [
      {
        'id': '1',
        'title': 'Toán Học - Lớp 10A2',
        'subtitle': 'Phòng 302 • Thứ 2, 4, 6',
        'type': 'class',
      },
      {
        'id': '2',
        'title': 'Vật Lý - Lớp 11B1',
        'subtitle': 'Phòng Lab 1 • Thứ 3, 5',
        'type': 'class',
      },
      {
        'id': '3',
        'title': 'Ngữ Văn - Lớp 12C3',
        'subtitle': 'Phòng 205 • Chiều thứ 4',
        'type': 'class',
      },
      {
        'id': '4',
        'title': 'Chủ nhiệm - Lớp 10A2',
        'subtitle': 'Sinh hoạt lớp • Sáng thứ 2',
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
              builder: (context) => TeacherClassDetailScreen(
                classId: item['id'],
                className: item['title'],
                semesterInfo: 'Học kỳ 1 - 2023',
              ),
            ),
          );
        },
      ),
    );
  }
}
