import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/class_member.dart';
import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/presentation/providers/class_notifier.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Màn hình danh sách học sinh cho giáo viên
/// Hiển thị danh sách học sinh trong lớp với chức năng duyệt
class StudentListScreen extends ConsumerStatefulWidget {
  final String classId;
  final String className;

  const StudentListScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  ConsumerState<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends ConsumerState<StudentListScreen> {
  // Trạng thái lọc
  String _currentFilter = 'all'; // 'all', 'approved', 'pending'

  // State dữ liệu members từ backend
  AsyncValue<List<ClassMember>> _membersState =
      const AsyncValue<List<ClassMember>>.loading();

  // Cache profile theo studentId để hiển thị tên/sđt/giới tính & avatar
  final Map<String, Profile> _profilesByStudentId = {};

  List<ClassMember> get _students {
    return _membersState.value ?? const <ClassMember>[];
  }

  // Lọc danh sách học sinh theo trạng thái
  List<ClassMember> get _filteredStudents {
    if (_currentFilter == 'all') {
      return _students;
    } else if (_currentFilter == 'approved') {
      return _students
          .where((student) => student.status == 'approved')
          .toList();
    } else {
      return _students.where((student) => student.status == 'pending').toList();
    }
  }

  // Đếm số lượng học sinh cho mỗi trạng thái
  int get _totalCount => _students.length;
  int get _approvedCount =>
      _students.where((s) => s.status == 'approved').length;
  int get _pendingCount => _students.where((s) => s.status == 'pending').length;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _membersState = const AsyncValue.loading();
    });

    try {
      final notifier = ref.read(classNotifierProvider.notifier);
      final members = await notifier.getClassMembers(widget.classId);
      await _loadProfilesForMembers(members);
      if (!mounted) return;
      setState(() {
        _membersState = AsyncValue.data(members);
      });
    } catch (e, stackTrace) {
      setState(() {
        _membersState = AsyncValue.error(e, stackTrace);
      });
    }
  }

  Future<void> _loadProfilesForMembers(List<ClassMember> members) async {
    try {
      final ids = members.map((m) => m.studentId).toSet().toList();
      if (ids.isEmpty) {
        _profilesByStudentId.clear();
        return;
      }

      final client = Supabase.instance.client;
      final response =
          await client.from('profiles').select().inFilter('id', ids)
              as List<dynamic>;

      _profilesByStudentId.clear();
      for (final item in response) {
        final json = Map<String, dynamic>.from(item as Map);
        final profile = Profile.fromJson(json);
        _profilesByStudentId[profile.id] = profile;
      }
    } catch (_) {
      // Nếu lỗi, bỏ qua để không chặn luồng chính; UI sẽ chỉ hiển thị ID
    }
  }

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
          Expanded(child: _buildStudentList()),
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
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            // Fallback: navigate về class detail nếu không thể pop
            context.goNamed(
              AppRoute.teacherClassDetail,
              pathParameters: {'classId': widget.classId},
            );
          }
        },
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
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
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
                color: isSelected
                    ? DesignColors.primary
                    : DesignColors.textSecondary,
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
    return _membersState.when(
      data: (members) {
        if (members.isEmpty) {
          return Center(
            child: Text(
              'Chưa có học sinh nào trong lớp này.',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadMembers,
          child: ListView.builder(
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        return _buildStudentItem(student);
      },
          ),
        );
      },
      loading: () => const ShimmerListTileLoading(),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lỗi khi tải danh sách học sinh',
              style: DesignTypography.bodyMedium.copyWith(
                color: DesignColors.error,
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              error.toString(),
              style: DesignTypography.bodySmall.copyWith(
                color: DesignColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.md),
            ElevatedButton(
              onPressed: _loadMembers,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  /// Một mục học sinh trong danh sách
  Widget _buildStudentItem(ClassMember student) {
    final profile = _profilesByStudentId[student.studentId];
    final fullName = profile?.fullName ?? 'Học sinh chưa cập nhật tên';
    final phone = profile?.phone?.isNotEmpty == true
        ? profile!.phone!
        : 'Chưa có';
    final genderLabel = _mapGender(profile?.gender);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Avatar học sinh
          _buildStudentAvatar(student),
          SizedBox(width: DesignSpacing.md),

          // Thông tin học sinh
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: DesignTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: DesignSpacing.xs),
                Text(
                  'SĐT: $phone',
                  style: DesignTypography.bodySmall.copyWith(
                    color: DesignColors.textSecondary,
                  ),
                ),
                SizedBox(height: DesignSpacing.xs),
                Text(
                  'Giới tính: $genderLabel',
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
  Widget _buildStudentAvatar(ClassMember student) {
    final profile = _profilesByStudentId[student.studentId];
    final size = DesignComponents.avatarMedium;
    final avatarUrl = profile?.avatarUrl;
    final fullName = profile?.fullName ?? '';
    final initials = _buildInitialsFromFullName(fullName);

    Widget buildInitialAvatar() {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: DesignColors.primary.withValues(alpha: 0.1),
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              fontSize: size * 0.5,
              color: DesignColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: ClipOval(
          child: Image.network(
            avatarUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return buildInitialAvatar();
            },
          ),
        ),
      );
    }

    return buildInitialAvatar();
  }

  String _buildInitialsFromFullName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    final last = parts.isNotEmpty ? parts.last : trimmed;
    return last.isNotEmpty ? last[0].toUpperCase() : '?';
  }

  /// Trạng thái và hành động của học sinh
  Widget _buildStudentStatus(ClassMember student) {
    if (student.status == 'approved') {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: DesignColors.primary.withValues(alpha: 0.1),
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
              color: Colors.orange.withValues(alpha: 0.1),
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
                  _approveStudent(student);
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
                  _rejectStudent(student);
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
  Future<void> _approveStudent(ClassMember student) async {
    try {
      final notifier = ref.read(classNotifierProvider.notifier);
      await notifier.approveStudent(student.classId, student.studentId);
      await _loadMembers();
      if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          content: const Text('Đã duyệt học sinh'),
            backgroundColor: DesignColors.success,
          ),
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: DesignColors.error,
        ),
      );
    }
  }

  /// Từ chối học sinh
  void _rejectStudent(ClassMember student) {
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
                Navigator.pop(context);
              _confirmRejectStudent(student);
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

  Future<void> _confirmRejectStudent(ClassMember student) async {
    try {
      final notifier = ref.read(classNotifierProvider.notifier);
      await notifier.rejectStudent(student.classId, student.studentId);
      await _loadMembers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã từ chối học sinh'),
          backgroundColor: DesignColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: DesignColors.error,
        ),
      );
    }
  }

  String _mapGender(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'male':
      case 'nam':
        return 'Nam';
      case 'female':
      case 'nu':
      case 'nữ':
        return 'Nữ';
      case 'other':
        return 'Khác';
      default:
        return 'Chưa rõ';
    }
  }
}
