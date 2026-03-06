/// Utility class for validation functions
class ValidationUtils {
  /// Validates phone number format (10-11 digits only)
  static bool isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;
    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
    return phoneRegex.hasMatch(phone);
  }

  /// Validates email format
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Capitalizes the first letter of each word in a name
  static String capitalizeName(String name) {
    if (name.isEmpty) return name;
    return name.trim().split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Validates password (minimum 8 characters)
  static bool isValidPassword(String password) {
    // Yêu cầu: mật khẩu phải có ít nhất 8 ký tự
    return password.length >= 8;
  }
}