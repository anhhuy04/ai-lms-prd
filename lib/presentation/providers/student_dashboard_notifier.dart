import 'dart:async';

import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'student_dashboard_notifier.g.dart';

/// StudentDashboardNotifier (Riverpod) thay thế dần `StudentDashboardViewModel`.
///
/// Hiện tại dashboard của student phụ thuộc nhiều vào `AuthViewModel`.
/// Giai đoạn này migrate tối thiểu:
/// - Lấy được profile hiện tại từ AuthNotifier.
/// - Cung cấp hook `refresh()` để UI gọi (chuẩn bị cho migrate data sau).
@riverpod
class StudentDashboardNotifier extends _$StudentDashboardNotifier {
  @override
  FutureOr<Profile?> build() async {
    // Theo dõi auth state.
    final auth = ref.watch(authNotifierProvider);
    return auth.value;
  }

  /// Refresh dashboard data (classes, assignments, etc.)
  /// 
  /// Lưu ý: KHÔNG refresh auth state để tránh trigger redirect về login.
  /// Chỉ refresh data providers (classes, assignments) mà không touch auth.
  Future<void> refresh({bool showLoading = false}) async {
    // Không set state về loading để tránh trigger router redirect
    // Chỉ refresh data providers, không refresh auth state
    
    try {
      // Refresh class list nếu có teacherId/studentId
      final auth = ref.read(authNotifierProvider);
      final profile = auth.value;
      
      if (profile != null) {
        // Refresh class list data (nếu có provider)
        // TODO: Thêm refresh cho các data providers khác (assignments, scores, etc.)
        AppLogger.debug('🟢 [STUDENT_DASHBOARD] refresh data for user: ${profile.id}');
      }
      
      // Không thay đổi state của notifier này để tránh trigger rebuild
      // State sẽ tự động update khi data providers refresh
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [STUDENT_DASHBOARD] refresh lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      // Không set error state để tránh trigger redirect
    }
  }
}

