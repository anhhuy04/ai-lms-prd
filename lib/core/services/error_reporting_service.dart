import 'package:ai_mls/core/env/env.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Dịch vụ báo cáo lỗi tập trung sử dụng Sentry
///
/// Dịch vụ này cung cấp:
/// - Tự động ghi lại lỗi Flutter và Dart
/// - Theo dõi breadcrumb cho các hành động người dùng
/// - Theo dõi ngữ cảnh người dùng
/// - Theo dõi phiên bản
///
/// Cách sử dụng:
/// ```dart
/// // Khởi tạo trong main.dart trước khi app khởi động
/// await ErrorReportingService.initialize();
///
/// // Thêm breadcrumbs cho các hành động người dùng
/// ErrorReportingService.addBreadcrumb('Người dùng đã đăng nhập', {'userId': '123'});
///
/// // Đặt ngữ cảnh người dùng
/// ErrorReportingService.setUser(userId: '123', email: 'user@example.com');
///
/// // Ghi lại ngoại lệ thủ công
/// ErrorReportingService.captureException(error, stackTrace: stackTrace);
/// ```
class ErrorReportingService {
  ErrorReportingService._();

  static bool _isInitialized = false;

  /// Khởi tạo báo cáo lỗi Sentry
  ///
  /// Nên được gọi trong main.dart trước khi khởi tạo app.
  /// Thiết lập các trình xử lý lỗi cho cả lỗi Flutter và Dart.
  ///
  /// [appRunner] - Hàm chạy app (thường là runApp)
  static Future<void> initialize({
    required Future<void> Function() appRunner,
  }) async {
    if (_isInitialized) {
      return;
    }

    final dsn = Env.sentryDsn;
    if (dsn.isEmpty) {
      // Nếu DSN chưa được cấu hình, bỏ qua khởi tạo Sentry
      // Cho phép app chạy mà không có Sentry trong development
      if (kDebugMode) {
        AppLogger.warning(
          '⚠️ Sentry DSN chưa được cấu hình. Báo cáo lỗi đã bị tắt.',
        );
      }
      await appRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.environment = kDebugMode ? 'development' : 'production';
        options.tracesSampleRate = kDebugMode ? 1.0 : 0.1; // 100% trong dev, 10% trong prod
        options.profilesSampleRate = kDebugMode ? 1.0 : 0.1;
        
        // Cấu hình theo dõi phiên bản
        options.release = _getReleaseVersion();
      },
      appRunner: () async {
        // Thiết lập trình xử lý lỗi Flutter
        FlutterError.onError = (FlutterErrorDetails details) {
          FlutterError.presentError(details);
          Sentry.captureException(
            details.exception,
            stackTrace: details.stack,
            hint: Hint.withMap({'flutterError': true}),
          );
        };

        // Thiết lập trình xử lý lỗi Dart
        PlatformDispatcher.instance.onError = (error, stack) {
          Sentry.captureException(
            error,
            stackTrace: stack,
            hint: Hint.withMap({'dartError': true}),
          );
          return true; // Báo hiệu lỗi đã được xử lý
        };

        _isInitialized = true;
        await appRunner();
      },
    );
  }

  /// Lấy phiên bản từ pubspec.yaml hoặc environment
  static String _getReleaseVersion() {
    // Thử lấy phiên bản từ biến môi trường trước
    const versionFromEnv = String.fromEnvironment('APP_VERSION');
    if (versionFromEnv.isNotEmpty) {
      return versionFromEnv;
    }

    // Phiên bản mặc định (nên được cập nhật từ pubspec.yaml trong CI/CD)
    return '1.0.0';
  }

  /// Thêm breadcrumb để theo dõi các hành động người dùng
  ///
  /// Breadcrumb giúp hiểu người dùng đang làm gì trước khi lỗi xảy ra.
  ///
  /// [message] - Mô tả hành động
  /// [data] - Dữ liệu bổ sung về hành động
  /// [level] - Cấp độ nghiêm trọng (mặc định: info)
  static void addBreadcrumb(
    String message, {
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.info,
  }) {
    if (!_isInitialized) return;

    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        data: data,
        level: level,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Đặt ngữ cảnh người dùng cho theo dõi lỗi
  ///
  /// Giúp xác định người dùng nào đang gặp lỗi.
  ///
  /// [userId] - Định danh người dùng duy nhất
  /// [email] - Email người dùng (tùy chọn)
  /// [username] - Tên người dùng (tùy chọn)
  /// [data] - Dữ liệu người dùng bổ sung (tùy chọn)
  static void setUser({
    required String userId,
    String? email,
    String? username,
    Map<String, dynamic>? data,
  }) {
    if (!_isInitialized) return;

    Sentry.configureScope((scope) {
      scope.setUser(
        SentryUser(
          id: userId,
          email: email,
          username: username,
          data: data,
        ),
      );
    });
  }

  /// Xóa ngữ cảnh người dùng (ví dụ: khi đăng xuất)
  static void clearUser() {
    if (!_isInitialized) return;

    Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }

  /// Ghi lại ngoại lệ thủ công
  ///
  /// Sử dụng khi muốn báo cáo lỗi rõ ràng lên Sentry.
  ///
  /// [exception] - Ngoại lệ cần ghi lại
  /// [stackTrace] - Stack trace (tùy chọn nhưng nên có)
  /// [hint] - Ngữ cảnh bổ sung (tùy chọn)
  static Future<void> captureException(
    Object exception, {
    StackTrace? stackTrace,
    Hint? hint,
  }) async {
    if (!_isInitialized) return;

    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      hint: hint,
    );
  }

  /// Ghi lại một tin nhắn (sự kiện không phải ngoại lệ)
  ///
  /// Sử dụng để ghi log các sự kiện quan trọng không phải ngoại lệ.
  ///
  /// [message] - Tin nhắn cần ghi lại
  /// [level] - Cấp độ nghiêm trọng (mặc định: info)
  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
  }) async {
    if (!_isInitialized) return;

    await Sentry.captureMessage(message, level: level);
  }

  /// Đặt tag để lọc lỗi trong dashboard Sentry
  ///
  /// [key] - Khóa tag
  /// [value] - Giá trị tag
  static void setTag(String key, String value) {
    if (!_isInitialized) return;

    Sentry.configureScope((scope) {
      scope.setTag(key, value);
    });
  }
}
