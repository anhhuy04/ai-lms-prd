import 'package:flutter/material.dart';

/// Design System - Unified Design Tokens
///
/// This file is the single source of truth for all design specifications
/// including colors, spacing, typography, icons, shadows, and responsive breakpoints.
/// All components MUST use these tokens to maintain visual consistency.

// ==================== COLOR PALETTE (Moon + Teal Theme) ====================
class DesignColors {
  DesignColors._(); // Prevent instantiation

  // Primary Palette - Moon (Backgrounds)
  static const Color moonLight = Color(0xFFF5F7FA); // Primary background
  static const Color moonMedium = Color(0xFFE9EEF3); // Secondary background
  static const Color moonDark = Color(0xFFDEE4EC); // Tertiary background

  // Primary Color - Blue (Brand)
  static const Color primary = Color(0xFF4A90E2); // Main brand color (blue)
  static const Color primaryDark = Color(0xFF2E5C8A); // Dark variant
  static const Color primaryLight = Color(0xFF6BA3E8); // Light variant

  // Secondary Color - Teal (Accent)
  static const Color tealPrimary = Color(0xFF0EA5A4); // Teal accent color
  static const Color tealDark = Color(0xFF0B7E7C); // Dark variant
  static const Color tealLight = Color(0xFF14B8A6); // Light variant
  static const Color tealAccent = Color(0xff1f0ea5a4); // 12% opacity accent

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(
    0xFF04202A,
  ); // Dark blue-black for text
  static const Color textSecondary = Color(
    0xFF546E7A,
  ); // Gray for secondary text
  static const Color textTertiary = Color(
    0xFF90A4AE,
  ); // Light gray for tertiary

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50); // Green for success states
  static const Color warning = Color(0xFFFFA726); // Orange for warnings
  static const Color error = Color(0xFFEF5350); // Red for errors
  static const Color info = Color(0xFF29B6F6); // Light blue for info

  // Dividers & Borders
  static const Color dividerLight = Color(0xFFEDEDED); // Light dividers
  static const Color dividerMedium = Color(0xFFBDBDBD); // Medium dividers

  // Disabled States
  static const Color disabledLight = Color(0xFFFAFAFA);
  static const Color disabledMedium = Color(0xFFEBEBEB);

  // Shadows (Black with opacity variants)
  static Color shadowLight = Colors.black.withOpacity(0.05);
  static Color shadowMedium = Colors.black.withOpacity(0.12);
  static Color shadowHeavy = Colors.black.withOpacity(0.2);
}

// ==================== SPACING SCALE (8dp Base Unit) ====================
class DesignSpacing {
  DesignSpacing._(); // Prevent instantiation

  // Base unit: 4dp (for fine control)
  static const double xs = 4.0; // Extra small
  static const double sm = 8.0; // Small (1 unit)
  static const double md = 12.0; // Medium (1.5 units)
  static const double lg = 16.0; // Large (2 units) - STANDARD
  static const double xl = 18.0; // Extra large (2.25 units)
  static const double xxl = 22.0; // Double extra large (2.75 units)
  static const double xxxl = 28.0; // Triple extra large (3.5 units)
  static const double xxxxl = 36.0; // Quad extra large (4.5 units)
  static const double xxxxxl = 44.0; // Five extra large (5.5 units)
  static const double xxxxxxl = 56.0; // Six extra large (7 units)

  // Semantic spacing names
  static const double paddingMinimal = xs;
  static const double paddingSmall = sm;
  static const double paddingNormal = lg; // Default padding for most components
  static const double paddingLarge = xxl;
  static const double paddingXLarge = xxxl;

  static const double marginMinimal = xs;
  static const double marginSmall = sm;
  static const double marginNormal = lg; // Default margin for most components
  static const double marginLarge = xxl;
  static const double marginXLarge = xxxl;

  // Component-specific spacing
  static const double screenPadding = lg; // Padding from screen edges (16dp)
  static const double cardPadding = lg; // Content padding inside cards (16dp)
  static const double itemSpacing = md; // Space between list items (12dp)
  static const double sectionSpacing =
      xxl; // Space between major sections (24dp)
}

// ==================== TYPOGRAPHY SCALE ====================
class DesignTypography {
  DesignTypography._(); // Prevent instantiation

  // Typography Scale - Font Sizes
  // Follows Material Design 3 + custom adjustments for Vietnamese content

  // Display Level (Large headings)
  static const double displayLargeSize = 28.0;
  static const double displayMediumSize = 26.0;
  static const double displaySmallSize = 24.0;

  // Headline Level (Page titles)
  static const double headlineLargeSize = 22.0;
  static const double headlineMediumSize = 20.0;
  static const double headlineSmallSize = 18.0;

  // Title Level (Section titles)
  static const double titleLargeSize = 18.0; // CURRENT STANDARD
  static const double titleMediumSize = 16.0;
  static const double titleSmallSize = 14.0;

  // Body Level (Main content)
  static const double bodyLargeSize = 16.0;
  static const double bodyMediumSize = 14.0; // CURRENT STANDARD
  static const double bodySmallSize = 12.0;

  // Label Level (Button text, badges)
  static const double labelLargeSize = 14.0;
  static const double labelMediumSize = 12.0;
  static const double labelSmallSize = 11.0;

  // Caption (Small text, hints)
  static const double captionSize = 12.0;
  static const double overlineSize = 12.0;

  // Line Heights (in proportion to font size)
  static const double lineHeightTight = 1.25; // For headings
  static const double lineHeightNormal = 1.4; // For body text
  static const double lineHeightRelaxed = 1.5; // For longer body copy

  // Letter Spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingLoose = 0.5;

  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // Predefined TextStyles for consistency
  static TextStyle displayLarge = TextStyle(
    fontSize: displayLargeSize,
    fontWeight: bold,
    height: lineHeightTight,
    color: DesignColors.textPrimary,
  );

  static TextStyle displayMedium = TextStyle(
    fontSize: displayMediumSize,
    fontWeight: bold,
    height: lineHeightTight,
    color: DesignColors.textPrimary,
  );

  static TextStyle headlineLarge = TextStyle(
    fontSize: headlineLargeSize,
    fontWeight: bold,
    height: lineHeightTight,
    color: DesignColors.textPrimary,
  );

  static TextStyle headlineMedium = TextStyle(
    fontSize: headlineMediumSize,
    fontWeight: semiBold,
    height: lineHeightNormal,
    color: DesignColors.textPrimary,
  );

  static TextStyle titleLarge = TextStyle(
    fontSize: titleLargeSize,
    fontWeight: bold,
    height: lineHeightNormal,
    color: DesignColors.textPrimary,
  );

  static TextStyle titleMedium = TextStyle(
    fontSize: titleMediumSize,
    fontWeight: semiBold,
    height: lineHeightNormal,
    color: DesignColors.textPrimary,
  );

  static TextStyle bodyLarge = TextStyle(
    fontSize: bodyLargeSize,
    fontWeight: regular,
    height: lineHeightRelaxed,
    color: DesignColors.textPrimary,
  );

  static TextStyle bodyMedium = TextStyle(
    fontSize: bodyMediumSize,
    fontWeight: regular,
    height: lineHeightRelaxed,
    color: DesignColors.textPrimary,
  );

  static TextStyle bodySmall = TextStyle(
    fontSize: bodySmallSize,
    fontWeight: regular,
    height: lineHeightRelaxed,
    color: DesignColors.textSecondary,
  );

  static TextStyle caption = TextStyle(
    fontSize: captionSize,
    fontWeight: regular,
    height: lineHeightNormal,
    color: DesignColors.textSecondary,
  );

  static TextStyle labelMedium = TextStyle(
    fontSize: labelMediumSize,
    fontWeight: medium,
    height: lineHeightNormal,
    color: DesignColors.textPrimary,
  );
}

// ==================== ICON SIZES ====================
class DesignIcons {
  DesignIcons._(); // Prevent instantiation

  // Icon sizes follow a 4dp scale for flexibility
  static const double xsSize = 16.0; // Extra small (e.g., decorative icons)
  static const double smSize = 18.0; // Small (e.g., form field icons)
  static const double mdSize =
      22.0; // Medium - STANDARD (e.g., button icons, toolbar)
  static const double lgSize = 28.0; // Large (e.g., empty states)
  static const double xlSize = 40.0; // Extra large (e.g., avatar in profiles)
  static const double xxlSize = 56.0; // Double extra large (e.g., hero icons)

  // Semantic icon sizes
  static const double buttonIconSize = mdSize; // Icons inside buttons
  static const double appBarIconSize = mdSize; // AppBar action icons
  static const double bottomNavIconSize = 24.0; // BottomNavigationBar icons
  static const double floatingActionButtonIconSize = 24.0; // FAB icon
  static const double decorativeIconSize = smSize; // Decorative or status icons
  static const double largeEmptyStateIconSize =
      xxlSize; // Hero icons for empty states
}

// ==================== BORDER RADIUS SCALE ====================
class DesignRadius {
  DesignRadius._(); // Prevent instantiation

  // Border radius follows a 4dp scale
  static const double none = 0.0;
  static const double xs = 4.0; // Extra small corners
  static const double sm = 8.0; // Small corners
  static const double md = 12.0; // Medium corners - STANDARD for cards
  static const double lg = 16.0; // Large corners
  static const double full = 50.0; // Pill-shaped (used for badges, avatars)

  // Semantic radius names
  static const double cardRadius = md; // Card border radius (12dp)
  static const double buttonRadius = sm; // Button border radius (8dp)
  static const double inputRadius = sm; // Input field radius (8dp)
  static const double badgeRadius = full; // Badge radius (pill-shaped)
  static const double avatarRadius = full; // Avatar radius (circular)
}

// ==================== ELEVATION & SHADOW SYSTEM ====================
class DesignElevation {
  DesignElevation._(); // Prevent instantiation

  // Elevation levels (Material Design 3 inspired)
  // Each level represents depth in the UI hierarchy

  /// No shadow - flat surface
  static BoxShadow get level0 => BoxShadow(
    color: Colors.transparent,
    blurRadius: 0,
    offset: const Offset(0, 0),
  );

  /// Subtle elevation - button hover, light cards
  static BoxShadow get level1 => BoxShadow(
    color: DesignColors.shadowLight,
    blurRadius: 3.0,
    offset: const Offset(0, 1.0),
  );

  /// Standard elevation - default cards, selected items
  static BoxShadow get level2 => BoxShadow(
    color: DesignColors.shadowMedium,
    blurRadius: 6.0,
    offset: const Offset(0, 3.0),
  );

  /// Medium elevation - dialog containers
  static BoxShadow get level3 => BoxShadow(
    color: DesignColors.shadowMedium,
    blurRadius: 16.0,
    offset: const Offset(0, 6.0),
  );

  /// High elevation - modals, floating action buttons
  static BoxShadow get level4 => BoxShadow(
    color: DesignColors.shadowHeavy,
    blurRadius: 24.0,
    offset: const Offset(0, 12.0),
  );

  /// Very high elevation - app drawer, menus
  static BoxShadow get level5 => BoxShadow(
    color: DesignColors.shadowHeavy,
    blurRadius: 24.0,
    offset: const Offset(0, 16.0),
  );

  // Semantic shadow names
  static BoxShadow get cardShadow => level2;
  static BoxShadow get modalShadow => level4;
  static BoxShadow get floatingActionButtonShadow => level4;
  static BoxShadow get bottomNavigationShadow => level3;
}

// ==================== COMPONENT SIZING STANDARDS ====================
/// Component reference sizes for consistency
/// These are TARGET sizes after optimization (reduced from current)
class DesignComponents {
  DesignComponents._(); // Prevent instantiation

  // Button Sizing
  static const double buttonHeightSmall = 34.0;
  static const double buttonHeightMedium = 40.0; // STANDARD
  static const double buttonHeightLarge = 48.0;
  static const double buttonPaddingHorizontal = DesignSpacing.lg;
  static const double buttonPaddingVertical = 10.0;

  // Input Field Sizing
  static const double inputFieldHeight =
      48.0; // Material standard (reduced from 56dp)
  static const double inputFieldPadding = DesignSpacing.lg;
  static const double inputBorderRadius = DesignRadius.sm;

  // Card Sizing
  static const double cardPadding = DesignSpacing.lg; // 16dp
  static const double cardBorderRadius = DesignRadius.md; // 12dp
  static const double cardMinHeight =
      100.0; // Minimum height for cards (reduced from 120dp)

  // Avatar Sizing
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 40.0; // STANDARD
  static const double avatarLarge = 56.0;
  static const double avatarExtraLarge = 72.0; // For profiles

  // Badge Sizing
  static const double badgePaddingHorizontal = 8.0;
  static const double badgePaddingVertical = 4.0;
  static const double badgeMinHeight = 24.0;
  static const double badgeBorderRadius = DesignRadius.full;

  // List Item / Row Sizing
  static const double listItemMinHeight = 48.0; // Standard touch target
  static const double listItemPadding = DesignSpacing.lg;

  // AppBar Sizing
  static const double appBarHeight =
      56.0; // Reduced from 80dp to Material standard
  static const double appBarPadding = DesignSpacing.lg;
  static const double appBarElevation = 3.0;

  // Bottom Navigation Bar Sizing
  static const double bottomNavHeight = 56.0; // Standard Material
  static const double bottomNavPadding = DesignSpacing.sm;

  // FAB (Floating Action Button)
  static const double fabSize = 56.0; // Standard Material size
  static const double fabSizeSmall = 40.0;
  static const double fabSizeLarge = 80.0;

  // Chip/Tag Sizing
  static const double chipHeight = 32.0;
  static const double chipPaddingHorizontal = 12.0;
  static const double chipPaddingVertical = 8.0;

  // Dialog Sizing
  static const double dialogMinWidth = 280.0;
  static const double dialogMaxWidth = 560.0;
  static const double dialogPadding = DesignSpacing.lg;
  static const double dialogBorderRadius = DesignRadius.lg;

  // SnackBar Sizing
  static const double snackBarMinHeight = 48.0;
  static const double snackBarPadding = DesignSpacing.lg;
}

// ==================== RESPONSIVE BREAKPOINTS ====================
/// Mobile-first responsive design breakpoints
class DesignBreakpoints {
  DesignBreakpoints._(); // Prevent instantiation

  // Standard breakpoints (in logical pixels)
  static const double mobileSmall = 320.0; // Small phones (iPhone SE)
  static const double mobileMedium = 375.0; // Standard phones (iPhone 12)
  static const double mobileLarge = 414.0; // Large phones (iPhone 12 Pro Max)
  static const double tabletSmall = 600.0; // Small tablets (iPad mini)
  static const double tabletMedium = 768.0; // Standard tablets (iPad)
  static const double tabletLarge = 1024.0; // Large tablets
  static const double desktop = 1200.0; // Desktop screens

  // Helper methods for responsive design
  static bool isMobile(double width) => width < tabletSmall;
  static bool isTablet(double width) => width >= tabletSmall && width < desktop;
  static bool isDesktop(double width) => width >= desktop;

  // Responsive padding adjustments
  static double getScreenPadding(double width) {
    if (isDesktop(width)) return DesignSpacing.xxxl; // 32dp for desktop
    if (isTablet(width)) return DesignSpacing.xxl; // 24dp for tablets
    return DesignSpacing.lg; // 16dp for mobile (standard)
  }

  // Responsive font size scale
  static double getResponsiveFontSize(
    double mobileSize, {
    double tabletMultiplier = 1.1,
    double desktopMultiplier = 1.2,
    required double screenWidth,
  }) {
    if (isDesktop(screenWidth)) return mobileSize * desktopMultiplier;
    if (isTablet(screenWidth)) return mobileSize * tabletMultiplier;
    return mobileSize;
  }
}

// ==================== ANIMATION TIMINGS ====================
class DesignAnimations {
  DesignAnimations._(); // Prevent instantiation

  // Duration specifications (in milliseconds)
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationVerySlow = Duration(milliseconds: 800);

  // Common curves for animations
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveLinear = Curves.linear;

  // Semantic animation durations
  static const Duration fadeInDuration = durationNormal;
  static const Duration slideInDuration = durationNormal;
  static const Duration buttonPressDuration = durationFast;
  static const Duration dialogOpenDuration = durationNormal;
  static const Duration scrollAnimationDuration = durationSlow;
}

// ==================== ACCESSIBILITY STANDARDS ====================
class DesignAccessibility {
  DesignAccessibility._(); // Prevent instantiation

  // Minimum touch target size (Material Design standard)
  static const double minTouchTargetSize = 48.0;

  // Minimum contrast ratios
  static const double contrastRatioAAA = 7.0; // AAA level (strict)
  static const double contrastRatioAA = 4.5; // AA level (standard)

  // Focus indicators
  static const double focusBorderWidth = 2.0;
  static const Color focusColor = DesignColors.primary;
  static const double focusOutlineOffset = 2.0;
}
