import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/profile.dart';
import 'package:flutter/material.dart';

/// Utility class cho avatar widgets
class AvatarUtils {
  AvatarUtils._(); // Prevent instantiation

  /// Xây dựng avatar với chữ cái đầu nếu không có hình nền
  /// 
  /// Sử dụng cùng styling như dashboard:
  /// - Background: DesignColors.primary.withOpacity(0.1)
  /// - Text color: DesignColors.primary
  /// - Font size: 14, bold
  static Widget buildAvatar({
    required Profile? profile,
    double size = 28.0,
    Color? borderColor,
  }) {
    // Kiểm tra nếu profile null hoặc không có avatarUrl
    final hasAvatar =
        profile?.avatarUrl != null && (profile!.avatarUrl?.isNotEmpty ?? false);
    final fullName = profile?.fullName ?? '';
    final initials = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
    final avatarUrl = profile?.avatarUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: ClipOval(
        child: hasAvatar && avatarUrl != null
            ? Image.network(
                avatarUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialAvatar(initials, size);
                },
              )
            : _buildInitialAvatar(initials, size),
      ),
    );
  }

  /// Xây dựng avatar với chữ cái đầu (giống dashboard)
  static Widget _buildInitialAvatar(String initials, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: DesignColors.primary.withOpacity(0.1),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.5, // Tỷ lệ font size với size
            color: DesignColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
