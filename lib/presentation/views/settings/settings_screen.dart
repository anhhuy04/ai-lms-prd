import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/services/api_key_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
        elevation: 0,
        title: Text(
          'Cài đặt',
          style: DesignTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(DesignSpacing.lg),
        children: [
          // API Settings Section
          _buildSection(
            context,
            title: 'API & Tích hợp',
            icon: Icons.api_rounded,
            isDark: isDark,
            children: [
              _buildSettingsTile(
                context,
                title: 'Cài đặt API Key',
                subtitle: 'Quản lý Gemini API Key và các API keys khác',
                icon: Icons.key_rounded,
                iconColor: DesignColors.primary,
                isDark: isDark,
                onTap: () => context.push(AppRoute.apiKeySetupPath),
                trailing: FutureBuilder<bool>(
                  future: ApiKeyService.hasGeminiApiKey(),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: DesignColors.success,
                          shape: BoxShape.circle,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: DesignSpacing.xl),

          // Account Settings Section
          _buildSection(
            context,
            title: 'Tài khoản',
            icon: Icons.account_circle_outlined,
            isDark: isDark,
            children: [
              _buildSettingsTile(
                context,
                title: 'Hồ sơ',
                subtitle: 'Xem và chỉnh sửa thông tin cá nhân',
                icon: Icons.person_outline,
                iconColor: DesignColors.tealPrimary,
                isDark: isDark,
                onTap: () => context.push(AppRoute.profilePath),
              ),
            ],
          ),

          SizedBox(height: DesignSpacing.xl),

          // App Settings Section
          _buildSection(
            context,
            title: 'Ứng dụng',
            icon: Icons.settings_outlined,
            isDark: isDark,
            children: [
              _buildSettingsTile(
                context,
                title: 'Thông báo',
                subtitle: 'Quản lý thông báo đẩy',
                icon: Icons.notifications_outlined,
                iconColor: DesignColors.warning,
                isDark: isDark,
                onTap: () {
                  // TODO: Implement notifications settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng đang phát triển'),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                context,
                title: 'Ngôn ngữ',
                subtitle: 'Tiếng Việt',
                icon: Icons.language_outlined,
                iconColor: DesignColors.info,
                isDark: isDark,
                onTap: () {
                  // TODO: Implement language settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng đang phát triển'),
                    ),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: DesignSpacing.xl),

          // About Section
          _buildSection(
            context,
            title: 'Về ứng dụng',
            icon: Icons.info_outline,
            isDark: isDark,
            children: [
              _buildSettingsTile(
                context,
                title: 'Phiên bản',
                subtitle: '1.0.0',
                icon: Icons.phone_android_outlined,
                iconColor: DesignColors.textSecondary,
                isDark: isDark,
                onTap: null,
              ),
              _buildSettingsTile(
                context,
                title: 'Điều khoản sử dụng',
                subtitle: 'Xem điều khoản và chính sách',
                icon: Icons.description_outlined,
                iconColor: DesignColors.textSecondary,
                isDark: isDark,
                onTap: () {
                  // TODO: Implement terms
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng đang phát triển'),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                context,
                title: 'Chính sách bảo mật',
                subtitle: 'Xem chính sách bảo mật',
                icon: Icons.privacy_tip_outlined,
                iconColor: DesignColors.textSecondary,
                isDark: isDark,
                onTap: () {
                  // TODO: Implement privacy policy
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng đang phát triển'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
  }) {
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
              Icon(icon, size: 20, color: DesignColors.primary),
              const SizedBox(width: 8),
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
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 8,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignRadius.md),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: DesignTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : DesignColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: DesignTypography.bodySmall.copyWith(
          color: isDark ? Colors.grey[400] : DesignColors.textSecondary,
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                )
              : null),
      onTap: onTap,
    );
  }
}
