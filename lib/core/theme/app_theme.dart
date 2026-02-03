import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// App theme and shared color palette (moon + blue-green)
class AppColors {
  static const Color moon = Color(0xFFF5F7FA); // soft moon background
  static const Color deepMoon = Color(0xFFE9EEF3);
  static const Color teal = Color(0xFF0EA5A4); // primary blue-green
  static const Color tealDark = Color(0xFF0B7E7C);
  // ~12% opacity teal for accents
  static const Color teal12 = Color(0x1F0EA5A4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF04202A);
}

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.teal,
  scaffoldBackgroundColor: AppColors.moon,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: AppColors.teal,
    secondary: AppColors.tealDark,
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
    backgroundColor: AppColors.teal,
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
);

// Backwards-compatible wrapper expected by existing code (e.g. `AppTheme.lightTheme`)
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => appTheme;
}

/// Global push-style page transitions:
/// - New page: slide in from right (Offset(1, 0) -> Offset.zero)
/// - Old page: slide out to left (Offset.zero -> Offset(-1, 0))
class PushPageTransitionsBuilder extends PageTransitionsBuilder {
  const PushPageTransitionsBuilder();

  static const Curve _curveIn = Curves.easeOutCubic;
  static const Curve _curveOut = Curves.easeInCubic;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Dialogs / popups giữ hiệu ứng mặc định của Flutter.
    if (route is PopupRoute) {
      return child;
    }

    // Route hiện tại (trang mới trên top): dùng animation → trượt từ phải vào.
    if (route.isCurrent) {
      final inOffset = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: _curveIn)).animate(animation);

      return SlideTransition(position: inOffset, child: child);
    }

    // Route bên dưới (trang cũ): dùng secondaryAnimation → trượt toàn bộ sang trái.
    final outOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).chain(CurveTween(curve: _curveOut)).animate(secondaryAnimation);

    return SlideTransition(position: outOffset, child: child);
  }
}
