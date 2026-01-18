import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralized logging service for the application
///
/// This class provides structured logging with different log levels and
/// environment-based configuration. In development, all logs are shown.
/// In production, only errors are logged.
///
/// Usage:
/// ```dart
/// AppLogger.debug('Debug message');
/// AppLogger.info('Info message');
/// AppLogger.warning('Warning message');
/// AppLogger.error('Error message', error: exception, stackTrace: stackTrace);
/// ```
///
/// Future integration:
/// - Sentry error reporting (TODO 1.10)
/// - Breadcrumbs for user actions
class AppLogger {
  AppLogger._();

  /// Logger instance with PrettyPrinter configuration
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: kDebugMode ? 2 : 0, // Show method count in debug mode
      errorMethodCount: 8, // Always show more methods for errors
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
      noBoxingByDefault: false,
    ),
    level: _getLogLevel(),
  );

  /// Get log level based on environment
  static Level _getLogLevel() {
    if (kDebugMode) {
      return Level.trace; // Show all logs in debug mode
    } else {
      return Level.error; // Only show errors in production
    }
  }

  /// Log a debug message
  ///
  /// Use for detailed debugging information that is normally not needed
  /// in production builds.
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    } else {
      _logger.d(message);
    }
  }

  /// Log an info message
  ///
  /// Use for general informational messages about application flow.
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    } else {
      _logger.i(message);
    }

    // TODO: Add breadcrumb to Sentry (TODO 1.10)
    // ErrorReportingService.addBreadcrumb(message, level: 'info');
  }

  /// Log a warning message
  ///
  /// Use for warnings that don't prevent the app from functioning but
  /// indicate potential issues.
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    } else {
      _logger.w(message);
    }

    // TODO: Add breadcrumb to Sentry (TODO 1.10)
    // ErrorReportingService.addBreadcrumb(message, level: 'warning');
  }

  /// Log an error message
  ///
  /// Use for errors that need attention. In production, these will be
  /// automatically reported to Sentry (after TODO 1.10).
  static void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.e(message, error: error, stackTrace: stackTrace);

    // TODO: Auto-report to Sentry (TODO 1.10)
    // if (error != null) {
    //   ErrorReportingService.captureException(
    //     error,
    //     stackTrace: stackTrace,
    //     hint: message,
    //   );
    // }
  }

  /// Log a fatal error
  ///
  /// Use for critical errors that should always be reported.
  static void fatal(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.f(message, error: error, stackTrace: stackTrace);

    // TODO: Auto-report to Sentry (TODO 1.10)
    // ErrorReportingService.captureException(
    //   error ?? message,
    //   stackTrace: stackTrace,
    //   hint: message,
    //   level: SentryLevel.fatal,
    // );
  }
}
