import 'package:ai_mls/domain/entities/profile.dart';

/// Abstract Repository định nghĩa các "hợp đồng" cho chức năng xác thực.
/// Tầng Presentation (ViewModel) sẽ phụ thuộc vào lớp này,
/// không phải vào lớp triển khai cụ thể.
abstract class AuthRepository {
  /// Hàm đăng nhập bằng email và mật khẩu.
  /// Trả về một đối tượng Profile nếu thành công.
  /// Ném ra một Exception nếu thất bại.
  Future<Profile> signInWithEmailAndPassword(String email, String password);

  /// Hàm đăng ký người dùng mới.
  /// Trả về một chuỗi thông báo thành công (ví dụ: yêu cầu xác thực email).
  /// Ném ra một Exception nếu thất bại.
  Future<String?> signUp(
    String email,
    String password,
    String fullName,
    String role,
    String phone,
    String? gender,
  );

  /// Hàm đăng xuất người dùng.
  Future<void> signOut();

  /// Hàm kiểm tra người dùng hiện tại và lấy thông tin profile.
  /// Trả về đối tượng Profile nếu có phiên đăng nhập hợp lệ, ngược lại trả về null.
  Future<Profile?> checkCurrentUser();

  /// Hàm cập nhật thông tin profile của người dùng.
  /// Trả về Profile đã được cập nhật.
  /// Ném ra một Exception nếu thất bại.
  Future<Profile> updateProfile({
    String? fullName,
    String? bio,
    String? phone,
    String? gender,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  });
}
