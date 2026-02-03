import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Dịch vụ xử lý deep linking cho ứng dụng
///
/// Dịch vụ này lắng nghe các deep links (universal links, custom URL schemes)
/// và chuyển hướng đến các route tương ứng trong GoRouter.
///
/// Cách sử dụng:
/// ```dart
/// // Khởi tạo trong main.dart
/// final deepLinkService = DeepLinkService();
/// await deepLinkService.initialize();
///
/// // Lắng nghe deep links
/// deepLinkService.linkStream.listen((uri) {
///   // Xử lý deep link
/// });
/// ```
class DeepLinkService {
  DeepLinkService._();
  
  static final DeepLinkService _instance = DeepLinkService._();
  static DeepLinkService get instance => _instance;

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  StreamSubscription<Uri>? _initialLinkSubscription;
  String? _pendingRouterPath;

  /// Router path đã parse từ deep link gần nhất (nếu có).
  /// Dùng để điều hướng sau khi app/router đã sẵn sàng.
  String? get pendingRouterPath => _pendingRouterPath;

  /// Khởi tạo dịch vụ deep linking
  ///
  /// Lắng nghe cả initial link (khi app được mở qua deep link)
  /// và link updates (khi app đang chạy và nhận deep link mới)
  Future<void> initialize() async {
    try {
      AppLogger.info('Đang khởi tạo DeepLinkService...');

      // Lắng nghe initial link (app được mở qua deep link)
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        AppLogger.info('Nhận initial deep link: $initialLink');
        _handleDeepLink(initialLink);
      }

      // Lắng nghe link updates (app đang chạy)
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (uri) {
          AppLogger.info('Nhận deep link update: $uri');
          _handleDeepLink(uri);
        },
        onError: (error) {
          AppLogger.error('Lỗi khi lắng nghe deep links', error: error);
        },
      );

      AppLogger.info('DeepLinkService đã khởi tạo thành công');
    } catch (e, stackTrace) {
      AppLogger.error('Lỗi khi khởi tạo DeepLinkService', error: e, stackTrace: stackTrace);
    }
  }

  /// Xử lý deep link và chuyển hướng đến route tương ứng
  ///
  /// [uri] - URI của deep link
  void _handleDeepLink(Uri uri) {
    try {
      AppLogger.debug('Xử lý deep link: $uri');

      // Lấy path từ URI
      final path = uri.path;
      final queryParams = uri.queryParameters;

      AppLogger.debug('Path: $path, Query params: $queryParams');

      // Chuyển đổi deep link sang GoRouter path
      String? routerPath;

      // Xử lý các deep link cụ thể
      if (path.startsWith('/reset-password')) {
        // Deep link reset password
        final token = queryParams['token'];
        if (token != null) {
          routerPath = '${AppRoute.resetPasswordPath}?token=$token';
        }
      } else if (path.startsWith('/verify-email')) {
        // Deep link xác thực email
        final token = queryParams['token'];
        if (token != null) {
          routerPath = '${AppRoute.emailVerificationPath}?token=$token';
        }
      } else if (path.startsWith('/class/')) {
        // Deep link đến lớp học
        final classId = path.split('/').last;
        routerPath = AppRoute.studentClassDetailPath(classId);
      } else if (path.startsWith('/assignment/')) {
        // Deep link đến bài tập
        final assignmentId = path.split('/').last;
        routerPath = AppRoute.studentAssignmentDetailPath(assignmentId);
      } else {
        // Các deep link khác
        routerPath = path;
      }

      if (routerPath != null) {
        AppLogger.info('Chuyển hướng đến: $routerPath');
        // Lưu pending path để điều hướng khi router/context sẵn sàng.
        _pendingRouterPath = routerPath;
      } else {
        AppLogger.info('Deep link không hợp lệ: $path');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Lỗi khi xử lý deep link', error: e, stackTrace: stackTrace);
    }
  }

  /// Apply pending deep link navigation (nếu có) sau khi router đã sẵn sàng.
  /// An toàn để gọi nhiều lần; chỉ điều hướng khi có pendingRouterPath.
  void applyPendingDeepLink(BuildContext context) {
    final path = _pendingRouterPath;
    if (path == null || path.isEmpty) return;

    try {
      AppLogger.info('Apply pending deep link: $path');
      _pendingRouterPath = null; // clear first to avoid loops
      context.go(path);
    } catch (e, stackTrace) {
      AppLogger.error('Lỗi khi apply pending deep link', error: e, stackTrace: stackTrace);
    }
  }

  /// Chuyển hướng đến route trong GoRouter
  ///
  /// [context] - BuildContext để truy cập GoRouter
  /// [path] - Đường dẫn route
  /// [queryParams] - Query parameters (nếu có)
  static void navigateToRoute(
    BuildContext context,
    String path, {
    Map<String, String>? queryParams,
  }) {
    try {
      AppLogger.debug('Chuyển hướng đến route: $path');

      // Sử dụng GoRouter để điều hướng
      if (queryParams != null && queryParams.isNotEmpty) {
        // Thêm query parameters vào path
        final uri = Uri(path: path, queryParameters: queryParams);
        context.go(uri.toString());
      } else {
        context.go(path);
      }

      AppLogger.info('Đã chuyển hướng đến $path');
    } catch (e, stackTrace) {
      AppLogger.error('Lỗi khi chuyển hướng đến route', error: e, stackTrace: stackTrace);
    }
  }

  /// Giải phóng tài nguyên
  void dispose() {
    AppLogger.info('Đang giải phóng DeepLinkService...');
    _linkSubscription?.cancel();
    _initialLinkSubscription?.cancel();
    AppLogger.info('DeepLinkService đã được giải phóng');
  }
}
