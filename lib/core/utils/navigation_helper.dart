import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Helper class for navigation operations without router dependency
class NavigationHelper {
  NavigationHelper._();

  /// Go back to previous screen in navigation stack
  /// Works across all navigation patterns (GoRouter, Navigator, etc.)
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      // Fallback: try Navigator
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  /// Go back with a result
  static void goBackWithResult<T>(BuildContext context, T result) {
    if (context.canPop()) {
      context.pop(result);
    } else {
      Navigator.of(context).pop(result);
    }
  }

  /// Check if can go back
  static bool canGoBack(BuildContext context) {
    return context.canPop() || Navigator.of(context).canPop();
  }
}
