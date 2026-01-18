/// Utility class for Vietnamese text processing
/// Hỗ trợ normalize và so sánh chuỗi tiếng Việt để sắp xếp đúng
/// 
/// Xử lý đầy đủ các ký tự đặc biệt của tiếng Việt:
/// - đ/Đ → d/D
/// - ư/Ư → u/U
/// - Tất cả các dấu thanh (á, à, ả, ã, ạ, ...)
class VietnameseTextUtils {
  VietnameseTextUtils._(); // Prevent instantiation

  /// Map các ký tự tiếng Việt có dấu sang không dấu
  /// Bao gồm đầy đủ: đ/Đ, ư/Ư và tất cả các dấu thanh
  static const Map<String, String> _vietnameseMap = {
    'à': 'a', 'á': 'a', 'ạ': 'a', 'ả': 'a', 'ã': 'a',
    'â': 'a', 'ầ': 'a', 'ấ': 'a', 'ậ': 'a', 'ẩ': 'a', 'ẫ': 'a',
    'ă': 'a', 'ằ': 'a', 'ắ': 'a', 'ặ': 'a', 'ẳ': 'a', 'ẵ': 'a',
    'è': 'e', 'é': 'e', 'ẹ': 'e', 'ẻ': 'e', 'ẽ': 'e',
    'ê': 'e', 'ề': 'e', 'ế': 'e', 'ệ': 'e', 'ể': 'e', 'ễ': 'e',
    'ì': 'i', 'í': 'i', 'ị': 'i', 'ỉ': 'i', 'ĩ': 'i',
    'ò': 'o', 'ó': 'o', 'ọ': 'o', 'ỏ': 'o', 'õ': 'o',
    'ô': 'o', 'ồ': 'o', 'ố': 'o', 'ộ': 'o', 'ổ': 'o', 'ỗ': 'o',
    'ơ': 'o', 'ờ': 'o', 'ớ': 'o', 'ợ': 'o', 'ở': 'o', 'ỡ': 'o',
    'ù': 'u', 'ú': 'u', 'ụ': 'u', 'ủ': 'u', 'ũ': 'u',
    'ư': 'u', 'ừ': 'u', 'ứ': 'u', 'ự': 'u', 'ử': 'u', 'ữ': 'u',
    'ỳ': 'y', 'ý': 'y', 'ỵ': 'y', 'ỷ': 'y', 'ỹ': 'y',
    'đ': 'd',
    'À': 'A', 'Á': 'A', 'Ạ': 'A', 'Ả': 'A', 'Ã': 'A',
    'Â': 'A', 'Ầ': 'A', 'Ấ': 'A', 'Ậ': 'A', 'Ẩ': 'A', 'Ẫ': 'A',
    'Ă': 'A', 'Ằ': 'A', 'Ắ': 'A', 'Ặ': 'A', 'Ẳ': 'A', 'Ẵ': 'A',
    'È': 'E', 'É': 'E', 'Ẹ': 'E', 'Ẻ': 'E', 'Ẽ': 'E',
    'Ê': 'E', 'Ề': 'E', 'Ế': 'E', 'Ệ': 'E', 'Ể': 'E', 'Ễ': 'E',
    'Ì': 'I', 'Í': 'I', 'Ị': 'I', 'Ỉ': 'I', 'Ĩ': 'I',
    'Ò': 'O', 'Ó': 'O', 'Ọ': 'O', 'Ỏ': 'O', 'Õ': 'O',
    'Ô': 'O', 'Ồ': 'O', 'Ố': 'O', 'Ộ': 'O', 'Ổ': 'O', 'Ỗ': 'O',
    'Ơ': 'O', 'Ờ': 'O', 'Ớ': 'O', 'Ợ': 'O', 'Ở': 'O', 'Ỡ': 'O',
    'Ù': 'U', 'Ú': 'U', 'Ụ': 'U', 'Ủ': 'U', 'Ũ': 'U',
    'Ư': 'U', 'Ừ': 'U', 'Ứ': 'U', 'Ự': 'U', 'Ử': 'U', 'Ữ': 'U',
    'Ỳ': 'Y', 'Ý': 'Y', 'Ỵ': 'Y', 'Ỷ': 'Y', 'Ỹ': 'Y',
    'Đ': 'D',
  };

  /// Normalize tiếng Việt để sắp xếp đúng (loại bỏ dấu)
  /// 
  /// Xử lý đầy đủ các ký tự đặc biệt:
  /// - "đ" → "d", "Đ" → "D"
  /// - "ư" → "u", "Ư" → "U"
  /// - Tất cả các dấu thanh (á, à, ả, ã, ạ, ...)
  /// 
  /// Ví dụ:
  /// - "Nguyễn" → "nguyen"
  /// - "Địa lý" → "dia ly"
  /// - "Ưu đãi" → "uu dai" (test case: "u d" sẽ tìm được "Ưu đãi")
  /// - "Toán học" → "toan hoc" (test case: "toan" sẽ tìm được "Toán")
  static String normalizeVietnamese(String text) {
    if (text.isEmpty) return text;
    
    String normalized = text.toLowerCase();
    _vietnameseMap.forEach((key, value) {
      normalized = normalized.replaceAll(key, value);
    });
    
    return normalized;
  }

  /// So sánh hai chuỗi tiếng Việt với locale-aware
  /// 
  /// Trả về:
  /// - < 0 nếu a < b
  /// - 0 nếu a == b
  /// - > 0 nếu a > b
  static int compareVietnamese(String a, String b) {
    final normalizedA = normalizeVietnamese(a);
    final normalizedB = normalizeVietnamese(b);
    return normalizedA.compareTo(normalizedB);
  }
}
