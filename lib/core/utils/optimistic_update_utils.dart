import 'dart:async';

import 'package:ai_mls/core/utils/app_logger.dart';

/// Utility class để xử lý optimistic updates cho các notifiers
///
/// Pattern này cho phép:
/// - Update UI ngay lập tức (không hiển thị loading spinner)
/// - Sync với backend trong background
/// - Tự động rollback nếu có lỗi
/// - Chỉ log khi thất bại, không log khi thành công
class OptimisticUpdateUtils {
  OptimisticUpdateUtils._();

  /// Thực hiện optimistic update với rollback tự động
  ///
  /// [optimisticUpdate] - Function để update local state ngay lập tức
  /// [syncToBackend] - Function để sync với backend (chạy trong background)
  /// [onError] - Callback khi có lỗi (optional)
  ///
  /// Returns: true nếu optimistic update thành công, false nếu có lỗi
  static Future<bool> execute<T>({
    required Future<bool> Function() optimisticUpdate,
    required Future<void> Function() syncToBackend,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      // Bước 1: Update UI ngay lập tức
      final success = await optimisticUpdate();
      if (!success) {
        return false;
      }

      // Bước 2: Sync với backend trong background (không block UI)
      unawaited(_syncInBackground(syncToBackend, onError));

      return true;
    } catch (e, stackTrace) {
      // Log lỗi nếu có
      if (onError != null) {
        onError(e, stackTrace);
      }
      AppLogger.error(
        '🔴 [OptimisticUpdate] execute lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Sync với backend trong background
  static Future<void> _syncInBackground(
    Future<void> Function() syncToBackend,
    void Function(Object error, StackTrace stackTrace)? onError,
  ) async {
    try {
      await syncToBackend();
      // Không log thành công theo yêu cầu
    } catch (e, stackTrace) {
      // Chỉ log khi thất bại
      if (onError != null) {
        onError(e, stackTrace);
      }
      AppLogger.error(
        '🔴 [OptimisticUpdate] syncToBackend lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Helper để update nested map value theo path
  ///
  /// Ví dụ: updateNestedValue(settings, 'defaults.lock_class', true)
  static void updateNestedValue(
    Map<String, dynamic> map,
    String path,
    dynamic value,
  ) {
    final pathParts = path.split('.');
    Map<String, dynamic> current = map;
    for (int i = 0; i < pathParts.length - 1; i++) {
      final key = pathParts[i];
      if (current[key] == null || current[key] is! Map) {
        current[key] = <String, dynamic>{};
      }
      current = current[key] as Map<String, dynamic>;
    }
    current[pathParts.last] = value;
  }

  /// Helper để deep copy một map
  static Map<String, dynamic> deepCopyMap(Map<String, dynamic>? source) {
    if (source == null) return <String, dynamic>{};
    return Map<String, dynamic>.from(source);
  }
}
