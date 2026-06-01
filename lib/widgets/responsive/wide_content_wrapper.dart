import 'package:flutter/material.dart';

/// Canh giữa + giới hạn bề rộng nội dung trên màn rộng (tablet/desktop/web)
/// để tránh card/form bị kéo dãn edge-to-edge xấu xí. Trên màn hẹp (mobile,
/// hoặc pane nhỏ hơn [maxWidth]): trả [child] nguyên vẹn — non-destructive.
///
/// Dùng [LayoutBuilder] (không phải MediaQuery) nên đo đúng bề rộng KHẢ DỤNG
/// của vùng chứa — chính xác khi đặt trong content pane đã bị sidebar thu hẹp.
///
/// Chỉ constrain BỀ RỘNG; chiều cao truyền nguyên (an toàn cho ListView/
/// CustomScrollView bên trong).
class WideContentWrapper extends StatelessWidget {
  final Widget child;

  /// Bề rộng tối đa của nội dung. Mặc định 1100 — đủ thoáng cho list/form.
  final double maxWidth;

  const WideContentWrapper({
    super.key,
    required this.child,
    this.maxWidth = 1100,
  });

  @override
  Widget build(BuildContext context) {
    // TẠM no-op (đang chẩn đoán lỗi layout "RenderBox no size" khi chuyển tab).
    // Trả child nguyên vẹn → không can thiệp layout bất kỳ màn nào.
    return child;
  }
}
