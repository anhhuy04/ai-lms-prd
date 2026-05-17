// ignore_for_file: use_build_context_synchronously
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/services/api_key_service.dart';
import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/views/dashboard/widgets/dashboard_top_bar.dart';
import 'package:ai_mls/widgets/loading/profile_shimmer_loading.dart';
import 'package:ai_mls/widgets/refresh/app_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _phoneController;
  // Student-specific
  late final TextEditingController _schoolNameController;
  late final TextEditingController _studentCodeController;
  late final TextEditingController _enrollmentClassController;
  // Teacher-specific
  late final TextEditingController _teacherCodeController;
  late final TextEditingController _degreeTitleController;
  late final TextEditingController _addressController;

  String? _selectedGender;
  List<Map<String, String>> _profileExtras = [];
  Profile? _lastSyncedUser;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _bioController = TextEditingController();
    _phoneController = TextEditingController();
    _schoolNameController = TextEditingController();
    _studentCodeController = TextEditingController();
    _enrollmentClassController = TextEditingController();
    _teacherCodeController = TextEditingController();
    _degreeTitleController = TextEditingController();
    _addressController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateControllersFromUser();
    });
  }

  void _updateControllersFromUser() {
    if (!mounted) return;
    final user = ref.read(authNotifierProvider).value;
    if (user != null && user != _lastSyncedUser) {
      final meta = user.metadata ?? {};
      final extrasRaw = meta['profile_extras'];
      final newExtras = extrasRaw is List
          ? extrasRaw
              .whereType<Map>()
              .map(
                (e) => Map<String, String>.from(
                  e.map((k, v) => MapEntry(k.toString(), v.toString())),
                ),
              )
              .toList()
          : <Map<String, String>>[];

      // Controllers don't need setState (họ tự notify listeners)
      _lastSyncedUser = user;
      _fullNameController.text = user.fullName ?? '';
      _bioController.text = user.bio ?? '';
      _phoneController.text = user.phone ?? '';
      _schoolNameController.text = (meta['school_name'] as String?) ?? '';
      _studentCodeController.text = (meta['student_code'] as String?) ?? '';
      _enrollmentClassController.text =
          (meta['enrollment_class'] as String?) ?? '';
      _teacherCodeController.text = (meta['teacher_code'] as String?) ?? '';
      _degreeTitleController.text = (meta['degree_title'] as String?) ?? '';
      _addressController.text = (meta['address'] as String?) ?? '';

      // _selectedGender và _profileExtras là plain state → cần setState
      setState(() {
        _selectedGender = user.gender;
        _profileExtras = newExtras;
      });
    }
  }

  Future<void> _refreshProfile() async {
    if (!mounted) return;
    try {
      await ref.read(authNotifierProvider.notifier).checkCurrentUser();
      if (mounted) _updateControllersFromUser();
    } catch (e) {
      if (mounted && _isEditing) setState(() => _isEditing = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _schoolNameController.dispose();
    _studentCodeController.dispose();
    _enrollmentClassController.dispose();
    _teacherCodeController.dispose();
    _degreeTitleController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    if (!mounted) return;
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = ref.read(authNotifierProvider).value;
      final role = user?.role.toLowerCase() ?? '';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Đang cập nhật...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final metaToUpdate = <String, dynamic>{
        'profile_extras': _profileExtras,
      };
      if (role == 'student') {
        metaToUpdate.addAll({
          'school_name': _schoolNameController.text.trim(),
          'student_code': _studentCodeController.text.trim(),
          'enrollment_class': _enrollmentClassController.text.trim(),
        });
      } else if (role == 'teacher') {
        metaToUpdate.addAll({
          'school_name': _schoolNameController.text.trim(),
          'teacher_code': _teacherCodeController.text.trim(),
          'degree_title': _degreeTitleController.text.trim(),
          'address': _addressController.text.trim(),
        });
      }

      await authRepo.updateProfile(
        fullName: _fullNameController.text.trim().isEmpty
            ? null
            : _fullNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        gender: _selectedGender,
        metadata: metaToUpdate,
      );

      await ref.read(authNotifierProvider.notifier).checkCurrentUser();

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã cập nhật thông tin thành công!'),
            backgroundColor: DesignColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: ${e.toString()}'),
            backgroundColor: DesignColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= DesignBreakpoints.tabletSmall;

    authState.whenData((user) {
      if (user != null && user != _lastSyncedUser && !_isEditing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _updateControllersFromUser();
        });
      }
    });

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      body: Column(
        children: [
          DashboardTopBar(
            title: 'Cá nhân',
            subtitle: 'Thông tin tài khoản',
            profile: authState.value,
            showAvatar: !isWide,
            actions: [
              Builder(
                builder: (context) {
                  final currentUser = authState.value;
                  if (!_isEditing && currentUser != null) {
                    return IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 22),
                      onPressed: () => setState(() => _isEditing = true),
                      tooltip: 'Chỉnh sửa',
                      color: isDark ? Colors.white70 : DesignColors.textSecondary,
                    );
                  }
                  if (_isEditing) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (!mounted) return;
                            setState(() {
                              _isEditing = false;
                              _lastSyncedUser = null;
                            });
                            _updateControllersFromUser();
                          },
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: _handleUpdateProfile,
                          child: const Text(
                            'Lưu',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          Expanded(
            child: authState.when(
              data: (user) {
                if (user == null) return _buildNotLoggedInState();
                return _buildProfileContent(user, isDark);
              },
              loading: () => const ProfileShimmerLoading(),
              error: (error, _) => _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Avatar ──────────────────────────────────────────────────────────────

  Widget _buildAvatarSection(BuildContext context, Profile user, bool isDark) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: DesignColors.primary, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: DesignColors.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? Image.network(
                          user.avatarUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) =>
                              progress == null ? child : _buildDefaultAvatar(),
                          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: DesignColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isEditing)
            SizedBox(
              width: 260,
              child: TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  hintText: 'Nhập họ và tên',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.lg),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                textAlign: TextAlign.center,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Vui lòng nhập họ và tên';
                  if (text.length < 3) return 'Tên quá ngắn';
                  return null;
                },
              ),
            )
          else
            Text(
              user.fullName ?? 'Chưa cập nhật',
              style: DesignTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : DesignColors.textPrimary,
              ),
            ),
          if (!_isEditing && user.role.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignRadius.full),
                border: Border.all(color: _getRoleColor(user.role), width: 1),
              ),
              child: Text(
                _getRoleLabel(user.role),
                style: DesignTypography.bodySmall.copyWith(
                  color: _getRoleColor(user.role),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: DesignColors.moonMedium,
      child: const Icon(
        Icons.person,
        size: 60,
        color: DesignColors.textTertiary,
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'teacher':
        return DesignColors.primary;
      case 'admin':
        return DesignColors.error;
      default:
        return DesignColors.tealPrimary;
    }
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'teacher':
        return 'Giáo viên';
      case 'admin':
        return 'Quản trị viên';
      default:
        return 'Học sinh';
    }
  }

  // ─── Personal info ────────────────────────────────────────────────────────

  Widget _buildProfileInfoSection(
    BuildContext context,
    Profile user,
    bool isDark,
  ) {
    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('THÔNG TIN CÁ NHÂN', isDark),
          const SizedBox(height: 16),
          _buildInfoField(
            context,
            label: 'Tiểu sử',
            icon: Icons.description_outlined,
            isDark: isDark,
            child: _isEditing
                ? TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Nhập tiểu sử',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignRadius.lg),
                      ),
                    ),
                  )
                : Text(
                    user.bio ?? 'Chưa cập nhật',
                    style: DesignTypography.bodyMedium.copyWith(
                      color: user.bio == null
                          ? DesignColors.textTertiary
                          : DesignColors.textPrimary,
                      fontStyle: user.bio == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            context,
            label: 'Số điện thoại',
            icon: Icons.phone_outlined,
            isDark: isDark,
            isSingleLine: true,
            child: _isEditing
                ? TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Nhập số điện thoại',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignRadius.lg),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    maxLength: 20,
                  )
                : Text(
                    user.phone ?? 'Chưa cập nhật',
                    style: DesignTypography.bodyMedium,
                  ),
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            context,
            label: 'Giới tính',
            icon: Icons.wc_outlined,
            isDark: isDark,
            isSingleLine: true,
            child: _isEditing
                ? DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    isExpanded: true,
                    decoration: InputDecoration(
                      hintText: 'Chọn giới tính',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignRadius.lg),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Nam')),
                      DropdownMenuItem(value: 'female', child: Text('Nữ')),
                      DropdownMenuItem(value: 'other', child: Text('Khác')),
                    ],
                    onChanged: (v) => setState(() => _selectedGender = v),
                  )
                : Text(
                    _getGenderLabel(user.gender),
                    style: DesignTypography.bodyMedium,
                  ),
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            context,
            label: 'Cập nhật lần cuối',
            icon: Icons.update_outlined,
            isDark: isDark,
            isSingleLine: true,
            child: Text(
              _formatDateTime(user.updatedAt),
              style: DesignTypography.bodySmall.copyWith(
                color: DesignColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Role-specific card ───────────────────────────────────────────────────
  //
  // Các trường trong card này được lưu thẳng vào metadata (không qua
  // profile_extras), nên extras sheet sẽ tự loại bỏ các key trùng.

  Widget _buildRoleSpecificSection(Profile user, bool isDark) {
    final role = user.role.toLowerCase();
    if (role != 'student' && role != 'teacher') return const SizedBox.shrink();

    final title =
        role == 'student' ? 'THÔNG TIN HỌC SINH' : 'THÔNG TIN GIÁO VIÊN';
    final icon =
        role == 'student' ? Icons.school_outlined : Icons.person_pin_outlined;
    final meta = user.metadata ?? {};

    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title,
            isDark,
            icon: icon,
            color: _getRoleColor(user.role),
          ),
          const SizedBox(height: 16),
          // Trường học — shared
          _buildInfoField(
            context,
            label: 'Trường',
            icon: Icons.account_balance_outlined,
            isDark: isDark,
            child: _isEditing
                ? TextFormField(
                    controller: _schoolNameController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên trường',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignRadius.lg),
                      ),
                    ),
                  )
                : Text(
                    _metaString(meta, 'school_name'),
                    style: DesignTypography.bodyMedium.copyWith(
                      color: meta['school_name'] == null
                          ? DesignColors.textTertiary
                          : DesignColors.textPrimary,
                      fontStyle: meta['school_name'] == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          if (role == 'student') ...[
            _buildInfoField(
              context,
              label: 'Mã sinh viên',
              icon: Icons.badge_outlined,
              isDark: isDark,
              isSingleLine: true,
              child: _isEditing
                  ? TextFormField(
                      controller: _studentCodeController,
                      decoration: InputDecoration(
                        hintText: 'Nhập mã sinh viên',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.lg),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    )
                  : Text(
                      _metaString(meta, 'student_code'),
                      style: DesignTypography.bodyMedium.copyWith(
                        color: meta['student_code'] == null
                            ? DesignColors.textTertiary
                            : DesignColors.textPrimary,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              context,
              label: 'Lớp',
              icon: Icons.class_outlined,
              isDark: isDark,
              isSingleLine: true,
              child: _isEditing
                  ? TextFormField(
                      controller: _enrollmentClassController,
                      decoration: InputDecoration(
                        hintText: 'Nhập tên lớp',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.lg),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    )
                  : Text(
                      _metaString(meta, 'enrollment_class'),
                      style: DesignTypography.bodyMedium.copyWith(
                        color: meta['enrollment_class'] == null
                            ? DesignColors.textTertiary
                            : DesignColors.textPrimary,
                      ),
                    ),
            ),
          ] else ...[
            // Teacher fields
            _buildInfoField(
              context,
              label: 'Mã giáo viên',
              icon: Icons.badge_outlined,
              isDark: isDark,
              isSingleLine: true,
              child: _isEditing
                  ? TextFormField(
                      controller: _teacherCodeController,
                      decoration: InputDecoration(
                        hintText: 'Nhập mã giáo viên',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.lg),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    )
                  : Text(
                      _metaString(meta, 'teacher_code'),
                      style: DesignTypography.bodyMedium.copyWith(
                        color: meta['teacher_code'] == null
                            ? DesignColors.textTertiary
                            : DesignColors.textPrimary,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              context,
              label: 'Học hàm/học vị',
              icon: Icons.military_tech_outlined,
              isDark: isDark,
              isSingleLine: true,
              child: _isEditing
                  ? TextFormField(
                      controller: _degreeTitleController,
                      decoration: InputDecoration(
                        hintText: 'VD: ThS, TS, PGS.TS...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.lg),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    )
                  : Text(
                      _metaString(meta, 'degree_title'),
                      style: DesignTypography.bodyMedium.copyWith(
                        color: meta['degree_title'] == null
                            ? DesignColors.textTertiary
                            : DesignColors.textPrimary,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              context,
              label: 'Địa chỉ',
              icon: Icons.location_on_outlined,
              isDark: isDark,
              child: _isEditing
                  ? TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: 'Nhập địa chỉ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.lg),
                        ),
                      ),
                    )
                  : Text(
                      _metaString(meta, 'address'),
                      style: DesignTypography.bodyMedium.copyWith(
                        color: meta['address'] == null
                            ? DesignColors.textTertiary
                            : DesignColors.textPrimary,
                        fontStyle: meta['address'] == null
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Profile extras ───────────────────────────────────────────────────────

  Widget _buildExtrasSection(Profile user, bool isDark) {
    final hasExtras = _profileExtras.isNotEmpty;
    if (!hasExtras && !_isEditing) return const SizedBox.shrink();

    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'THÔNG TIN MỞ RỘNG',
            isDark,
            icon: Icons.info_outline,
            color: DesignColors.textSecondary,
          ),
          if (hasExtras) ...[
            const SizedBox(height: 12),
            ...(_profileExtras.map((extra) => _buildExtraItem(extra, isDark))),
          ],
          if (_isEditing) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showAddExtraBottomSheet(context, user.role),
              borderRadius: BorderRadius.circular(DesignRadius.lg),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: DesignColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                        color: DesignColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Thêm thông tin',
                      style: DesignTypography.bodyMedium.copyWith(
                        color: DesignColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (!hasExtras)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Chưa có thông tin thêm',
                style: DesignTypography.bodySmall.copyWith(
                  color: DesignColors.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExtraItem(Map<String, String> extra, bool isDark) {
    final key = extra['key'] ?? 'custom';
    final label = extra['label'] ?? key;
    final value = extra['value'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DesignColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getExtraIcon(key),
              size: 18,
              color: DesignColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: DesignTypography.labelSmallSize,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: DesignTypography.bodyMedium),
              ],
            ),
          ),
          if (_isEditing)
            IconButton(
              icon: Icon(
                Icons.close,
                size: 18,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
              onPressed: () => setState(() => _profileExtras.remove(extra)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }

  void _showAddExtraBottomSheet(BuildContext context, String userRole) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddExtraSheet(
        existingKeys: _profileExtras.map((e) => e['key'] ?? '').toList(),
        userRole: userRole,
        onAdd: (extra) {
          setState(() {
            final idx = _profileExtras
                .indexWhere((e) => e['key'] == extra['key']);
            if (idx >= 0) {
              _profileExtras[idx] = extra;
            } else {
              _profileExtras.add(extra);
            }
          });
        },
      ),
    );
  }

  // ─── Quick actions ────────────────────────────────────────────────────────

  Widget _buildQuickActionsSection(
    BuildContext context,
    Profile user,
    bool isDark,
  ) {
    final isStudent = user.role.toLowerCase() == 'student';

    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('THAO TÁC NHANH', isDark),
          const SizedBox(height: 16),
          if (!isStudent)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  _actionIcon(Icons.key_rounded, DesignColors.primary),
              title: Text(
                'Cài đặt API Key',
                style: DesignTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : DesignColors.textPrimary,
                ),
              ),
              subtitle: FutureBuilder<bool>(
                future: ApiKeyService.hasGeminiApiKey(),
                builder: (context, snapshot) {
                  final hasKey = snapshot.data ?? false;
                  return Text(
                    snapshot.connectionState == ConnectionState.waiting
                        ? 'Đang kiểm tra...'
                        : hasKey
                            ? 'Đã cấu hình'
                            : 'Chưa cấu hình',
                    style: DesignTypography.bodySmall.copyWith(
                      color: hasKey
                          ? DesignColors.success
                          : DesignColors.textTertiary,
                    ),
                  );
                },
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
              onTap: () => context.push(AppRoute.apiKeySetupPath),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                _actionIcon(Icons.settings_rounded, DesignColors.tealPrimary),
            title: Text(
              'Cài đặt',
              style: DesignTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : DesignColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Quản lý cài đặt ứng dụng',
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.grey[400] : DesignColors.textSecondary,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            onTap: () => context.push(AppRoute.settingsPath),
          ),
        ],
      ),
    );
  }

  // ─── Metadata (API keys status) ───────────────────────────────────────────

  Widget _buildMetadataSection(
    BuildContext context,
    Profile user,
    bool isDark,
  ) {
    final apiKeys = user.metadata?['api_keys'];
    if (apiKeys is! Map<String, dynamic> || apiKeys.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('API KEYS', isDark, icon: Icons.data_object_outlined),
          const SizedBox(height: 16),
          _buildInfoField(
            context,
            label: 'API Keys',
            icon: Icons.key_rounded,
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (apiKeys.containsKey('gemini'))
                  _apiKeyBadge('Gemini API Key', DesignColors.success),
                if (apiKeys.containsKey('gemini') && apiKeys.containsKey('ai'))
                  const SizedBox(height: 8),
                if (apiKeys.containsKey('ai'))
                  _apiKeyBadge('AI API Key', DesignColors.info),
                if (apiKeys.containsKey('groq')) ...[
                  const SizedBox(height: 8),
                  _apiKeyBadge('Groq API Key', DesignColors.warning),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _apiKeyBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: Đã cấu hình',
            style: DesignTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Main layout ──────────────────────────────────────────────────────────

  Widget _buildProfileContent(Profile user, bool isDark) {
    final isStudent = user.role.toLowerCase() == 'student';
    final hasApiKeys = !isStudent &&
        user.metadata != null &&
        user.metadata!['api_keys'] is Map<String, dynamic> &&
        (user.metadata!['api_keys'] as Map<String, dynamic>).isNotEmpty;

    return AppRefreshIndicator(
      onRefresh: _refreshProfile,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: DesignSpacing.lg,
          right: DesignSpacing.lg,
          top: DesignSpacing.lg,
          bottom: MediaQuery.of(context).padding.bottom +
              kBottomNavigationBarHeight +
              DesignSpacing.xxl,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatarSection(context, user, isDark),
              SizedBox(height: DesignSpacing.xxl),
              _buildProfileInfoSection(context, user, isDark),
              SizedBox(height: DesignSpacing.xxl),
              _buildRoleSpecificSection(user, isDark),
              SizedBox(height: DesignSpacing.xxl),
              _buildExtrasSection(user, isDark),
              SizedBox(height: DesignSpacing.xxl),
              _buildQuickActionsSection(context, user, isDark),
              SizedBox(height: DesignSpacing.xxl),
              if (hasApiKeys) ...[
                _buildMetadataSection(context, user, isDark),
                SizedBox(height: DesignSpacing.xxl),
              ],
              _buildAccountActionsSection(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Shared UI helpers ────────────────────────────────────────────────────

  Widget _buildCard({required bool isDark, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: child,
    );
  }

  Widget _sectionHeader(
    String title,
    bool isDark, {
    IconData? icon,
    Color? color,
  }) {
    final c = color ?? DesignColors.primary;
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: c),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: DesignTypography.labelSmallSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _actionIcon(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildInfoField(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Widget child,
    required bool isDark,
    bool isSingleLine = false,
  }) {
    if (isSingleLine) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: DesignColors.primary),
          const SizedBox(width: 8),
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: DesignTypography.labelSmallSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(flex: 3, child: child),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: DesignColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: DesignTypography.labelSmallSize,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  // ─── Misc ─────────────────────────────────────────────────────────────────

  String _metaString(Map<String, dynamic> meta, String key) {
    final val = meta[key] as String?;
    return (val != null && val.isNotEmpty) ? val : 'Chưa cập nhật';
  }

  String _getGenderLabel(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'male':
        return 'Nam';
      case 'female':
        return 'Nữ';
      case 'other':
        return 'Khác';
      default:
        return 'Chưa cập nhật';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return diff.inMinutes == 0
            ? 'Vừa xong'
            : '${diff.inMinutes} phút trước';
      }
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  IconData _getExtraIcon(String key) {
    switch (key) {
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.photo_camera_outlined;
      case 'tiktok':
        return Icons.music_note;
      case 'youtube':
        return Icons.play_circle_outline;
      case 'zalo':
        return Icons.chat;
      case 'linkedin':
        return Icons.work_outline;
      case 'github':
        return Icons.code;
      case 'website':
        return Icons.language;
      case 'home_address':
        return Icons.home;
      default:
        return Icons.link;
    }
  }

  // ─── Error / empty states ─────────────────────────────────────────────────

  Widget _buildErrorState(Object error) {
    return AppRefreshIndicator(
      onRefresh: _refreshProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.xxxxxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: DesignColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi khi tải thông tin',
                    style: DesignTypography.titleMedium.copyWith(
                      color: DesignColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: DesignTypography.bodyMedium.copyWith(
                      color: DesignColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _refreshProfile,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotLoggedInState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: DesignColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text('Chưa đăng nhập', style: DesignTypography.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Vui lòng đăng nhập để xem thông tin hồ sơ',
            style: DesignTypography.bodySmall.copyWith(
              color: DesignColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActionsSection(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: ListTile(
        leading: const Icon(Icons.logout, color: DesignColors.error),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(color: DesignColors.error),
        ),
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Xác nhận đăng xuất'),
              content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: DesignColors.error,
                  ),
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
          );
          if (confirm == true && mounted) {
            await ref.read(authNotifierProvider.notifier).signOut();
            if (mounted) context.go(AppRoute.loginPath);
          }
        },
      ),
    );
  }
}

// ─── Add Extra Bottom Sheet ─────────────────────────────────────────────────
//
// Các key bị loại khỏi danh sách theo role:
//   student → teacher_code, employee_id (không liên quan)
//   teacher → teacher_code (đã có trong card THÔNG TIN GIÁO VIÊN)
//
// Khi user chọn một option, thẻ đó được thêm vào profile_extras trong metadata.
// Các field chuyên biệt theo role (teacher_code, student_code, v.v.) được lưu
// riêng trong metadata và hiển thị trong card vai trò tương ứng.

typedef _ExtraOption = ({
  String key,
  String label,
  IconData icon,
  String hint,
});

class _AddExtraSheet extends StatefulWidget {
  final List<String> existingKeys;
  final String userRole;
  final void Function(Map<String, String> extra) onAdd;

  const _AddExtraSheet({
    required this.existingKeys,
    required this.userRole,
    required this.onAdd,
  });

  @override
  State<_AddExtraSheet> createState() => _AddExtraSheetState();
}

class _AddExtraSheetState extends State<_AddExtraSheet> {
  // Toàn bộ options có thể thêm vào extras
  static final List<_ExtraOption> _allOptions = [
    (
      key: 'facebook',
      label: 'Facebook',
      icon: Icons.facebook,
      hint: 'URL hoặc tên người dùng',
    ),
    (
      key: 'instagram',
      label: 'Instagram',
      icon: Icons.photo_camera_outlined,
      hint: '@tên_người_dùng',
    ),
    (
      key: 'tiktok',
      label: 'TikTok',
      icon: Icons.music_note,
      hint: '@tên_người_dùng',
    ),
    (
      key: 'youtube',
      label: 'YouTube',
      icon: Icons.play_circle_outline,
      hint: 'URL kênh YouTube',
    ),
    (
      key: 'zalo',
      label: 'Zalo',
      icon: Icons.chat,
      hint: 'Số điện thoại Zalo',
    ),
    (
      key: 'linkedin',
      label: 'LinkedIn',
      icon: Icons.work_outline,
      hint: 'URL LinkedIn',
    ),
    (
      key: 'github',
      label: 'GitHub',
      icon: Icons.code,
      hint: 'URL GitHub',
    ),
    (
      key: 'website',
      label: 'Website',
      icon: Icons.language,
      hint: 'https://...',
    ),
    (
      key: 'home_address',
      label: 'Địa chỉ nhà',
      icon: Icons.home,
      hint: 'Nhập địa chỉ',
    ),
    (
      key: 'custom',
      label: 'Tùy chỉnh',
      icon: Icons.add_circle_outline,
      hint: '',
    ),
  ];

  // Keys đã được xử lý trong card vai trò — không hiển thị trong extras
  Set<String> get _roleReservedKeys {
    switch (widget.userRole.toLowerCase()) {
      case 'student':
        // student_code, enrollment_class, school_name nằm trong card học sinh
        return {'teacher_code', 'employee_id'};
      case 'teacher':
        // teacher_code nằm trong card giáo viên
        return {'teacher_code', 'employee_id'};
      default:
        return {};
    }
  }

  _ExtraOption? _selected;
  final _valueCtrl = TextEditingController();
  final _labelCtrl = TextEditingController();

  @override
  void dispose() {
    _valueCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final value = _valueCtrl.text.trim();
    if (value.isEmpty || _selected == null) return;

    final label = _selected!.key == 'custom'
        ? (_labelCtrl.text.trim().isEmpty
            ? 'Tùy chỉnh'
            : _labelCtrl.text.trim())
        : _selected!.label;

    widget.onAdd({'key': _selected!.key, 'label': label, 'value': value});
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: _selected == null
            ? _buildTypeGrid(isDark)
            : _buildValueInput(isDark),
      ),
    );
  }

  Widget _buildTypeGrid(bool isDark) {
    final available = _allOptions.where((o) {
      if (o.key == 'custom') return true;
      if (widget.existingKeys.contains(o.key)) return false;
      if (_roleReservedKeys.contains(o.key)) return false;
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Thêm thông tin vào hồ sơ',
            style: DesignTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Chọn loại thông tin muốn thêm',
            style: DesignTypography.bodySmall.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: available.map((opt) {
              return InkWell(
                onTap: () => setState(() {
                  _selected = opt;
                  _valueCtrl.clear();
                  _labelCtrl.clear();
                }),
                borderRadius: BorderRadius.circular(DesignRadius.lg),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(DesignRadius.lg),
                    border: Border.all(
                      color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(opt.icon, size: 18, color: DesignColors.primary),
                      const SizedBox(width: 8),
                      Text(opt.label, style: DesignTypography.bodyMedium),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildValueInput(bool isDark) {
    final opt = _selected!;
    final isCustom = opt.key == 'custom';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selected = null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Icon(opt.icon, color: DesignColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                opt.label,
                style: DesignTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isCustom) ...[
            TextField(
              controller: _labelCtrl,
              decoration: InputDecoration(
                labelText: 'Tên trường',
                hintText: 'VD: Blog, Địa chỉ công ty...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.lg),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _valueCtrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: isCustom ? 'Nội dung' : opt.label,
              hintText: opt.hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignRadius.lg),
              ),
            ),
            onSubmitted: (_) => _confirm(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.lg),
                ),
              ),
              child: const Text('Thêm vào hồ sơ'),
            ),
          ),
        ],
      ),
    );
  }
}
