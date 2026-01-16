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

@deprecated
class AppColors {
  @deprecated
  static const Color primary = DesignColors.primary;

  @deprecated
  static const Color secondary = DesignColors.primaryDark;

  @deprecated
  static const Color background = DesignColors.moonLight;

  @deprecated
  static const Color error = DesignColors.error;

  @deprecated
  static const Color teal = DesignColors.primary;
}

@deprecated
class AppSizes {
  @deprecated
  static const double p4 = DesignSpacing.xs;

  @deprecated
  static const double p8 = DesignSpacing.sm;

  @deprecated
  static const double p12 = DesignSpacing.md;

  @deprecated
  static const double p16 = DesignSpacing.lg;

  @deprecated
  static const double p20 = DesignSpacing.xl;

  @deprecated
  static const double p24 = DesignSpacing.xxl;

  @deprecated
  static const double p32 = DesignSpacing.xxxl;
}
