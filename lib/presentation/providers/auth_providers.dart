import 'package:ai_mls/domain/repositories/auth_repository.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

/// Provider cho AuthRepository (dùng @riverpod để codegen)
@riverpod
AuthRepository authRepository(Ref ref) {
  throw UnimplementedError('Must override authRepositoryProvider');
}

/// Provider cho current user profile (reactive, async)
///
/// Sử dụng AuthNotifier (đã migrate sang @riverpod).
/// State: AsyncValue&lt;Profile?&gt; - null nếu chưa đăng nhập, Profile nếu đã đăng nhập.
final currentUserProvider = authNotifierProvider;

/// Provider cho current user ID (synchronous, nullable)
/// Watch currentUserProvider để đảm bảo đợi user được load xong
final currentUserIdProvider = Provider<String?>((ref) {
  final currentUserAsync = ref.watch(currentUserProvider);
  return currentUserAsync.value?.id;
});
