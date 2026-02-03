import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/profile.dart';
import 'package:flutter/material.dart';

/// Utility class cho avatar widgets
class AvatarUtils {
  AvatarUtils._(); // Prevent instantiation

  /// Xây dựng avatar với chữ cái đầu nếu không có hình nền
  ///
  /// Sử dụng cùng styling như dashboard:
  /// - Background: DesignColors.primary.withValues(alpha: 0.1)
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
    // Lấy chữ đầu của tên (từ cuối chuỗi, sau dấu cách cuối cùng)
    // Ví dụ: "Nguyễn Văn A" -> "A", "Trần Thị B" -> "B"
    final initials = _getFirstNameInitial(fullName);
    final avatarUrl = profile?.avatarUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor ?? Colors.grey[300]!, width: 1),
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

  /// Lấy chữ đầu của tên (từ cuối chuỗi)
  /// Ví dụ: "Nguyễn Văn A" -> "A", "Trần Thị B" -> "B"
  static String _getFirstNameInitial(String fullName) {
    if (fullName.isEmpty) return '?';

    // Trim và tách các từ
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '?';

    // Lấy từ cuối cùng (tên)
    final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';

    // Lấy chữ đầu của từ cuối cùng
    final firstName = parts.last;
    return firstName[0].toUpperCase();
  }

  /// Xây dựng avatar với chữ cái đầu (giống dashboard)
  static Widget _buildInitialAvatar(String initials, double size) {
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
            fontSize: size * 0.5, // Tỷ lệ font size với size
            color: DesignColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
