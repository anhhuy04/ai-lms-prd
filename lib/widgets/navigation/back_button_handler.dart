import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Widget wrapper để xử lý nút back vật lý cho toàn bộ app
/// Ngăn app tự động thoát khi bấm back button và không có route để pop
class BackButtonHandler extends ConsumerWidget {
  final Widget child;

  const BackButtonHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false, // Ngăn app tự động thoát khi bấm back
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBackButton(context, ref);
      },
      child: child,
    );
  }

  /// Xử lý khi người dùng bấm nút back vật lý
  void _handleBackButton(BuildContext context, WidgetRef ref) {
    // Nếu có route để pop, thì pop
    if (context.canPop()) {
      context.pop();
      return;
    }

    // Nếu không có route để pop, điều hướng về dashboard tương ứng với role
    final currentUser = ref.read(currentUserProvider).value;
    final userRole = currentUser?.role ?? '';

    // Điều hướng về dashboard tương ứng với role
    final dashboardPath = AppRoute.getDashboardPathForRole(userRole);

    // Chỉ điều hướng nếu đang không ở dashboard
    final currentPath = GoRouterState.of(context).matchedLocation;
    if (currentPath != dashboardPath) {
      context.go(dashboardPath);
    } else {
      // Nếu đã ở dashboard rồi mà vẫn bấm back, có thể hiển thị dialog xác nhận
      // hoặc đơn giản là không làm gì (giữ nguyên màn hình hiện tại)
      // Hoặc có thể thoát app nếu muốn
      // Ở đây chúng ta sẽ không làm gì để giữ user ở dashboard
    }
  }
}
