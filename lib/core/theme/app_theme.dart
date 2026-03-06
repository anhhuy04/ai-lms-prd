import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// App theme and shared color palette (moon + blue-green)
class AppColors {
  static const Color moon = DesignColors.moonLight;
  static const Color deepMoon = DesignColors.moonMedium;
  static const Color primary = DesignColors.primary; // Light blue
  static const Color primaryDark = DesignColors.primaryDark;
  static const Color primaryAccent = Color(0x1F4A90E2); // 12% opacity blue
  static const Color surface = DesignColors.white;
  static const Color card = DesignColors.white;
  static const Color textPrimary = DesignColors.textPrimary;
}

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.moon,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
    primary: AppColors.primary,
    secondary: AppColors.primaryDark,
    surface: AppColors.moon,
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.moon,
    foregroundColor: AppColors.textPrimary,
    iconTheme: IconThemeData(color: AppColors.textPrimary),
    centerTitle: false,
  ),
  cardTheme: const CardThemeData(
    color: AppColors.card,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
  ),
  // Hiệu ứng chuyển trang global: push custom (slide full từ phải sang trái)
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: PushPageTransitionsBuilder(),
      TargetPlatform.iOS: PushPageTransitionsBuilder(),
      TargetPlatform.macOS: PushPageTransitionsBuilder(),
      TargetPlatform.windows: PushPageTransitionsBuilder(),
      TargetPlatform.linux: PushPageTransitionsBuilder(),
    },
  ),
  textTheme: TextTheme(
    titleLarge: DesignTypography.titleLarge.copyWith(
      fontSize: DesignTypography.titleLargeSize.sp,
    ),
    bodyMedium: DesignTypography.bodyMedium.copyWith(
      fontSize: DesignTypography.bodyMediumSize.sp,
    ),
  ),
  switchTheme: SwitchThemeData(
    trackOutlineWidth: WidgetStateProperty.all(0),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFFEEEEEE),
    thickness: 1,
    space: 1,
  ),
  listTileTheme: const ListTileThemeData(
    shape: RoundedRectangleBorder(side: BorderSide.none),
  ),
);

// Backwards-compatible wrapper expected by existing code (e.g. `AppTheme.lightTheme`)
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => appTheme;
}

/// Global push-style page transitions (giống iOS / TikTok / Shopee):
///
/// KHI LÀ TRANG ĐÍCH (animation chạy 0→1):
///   - Slide từ phải vào (Offset(1,0) → Offset.zero)
///
/// KHI BỊ TRANG KHÁC ĐÈ LÊN (secondaryAnimation chạy 0→1):
///   - Nhích sang trái 30% (Offset.zero → Offset(-0.3, 0))
///   - Phủ lớp dim mờ nhẹ
///
/// Cả hai animation áp dụng trên CÙNG MỘT child thông qua stack,
/// Flutter tự quản lý z-order (trang mới luôn nằm trên).
class PushPageTransitionsBuilder extends PageTransitionsBuilder {
  const PushPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Popups / dialogs giữ nguyên hiệu ứng mặc định
    if (route is PopupRoute) {
      return child;
    }

    // === INCOMING: trang này đang được push vào ===
    // Slide từ phải sang trái (1.0 → 0.0)
    final inSlide =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    // === OUTGOING: trang này bị trang mới đè lên ===
    // Nhích nhẹ sang trái 30% (parallax, giống iOS)
    final outSlide =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-0.3, 0.0)).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    // Dim overlay khi bị đè (opacity: 0 → 0.15)
    final dimOpacity = Tween<double>(begin: 0.0, end: 0.15).animate(
      CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
    );

    return SlideTransition(
      position: inSlide,
      child: DecoratedBox(
        // Shadow cạnh trái trang mới khi slide vào (giống iOS)
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: const Offset(-2, 0),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: SlideTransition(
          position: outSlide,
          child: ColoredBox(
            // Nền opaque đảm bảo che phủ hoàn toàn trang cũ
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Stack(
              children: [
                child,
                // Dim mờ phủ khi trang khác đè lên
                IgnorePointer(
                  child: FadeTransition(
                    opacity: dimOpacity,
                    child: const ColoredBox(
                      color: Colors.black,
                      child: SizedBox.expand(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
