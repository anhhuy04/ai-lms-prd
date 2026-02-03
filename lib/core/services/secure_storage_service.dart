import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive data
///
/// This service provides a wrapper around flutter_secure_storage for storing
/// sensitive data like authentication tokens, API keys, and credentials.
///
/// **Security Features:**
/// - Uses platform-specific secure storage (Keychain on iOS, KeyStore on Android)
/// - Data is encrypted at rest
/// - Automatically handles platform-specific security requirements
///
/// **Usage:**
/// ```dart
/// // Write sensitive data
/// await SecureStorageService.write('auth_token', 'your-token-here');
///
/// // Read sensitive data
/// final token = await SecureStorageService.read('auth_token');
///
/// // Check if key exists
/// final exists = await SecureStorageService.containsKey('auth_token');
///
/// // Delete data
/// await SecureStorageService.delete('auth_token');
///
/// // Clear all data
/// await SecureStorageService.clear();
/// ```
///
/// **When to use SecureStorageService vs SharedPreferences:**
/// - **SecureStorageService**: Tokens, passwords, API keys, credentials
/// - **SharedPreferences**: User preferences, settings, non-sensitive data
class SecureStorageService {
  SecureStorageService._();

  /// FlutterSecureStorage instance with default options
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    // Use default options - secure on both iOS and Android
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Write a value to secure storage
  ///
  /// [key] - The key to store the value under
  /// [value] - The value to store (must be a String)
  ///
  /// Throws an exception if writing fails.
  static Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      AppLogger.debug('SecureStorageService: Wrote value for key "$key"');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SecureStorageService: Failed to write key "$key"',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Read a value from secure storage
  ///
  /// [key] - The key to read the value for
  ///
  /// Returns the value if found, null otherwise.
  /// Throws an exception if reading fails.
  static Future<String?> read(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null) {
        AppLogger.debug('SecureStorageService: Read value for key "$key"');
      } else {
        AppLogger.debug('SecureStorageService: No value found for key "$key"');
      }
      return value;
    } catch (e, stackTrace) {
      AppLogger.error(
        'SecureStorageService: Failed to read key "$key"',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Delete a value from secure storage
  ///
  /// [key] - The key to delete
  ///
  /// Throws an exception if deletion fails.
  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      AppLogger.debug('SecureStorageService: Deleted key "$key"');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SecureStorageService: Failed to delete key "$key"',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Check if a key exists in secure storage
  ///
  /// [key] - The key to check
  ///
  /// Returns true if the key exists, false otherwise.
  /// Throws an exception if checking fails.
  static Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      final exists = value != null;
      AppLogger.debug(
        'SecureStorageService: Key "$key" ${exists ? "exists" : "does not exist"}',
      );
      return exists;
    } catch (e, stackTrace) {
      AppLogger.error(
        'SecureStorageService: Failed to check key "$key"',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Clear all data from secure storage
  ///
  /// **Warning:** This will delete ALL stored data. Use with caution.
  ///
  /// Throws an exception if clearing fails.
  static Future<void> clear() async {
    try {
      await _storage.deleteAll();
      AppLogger.info('SecureStorageService: Cleared all secure storage data');
    } catch (e, stackTrace) {
      AppLogger.error(
        'SecureStorageService: Failed to clear secure storage',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Read all keys and values from secure storage
  ///
  /// Returns a map of all stored key-value pairs.
  /// Throws an exception if reading fails.
  static Future<Map<String, String>> readAll() async {
    try {
      final allData = await _storage.readAll();
      AppLogger.debug(
        'SecureStorageService: Read all data (${allData.length} keys)',
      );
      return allData;
    } catch (e, stackTrace) {
      AppLogger.error(
        'SecureStorageService: Failed to read all data',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
