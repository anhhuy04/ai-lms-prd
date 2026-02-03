import 'package:ai_mls/core/services/profile_metadata_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/validation_utils.dart';
import 'package:ai_mls/data/datasources/supabase_datasource.dart';
import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/domain/repositories/auth_repository.dart';
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
        AppLogger.error('🔴 [REPO ERROR] SignIn: User is null');
        throw Exception('Không tìm thấy người dùng');
      }

      // Lấy thông tin profile từ bảng profiles
      final profileData = await _profileDataSource.getById(
        authResponse.user!.id,
      );
      if (profileData == null) {
        AppLogger.error(
          '🔴 [REPO ERROR] SignIn: Profile not found for user ${authResponse.user!.id}',
        );
        throw Exception('Không thể tải thông tin hồ sơ. Vui lòng thử lại.');
      }
      return Profile.fromJson(profileData);
    } on AuthException catch (e) {
      // Log error hệ thống cho developer
      AppLogger.error('🔴 [REPO ERROR] SignIn Auth: ${e.message}', error: e);

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
      AppLogger.error('🔴 [REPO ERROR] SignIn (Unknown): $e', error: e);
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
          AppLogger.info(
            '✅ [REPO] SignUp: Profile updated in database with capitalized name and full data',
          );
        } catch (e) {
          AppLogger.warning(
            '⚠️ [REPO WARN] SignUp: Failed to update profile: $e',
            error: e,
          );
          // Không ném lỗi, vì auth đã thành công
          // Profile có thể được update sau hoặc user có thể update nó
        }
      }

      // Xử lý các trường hợp khác nhau dựa trên phản hồi của Supabase
      if (response.user != null && response.session == null) {
        AppLogger.info('✅ [REPO] SignUp: Email verification required');
        return 'Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản.';
      } else if (response.user != null && response.session != null) {
        AppLogger.info(
          '✅ [REPO] SignUp: Auto-confirmed (no email verification needed)',
        );
        return 'Đăng ký thành công! Bạn có thể đăng nhập ngay bây giờ.';
      } else {
        AppLogger.error('🔴 [REPO ERROR] SignUp: Unexpected response');
        throw Exception('Đăng ký thất bại. Vui lòng thử lại.');
      }
    } on AuthException catch (e) {
      // Log error hệ thống cho developer
      AppLogger.error('🔴 [REPO ERROR] SignUp Auth: ${e.message}', error: e);

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
      AppLogger.error('🔴 [REPO ERROR] SignUp (Unknown): $e', error: e);
      throw Exception('Lỗi đăng ký. Vui lòng thử lại.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Gọi Supabase Auth
      await _supabaseClient.auth.signOut();
      AppLogger.info('✅ [REPO] SignOut: Success');
    } on AuthException catch (e) {
      AppLogger.error('🔴 [REPO ERROR] SignOut Auth: ${e.message}', error: e);
      throw Exception('Lỗi đăng xuất. Vui lòng thử lại.');
    } catch (e) {
      AppLogger.error('🔴 [REPO ERROR] SignOut (Unknown): $e', error: e);
      throw Exception('Lỗi đăng xuất. Vui lòng thử lại.');
    }
  }

  @override
  Future<Profile?> checkCurrentUser() async {
    try {
      final session = _supabaseClient.auth.currentSession;
      AppLogger.debug(
        '🔵 [REPO] checkCurrentUser: Session snapshot - '
        'hasSession: ${session != null}, userId: ${session?.user.id}',
      );

      if (session?.user == null) {
        // No active session is a normal condition, use debug level instead of warning
        AppLogger.debug('🔵 [REPO INFO] CheckCurrentUser: No active session (normal for first launch)');
        return null;
      }

      final userId = session!.user.id;

        // Thử lấy profile bằng cách sử dụng Supabase client trực tiếp
        // với RLS-aware query (đảm bảo user chỉ đọc được profile của chính họ)
        try {
          final response = await _supabaseClient
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();

          AppLogger.debug(
            '🔵 [REPO] checkCurrentUser: Query result - '
            'isResponseNull: ${response == null}, keys: ${response?.keys.toList()}',
          );

          if (response == null) {
          AppLogger.warning(
            '⚠️ [REPO WARN] CheckCurrentUser: Profile not found for user $userId',
          );
          return null;
        }

        return Profile.fromJson(response);
      } on PostgrestException catch (e) {
        // Xử lý lỗi 401 (Unauthorized) - thường do RLS policy
        if (e.code == '401' ||
            e.code == 'PGRST301' ||
            e.message.contains('permission')) {
          AppLogger.warning(
            '⚠️ [REPO WARN] CheckCurrentUser: Permission denied (401). '
            'This may be due to RLS policies. User ID: $userId',
          );

          // Thử fallback: sử dụng profileDataSource với error handling tốt hơn
          try {
            final profileData = await _profileDataSource.getById(userId);
            if (profileData != null) {
              return Profile.fromJson(profileData);
            }
          } catch (fallbackError) {
            AppLogger.error(
              '🔴 [REPO ERROR] CheckCurrentUser Fallback: $fallbackError',
              error: fallbackError,
            );
          }

          return null;
        }
        rethrow;
      }
    } on PostgrestException catch (e) {
      AppLogger.debug(
        '🔵 [REPO] checkCurrentUser: Postgrest error - '
        'code: ${e.code}, message: ${e.message}',
      );

      // Xử lý lỗi Postgrest cụ thể
      if (e.code == '401' || e.code == 'PGRST301') {
        AppLogger.warning(
          '⚠️ [REPO WARN] CheckCurrentUser: Unauthorized (401). '
          'Please check RLS policies for profiles table.',
        );
      } else {
        AppLogger.error(
          '🔴 [REPO ERROR] CheckCurrentUser Postgrest: ${e.code} - ${e.message}',
          error: e,
        );
      }
      return null;
    } catch (e) {
      AppLogger.debug(
        '🔵 [REPO] checkCurrentUser: Unknown error - ${e.toString()}',
      );
      AppLogger.error('🔴 [REPO ERROR] CheckCurrentUser: $e', error: e);
      // Không ném lỗi, chỉ return null nếu không lấy được profile
      return null;
    }
  }

  @override
  Future<Profile> updateProfile({
    String? fullName,
    String? bio,
    String? phone,
    String? gender,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Tạo map chứa các fields cần update (chỉ những field không null)
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (bio != null) updateData['bio'] = bio;
      if (phone != null) updateData['phone'] = phone;
      if (gender != null) updateData['gender'] = gender;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      
      // Xử lý metadata: merge với metadata hiện tại nếu có
      if (metadata != null) {
        // Lấy metadata hiện tại
        final currentProfile = await _profileDataSource.getById(userId);
        final currentMetadata = currentProfile?['metadata'] as Map<String, dynamic>?;
        
        // Merge metadata mới với metadata cũ
        final mergedMetadata = <String, dynamic>{};
        if (currentMetadata != null) {
          mergedMetadata.addAll(currentMetadata);
        }
        mergedMetadata.addAll(metadata);
        
        updateData['metadata'] = mergedMetadata;
      }

      // Update profile trong database
      await _profileDataSource.update(userId, updateData);

      // Lấy profile đã được update
      final updatedProfileData = await _profileDataSource.getById(userId);
      if (updatedProfileData == null) {
        throw Exception('Failed to fetch updated profile');
      }

      AppLogger.info('✅ [REPO] UpdateProfile: Profile updated successfully');
      
      // Invalidate metadata cache khi profile được update
      ProfileMetadataService.invalidateCache();
      
      return Profile.fromJson(updatedProfileData);
    } catch (e) {
      AppLogger.error(
        '🔴 [REPO ERROR] UpdateProfile: $e',
        error: e,
      );
      rethrow;
    }
  }
}
