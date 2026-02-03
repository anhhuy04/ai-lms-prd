import 'dart:convert';
import 'dart:io' show File, FileMode, Platform;

import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/constants/design_tokens.dart';
import '../../core/utils/responsive_utils.dart';

/// Grid layout that automatically adjusts column count based on device type
class ResponsiveGrid extends StatelessWidget {
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
    if (!kDebugMode) return;
    try {
      // Chỉ ghi log ra file trên Windows host để tránh I/O + jank trên mobile.
      if (!Platform.isWindows) return;
      final logPath = r'd:\code\Flutter_Android\AI_LMS_PRD\.cursor\debug.log';
      final logFile = File(logPath);

      try {
        // Tránh I/O sync trong runtime UI loop
        // ignore: discarded_futures
        logFile.parent.create(recursive: true);
      } catch (_) {
        AppLogger.debug('Log: $location - $message - ${_sanitizeData(data)}');
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
      // ignore: discarded_futures
      logFile
          .writeAsString(
            '$jsonString\n',
            mode: FileMode.append,
            flush: false,
          )
          .catchError((_) => logFile);
    } catch (e) {
      AppLogger.debug('Log: $location - $message - ${_sanitizeData(data)}');
      AppLogger.error('Logging error: $e', error: e);
    }
  }

  // #endregion
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double? spacing;
  final double? runSpacing;
  final CrossAxisAlignment? crossAxisAlignment;
  final MainAxisAlignment? mainAxisAlignment;
  final MainAxisSize? mainAxisSize;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.spacing,
    this.runSpacing,
    this.crossAxisAlignment,
    this.mainAxisAlignment,
    this.mainAxisSize,
  });

  @override
  Widget build(BuildContext context) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    final screenWidth = ResponsiveUtils.screenWidth(context);
    // #region agent log
    _log('responsive_grid.dart:32', 'ResponsiveGrid build entry', {
      'screenWidth': screenWidth,
      'childrenCount': children.length,
    }, 'D');
    // #endregion

    // Determine column count
    final columns = DesignBreakpoints.getColumnCount(
      screenWidth,
      mobileColumns: mobileColumns ?? config.maxColumns,
      tabletColumns: tabletColumns ?? config.maxColumns,
      desktopColumns: desktopColumns ?? config.maxColumns,
    );

    // Determine spacing
    final effectiveSpacing = spacing ?? config.gridSpacing;
    final effectiveRunSpacing = runSpacing ?? config.gridSpacing;

    // Calculate item width
    // Ensure we don't have negative width
    final totalSpacing = effectiveSpacing * (columns - 1);
    final horizontalPadding = config.screenPadding * 2;
    final availableWidth = (screenWidth - horizontalPadding).clamp(
      0.0,
      double.infinity,
    );
    final itemWidth = columns > 0
        ? ((availableWidth - totalSpacing) / columns).clamp(
            0.0,
            double.infinity,
          )
        : availableWidth;
    // #region agent log
    _log('responsive_grid.dart:55', 'ResponsiveGrid width calculation', {
      'columns': columns,
      'totalSpacing': totalSpacing,
      'horizontalPadding': horizontalPadding,
      'availableWidth': availableWidth,
      'itemWidth': itemWidth,
      'effectiveSpacing': effectiveSpacing,
    }, 'D');
    // #endregion

    return Wrap(
      spacing: effectiveSpacing,
      runSpacing: effectiveRunSpacing,
      alignment: mainAxisAlignment?.toWrapAlignment() ?? WrapAlignment.start,
      children: children.map((child) {
        return SizedBox(width: itemWidth, child: child);
      }).toList(),
    );
  }
}

/// Extension to convert MainAxisAlignment to WrapAlignment
extension MainAxisAlignmentExtension on MainAxisAlignment {
  WrapAlignment toWrapAlignment() {
    switch (this) {
      case MainAxisAlignment.start:
        return WrapAlignment.start;
      case MainAxisAlignment.end:
        return WrapAlignment.end;
      case MainAxisAlignment.center:
        return WrapAlignment.center;
      case MainAxisAlignment.spaceBetween:
        return WrapAlignment.spaceBetween;
      case MainAxisAlignment.spaceAround:
        return WrapAlignment.spaceAround;
      case MainAxisAlignment.spaceEvenly:
        return WrapAlignment.spaceEvenly;
    }
  }
}
