import 'package:ai_mls/widgets/cards/base_card.dart';
import 'package:flutter/material.dart';

/// Widget hiển thị management card với icon, label và số lượng
/// Teacher-specific widget sử dụng BaseCard
class AssignmentManagementCard extends StatelessWidget {
  final String label;
  final int count;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;
  final VoidCallback? onTap;

  const AssignmentManagementCard({
    super.key,
    required this.label,
    required this.count,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      label: label,
      count: count,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      textColor: textColor,
      icon: icon,
      onTap: onTap,
    );
  }
}
