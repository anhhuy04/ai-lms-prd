import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hàm xử lý làm mới chung cho các trang dashboard.
///
/// Tải lại dữ liệu người dùng và có thể mở rộng để tải lại các dữ liệu khác.
///
/// **LƯU Ý:** Hàm này yêu cầu Widget phải được wrap trong `ConsumerWidget` hoặc `Consumer`
/// để có thể truy cập `WidgetRef`.
///
/// **DEPRECATED:** Theo pattern mới, các dashboard notifiers đã có method `refresh()` riêng.
/// Nên sử dụng `ref.read(dashboardNotifierProvider.notifier).refresh()` trực tiếp thay vì hàm này.
@Deprecated(
  'Sử dụng dashboard notifier refresh() method trực tiếp thay vì hàm này',
)
Future<void> handleDashboardRefresh(WidgetRef ref) async {
  // Gọi AuthNotifier để tải lại dữ liệu người dùng.
  await ref.read(currentUserProvider.notifier).checkCurrentUser();

  // Ví dụ mở rộng trong tương lai:
  // await ref.read(assignmentNotifierProvider.notifier).refresh();
  // await ref.read(scoresNotifierProvider.notifier).refresh();
}

/// **REFRESH INDICATOR CONFIGURATION**
///
/// Để sử dụng RefreshIndicator với cấu hình chung cho toàn bộ app, sử dụng:
/// ```dart
/// import 'package:ai_mls/widgets/refresh/app_refresh_indicator.dart';
///
/// AppRefreshIndicator(
///   onRefresh: () async {
///     await _loadData();
///   },
///   child: ListView.builder(...),
/// )
/// ```
///
/// **Lợi ích:**
/// - Màu sắc đồng bộ (xanh nước biển) được định nghĩa trong `DesignColors.refreshIndicator`
/// - Cấu hình thống nhất (displacement, strokeWidth, etc.)
/// - Dễ dàng thay đổi toàn bộ app chỉ bằng cách sửa `app_refresh_indicator.dart`
///
/// **Thay đổi màu hoặc hoạt ảnh:**
/// - Sửa `DesignColors.refreshIndicator` trong `design_tokens.dart` để thay đổi màu
/// - Sửa default values trong `AppRefreshIndicator` constructor để thay đổi cấu hình khác
