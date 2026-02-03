import 'package:flutter/material.dart';
import 'design_tokens.dart';

// ============================================================================
// DEPRECATED: Use design_tokens.dart instead for all new code
//
// This file is maintained for backward compatibility only.
// All references should be migrated to DesignColors, DesignSpacing,
// DesignTypography, DesignIcons, DesignRadius, DesignElevation, and
// DesignComponents from design_tokens.dart
//
// Single Source of Truth: lib/core/constants/design_tokens.dart
// ============================================================================

@Deprecated('Legacy constants. Dùng DesignColors trong design_tokens.dart.')
class AppColors {
  @Deprecated('Legacy constants. Dùng DesignColors.primary trong design_tokens.dart.')
  static const Color primary = DesignColors.primary;

  @Deprecated('Legacy constants. Dùng DesignColors.primaryDark trong design_tokens.dart.')
  static const Color secondary = DesignColors.primaryDark;

  @Deprecated('Legacy constants. Dùng DesignColors.moonLight trong design_tokens.dart.')
  static const Color background = DesignColors.moonLight;

  @Deprecated('Legacy constants. Dùng DesignColors.error trong design_tokens.dart.')
  static const Color error = DesignColors.error;

  @Deprecated('Legacy constants. Dùng DesignColors.primary/tealPrimary trong design_tokens.dart.')
  static const Color teal = DesignColors.primary;
}

@Deprecated('Legacy constants. Dùng DesignSpacing trong design_tokens.dart.')
class AppSizes {
  @Deprecated('Legacy constants. Dùng DesignSpacing.xs trong design_tokens.dart.')
  static const double p4 = DesignSpacing.xs;

  @Deprecated('Legacy constants. Dùng DesignSpacing.sm trong design_tokens.dart.')
  static const double p8 = DesignSpacing.sm;

  @Deprecated('Legacy constants. Dùng DesignSpacing.md trong design_tokens.dart.')
  static const double p12 = DesignSpacing.md;

  @Deprecated('Legacy constants. Dùng DesignSpacing.lg trong design_tokens.dart.')
  static const double p16 = DesignSpacing.lg;

  @Deprecated('Legacy constants. Dùng DesignSpacing.xl trong design_tokens.dart.')
  static const double p20 = DesignSpacing.xl;

  @Deprecated('Legacy constants. Dùng DesignSpacing.xxl trong design_tokens.dart.')
  static const double p24 = DesignSpacing.xxl;

  @Deprecated('Legacy constants. Dùng DesignSpacing.xxxl trong design_tokens.dart.')
  static const double p32 = DesignSpacing.xxxl;
}
