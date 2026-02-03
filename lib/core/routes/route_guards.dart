import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Future<void> routeGuardLog({
  required String location,
  required String message,
  required Map<String, dynamic> data,
}) async {
  // Logging này chỉ phục vụ debug; tuyệt đối không chạy trong release/profile
  // vì gây I/O + network => dễ jank khi chuyển route/tab.
  if (!kDebugMode) return;

  final logEntry = {
    'sessionId': 'debug-session',
    'runId': 'run1',
    'hypothesisId': 'H2',
    'location': location,
    'message': message,
    'data': data,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };

  if (Platform.isWindows) {
    try {
      final logFile = File(
        'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
      );
      await logFile.parent.create(recursive: true);
      // Tránh ghi sync (block UI thread). Dùng async append.
      await logFile.writeAsString(
        '${jsonEncode(logEntry)}\n',
        mode: FileMode.append,
        flush: false,
      );
    } catch (_) {}
  }

  // Tắt gửi HTTP log: gây network jitter + không cần thiết cho app runtime.
}

/// Route guard utilities for authentication and authorization
///
/// This module provides helper functions for route guards used in GoRouter.
/// Guards check authentication status and user roles before allowing navigation.
class RouteGuards {
  RouteGuards._();

  /// Check if user is authenticated
  ///
  /// [ref] - Riverpod ref to access providers
  /// Returns true if user is logged in, false otherwise
  static bool isAuthenticated(Ref ref) {
    final currentUserAsync = ref.read(currentUserProvider);
    return currentUserAsync.value != null;
  }

  /// Get current user profile
  ///
  /// [ref] - Riverpod ref to access providers
  /// Returns user profile or null if not logged in
  static dynamic getCurrentUser(Ref ref) {
    final currentUserAsync = ref.read(currentUserProvider);
    return currentUserAsync.value;
  }

  /// Get current user role
  ///
  /// [ref] - Riverpod ref to access providers
  /// Returns user role ('student', 'teacher', 'admin') or empty string if not logged in
  static String getCurrentUserRole(Ref ref) {
    final profile = getCurrentUser(ref);
    return profile?.role ?? '';
  }

  /// Check if user has specific role
  ///
  /// [ref] - Riverpod ref to access providers
  /// [role] - Role to check ('student', 'teacher', 'admin')
  /// Returns true if user has the specified role
  static bool hasRole(Ref ref, String role) {
    final profile = getCurrentUser(ref);
    return profile?.role == role;
  }

  /// Check if user has any of the specified roles
  ///
  /// [ref] - Riverpod ref to access providers
  /// [roles] - List of roles to check
  /// Returns true if user has any of the specified roles
  static bool hasAnyRole(Ref ref, List<String> roles) {
    final profile = getCurrentUser(ref);
    if (profile == null) return false;
    return roles.contains(profile.role);
  }

  /// Check if user can access a specific route
  ///
  /// [ref] - Riverpod ref to access providers
  /// [routeName] - Name of the route to check
  /// Returns true if user has permission to access the route
  static bool canAccessRoute(Ref ref, String routeName) {
    final role = getCurrentUserRole(ref);
    return AppRoute.canAccessRoute(role, routeName);
  }

  /// Get the default dashboard path for user role
  ///
  /// [ref] - Riverpod ref to access providers
  /// Returns dashboard path for user's role
  static String getDefaultDashboardPath(Ref ref) {
    final role = getCurrentUserRole(ref);
    return AppRoute.getDashboardPathForRole(role);
  }

  /// Guard function for redirect logic - 3-step authentication + RBAC check
  ///
  /// Step 1: Allow public routes
  /// Step 2: Check authentication (redirect to login if not authenticated)
  /// Step 3: Check RBAC (redirect to default dashboard if role doesn't match)
  static String? appRouterRedirect(
    BuildContext context,
    GoRouterState state,
    Ref ref,
  ) {
    final currentPath = state.matchedLocation;
    final isAuth = isAuthenticated(ref);
    final userRole = getCurrentUserRole(ref);
    // #region agent log
    unawaited(
      routeGuardLog(
        location: 'route_guards.dart:40',
        message: 'appRouterRedirect evaluated',
        data: {
          'matchedLocation': currentPath,
          'routeName': state.name,
          'isAuth': isAuth,
          'userRole': userRole,
        },
      ),
    );
    // #endregion

    // Step 1: Allow public routes (no redirect needed)
    if (AppRoute.isPublicRoute(currentPath)) {
      return null;
    }

    // Step 2: Not authenticated - redirect to login (with return-to parameter)
    if (!isAuth) {
      if (currentPath != AppRoute.loginPath &&
          currentPath != AppRoute.registerPath) {
        return '${AppRoute.loginPath}?redirect=${Uri.encodeComponent(currentPath)}';
      }
      return null;
    }

    // If authenticated but trying to access login/register, redirect to dashboard
    if (currentPath == AppRoute.loginPath ||
        currentPath == AppRoute.registerPath) {
      return AppRoute.getDashboardPathForRole(userRole);
    }

    // Step 3: RBAC check - verify user can access this route
    final routeName = state.name;
    if (routeName != null && !canAccessRoute(ref, routeName)) {
      // User doesn't have permission - redirect to appropriate dashboard
      return AppRoute.getDashboardPathForRole(userRole);
    }

    return null;
  }

  /// Redirect logic for authenticated access only
  ///
  /// This is a simpler version if you just need auth checks without RBAC
  static String? authGuard(BuildContext context, GoRouterState state, Ref ref) {
    final isAuth = isAuthenticated(ref);
    final isLoggingIn =
        state.matchedLocation == AppRoute.loginPath ||
        state.matchedLocation == AppRoute.registerPath;
    final isSplash = state.matchedLocation == AppRoute.splashPath;

    // Allow splash screen
    if (isSplash) {
      return null;
    }

    // Not authenticated - redirect to login
    if (!isAuth) {
      if (!isLoggingIn) {
        final currentPath = state.uri.toString();
        if (currentPath != AppRoute.loginPath &&
            currentPath != AppRoute.registerPath) {
          return '${AppRoute.loginPath}?redirect=${Uri.encodeComponent(currentPath)}';
        }
        return AppRoute.loginPath;
      }
      return null; // Allow login/register access
    }

    // Already authenticated but trying to access login/register
    if (isLoggingIn) {
      final profile = getCurrentUser(ref);
      return AppRoute.getDashboardPathForRole(profile?.role ?? '');
    }

    return null;
  }
}
