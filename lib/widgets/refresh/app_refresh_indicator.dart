import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// Widget wrapper cho RefreshIndicator với cấu hình chung cho toàn bộ app.
///
/// Sử dụng widget này thay vì RefreshIndicator trực tiếp để đảm bảo:
/// - Màu sắc đồng bộ (xanh nước biển)
/// - Cấu hình thống nhất
/// - Dễ dàng thay đổi toàn bộ app chỉ bằng cách sửa file này
///
/// **Ví dụ sử dụng:**
/// ```dart
/// AppRefreshIndicator(
///   onRefresh: () async {
///     await _loadData();
///   },
///   child: ListView.builder(...),
/// )
/// ```
class AppRefreshIndicator extends StatelessWidget {
  /// Callback được gọi khi user pull-to-refresh
  final Future<void> Function() onRefresh;

  /// Widget con cần được wrap trong RefreshIndicator
  final Widget child;

  /// Màu của refresh indicator (mặc định: DesignColors.refreshIndicator)
  final Color? color;

  /// Màu nền của refresh indicator
  final Color? backgroundColor;

  /// Khoảng cách từ trên xuống để trigger refresh
  final double? displacement;

  /// Khoảng cách từ cạnh để hiển thị indicator
  final double? edgeOffset;

  /// Kích thước của indicator
  final double? strokeWidth;

  /// Trigger refresh khi scroll đến đầu danh sách
  final RefreshIndicatorTriggerMode triggerMode;

  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
    this.displacement,
    this.edgeOffset,
    this.strokeWidth,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? DesignColors.refreshIndicator,
      backgroundColor: backgroundColor,
      displacement: displacement ?? 40.0,
      edgeOffset: edgeOffset ?? 0.0,
      strokeWidth: strokeWidth ?? 2.0,
      triggerMode: triggerMode,
      child: child,
    );
  }
}
