import 'package:flutter/material.dart';

/// Configuration cho AssignmentCard badge
class AssignmentBadgeConfig {
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const AssignmentBadgeConfig({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  /// Badge cho draft assignment
  static const draft = AssignmentBadgeConfig(
    label: 'Bản nháp',
    backgroundColor: Color(0xFFFFF4E6), // orange[50]
    borderColor: Color(0xFFFFB366), // orange[300]
    textColor: Color(0xFFB45309), // orange[700]
  );

  /// Badge cho published assignment
  static const published = AssignmentBadgeConfig(
    label: 'Đã xuất bản',
    backgroundColor: Color(0xFFF0FDF4), // green[50]
    borderColor: Color(0xFF86EFAC), // green[300]
    textColor: Color(0xFF15803D), // green[700]
  );
}

/// Configuration cho AssignmentCard action button
class AssignmentActionConfig {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const AssignmentActionConfig({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}

/// Configuration cho metadata display
class AssignmentMetadataConfig {
  final bool showPoints;
  final bool showDueDate;
  final bool showLastUpdated;

  const AssignmentMetadataConfig({
    this.showPoints = true,
    this.showDueDate = false,
    this.showLastUpdated = true,
  });

  /// Config cho draft (không có due date)
  static const draft = AssignmentMetadataConfig(
    showPoints: true,
    showDueDate: false,
    showLastUpdated: true,
  );

  /// Config cho published (có due date)
  static const published = AssignmentMetadataConfig(
    showPoints: true,
    showDueDate: true,
    showLastUpdated: true,
  );
}
