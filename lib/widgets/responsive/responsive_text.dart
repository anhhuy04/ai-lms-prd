import 'dart:convert';
import 'dart:io' show File, FileMode, Platform;

import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/constants/design_tokens.dart';
import '../../core/utils/responsive_utils.dart';

/// Text widget with responsive font sizing based on device type
class ResponsiveText extends StatelessWidget {
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
    // Widget này được build rất thường xuyên; tuyệt đối không log sync trong runtime.
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
      // Append async, không đọc/ghi sync.
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
  final String text;
  final TextStyle? style;
  final double? fontSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final double? height;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontWeight,
    this.letterSpacing,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveUtils.screenWidth(context);
    final baseFontSize =
        fontSize ?? style?.fontSize ?? DesignTypography.bodyMediumSize;
    // #region agent log
    _log('responsive_text.dart:34', 'ResponsiveText build entry', {
      'screenWidth': screenWidth,
      'baseFontSize': baseFontSize,
      'text': text.substring(0, text.length > 20 ? 20 : text.length),
    }, 'C');
    // #endregion

    // Calculate responsive font size
    final responsiveFontSize = DesignBreakpoints.getResponsiveFontSize(
      baseFontSize,
      screenWidth: screenWidth,
    );
    // #region agent log
    _log('responsive_text.dart:42', 'ResponsiveText font size calculated', {
      'responsiveFontSize': responsiveFontSize,
      'multiplier': responsiveFontSize / baseFontSize,
    }, 'C');
    // #endregion

    // Merge styles
    final effectiveStyle = (style ?? const TextStyle()).copyWith(
      fontSize: responsiveFontSize,
      color: color ?? style?.color,
      fontWeight: fontWeight ?? style?.fontWeight,
      letterSpacing: letterSpacing ?? style?.letterSpacing,
      height: height ?? style?.height,
    );

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
