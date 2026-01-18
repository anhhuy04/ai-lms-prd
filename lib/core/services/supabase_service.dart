import 'package:ai_mls/core/env/env.dart';
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
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );
    } catch (e) {
      throw Exception(
        'Failed to initialize Supabase: $e\n'
        'Please ensure your .env file is properly configured.',
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
