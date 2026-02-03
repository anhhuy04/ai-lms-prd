import 'package:ai_mls/core/utils/vietnamese_text_utils.dart';
import 'package:flutter/material.dart';

/// Widget hiển thị text với highlight từ khóa tìm kiếm
/// Hỗ trợ tìm kiếm tiếng Việt không dấu (ví dụ: "toan" sẽ highlight "Toán")
class SmartHighlightText extends StatelessWidget {
  final String fullText; // Ví dụ: "Lớp Toán - Học kỳ 1"
  final String query; // Ví dụ: "toan"
  final TextStyle style;
  final Color highlightColor;

  const SmartHighlightText({
    super.key,
    required this.fullText,
    required this.query,
    required this.style,
    this.highlightColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(fullText, style: style);
    }

    // Chuyển query về không dấu để so khớp
    final normalizedQuery = VietnameseTextUtils.normalizeVietnamese(query);

    // Tìm tất cả các vị trí match bằng cách so sánh từng substring
    final List<TextSpan> spans = [];
    int start = 0;

    // Tìm match bằng cách normalize từng substring của fullText
    for (int i = 0; i <= fullText.length - query.length; i++) {
      // Thử các độ dài khác nhau để tìm match (vì có thể có dấu)
      for (
        int len = query.length;
        len <= query.length + 2 && i + len <= fullText.length;
        len++
      ) {
        final candidate = fullText.substring(i, i + len);
        final normalizedCandidate = VietnameseTextUtils.normalizeVietnamese(
          candidate,
        );

        if (normalizedCandidate == normalizedQuery) {
          // Phần text bình thường trước từ khóa
          if (i > start) {
            spans.add(
              TextSpan(text: fullText.substring(start, i), style: style),
            );
          }

          // Phần text được tô sáng
          spans.add(
            TextSpan(
              text: candidate,
              style: style.copyWith(
                color: highlightColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          );

          start = i + len;
          i = start - 1; // -1 vì vòng lặp sẽ tăng i
          break; // Tìm thấy match, break khỏi vòng lặp len
        }
      }
    }

    // Phần còn lại sau cùng
    if (start < fullText.length) {
      spans.add(TextSpan(text: fullText.substring(start), style: style));
    }

    // Nếu không có match nào, trả về text bình thường
    if (spans.isEmpty) {
      return Text(fullText, style: style);
    }

    return RichText(text: TextSpan(children: spans));
  }
}
