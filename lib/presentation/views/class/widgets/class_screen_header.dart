import 'package:ai_mls/core/utils/avatar_utils.dart';
import 'package:flutter/material.dart';

/// Header chung cho màn hình danh sách lớp học (teacher và student)
class ClassScreenHeader extends StatelessWidget {
  /// Tiêu đề chính (mặc định: "Lớp học của tôi")
  final String title;

  /// Phụ đề (mặc định: "Năm học 2023 - 2024")
  final String subtitle;

  /// Callback khi bấm nút search
  final VoidCallback? onSearch;

  /// Callback khi bấm nút notifications
  final VoidCallback? onNotifications;

  /// Profile để hiển thị avatar
  final dynamic profile;

  const ClassScreenHeader({
    super.key,
    this.title = 'Lớp học của tôi',
    this.subtitle = 'Năm học 2023 - 2024',
    this.onSearch,
    this.onNotifications,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (onSearch != null)
                IconButton(
                  icon: Icon(
                    Icons.search,
                    size: 20,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: onSearch,
                ),
              if (onNotifications != null)
                IconButton(
                  icon: Icon(
                    Icons.notifications,
                    size: 20,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: onNotifications,
                ),
              const SizedBox(width: 6),
              AvatarUtils.buildAvatar(profile: profile),
            ],
          ),
        ],
      ),
    );
  }
}
