import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service quản lý metadata của profile một cách thông minh
///
/// Cung cấp:
/// - Cache metadata để tránh query nhiều lần
/// - Helper methods để get/set nested values trong JSONB
/// - Type-safe accessors cho các keys phổ biến
/// - Auto-sync với profile changes
///
/// Usage:
/// ```dart
/// // Get nested value
/// final geminiKey = await ProfileMetadataService.get<String>('api_keys.gemini');
///
/// // Set nested value
/// await ProfileMetadataService.set('api_keys.gemini', 'AIzaSy...');
///
/// // Type-safe getters
/// final geminiKey = await ProfileMetadataService.getGeminiApiKey();
/// await ProfileMetadataService.setGeminiApiKey('AIzaSy...');
/// ```
class ProfileMetadataService {
  ProfileMetadataService._();

  static SupabaseClient get _supabase => SupabaseService.client;

  // Cache metadata để tránh query nhiều lần
  static Map<String, dynamic>? _cachedMetadata;
  static String? _cachedUserId;
  static DateTime? _lastCacheUpdate;

  // Cache TTL: 5 phút
  static const Duration _cacheTtl = Duration(minutes: 5);

  /// Lấy metadata từ cache hoặc database
  ///
  /// [forceRefresh] - Nếu true, bỏ qua cache và query lại từ database
  ///
  /// Returns: Metadata map hoặc null nếu không có
  static Future<Map<String, dynamic>?> getMetadata({
    bool forceRefresh = false,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _clearCache();
        return null;
      }

      // Kiểm tra cache
      if (!forceRefresh &&
          _cachedMetadata != null &&
          _cachedUserId == userId &&
          _lastCacheUpdate != null &&
          DateTime.now().difference(_lastCacheUpdate!) < _cacheTtl) {
        AppLogger.debug('📦 [Metadata Service] Using cached metadata');
        return _cachedMetadata;
      }

      // Query từ database
      final response = await _supabase
          .from('profiles')
          .select('metadata')
          .eq('id', userId)
          .single();

      final metadata = response['metadata'] as Map<String, dynamic>?;

      // Update cache
      _cachedMetadata = metadata ?? {};
      _cachedUserId = userId;
      _lastCacheUpdate = DateTime.now();

      AppLogger.debug('💾 [Metadata Service] Metadata cached');
      return _cachedMetadata;
    } catch (e) {
      AppLogger.error(
        '❌ [Metadata Service] Error getting metadata: $e',
        error: e,
      );
      // Return cached data nếu có, ngay cả khi đã hết TTL
      return _cachedMetadata;
    }
  }

  /// Lấy giá trị từ metadata theo path (dot notation)
  ///
  /// Example:
  /// - Path: 'api_keys.gemini' → metadata['api_keys']['gemini']
  /// - Path: 'preferences.theme' → metadata['preferences']['theme']
  ///
  /// [path] - Dot-separated path trong metadata
  /// [defaultValue] - Giá trị mặc định nếu không tìm thấy
  ///
  /// Returns: Giá trị tại path hoặc defaultValue
  static Future<T?> get<T>(
    String path, {
    T? defaultValue,
    bool forceRefresh = false,
  }) async {
    final metadata = await getMetadata(forceRefresh: forceRefresh);
    if (metadata == null) return defaultValue;

    final keys = path.split('.');
    dynamic current = metadata;

    for (final key in keys) {
      if (current is Map<String, dynamic>) {
        current = current[key];
        if (current == null) return defaultValue;
      } else {
        return defaultValue;
      }
    }

    try {
      return current as T;
    } catch (e) {
      AppLogger.warning(
        '⚠️ [Metadata Service] Type cast error for path "$path": $e',
      );
      return defaultValue;
    }
  }

  /// Set giá trị vào metadata theo path (dot notation)
  ///
  /// Example:
  /// - Path: 'api_keys.gemini', value: 'AIzaSy...'
  /// - Path: 'preferences.theme', value: 'dark'
  ///
  /// [path] - Dot-separated path trong metadata
  /// [value] - Giá trị cần set
  /// [merge] - Nếu true, merge với metadata hiện tại (default: true)
  ///
  /// Returns: true nếu thành công
  static Future<bool> set<T>(String path, T value, {bool merge = true}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning(
          '⚠️ [Metadata Service] Cannot set metadata: User not authenticated',
        );
        return false;
      }

      // Lấy metadata hiện tại
      final currentMetadata = await getMetadata(forceRefresh: true) ?? {};

      // Tạo nested structure theo path
      final keys = path.split('.');
      Map<String, dynamic> target = currentMetadata;

      // Navigate đến parent của key cuối cùng
      for (int i = 0; i < keys.length - 1; i++) {
        final key = keys[i];
        if (target[key] is! Map<String, dynamic>) {
          target[key] = <String, dynamic>{};
        }
        target = target[key] as Map<String, dynamic>;
      }

      // Set giá trị tại key cuối cùng
      final lastKey = keys.last;
      target[lastKey] = value;

      // Update database
      await _supabase
          .from('profiles')
          .update({
            'metadata': currentMetadata,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // Update cache
      _cachedMetadata = currentMetadata;
      _lastCacheUpdate = DateTime.now();

      AppLogger.info('✅ [Metadata Service] Set metadata path "$path"');
      return true;
    } catch (e) {
      AppLogger.error(
        '❌ [Metadata Service] Error setting metadata: $e',
        error: e,
      );
      return false;
    }
  }

  /// Xóa giá trị tại path
  ///
  /// [path] - Dot-separated path trong metadata
  ///
  /// Returns: true nếu thành công
  static Future<bool> remove(String path) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final currentMetadata = await getMetadata(forceRefresh: true) ?? {};
      final keys = path.split('.');

      if (keys.length == 1) {
        // Xóa key ở root level
        currentMetadata.remove(keys.first);
      } else {
        // Navigate đến parent và xóa
        Map<String, dynamic>? target = currentMetadata;
        for (int i = 0; i < keys.length - 1; i++) {
          target = target?[keys[i]] as Map<String, dynamic>?;
          if (target == null) return false;
        }
        target?.remove(keys.last);
      }

      // Update database
      await _supabase
          .from('profiles')
          .update({
            'metadata': currentMetadata,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // Update cache
      _cachedMetadata = currentMetadata;
      _lastCacheUpdate = DateTime.now();

      AppLogger.info('✅ [Metadata Service] Removed metadata path "$path"');
      return true;
    } catch (e) {
      AppLogger.error(
        '❌ [Metadata Service] Error removing metadata: $e',
        error: e,
      );
      return false;
    }
  }

  /// Clear cache (khi user logout hoặc profile thay đổi)
  static void clearCache() {
    _clearCache();
    AppLogger.debug('🗑️ [Metadata Service] Cache cleared');
  }

  static void _clearCache() {
    _cachedMetadata = null;
    _cachedUserId = null;
    _lastCacheUpdate = null;
  }

  /// Invalidate cache (force refresh next time)
  static void invalidateCache() {
    _lastCacheUpdate = null;
    AppLogger.debug('🔄 [Metadata Service] Cache invalidated');
  }

  // ==================== TYPE-SAFE GETTERS/SETTERS ====================

  /// Lấy Gemini API key từ metadata
  static Future<String?> getGeminiApiKey() async {
    return await get<String>('api_keys.gemini');
  }

  /// Set Gemini API key vào metadata
  static Future<bool> setGeminiApiKey(String apiKey) async {
    if (apiKey.isEmpty) return false;
    return await set('api_keys.gemini', apiKey);
  }

  /// Xóa Gemini API key khỏi metadata
  static Future<bool> removeGeminiApiKey() async {
    return await remove('api_keys.gemini');
  }

  /// Lấy AI API key (generic) từ metadata
  static Future<String?> getAiApiKey() async {
    return await get<String>('api_keys.ai');
  }

  /// Lấy Groq API key từ metadata
  static Future<String?> getGroqApiKey() async {
    return await get<String>('api_keys.groq');
  }

  /// Set AI API key vào metadata
  static Future<bool> setAiApiKey(String apiKey) async {
    if (apiKey.isEmpty) return false;
    return await set('api_keys.ai', apiKey);
  }

  /// Set Groq API key vào metadata
  static Future<bool> setGroqApiKey(String apiKey) async {
    if (apiKey.isEmpty) return false;
    return await set('api_keys.groq', apiKey);
  }

  /// Xóa AI API key khỏi metadata
  static Future<bool> removeAiApiKey() async {
    return await remove('api_keys.ai');
  }

  /// Xóa Groq API key khỏi metadata
  static Future<bool> removeGroqApiKey() async {
    return await remove('api_keys.groq');
  }

  /// Lấy AI provider đang được chọn (vd: 'gemini', 'groq')
  static Future<String?> getAiProvider() async {
    return await get<String>('ai.provider');
  }

  /// Set AI provider đang được chọn (vd: 'gemini', 'groq')
  static Future<bool> setAiProvider(String provider) async {
    if (provider.isEmpty) return false;
    return await set('ai.provider', provider);
  }

  /// Lấy AI model đang được chọn (vd: 'gemini-1.5-flash', 'llama-3.1-8b-instant')
  static Future<String?> getAiModel() async {
    return await get<String>('ai.model');
  }

  /// Set AI model đang được chọn
  static Future<bool> setAiModel(String model) async {
    if (model.isEmpty) return false;
    return await set('ai.model', model);
  }

  /// Set AI provider + model cùng lúc (helper)
  static Future<bool> setAiConfig({
    required String provider,
    required String model,
  }) async {
    final okProvider = await setAiProvider(provider);
    final okModel = await setAiModel(model);
    return okProvider && okModel;
  }

  /// Kiểm tra xem có Gemini API key không
  static Future<bool> hasGeminiApiKey() async {
    final key = await getGeminiApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Kiểm tra xem có AI API key không
  static Future<bool> hasAiApiKey() async {
    final key = await getAiApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Kiểm tra xem có Groq API key không
  static Future<bool> hasGroqApiKey() async {
    final key = await getGroqApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Lấy tất cả API keys
  static Future<Map<String, String>> getAllApiKeys() async {
    final apiKeys = await get<Map<String, dynamic>>('api_keys') ?? {};
    return Map<String, String>.from(
      apiKeys.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  /// Set nhiều API keys cùng lúc
  static Future<bool> setAllApiKeys(Map<String, String> apiKeys) async {
    return await set('api_keys', apiKeys);
  }

  /// Lấy toàn bộ metadata (để hiển thị hoặc debug)
  static Future<Map<String, dynamic>?> getAllMetadata() async {
    return await getMetadata();
  }
}
