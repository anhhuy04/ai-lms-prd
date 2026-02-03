import 'package:flutter/material.dart';

/// Card hành động chính cho màn hình danh sách lớp học
/// Có thể dùng cho cả teacher (tạo lớp) và student (tham gia lớp)
class ClassPrimaryActionCard extends StatelessWidget {
  /// Icon hiển thị trong card
  final IconData icon;

  /// Màu của icon và button
  final Color color;

  /// Tiêu đề của card
  final String title;

  /// Mô tả ngắn
  final String description;

  /// Text của button
  final String buttonText;

  /// Callback khi bấm button
  final VoidCallback onPressed;

  const ClassPrimaryActionCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });

  /// Factory constructor cho teacher (tạo lớp mới)
  factory ClassPrimaryActionCard.forTeacher({
    required VoidCallback onPressed,
  }) {
    return ClassPrimaryActionCard(
      icon: Icons.domain_add,
      color: Colors.blue[800]!,
      title: 'Thêm Lớp học mới',
      description: 'Tạo không gian lớp học để quản lý',
      buttonText: 'Tạo ngay',
      onPressed: onPressed,
    );
  }

  /// Factory constructor cho student (tham gia lớp)
  factory ClassPrimaryActionCard.forStudent({
    required VoidCallback onPressed,
  }) {
    return ClassPrimaryActionCard(
      icon: Icons.join_inner,
      color: Colors.blue[800]!,
      title: 'Tham gia Lớp học',
      description: 'Nhập mã lớp để tham gia',
      buttonText: 'Tham gia',
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
