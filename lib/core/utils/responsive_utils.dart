import 'dart:convert';
import 'dart:io' show File, FileMode, Platform;

import 'package:flutter/material.dart';

import '../constants/design_tokens.dart';
import '../constants/device_types.dart';
import '../constants/responsive_config.dart';

/// Responsive utilities for device detection and responsive value calculation
class ResponsiveUtils {
  ResponsiveUtils._(); // Prevent instantiation

  // #region agent log
  static dynamic _sanitizeData(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.fromEntries(
        data.entries.map(
          (e) => MapEntry(e.key.toString(), _sanitizeData(e.value)),
        ),
      );
    } else if (data is List) {
      return data.map((e) => _sanitizeData(e)).toList();
    } else if (data is double) {
      if (data.isInfinite) return 'Infinity';
      if (data.isNaN) return 'NaN';
      return data;
    } else if (data is num && !data.isFinite) {
      return 'Infinity';
    }
    return data;
  }

  static void _log(
    String location,
    String message,
    Map<String, dynamic> data,
    String hypothesisId,
  ) {
    try {
      final logPath = Platform.isWindows
          ? r'd:\code\Flutter_Android\AI_LMS_PRD\.cursor\debug.log'
          : '/data/data/com.example.ai_mls/files/debug.log';
      final logFile = File(logPath);

      try {
        logFile.parent.createSync(recursive: true);
      } catch (_) {
        debugPrint('Log: $location - $message - ${_sanitizeData(data)}');
        return;
      }

      final sanitizedData = _sanitizeData(data);
      final logEntry = {
        'sessionId': 'debug-session',
        'runId': 'run1',
        'hypothesisId': hypothesisId,
        'location': location,
        'message': message,
        'data': sanitizedData,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      final jsonString = jsonEncode(logEntry);
      final existingContent = logFile.existsSync()
          ? logFile.readAsStringSync()
          : '';
      logFile.writeAsStringSync(
        '$existingContent$jsonString\n',
        mode: FileMode.write,
      );
    } catch (e) {
      debugPrint('Log: $location - $message - ${_sanitizeData(data)}');
      debugPrint('Logging error: $e');
    }
  }
  // #endregion

  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // #region agent log
    _log('responsive_utils.dart:13', 'getDeviceType entry', {
      'width': width,
      'tabletSmall': DesignBreakpoints.tabletSmall,
      'desktop': DesignBreakpoints.desktop,
    }, 'A');
    // #endregion
    DeviceType deviceType;
    if (width < DesignBreakpoints.tabletSmall) {
      deviceType = DeviceType.mobile;
    } else if (width < DesignBreakpoints.desktop) {
      deviceType = DeviceType.tablet;
    } else {
      deviceType = DeviceType.desktop;
    }
    // #region agent log
    _log('responsive_utils.dart:20', 'getDeviceType exit', {
      'deviceType': deviceType.toString(),
    }, 'A');
    // #endregion
    return deviceType;
  }

  /// Check if current device is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Check if current device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Check if current device is desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// Get responsive value based on device type
  ///
  /// Example:
  /// ```dart
  /// final padding = ResponsiveUtils.responsiveValue(
  ///   context,
  ///   mobile: 16.0,
  ///   tablet: 24.0,
  ///   desktop: 32.0,
  /// );
  /// ```
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get layout configuration for current device
  static ResponsiveLayoutConfig getLayoutConfig(BuildContext context) {
    final deviceType = getDeviceType(context);
    final config = ResponsiveConfig.getConfig(deviceType);
    // #region agent log
    _log('responsive_utils.dart:77', 'getLayoutConfig', {
      'deviceType': deviceType.toString(),
      'screenPadding': config.screenPadding,
      'cardPadding': config.cardPadding,
      'sectionSpacing': config.sectionSpacing,
      'maxColumns': config.maxColumns,
      'maxContentWidth': config.maxContentWidth,
      'gridSpacing': config.gridSpacing,
      'itemSpacing': config.itemSpacing,
    }, 'B');
    // #endregion
    return config;
  }
}
