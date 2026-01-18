import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/domain/repositories/auth_repository.dart';
import 'package:ai_mls/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider cho AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('Must override authRepositoryProvider');
});

/// Provider cho AuthViewModel
final authViewModelProvider = Provider<AuthViewModel>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository);
});

/// Provider cho current user profile (reactive, async)
final currentUserProvider = FutureProvider<Profile?>((ref) async {
  final authViewModel = ref.watch(authViewModelProvider);
  if (authViewModel.userProfile == null) {
    await authViewModel.checkCurrentUser();
  }
  return authViewModel.userProfile;
});

/// Provider cho current user ID (synchronous, nullable)
/// Watch currentUserProvider để đảm bảo đợi user được load xong
final currentUserIdProvider = Provider<String?>((ref) {
  final currentUserAsync = ref.watch(currentUserProvider);
  return currentUserAsync.value?.id;
});
