import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

/// ViewModel cho chức năng xác thực, tuân thủ Clean Architecture.
/// Chỉ tương tác với `AuthRepository` (tầng Domain).
/// Repository xử lý tất cả logic Supabase, error handling, và translation.
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  // --- State Properties ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Profile? _userProfile;
  Profile? get userProfile => _userProfile;

  AuthViewModel(this._authRepository);

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
  }

  void clearErrorMessage() {
    _errorMessage = null;
  }

  // ============ Hàm Public ViewModel ============
  // (Repository xử lý tất cả logic Supabase + error handling + Vietnamese messages)

  /// Đăng nhập bằng email và password
  /// Repository xử lý: Supabase Auth + profile fetching + error handling
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _setError(null);
    _setLoading(true);
    try {
      final profile = await _authRepository.signInWithEmailAndPassword(
        email,
        password,
      );
      _userProfile = profile;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Đăng ký tài khoản mới
  /// Repository xử lý: Supabase Auth + profile creation + error handling
  Future<String?> signUp(
    String email,
    String password,
    String fullName,
    String role,
    String phone,
    String? gender,
  ) async {
    _setError(null);
    _setLoading(true);
    try {
      final message = await _authRepository.signUp(
        email,
        password,
        fullName,
        role,
        phone,
        gender,
      );
      _setLoading(false);
      return message;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return null;
    }
  }

  /// Đăng xuất
  /// Repository xử lý: Supabase Auth signOut + cleanup
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> checkCurrentUser() async {
    final profile = await _authRepository.checkCurrentUser();
    if (profile != null) {
      _userProfile = profile;
      notifyListeners();
      return true;
    }
    return false;
  }
}
