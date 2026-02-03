import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/services/api_key_service.dart';
import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
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
  String? _selectedGender;
  Profile? _lastSyncedUser; // Track để tránh update không cần thiết

  @override
  void initState() {
    super.initState();
    // Initialize controllers với giá trị mặc định
    _fullNameController = TextEditingController();
    _bioController = TextEditingController();
    _phoneController = TextEditingController();

    // Initialize với data hiện tại nếu có (sau khi widget được mount)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateControllersFromUser();
      }
    });
  }

  /// Update controllers từ user data (chỉ khi user thay đổi)
  void _updateControllersFromUser() {
    if (!mounted) return;

    final user = ref.read(authNotifierProvider).value;
    if (user != null && user != _lastSyncedUser) {
      _lastSyncedUser = user;
      _fullNameController.text = user.fullName ?? '';
      _bioController.text = user.bio ?? '';
      _phoneController.text = user.phone ?? '';
      _selectedGender = user.gender;
    }
  }

  /// Refresh profile data
  Future<void> _refreshProfile() async {
    if (!mounted) return;

    try {
      await ref.read(authNotifierProvider.notifier).checkCurrentUser();
      // Update controllers với data mới
      if (mounted) {
        _updateControllersFromUser();
      }
    } catch (e) {
      // Error đã được handle bởi authNotifierProvider
      // Chỉ cần đảm bảo không crash
      if (mounted && _isEditing) {
        setState(() => _isEditing = false);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    if (!mounted) return;

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    try {
      final authRepo = ref.read(authRepositoryProvider);

      // Show loading indicator
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
      );

      // Refresh auth state để lấy profile mới
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

    // Update controllers khi user thay đổi (không phải từ refresh)
    authState.whenData((user) {
      if (user != null && user != _lastSyncedUser && !_isEditing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateControllersFromUser();
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
        elevation: 0,
        title: Text(
          'Hồ sơ',
          style: DesignTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
        ),
        actions: [
          Builder(
            builder: (context) {
              final currentUser = authState.value;
              if (!_isEditing && currentUser != null) {
                return IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => setState(() => _isEditing = true),
                  tooltip: 'Chỉnh sửa',
                );
              }
              if (_isEditing) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (!mounted) return;
                        setState(() => _isEditing = false);
                        // Reset form về giá trị ban đầu
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
      body: authState.when(
        data: (user) {
          if (user == null) {
            return _buildNotLoggedInState();
          }
          return _buildProfileContent(user, isDark);
        },
        loading: () => const ProfileShimmerLoading(),
        error: (error, stackTrace) => _buildErrorState(error),
      ),
    );
  }

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
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildDefaultAvatar();
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar();
                          },
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
          if (!_isEditing)
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
      case 'student':
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
      case 'student':
      default:
        return 'Học sinh';
    }
  }

  Widget _buildProfileInfoSection(
    BuildContext context,
    Profile user,
    bool isDark,
  ) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THÔNG TIN CÁ NHÂN',
            style: TextStyle(
              fontSize: DesignTypography.labelSmallSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          // Bio (multi-line)
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
          // Phone
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
          // Gender
          _buildInfoField(
            context,
            label: 'Giới tính',
            icon: Icons.wc_outlined,
            isDark: isDark,
            isSingleLine: true,
            child: _isEditing
                ? DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
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
                    onChanged: (value) =>
                        setState(() => _selectedGender = value),
                  )
                : Text(
                    _getGenderLabel(user.gender),
                    style: DesignTypography.bodyMedium,
                  ),
          ),
          const SizedBox(height: 16),
          // Updated At
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

  Widget _buildInfoField(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Widget child,
    required bool isDark,
    bool isSingleLine = false,
  }) {
    if (isSingleLine) {
      // Hiển thị trên 1 dòng: Label và value cùng hàng
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: DesignColors.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
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
          Expanded(child: child),
        ],
      );
    }

    // Hiển thị trên 2 dòng: Label trên, value dưới (cho tiểu sử)
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
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Widget _buildQuickActionsSection(BuildContext context, bool isDark) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
        children: [
              Icon(
                Icons.settings_outlined,
                size: 20,
                color: DesignColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'THAO TÁC NHANH',
                style: TextStyle(
                  fontSize: DesignTypography.labelSmallSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DesignColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignRadius.md),
              ),
              child: Icon(
                Icons.key_rounded,
                color: DesignColors.primary,
                size: 20,
              ),
            ),
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    'Đang kiểm tra...',
                    style: DesignTypography.bodySmall.copyWith(
                      color: DesignColors.textTertiary,
                    ),
                  );
                }
                final hasKey = snapshot.data ?? false;
                return Text(
                  hasKey ? 'Đã cấu hình' : 'Chưa cấu hình',
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
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DesignColors.tealPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignRadius.md),
              ),
              child: Icon(
                Icons.settings_rounded,
                color: DesignColors.tealPrimary,
                size: 20,
              ),
            ),
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

  Widget _buildMetadataSection(
    BuildContext context,
    Profile user,
    bool isDark,
  ) {
    final metadata = user.metadata;
    if (metadata == null || metadata.isEmpty) {
      return const SizedBox.shrink();
    }

    // Kiểm tra xem có API keys trong metadata không
    final apiKeys = metadata['api_keys'];
    final hasApiKeys = apiKeys is Map<String, dynamic> && apiKeys.isNotEmpty;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.data_object_outlined,
                size: 20,
                color: DesignColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'METADATA',
                style: TextStyle(
                  fontSize: DesignTypography.labelSmallSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasApiKeys) ...[
            _buildInfoField(
              context,
              label: 'API Keys',
              icon: Icons.key_rounded,
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasApiKeys && apiKeys.containsKey('gemini'))
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: DesignColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DesignRadius.sm),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: DesignColors.success,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Gemini API Key: Đã cấu hình',
                            style: DesignTypography.bodySmall.copyWith(
                              color: DesignColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (hasApiKeys && apiKeys.containsKey('ai'))
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DesignColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DesignRadius.sm),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: DesignColors.info,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI API Key: Đã cấu hình',
                            style: DesignTypography.bodySmall.copyWith(
                              color: DesignColors.info,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ] else
            Text(
              'Không có metadata',
              style: DesignTypography.bodySmall.copyWith(
                color: DesignColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  /// Build profile content với pull-to-refresh
  Widget _buildProfileContent(Profile user, bool isDark) {
    return AppRefreshIndicator(
      onRefresh: _refreshProfile,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: DesignSpacing.lg,
          right: DesignSpacing.lg,
          top: DesignSpacing.lg,
          bottom:
              DesignSpacing.lg +
              100, // Thêm padding bottom để tránh bị che bởi bottom bar
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              _buildAvatarSection(context, user, isDark),
              SizedBox(height: DesignSpacing.xxl),

              // Profile Information
              _buildProfileInfoSection(context, user, isDark),
              SizedBox(height: DesignSpacing.xxl),

              // Quick Actions
              _buildQuickActionsSection(context, isDark),
              SizedBox(height: DesignSpacing.xxl),

              // Metadata Info (if available)
              if (user.metadata != null && user.metadata!.isNotEmpty)
                _buildMetadataSection(context, user, isDark),
              if (user.metadata != null && user.metadata!.isNotEmpty)
                SizedBox(height: DesignSpacing.xxl),

              // Account Actions
              _buildAccountActionsSection(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  /// Build error state với retry button
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

  /// Build not logged in state
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
      child: Column(
        children: [
          ListTile(
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
                if (mounted) {
                context.go(AppRoute.loginPath);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
