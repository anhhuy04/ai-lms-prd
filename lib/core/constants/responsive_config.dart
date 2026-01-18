import 'device_types.dart';
import 'design_tokens.dart';

/// Responsive layout configuration for different device types
class ResponsiveLayoutConfig {
  final double screenPadding;
  final double cardPadding;
  final double sectionSpacing;
  final int maxColumns;
  final double maxContentWidth;
  final double gridSpacing;
  final double itemSpacing;

  const ResponsiveLayoutConfig({
    required this.screenPadding,
    required this.cardPadding,
    required this.sectionSpacing,
    required this.maxColumns,
    required this.maxContentWidth,
    required this.gridSpacing,
    required this.itemSpacing,
  });
}

/// Responsive configuration provider
class ResponsiveConfig {
  ResponsiveConfig._(); // Prevent instantiation

  /// Get mobile layout configuration
  static ResponsiveLayoutConfig mobile() {
    return const ResponsiveLayoutConfig(
      screenPadding: DesignSpacing.lg, // 16dp
      cardPadding: DesignSpacing.lg, // 16dp
      sectionSpacing: DesignSpacing.xxl, // 22dp
      maxColumns: 1,
      maxContentWidth: double.infinity, // Full width
      gridSpacing: DesignSpacing.md, // 12dp
      itemSpacing: DesignSpacing.md, // 12dp
    );
  }

  /// Get tablet layout configuration
  static ResponsiveLayoutConfig tablet() {
    return const ResponsiveLayoutConfig(
      screenPadding: DesignSpacing.xxl, // 22dp
      cardPadding: DesignSpacing.lg, // 16dp
      sectionSpacing: DesignSpacing.xxxl, // 28dp
      maxColumns: 2,
      maxContentWidth: 768.0, // Max width constraint
      gridSpacing: DesignSpacing.lg, // 16dp
      itemSpacing: DesignSpacing.md, // 12dp
    );
  }

  /// Get desktop layout configuration
  static ResponsiveLayoutConfig desktop() {
    return const ResponsiveLayoutConfig(
      screenPadding: DesignSpacing.xxxl, // 28dp
      cardPadding: DesignSpacing.xl, // 18dp
      sectionSpacing: DesignSpacing.xxxxl, // 36dp
      maxColumns: 3,
      maxContentWidth: 1200.0, // Max width constraint
      gridSpacing: DesignSpacing.lg, // 16dp
      itemSpacing: DesignSpacing.lg, // 16dp
    );
  }

  /// Get layout configuration based on device type
  static ResponsiveLayoutConfig getConfig(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile();
      case DeviceType.tablet:
        return tablet();
      case DeviceType.desktop:
        return desktop();
    }
  }
}
