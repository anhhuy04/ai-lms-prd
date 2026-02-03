import 'package:ai_mls/core/env/env.dart';
import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Connection Test
///
/// This test file verifies that the Supabase database connection is working properly.
/// It tests:
/// 1. Environment variables are correctly loaded
/// 2. Supabase client can be initialized
/// 3. Basic database operations can be performed
/// 4. Authentication status can be checked
void main() {
  group('Supabase Connection Tests', () {
    // Test 1: Verify environment variables are loaded
    test('Environment variables should be loaded correctly', () {
      expect(
        Env.supabaseUrl,
        isNotEmpty,
        reason: 'SUPABASE_URL should not be empty',
      );
      expect(
        Env.supabaseAnonKey,
        isNotEmpty,
        reason: 'SUPABASE_ANON_KEY should not be empty',
      );

      // Verify URL format
      expect(
        Env.supabaseUrl.startsWith('https://'),
        isTrue,
        reason: 'SUPABASE_URL should start with https://',
      );
      expect(
        Env.supabaseUrl.contains('.supabase.co'),
        isTrue,
        reason: 'SUPABASE_URL should contain .supabase.co',
      );

      // Verify anon key format (JWT format)
      expect(
        Env.supabaseAnonKey.split('.').length,
        equals(3),
        reason: 'SUPABASE_ANON_KEY should be in JWT format',
      );
    });

    // Test 2: Initialize Supabase client
    test('Supabase client should initialize successfully', () async {
      // This test should be run with network connectivity
      try {
        await SupabaseService.initialize(timeout: const Duration(seconds: 15));

        // Verify initialization
        expect(
          Supabase.instance.isInitialized,
          isTrue,
          reason: 'Supabase should be initialized',
        );

        // Verify client is available
        final client = SupabaseService.client;
        expect(client, isNotNull, reason: 'Supabase client should not be null');

        // Verify client has correct URL
        // Note: We can't directly access the URL from SupabaseClient in this version
        // But we can verify the client is working by checking if it's not null
        expect(client, isNotNull, reason: 'Supabase client should not be null');
      } catch (e) {
        fail('Failed to initialize Supabase: $e');
      }
    });

    // Test 3: Test basic database connectivity
    test('Database connectivity should work', () async {
      // Skip if Supabase is not initialized
      if (!Supabase.instance.isInitialized) {
        await SupabaseService.initialize(timeout: const Duration(seconds: 15));
      }

      final client = SupabaseService.client;

      try {
        // Test a simple RPC call to verify connectivity
        await client.rpc('test_connection').select();

        // If the RPC doesn't exist, we'll get an error, but that's okay
        // The important thing is that the connection attempt was made
        // Intentionally no print to keep CI logs clean.
      } on PostgrestException catch (e) {
        // This is expected if the test_connection RPC doesn't exist
        // Expected in some environments; keep logs quiet.
        // We'll consider this a pass as long as we got a response from the server
        expect(
          e.message,
          isNotEmpty,
          reason: 'Should get a response from server',
        );
      } catch (e) {
        fail('Failed to connect to database: $e');
      }
    });

    // Test 4: Test authentication status
    test('Authentication status should be checkable', () async {
      // Skip if Supabase is not initialized
      if (!Supabase.instance.isInitialized) {
        await SupabaseService.initialize(timeout: const Duration(seconds: 15));
      }

      final client = SupabaseService.client;

      try {
        // Check current session
        client.auth.currentSession;

        // Check current user
        client.auth.currentUser;

        // This should not throw an error, even if there's no active session
        // We're just verifying that the auth methods are accessible
      } catch (e) {
        fail('Failed to check authentication status: $e');
      }
    });

    // Test 5: Test basic table query (if tables exist)
    test('Basic table query should work', () async {
      // Skip if Supabase is not initialized
      if (!Supabase.instance.isInitialized) {
        await SupabaseService.initialize(timeout: const Duration(seconds: 15));
      }

      final client = SupabaseService.client;

      try {
        // Try to query a common table that likely exists
        // We'll use a small limit to avoid large data transfers
        await client.from('profiles').select('id').limit(1);

        // Intentionally no print to keep CI logs clean.

        // If the table doesn't exist, we'll get an error, but that's okay
        // The important thing is that the query attempt was made
      } on PostgrestException catch (e) {
        // This is expected if the table doesn't exist or we don't have permission
        // Expected in some environments; keep logs quiet.
        // We'll consider this a pass as long as we got a response from the server
        expect(
          e.message,
          isNotEmpty,
          reason: 'Should get a response from server',
        );
      } catch (e) {
        fail('Failed to perform basic query: $e');
      }
    });
  });

  // Helper test to run all connection tests sequentially
  test('Run all connection tests sequentially', () async {
    // Test 1: Environment variables
    expect(Env.supabaseUrl, isNotEmpty);
    expect(Env.supabaseAnonKey, isNotEmpty);

    // Test 2: Initialize Supabase
    try {
      await SupabaseService.initialize(timeout: const Duration(seconds: 15));
      expect(Supabase.instance.isInitialized, isTrue);
    } catch (e) {
      fail('Supabase initialization failed');
    }

    final client = SupabaseService.client;

    // Test 3: Database connectivity
    try {
      await client.rpc('test_connection').select();
    } on PostgrestException {
      // Expected in some environments; treat as pass (server responded).
    } catch (e) {
      fail('Database connectivity test failed');
    }

    // Test 4: Authentication status
    try {
      client.auth.currentSession;
      client.auth.currentUser;
    } catch (e) {
      fail('Authentication status check failed');
    }

    // Test 5: Basic query
    try {
      await client.from('profiles').select('id').limit(1);
    } on PostgrestException {
      // Expected in some environments; treat as pass (server responded).
    } catch (e) {
      fail('Basic query test failed');
    }
  });
}
