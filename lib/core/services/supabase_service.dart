import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ai_mls/core/env/env.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for initializing and accessing Supabase client
///
/// This service uses environment variables from the Env class
/// which are loaded at compile-time for security.
///
/// The Supabase URL and anon key are now securely managed through
/// environment configuration files (.env.dev, .env.staging, .env.prod)
class SupabaseService {
  /// Initialize Supabase with environment variables
  ///
  /// This method should be called once at app startup (in main.dart)
  /// before any Supabase operations.
  ///
  /// Throws an exception if initialization fails or times out after 15 seconds.
  static Future<void> initialize({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    // #region agent log
    _agentLog(
      location: 'supabase_service.dart:20',
      message: 'Supabase initialize start',
      data: {
        'supabaseHost': Uri.tryParse(Env.supabaseUrl)?.host,
        'timeoutSeconds': timeout.inSeconds,
      },
      hypothesisId: 'H1',
    );
    // #endregion

    try {
      // Validate environment variables before attempting connection
      if (Env.supabaseUrl.isEmpty || Env.supabaseAnonKey.isEmpty) {
        throw Exception(
          'Supabase environment variables are not configured. '
          'Please ensure SUPABASE_URL and SUPABASE_ANON_KEY are set in your .env file.',
        );
      }

      // Initialize with timeout to prevent indefinite hanging
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      ).timeout(
        timeout,
        onTimeout: () => throw TimeoutException(
          'Supabase initialization timed out after ${timeout.inSeconds} seconds. '
          'Check your network connection and Supabase configuration.',
          timeout,
        ),
      );

      // #region agent log
      _agentLog(
        location: 'supabase_service.dart:41',
        message: 'Supabase initialize success',
        data: {'isInitialized': Supabase.instance.isInitialized},
        hypothesisId: 'H1',
      );
      // #endregion
    } catch (e) {
      // #region agent log
      _agentLog(
        location: 'supabase_service.dart:50',
        message: 'Supabase initialize error',
        data: {'error': e.toString(), 'errorType': e.runtimeType.toString()},
        hypothesisId: 'H1',
      );
      // #endregion

      // Re-throw with more context for debugging
      throw Exception(
        'Failed to initialize Supabase: $e\n'
        'Please ensure:\n'
        '1. Your .env.dev file has valid SUPABASE_URL and SUPABASE_ANON_KEY\n'
        '2. Your network connection is active\n'
        '3. The Supabase project is accessible',
      );
    }
  }

  /// Get the Supabase client instance
  ///
  /// Returns the initialized Supabase client.
  /// Throws an error if Supabase has not been initialized.
  static SupabaseClient get client {
    if (!Supabase.instance.isInitialized) {
      throw Exception(
        'Supabase has not been initialized. '
        'Call SupabaseService.initialize() first.',
      );
    }
    return Supabase.instance.client;
  }
}

// #region agent log
void _agentLog({
  required String location,
  required String message,
  required Map<String, dynamic> data,
  required String hypothesisId,
}) {
  if (!kDebugMode) return;
  if (!Platform.isWindows) return;
  try {
    final logEntry = {
      'sessionId': 'debug-session',
      'runId': 'run1',
      'hypothesisId': hypothesisId,
      'location': location,
      'message': message,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    final logFile = File(
      r'd:\code\Flutter_Android\AI_LMS_PRD\.cursor\debug.log',
    );
    // Tránh I/O sync trong runtime UI loop
    // ignore: discarded_futures
    logFile.parent
        .create(recursive: true)
        .then((_) {
          return logFile.writeAsString(
            '${jsonEncode(logEntry)}\n',
            mode: FileMode.append,
            flush: false,
          );
        })
        .catchError((_) => logFile);
  } catch (_) {}
}

// #endregion
