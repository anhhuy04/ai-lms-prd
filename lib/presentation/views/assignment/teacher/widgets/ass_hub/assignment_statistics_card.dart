import 'package:ai_mls/widgets/cards/statistics_card.dart';
import 'package:flutter/material.dart';

/// Widget hiển thị statistics card với icon, label và value
/// Teacher-specific widget sử dụng StatisticsCard
class AssignmentStatisticsCard extends StatelessWidget {
  final String label;
  final int value;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData? icon;

  const AssignmentStatisticsCard({
    super.key,
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return StatisticsCard(
      label: label,
      value: value,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor,
      icon: icon,
    );
  }
}
