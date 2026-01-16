import 'package:ai_mls/data/datasources/supabase_datasource.dart';
import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/domain/repositories/auth_repository.dart';
import 'package:ai_mls/core/utils/validation_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lớp triển khai của AuthRepository, chịu trách nhiệm thực hiện logic xác thực.
class AuthRepositoryImpl implements AuthRepository {
  final BaseTableDataSource _profileDataSource;

  AuthRepositoryImpl(this._profileDataSource);

  // Lấy Supabase client từ Supabase.instance
  SupabaseClient get _supabaseClient => Supabase.instance.client;

  @override
  Future<Profile> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Gọi Supabase Auth
      final authResponse = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        print('🔴 [REPO ERROR] SignIn: User is null');
        throw Exception('Không tìm thấy người dùng');
      }

      // Lấy thông tin profile từ bảng profiles
      final profileData = await _profileDataSource.getById(
        authResponse.user!.id,
      );
      if (profileData == null) {
        print(
          '🔴 [REPO ERROR] SignIn: Profile not found for user ${authResponse.user!.id}',
        );
        throw Exception('Không thể tải thông tin hồ sơ. Vui lòng thử lại.');
      }
      return Profile.fromJson(profileData);
    } on AuthException catch (e) {
      // Log error hệ thống cho developer
      print('🔴 [REPO ERROR] SignIn Auth: ${e.message}');

      // Hiển thị lỗi tiếng Việt cho người dùng
      if (e.message.contains('Invalid login credentials')) {
        throw Exception('Email hoặc mật khẩu không chính xác');
      } else if (e.message.contains('User not found')) {
        throw Exception('Tài khoản không tồn tại');
      } else if (e.message.contains('Invalid email')) {
        throw Exception('Định dạng email không hợp lệ');
      } else {
        throw Exception('Lỗi đăng nhập. Vui lòng thử lại.');
      }
    } catch (e) {
      print('🔴 [REPO ERROR] SignIn (Unknown): $e');
      throw Exception('Lỗi đăng nhập. Vui lòng thử lại.');
    }
  }

  @override
  Future<String?> signUp(
    String email,
    String password,
    String fullName,
    String role,
    String phone,
    String? gender,
  ) async {
    try {
      // Capitalize name before saving
      final capitalizedFullName = ValidationUtils.capitalizeName(fullName);

      // Gọi Supabase Auth
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': capitalizedFullName,
          'role': role,
          'phone': phone,
          'gender': gender,
        },
      );

      // Nếu signup thành công, update profile trong bảng profiles
      // (Profile đã được tạo bởi trigger handle_new_user())
      if (response.user != null) {
        try {
          // Update profile data với tên đã chuẩn hóa và thông tin đầy đủ
          await _profileDataSource.update(response.user!.id, {
            'full_name': capitalizedFullName,
            'email': email,
            'role': role,
            'phone': phone,
            'gender': gender,
            'avatar_url': null,
            'updated_at': DateTime.now().toIso8601String(),
          });
          print('✅ [REPO] SignUp: Profile updated in database with capitalized name and full data');
        } catch (e) {
          print('⚠️ [REPO WARN] SignUp: Failed to update profile: $e');
          // Không ném lỗi, vì auth đã thành công
          // Profile có thể được update sau hoặc user có thể update nó
        }
      }

      // Xử lý các trường hợp khác nhau dựa trên phản hồi của Supabase
      if (response.user != null && response.session == null) {
        print('✅ [REPO] SignUp: Email verification required');
        return "Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản.";
      } else if (response.user != null && response.session != null) {
        print('✅ [REPO] SignUp: Auto-confirmed (no email verification needed)');
        return "Đăng ký thành công! Bạn có thể đăng nhập ngay bây giờ.";
      } else {
        print('🔴 [REPO ERROR] SignUp: Unexpected response');
        throw Exception('Đăng ký thất bại. Vui lòng thử lại.');
      }
    } on AuthException catch (e) {
      // Log error hệ thống cho developer
      print('🔴 [REPO ERROR] SignUp Auth: ${e.message}');

      // Hiển thị lỗi tiếng Việt cho người dùng
      if (e.message.contains('already registered') ||
          e.message.contains('User already registered')) {
        throw Exception('Email này đã được đăng ký');
      } else if (e.message.contains('Invalid email')) {
        throw Exception('Định dạng email không hợp lệ');
      } else if (e.message.contains('password')) {
        throw Exception('Mật khẩu phải có ít nhất 6 ký tự');
      } else {
        throw Exception('Đăng ký thất bại. Vui lòng thử lại.');
      }
    } catch (e) {
      print('🔴 [REPO ERROR] SignUp (Unknown): $e');
      throw Exception('Lỗi đăng ký. Vui lòng thử lại.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Gọi Supabase Auth
      await _supabaseClient.auth.signOut();
      print('✅ [REPO] SignOut: Success');
    } on AuthException catch (e) {
      print('🔴 [REPO ERROR] SignOut Auth: ${e.message}');
      throw Exception('Lỗi đăng xuất. Vui lòng thử lại.');
    } catch (e) {
      print('🔴 [REPO ERROR] SignOut (Unknown): $e');
      throw Exception('Lỗi đăng xuất. Vui lòng thử lại.');
    }
  }

  @override
  Future<Profile?> checkCurrentUser() async {
    try {
      final session = _supabaseClient.auth.currentSession;
      if (session?.user != null) {
        final profileData = await _profileDataSource.getById(session!.user.id);
        if (profileData == null) {
          print('⚠️ [REPO WARN] CheckCurrentUser: Profile not found');
          return null;
        }
        return Profile.fromJson(profileData);
      }
      return null;
    } catch (e) {
      print('🔴 [REPO ERROR] CheckCurrentUser: $e');
      // Không ném lỗi, chỉ return null nếu không lấy được profile
      return null;
    }
  }
}
