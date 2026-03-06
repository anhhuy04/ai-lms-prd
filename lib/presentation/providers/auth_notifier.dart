import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ai_mls/core/services/profile_metadata_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/domain/repositories/auth_repository.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

/// AuthNotifier (Riverpod) thay thế dần `AuthViewModel` (Provider/ChangeNotifier).
///
/// Quy ước state:
/// - `AsyncValue<Profile?>`:
///   - `data(null)`: chưa đăng nhập / chưa có session
///   - `data(Profile)`: đã đăng nhập
///   - `loading`: đang xử lý (login / check session / signout)
///   - `error`: có lỗi (message sẽ nằm trong `error.toString()`)
@Riverpod(keepAlive: true) // Giữ state alive để duy trì session
class AuthNotifier extends _$AuthNotifier {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> _writeAuthLog({
    required String location,
    required String message,
    required Map<String, dynamic> data,
    required String hypothesisId,
  }) async {
    if (!kDebugMode) return;
    // Skip host-file logging on web where dart:io Platform is unsupported.
    if (kIsWeb) return;
    final logEntry = {
      'sessionId': 'debug-session',
      'runId': 'run1',
      'hypothesisId': hypothesisId,
      'location': location,
      'message': message,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    if (Platform.isWindows) {
      try {
        final logFile = File(
          'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
        );
        await logFile.parent.create(recursive: true);
        await logFile.writeAsString(
          '${jsonEncode(logEntry)}\n',
          mode: FileMode.append,
          flush: false,
        );
      } catch (_) {}
    }
  }

  @override
  FutureOr<Profile?> build() async {
    // Mặc định: chưa load session. Ta chủ động check session 1 lần để hydrate state.
    final profile = await _safeCheckCurrentUser();
    // #region agent log
    unawaited(
      _writeAuthLog(
        location: 'auth_notifier.dart:28',
        message: 'AuthNotifier build resolved',
        data: {'hasProfile': profile != null},
        hypothesisId: 'H2',
      ),
    );
    // #endregion
    return profile;
  }

  /// Đăng nhập bằng email & password.
  ///
  /// Trả về true/false để UI dễ xử lý nhanh.
  Future<bool> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repo.signInWithEmailAndPassword(email, password);
      state = AsyncValue.data(profile);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [AUTH] Đăng nhập thất bại: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  /// Đăng ký tài khoản mới.
  ///
  /// Trả về message (nếu thành công) hoặc null (nếu thất bại).
  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    required String phone,
    String? gender,
  }) async {
    // Không set loading toàn cục nếu bạn muốn UI vẫn giữ state login hiện tại.
    // Tuy nhiên ở đây để đơn giản, mình vẫn set loading.
    state = const AsyncValue.loading();
    try {
      final message = await _repo.signUp(
        email,
        password,
        fullName,
        role,
        phone,
        gender,
      );
      // Sau signUp có thể chưa có session (yêu cầu verify email), nên check lại.
      state = AsyncValue.data(await _safeCheckCurrentUser());
      return message;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [AUTH] Đăng ký thất bại: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  /// Đăng xuất.
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _repo.signOut();
      // Clear metadata cache khi logout
      ProfileMetadataService.clearCache();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [AUTH] Đăng xuất thất bại: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Check session hiện tại.
  ///
  /// Trả về true nếu có user, false nếu không có.
  Future<bool> checkCurrentUser() async {
    state = const AsyncValue.loading();
    try {
      // Giới hạn thời gian chờ để tránh treo app nếu Supabase không phản hồi
      final profile = await _repo.checkCurrentUser().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          AppLogger.warning(
            '⚠️ [AUTH] CheckCurrentUser timeout sau 5s - coi như chưa đăng nhập',
          );
          return null;
        },
      );
      state = AsyncValue.data(profile);
      return profile != null;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [AUTH] CheckCurrentUser lỗi: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
      return false;
    } finally {
      // Đảm bảo trạng thái được thiết lập ngay cả khi có lỗi
      if (state.isLoading) {
        state = const AsyncValue.data(null);
      }
    }
  }

  Future<Profile?> _safeCheckCurrentUser() async {
    try {
      // Thêm timeout để tránh treo app nếu Supabase không phản hồi
      return await _repo.checkCurrentUser().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          AppLogger.warning(
            '⚠️ [AUTH] Safe checkCurrentUser timeout sau 5s - coi như chưa đăng nhập',
          );
          return null;
        },
      );
    } catch (e, stackTrace) {
      // Log nhưng không throw - coi như chưa đăng nhập
      AppLogger.warning(
        '⚠️ [AUTH] Safe checkCurrentUser lỗi (coi như chưa đăng nhập): $e',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
