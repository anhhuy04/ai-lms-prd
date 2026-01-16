import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';

/// Màn hình danh sách học sinh cho giáo viên
/// Hiển thị danh sách học sinh trong lớp với chức năng duyệt
class StudentListScreen extends StatefulWidget {
  final String classId;
  final String className;

  const StudentListScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  // Trạng thái lọc
  String _currentFilter = 'all'; // 'all', 'approved', 'pending'

  // Dữ liệu mẫu học sinh
  final List<Map<String, dynamic>> _students = [
    {
      'id': '1',
      'name': 'Nguyễn Văn An',
      'studentId': '2023001',
      'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBuHHscKTaW0cxtzzi6_qeFAvpa0gGkcz36l-kTNg6bjqiuvcNbrUOPqDwhsixuV99CKM4VOqTq7LnqHsaxp8Vj8Hc3pu4Ukjzh0b_fWu_KGj4BAryL3qbn4pocjkT8zGQRLjf180BLGxmJlEHE3iDlFbPQiGJ2OHdzY3mTDq8dBuC_Rk4iQkzieCE_GHLHT1-_dSP3EJCz0SRJeEXSHVFV54KZBYHQYw1huE2L5mmxHNh2_hf-qWrLWT9cCFCuYahsgCPkwnNbTA',
      'status': 'approved',
    },
    {
      'id': '2',
      'name': 'Hoàng Văn Hải',
      'studentId': '2023005',
      'avatarUrl': '',
      'status': 'pending',
    },
    {
      'id': '3',
      'name': 'Trần Thị Lan',
      'studentId': '2023003',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/44.jpg',
      'status': 'approved',
    },
    {
      'id': '4',
      'name': 'Phạm Minh Tuấn',
      'studentId': '2023004',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/32.jpg',
      'status': 'pending',
    },
    {
      'id': '5',
      'name': 'Lê Thị Hồng',
      'studentId': '2023002',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/68.jpg',
      'status': 'approved',
    },
  ];

  // Lọc danh sách học sinh
  List<Map<String, dynamic>> get _filteredStudents {
    if (_currentFilter == 'all') {
      return _students;
    } else if (_currentFilter == 'approved') {
      return _students.where((student) => student['status'] == 'approved').toList();
    } else {
      return _students.where((student) => student['status'] == 'pending').toList();
    }
  }

  // Đếm số lượng học sinh cho mỗi trạng thái
  int get _totalCount => _students.length;
  int get _approvedCount => _students.where((s) => s['status'] == 'approved').length;
  int get _pendingCount => _students.where((s) => s['status'] == 'pending').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Thanh tìm kiếm
          _buildSearchBar(),

          // Bộ lọc
          _buildFilterChips(),

          // Danh sách học sinh
          Expanded(
            child: _buildStudentList(),
          ),
        ],
      ),
    );
  }

  /// AppBar với nút quay lại
  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: DesignIcons.mdSize,
          color: Theme.of(context).iconTheme.color,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.className,
        style: DesignTypography.titleLarge.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [],
    );
  }

  /// Thanh tìm kiếm học sinh
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.md,
      ),
      child: Container(
        height: DesignComponents.inputFieldHeight,
        decoration: BoxDecoration(
          color: DesignColors.moonMedium,
          borderRadius: BorderRadius.circular(DesignRadius.full),
          boxShadow: [DesignElevation.level1],
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
              child: Icon(
                Icons.search,
                size: DesignIcons.mdSize,
                color: DesignColors.textSecondary,
              ),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm học sinh...',
                  hintStyle: DesignTypography.bodyMedium.copyWith(
                    color: DesignColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: DesignSpacing.md,
                  ),
                ),
                style: DesignTypography.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bộ lọc trạng thái học sinh (kiểu tab)
  Widget _buildFilterChips() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildFilterTab('Tất cả', 'all', _totalCount),
          _buildFilterTab('Đã duyệt', 'approved', _approvedCount),
          _buildFilterTab('Chờ duyệt', 'pending', _pendingCount),
        ],
      ),
    );
  }

  /// Một tab lọc với số lượng ở dưới
  Widget _buildFilterTab(String label, String value, int count) {
    final isSelected = _currentFilter == value;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentFilter = value;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: DesignTypography.labelMedium.copyWith(
                color: isSelected ? DesignColors.primary : DesignColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: DesignSpacing.xs),
            if (count > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? DesignColors.primary : DesignColors.error,
                  borderRadius: BorderRadius.circular(DesignRadius.full),
                ),
                child: Text(
                  '$count',
                  style: DesignTypography.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Danh sách học sinh
  Widget _buildStudentList() {
    return ListView.builder(
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        return _buildStudentItem(student);
      },
    );
  }

  /// Một mục học sinh trong danh sách
  Widget _buildStudentItem(Map<String, dynamic> student) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar học sinh
          _buildStudentAvatar(student['avatarUrl']),
          SizedBox(width: DesignSpacing.md),

          // Thông tin học sinh
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'],
                  style: DesignTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: DesignSpacing.xs),
                Text(
                  'MSSV: ${student['studentId']}',
                  style: DesignTypography.bodySmall.copyWith(
                    color: DesignColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: DesignSpacing.md),

          // Trạng thái và hành động
          _buildStudentStatus(student),
        ],
      ),
    );
  }

  /// Avatar học sinh
  Widget _buildStudentAvatar(String avatarUrl) {
    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: DesignComponents.avatarMedium / 2,
        backgroundImage: NetworkImage(avatarUrl),
        backgroundColor: DesignColors.moonMedium,
      );
    } else {
      // Avatar mặc định với chữ cái đầu tiên
      final firstLetter = _filteredStudents.isNotEmpty
          ? _filteredStudents[0]['name'][0].toUpperCase()
          : 'H';

      return CircleAvatar(
        radius: DesignComponents.avatarMedium / 2,
        backgroundColor: DesignColors.moonMedium,
        child: Text(
          firstLetter,
          style: DesignTypography.titleLarge.copyWith(
            color: DesignColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  /// Trạng thái và hành động của học sinh
  Widget _buildStudentStatus(Map<String, dynamic> student) {
    if (student['status'] == 'approved') {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: DesignColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(DesignRadius.full),
        ),
        child: Text(
          'Đã duyệt',
          style: DesignTypography.bodySmall.copyWith(
            color: DesignColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignSpacing.md,
              vertical: DesignSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignRadius.full),
            ),
            child: Text(
              'Chờ duyệt',
              style: DesignTypography.bodySmall.copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: DesignSpacing.sm),
          Row(
            children: [
              // Nút chấp nhận
              IconButton(
                icon: Icon(
                  Icons.check_circle,
                  size: DesignIcons.mdSize,
                  color: DesignColors.primary,
                ),
                onPressed: () {
                  _approveStudent(student['id']);
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              SizedBox(width: DesignSpacing.sm),

              // Nút từ chối
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: DesignIcons.mdSize,
                  color: DesignColors.error,
                ),
                onPressed: () {
                  _rejectStudent(student['id']);
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ],
      );
    }
  }

  /// Duyệt học sinh
  void _approveStudent(String studentId) {
    setState(() {
      final index = _students.indexWhere((s) => s['id'] == studentId);
      if (index != -1) {
        _students[index]['status'] = 'approved';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã duyệt học sinh'),
            backgroundColor: DesignColors.success,
          ),
        );
      }
    });
  }

  /// Từ chối học sinh
  void _rejectStudent(String studentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận từ chối'),
        content: Text('Bạn có chắc chắn muốn từ chối học sinh này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _students.removeWhere((s) => s['id'] == studentId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã từ chối học sinh'),
                    backgroundColor: DesignColors.error,
                  ),
                );
              });
            },
            child: Text(
              'Từ chối',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
