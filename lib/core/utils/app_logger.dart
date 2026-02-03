import 'package:ai_mls/core/services/error_reporting_service.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Dịch vụ ghi log tập trung cho ứng dụng
///
/// Lớp này cung cấp khả năng ghi log có cấu trúc với các cấp độ log khác nhau:
/// - debug: Thông tin chi tiết để gỡ lỗi (chỉ trong chế độ debug)
/// - info: Các thông báo thông tin chung
/// - warning: Các thông báo cảnh báo có thể chỉ ra các vấn đề tiềm ẩn
/// - error: Các thông báo lỗi chỉ ra sự cố
/// - fatal: Các lỗi nghiêm trọng có thể gây crash ứng dụng
///
/// Cách sử dụng:
/// ```dart
/// AppLogger.debug('Thông báo gỡ lỗi');
/// AppLogger.info('Thông báo thông tin');
/// AppLogger.warning('Thông báo cảnh báo');
/// AppLogger.error('Thông báo lỗi', error: e, stackTrace: st);
/// AppLogger.fatal('Lỗi nghiêm trọng', error: e, stackTrace: st);
/// ```
///
/// Trong các bản dựng production, chỉ các lỗi được ghi lại để giảm nhiễu.
/// Trong các bản dựng debug, tất cả các cấp độ log đều được hiển thị với màu sắc và dấu thời gian.

/// Custom output để đảm bảo log hiển thị trên debug console
class _ConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    // Sử dụng debugPrint để đảm bảo log hiển thị trên Flutter debug console
    for (final line in event.lines) {
      debugPrint(line);
    }
  }
}

class AppLogger {
  AppLogger._();

  /// Instance Logger tĩnh được cấu hình với PrettyPrinter
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Số lượng cuộc gọi phương thức được hiển thị
      errorMethodCount: 8, // Số lượng cuộc gọi phương thức nếu có stacktrace
      lineLength: 120, // Chiều rộng của đầu ra
      colors: true, // Tin nhắn log đầy màu sắc
      printEmojis: true, // In một emoji cho mỗi tin nhắn log
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Định dạng thời gian
    ),
    output: _ConsoleOutput(), // Sử dụng output tùy chỉnh để đảm bảo log hiển thị
    level: _getLogLevel(),
  );

  /// Lấy cấp độ log dựa trên môi trường
  ///
  /// - Chế độ Debug: Hiển thị tất cả các log (Level.all)
  /// - Production: Chỉ hiển thị lỗi và các cấp độ cao hơn (Level.error)
  static Level _getLogLevel() {
    if (kDebugMode) {
      return Level.all;
    } else {
      return Level.error;
    }
  }

  /// Ghi một tin nhắn debug
  ///
  /// Tin nhắn debug chỉ hiển thị trong các bản dựng debug.
  /// Sử dụng cái này cho thông tin gỡ lỗi chi tiết.
  ///
  /// [message] - Tin nhắn debug để ghi
  /// [error] - Đối tượng lỗi tùy chọn
  /// [stackTrace] - Stack trace tùy chọn
  static void debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Ghi một tin nhắn thông tin
  ///
  /// Sử dụng cái này cho các tin nhắn thông tin chung về luồng ứng dụng.
  /// Thêm breadcrumb vào Sentry để theo dõi ngữ cảnh.
  ///
  /// [message] - Tin nhắn thông tin để ghi
  /// [error] - Đối tượng lỗi tùy chọn
  /// [stackTrace] - Stack trace tùy chọn
  static void info(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.i(message, error: error, stackTrace: stackTrace);

    // Thêm breadcrumb để theo dõi ngữ cảnh
    ErrorReportingService.addBreadcrumb(
      message,
      data: error != null ? {'error': error.toString()} : null,
      level: SentryLevel.info,
    );
  }

  /// Ghi một tin nhắn cảnh báo
  ///
  /// Sử dụng cái này cho các cảnh báo có thể chỉ ra các vấn đề tiềm ẩn
  /// nhưng không ngăn ứng dụng hoạt động.
  /// Thêm breadcrumb vào Sentry để theo dõi ngữ cảnh.
  ///
  /// [message] - Tin nhắn cảnh báo để ghi
  /// [error] - Đối tượng lỗi tùy chọn
  /// [stackTrace] - Stack trace tùy chọn
  static void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.w(message, error: error, stackTrace: stackTrace);

    // Thêm breadcrumb để theo dõi cảnh báo
    ErrorReportingService.addBreadcrumb(
      message,
      data: error != null ? {'error': error.toString()} : null,
      level: SentryLevel.warning,
    );
  }

  /// Ghi một tin nhắn lỗi
  ///
  /// Sử dụng cái này cho các lỗi chỉ ra sự cố hoặc ngoại lệ.
  /// Lỗi luôn được ghi lại, ngay cả trong các bản dựng production.
  /// Tự động báo cáo lên Sentry để theo dõi lỗi.
  ///
  /// [message] - Tin nhắn lỗi để ghi
  /// [error] - Đối tượng lỗi tùy chọn
  /// [stackTrace] - Stack trace tùy chọn
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(message, error: error, stackTrace: stackTrace);

    // Tự động báo cáo lỗi lên Sentry
    if (error != null) {
      ErrorReportingService.captureException(
        error,
        stackTrace: stackTrace,
      );
    } else {
      // Nếu không có đối tượng lỗi, capture như một tin nhắn
      ErrorReportingService.captureMessage(message, level: SentryLevel.error);
    }

    // Thêm breadcrumb để theo dõi lỗi
    ErrorReportingService.addBreadcrumb(
      message,
      data: error != null ? {'error': error.toString()} : null,
      level: SentryLevel.error,
    );
  }

  /// Ghi một tin nhắn lỗi nghiêm trọng
  ///
  /// Sử dụng cái này cho các lỗi nghiêm trọng có thể gây crash ứng dụng.
  /// Tự động báo cáo lên Sentry với cấp độ fatal.
  ///
  /// [message] - Tin nhắn lỗi nghiêm trọng để ghi
  /// [error] - Đối tượng lỗi tùy chọn
  /// [stackTrace] - Stack trace tùy chọn
  static void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.f(message, error: error, stackTrace: stackTrace);

    // Tự động báo cáo lỗi nghiêm trọng lên Sentry
    if (error != null) {
      ErrorReportingService.captureException(
        error,
        stackTrace: stackTrace,
      );
    } else {
      ErrorReportingService.captureMessage(message, level: SentryLevel.fatal);
    }

    // Thêm breadcrumb để theo dõi lỗi nghiêm trọng
    ErrorReportingService.addBreadcrumb(
      message,
      data: error != null ? {'error': error.toString()} : null,
      level: SentryLevel.fatal,
    );
  }
}
