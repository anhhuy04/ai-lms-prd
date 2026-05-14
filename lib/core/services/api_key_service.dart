import 'dart:convert';

import 'package:ai_mls/core/env/env.dart';
import 'package:ai_mls/core/services/profile_metadata_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service quản lý API keys tại runtime
///
/// Cho phép user tự thêm API keys của mình mà không cần build lại app.
/// API keys được lưu trong metadata của profile (database) hoặc Secure Storage (fallback).
///
/// Sử dụng ProfileMetadataService để truy cập metadata một cách thông minh với cache.
///
/// Usage:
/// ```dart
/// // Lấy API key (từ storage hoặc fallback về .env)
/// final apiKey = await ApiKeyService.getGeminiApiKey();
///
/// // Lưu API key mới
/// await ApiKeyService.setGeminiApiKey('your-api-key');
///
/// // Xóa API key (sẽ fallback về .env)
/// await ApiKeyService.clearGeminiApiKey();
/// ```
class ApiKeyService {
  ApiKeyService._();

  // Providers
  static const String providerGemini = 'gemini';
  static const String providerGroq = 'groq';
  static const String providerOllama = 'ollama';
  static const String providerOpenRouter = 'openrouter';

  // Default models (fallback)
  static const String defaultGeminiModel = 'gemini-2.0-flash';
  static const String defaultGroqModel = 'llama-3.1-8b-instant';
  static const String defaultOllamaModel = 'mistral';
  // OpenRouter model: phải khớp với id còn live trên https://openrouter.ai/api/v1/models.
  // Model cũ `gemma-3-4b-it:free` đã bị OpenRouter remove (404 "No endpoints found").
  // Nếu model mới này cũng bị remove, user có thể pick model khác qua dropdown
  // trong Settings → API Keys (app tự fetch live list qua fetchOpenRouterModels()).
  static const String defaultOpenRouterModel = 'google/gemma-4-31b-it:free';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys cho Secure Storage (fallback)
  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _groqApiKeyKey = 'groq_api_key';
  static const String _ollamaBaseUrlKey = 'ollama_base_url';
  static const String _aiApiKeyKey = 'ai_api_key';
  static const String _openRouterApiKeyKey = 'openrouter_api_key';

  // Ollama - NO default base URL (user must enter manually)

  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _groqChatUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String _openRouterChatUrl = '$_openRouterBaseUrl/chat/completions';

  static String _geminiEndpointFromModel(String model) =>
      '$_geminiBaseUrl/models/$model:generateContent';

  // ── Reusable Dio instances ───────────────────────────────────────────────
  // Tái sử dụng connection pool, tránh overhead tạo Dio mới mỗi request
  static final Dio _geminiDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (s) => s != null, // không throw cho 4xx, xử lý tại caller
    ),
  );

  static final Dio _groqDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (s) => s != null,
    ),
  );

  static final Dio _ollamaDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (s) => s != null,
    ),
  );

  static final Dio _openRouterDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (s) => s != null,
    ),
  );

  // ── Error helpers (dùng chung) ───────────────────────────────────────────
  static String _parseHttpError(int? status, dynamic data) =>
      switch (status) {
        400 => 'Request không hợp lệ — kiểm tra API key và tên model (400)',
        401 => 'API key không được xác thực — kiểm tra lại key (401)',
        403 => 'API key không có quyền truy cập (403)',
        429 => 'Quota hết hoặc rate limit — kiểm tra billing (429)',
        _ => 'Lỗi HTTP $status: ${data?.toString() ?? 'Unknown'}',
      };

  static String _parseDioNetworkError(
    DioException e, {
    String server = 'server',
  }) =>
      switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout =>
          'Timeout: Không thể kết nối đến $server. Kiểm tra kết nối mạng.',
        DioExceptionType.connectionError =>
          'Không thể kết nối đến $server.\n'
              '• Kiểm tra URL có chính xác\n'
              '• Kiểm tra service đang chạy\n'
              '• Kiểm tra firewall / network policy',
        DioExceptionType.cancel => 'Request bị hủy',
        _ => e.message ?? 'Lỗi mạng không xác định',
      };

  /// Lấy thông tin về nơi lưu trữ API key
  ///
  /// Returns: Map chứa thông tin storage location
  static Future<Map<String, String>> getStorageInfo() async {
    final provider = await getActiveProvider();
    final model = await getActiveModel();

    final hasKey = provider == providerGroq
        ? await hasGroqApiKey()
        : await hasGeminiApiKey();
    final metadata = await ProfileMetadataService.getMetadata();
    final isInDatabase =
        metadata != null &&
        (metadata['api_keys'] as Map<String, dynamic>?)?[provider] != null;

    return {
      'storage_type': isInDatabase
          ? 'Profile Metadata (Database with Cache)'
          : 'Flutter Secure Storage',
      'platform': isInDatabase
          ? 'Supabase Database (PostgreSQL)'
          : _getPlatformName(),
      'location': isInDatabase
          ? 'profiles.metadata.api_keys.$provider (JSONB) - Cached'
          : _getStorageLocation(),
      'has_key': hasKey.toString(),
      'key_name': provider == providerGroq ? _groqApiKeyKey : _geminiApiKeyKey,
      'provider': provider,
      'model': model,
      'encryption': isInDatabase
          ? 'Database encryption + RLS policies + Cache (5min TTL)'
          : 'AES-256 (Android) / Keychain (iOS) / Credential Manager (Windows)',
    };
  }

  static String _getPlatformName() {
    // This would need platform detection, simplified here
    return 'Platform-specific secure storage';
  }

  static String _getStorageLocation() {
    // Platform-specific locations
    return '''
Android: /data/data/<package_name>/shared_prefs/FlutterSecureStorage.xml
iOS: Keychain Services (System Keychain)
Windows: Windows Credential Manager
Web: Browser's secure storage (if supported)
''';
  }

  /// Lấy Gemini API key
  ///
  /// Priority:
  /// 1. Từ metadata của profile trong database (ưu tiên cao nhất, có cache)
  /// 2. Từ Secure Storage (fallback)
  /// 3. Từ .env file (fallback cuối cùng)
  ///
  /// Returns: API key hoặc empty string nếu không có
  static Future<String> getGeminiApiKey() async {
    try {
      // 1. Ưu tiên lấy từ metadata (sử dụng ProfileMetadataService với cache)
      try {
        final geminiKey = await ProfileMetadataService.getGeminiApiKey();
        if (geminiKey != null && geminiKey.isNotEmpty) {
          AppLogger.info(
            '🔑 [API Key Service] Using Gemini API key from profile metadata',
          );
          return geminiKey;
        }
      } catch (e) {
        AppLogger.debug(
          '🔵 [API Key Service] Could not get key from metadata: $e',
        );
        // Continue to fallback
      }

      // 2. Fallback về Secure Storage
      final storedKey = await _storage.read(key: _geminiApiKeyKey);
      if (storedKey != null && storedKey.isNotEmpty) {
        AppLogger.info(
          '🔑 [API Key Service] Using Gemini API key from Secure Storage',
        );
        return storedKey;
      }

      // 3. Fallback về .env file
      final envKey = Env.geminiApiKey;
      if (envKey.isNotEmpty) {
        AppLogger.info(
          '🔑 [API Key Service] Using Gemini API key from .env file',
        );
        return envKey;
      }

      AppLogger.warning('⚠️ [API Key Service] No Gemini API key found');
      return '';
    } catch (e) {
      AppLogger.error(
        '❌ [API Key Service] Error reading Gemini API key: $e',
        error: e,
      );
      // Fallback về .env nếu có lỗi
      return Env.geminiApiKey;
    }
  }

  /// Test Gemini API key
  static Future<Map<String, dynamic>> testGeminiApiKey(
    String apiKey, {
    String? model,
  }) async {
    if (apiKey.isEmpty) {
      return {'success': false, 'error': 'API key không được để trống'};
    }
    try {
      final usedModel = model ?? await getActiveModelFor(providerGemini);
      final response = await _geminiDio.post(
        _geminiEndpointFromModel(usedModel),
        options: Options(headers: {'X-goog-api-key': apiKey}),
        data: {
          'contents': [
            {
              'parts': [
                {'text': 'Say "test".'},
              ],
            },
          ],
        },
      );
      if (response.statusCode == 200) {
        AppLogger.info('✅ [Gemini] API key test OK');
        return {'success': true};
      }
      final msg = _parseHttpError(response.statusCode, response.data);
      AppLogger.error('❌ [Gemini] $msg');
      return {'success': false, 'error': msg};
    } on DioException catch (e) {
      final msg = _parseDioNetworkError(e, server: 'Gemini');
      AppLogger.error('❌ [Gemini] $msg', error: e);
      return {'success': false, 'error': msg};
    } catch (e) {
      AppLogger.error('❌ [Gemini] Unexpected: $e', error: e);
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Test Groq API key (OpenAI-compatible Chat Completions)
  static Future<Map<String, dynamic>> testGroqApiKey(
    String apiKey, {
    String? model,
  }) async {
    if (apiKey.isEmpty) {
      return {'success': false, 'error': 'API key không được để trống'};
    }
    try {
      final usedModel = model ?? await getActiveModelFor(providerGroq);
      final response = await _groqDio.post(
        _groqChatUrl,
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        data: {
          'model': usedModel,
          'temperature': 0,
          'messages': [
            {'role': 'user', 'content': 'Reply with exactly: test'},
          ],
        },
      );
      if (response.statusCode == 200) {
        AppLogger.info('✅ [Groq] API key test OK');
        return {'success': true};
      }
      final msg = _parseHttpError(response.statusCode, response.data);
      AppLogger.error('❌ [Groq] $msg');
      return {'success': false, 'error': msg};
    } on DioException catch (e) {
      final msg = _parseDioNetworkError(e, server: 'Groq');
      AppLogger.error('❌ [Groq] $msg', error: e);
      return {'success': false, 'error': msg};
    } catch (e) {
      AppLogger.error('❌ [Groq] Unexpected: $e', error: e);
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Lưu Gemini API key vào metadata của profile trong database
  ///
  /// [apiKey] - API key cần lưu
  /// [model] - model Gemini muốn lưu làm active
  /// [setActive] - nếu true thì set ai.provider/ai.model
  /// [skipTest] - Nếu true, bỏ qua test API key (mặc định: false)
  ///
  /// Returns: Map với 'saved' (bool), 'tested' (bool), 'testSuccess' (bool?), 'error' (String?)
  static Future<Map<String, dynamic>> setGeminiApiKey(
    String apiKey, {
    String? model,
    bool setActive = false,
    bool skipTest = false,
  }) async {
    try {
      if (apiKey.isEmpty) {
        AppLogger.warning(
          '⚠️ [API Key Service] Cannot save empty Gemini API key',
        );
        return {
          'saved': false,
          'tested': false,
          'error': 'API key không được để trống',
        };
      }

      // Test API key trước khi lưu (nếu không skip)
      bool testSuccess = false;
      String? testError;

      if (!skipTest) {
        final testResult = await testGeminiApiKey(apiKey, model: model);
        testSuccess = testResult['success'] as bool;
        testError = testResult['error'] as String?;
      }

      // Lưu vào database (luôn lưu, kể cả khi test thất bại)
      final saved = await ProfileMetadataService.setGeminiApiKey(apiKey);

      if (setActive) {
        await ProfileMetadataService.setAiConfig(
          provider: providerGemini,
          model: model ?? await getActiveModelFor(providerGemini),
        );
      }

      if (saved) {
        AppLogger.info(
          '✅ [API Key Service] Gemini API key saved to profile metadata',
        );
        return {
          'saved': true,
          'tested': !skipTest,
          'testSuccess': skipTest ? null : testSuccess,
          'error': testError,
        };
      }

      // Fallback về Secure Storage nếu có lỗi
      AppLogger.warning(
        '⚠️ [API Key Service] Failed to save to metadata, using Secure Storage fallback',
      );
      await _storage.write(key: _geminiApiKeyKey, value: apiKey);
      AppLogger.info('✅ [API Key Service] Saved to Secure Storage as fallback');

      if (setActive) {
        await ProfileMetadataService.setAiConfig(
          provider: providerGemini,
          model: model ?? await getActiveModelFor(providerGemini),
        );
      }
      return {
        'saved': true,
        'tested': !skipTest,
        'testSuccess': skipTest ? null : testSuccess,
        'error': testError,
      };
    } catch (e) {
      AppLogger.error(
        '❌ [API Key Service] Error saving Gemini API key: $e',
        error: e,
      );
      // Fallback về Secure Storage nếu có lỗi
      try {
        await _storage.write(key: _geminiApiKeyKey, value: apiKey);
        return {
          'saved': true,
          'tested': false,
          'testSuccess': null,
          'error':
              'Lưu thành công nhưng không thể test API key: ${e.toString()}',
        };
      } catch (storageError) {
        AppLogger.error(
          '❌ [API Key Service] Error saving to Secure Storage: $storageError',
          error: storageError,
        );
        return {
          'saved': false,
          'tested': false,
          'testSuccess': null,
          'error': 'Lỗi khi lưu: ${storageError.toString()}',
        };
      }
    }
  }

  /// Lấy Groq API key
  ///
  /// Priority:
  /// 1. metadata (Supabase)
  /// 2. Secure Storage (fallback)
  static Future<String> getGroqApiKey() async {
    try {
      try {
        final groqKey = await ProfileMetadataService.getGroqApiKey();
        if (groqKey != null && groqKey.isNotEmpty) {
          AppLogger.info(
            '🔑 [API Key Service] Using Groq API key from profile metadata',
          );
          return groqKey;
        }
      } catch (_) {}

      final storedKey = await _storage.read(key: _groqApiKeyKey);
      if (storedKey != null && storedKey.isNotEmpty) {
        AppLogger.info(
          '🔑 [API Key Service] Using Groq API key from Secure Storage',
        );
        return storedKey;
      }

      return '';
    } catch (e) {
      AppLogger.error(
        '❌ [API Key Service] Error reading Groq API key: $e',
        error: e,
      );
      return '';
    }
  }

  /// Lưu Groq API key vào metadata + optional set active provider/model
  static Future<Map<String, dynamic>> setGroqApiKey(
    String apiKey, {
    String? model,
    bool setActive = true,
    bool skipTest = false,
  }) async {
    try {
      if (apiKey.isEmpty) {
        return {
          'saved': false,
          'tested': false,
          'error': 'API key không được để trống',
        };
      }

      bool testSuccess = false;
      String? testError;
      if (!skipTest) {
        final testResult = await testGroqApiKey(apiKey, model: model);
        testSuccess = testResult['success'] as bool;
        testError = testResult['error'] as String?;
      }

      final saved = await ProfileMetadataService.setGroqApiKey(apiKey);
      if (setActive) {
        await ProfileMetadataService.setAiConfig(
          provider: providerGroq,
          model: model ?? await getActiveModelFor(providerGroq),
        );
      }

      if (saved) {
        return {
          'saved': true,
          'tested': !skipTest,
          'testSuccess': skipTest ? null : testSuccess,
          'error': testError,
        };
      }

      await _storage.write(key: _groqApiKeyKey, value: apiKey);
      return {
        'saved': true,
        'tested': !skipTest,
        'testSuccess': skipTest ? null : testSuccess,
        'error': testError,
      };
    } catch (e) {
      AppLogger.error('❌ [API Key Service] Error saving Groq API key: $e');
      return {
        'saved': false,
        'tested': false,
        'testSuccess': null,
        'error': e.toString(),
      };
    }
  }

  static Future<bool> clearGroqApiKey() async {
    try {
      try {
        await ProfileMetadataService.removeGroqApiKey();
      } catch (_) {}
      await _storage.delete(key: _groqApiKeyKey);
      return true;
    } catch (e) {
      AppLogger.error('❌ [API Key Service] Error clearing Groq API key: $e');
      return false;
    }
  }

  static Future<bool> hasGroqApiKey() async {
    try {
      final hasKey = await ProfileMetadataService.hasGroqApiKey();
      if (hasKey) return true;
      final storedKey = await _storage.read(key: _groqApiKeyKey);
      return storedKey != null && storedKey.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Provider/model đang active để AiService dùng khi gọi API.
  ///
  /// [forceRefresh] true để bypass cache 5 phút — dùng khi gọi AI gen để
  /// đảm bảo đọc giá trị mới nhất user vừa save trong Settings, tránh case
  /// "đổi model nhưng vẫn dùng model cũ".
  static Future<String> getActiveProvider({bool forceRefresh = false}) async {
    final provider = await ProfileMetadataService.getAiProvider(
      forceRefresh: forceRefresh,
    );
    return provider?.isNotEmpty == true ? provider! : providerGemini;
  }

  static Future<String> getActiveModel({bool forceRefresh = false}) async {
    final provider = await getActiveProvider(forceRefresh: forceRefresh);
    return getActiveModelFor(provider, forceRefresh: forceRefresh);
  }

  static Future<String> getActiveModelFor(
    String provider, {
    bool forceRefresh = false,
  }) async {
    // Lưu ý: `ai.model` là model của provider đang active.
    // Nếu hỏi model cho provider KHÁC provider active, trả về default để tránh
    // việc lấy nhầm model (vd: active = groq, model = llama... nhưng test Gemini).
    final activeProvider = await getActiveProvider(forceRefresh: forceRefresh);
    if (activeProvider == provider) {
      final model = await ProfileMetadataService.getAiModel(
        forceRefresh: forceRefresh,
      );
      if (model != null && model.isNotEmpty) return model;
    }
    if (provider == providerGroq) return defaultGroqModel;
    if (provider == providerOllama) return defaultOllamaModel;
    if (provider == providerOpenRouter) return defaultOpenRouterModel;
    return defaultGeminiModel;
  }

  /// Set provider/model đang active (không đụng đến API key).
  ///
  /// Dùng cho UI Settings: user có thể lưu cả Gemini, Groq, Ollama key,
  /// rồi chọn provider/model nào sẽ được dùng cho toàn dự án.
  static Future<bool> setActiveAiConfig({
    required String provider,
    required String model,
  }) async {
    try {
      if (provider != providerGemini &&
          provider != providerGroq &&
          provider != providerOllama &&
          provider != providerOpenRouter) {
        throw Exception('Provider không hợp lệ: $provider');
      }
      if (model.trim().isEmpty) {
        throw Exception('Model không được để trống');
      }
      await ProfileMetadataService.setAiConfig(
        provider: provider,
        model: model.trim(),
      );
      return true;
    } catch (e) {
      AppLogger.error('❌ [API Key Service] setActiveAiConfig failed: $e');
      return false;
    }
  }

  // ── Analytics AI config ─────────────────────────────────────────────────

  /// Provider đang dùng cho tính năng phân tích dữ liệu.
  /// Default: providerGemini nếu chưa cấu hình.
  static Future<String> getAnalyticsProvider() async {
    final provider = await ProfileMetadataService.getAnalyticsProvider();
    return provider?.isNotEmpty == true ? provider! : providerGemini;
  }

  /// Model đang dùng cho phân tích dữ liệu (tuỳ provider).
  static Future<String> getAnalyticsModel() async {
    final provider = await getAnalyticsProvider();
    return getAnalyticsModelFor(provider);
  }

  /// Model cho analytics ứng với [provider] cụ thể.
  static Future<String> getAnalyticsModelFor(String provider) async {
    final activeProvider = await getAnalyticsProvider();
    if (activeProvider == provider) {
      final model = await ProfileMetadataService.getAnalyticsModel();
      if (model != null && model.isNotEmpty) return model;
    }
    if (provider == providerGroq) return defaultGroqModel;
    if (provider == providerOllama) return defaultOllamaModel;
    if (provider == providerOpenRouter) return defaultOpenRouterModel;
    return defaultGeminiModel;
  }

  /// Set provider/model cho phân tích dữ liệu (không đụng đến API key).
  static Future<bool> setAnalyticsConfig({
    required String provider,
    required String model,
  }) async {
    try {
      if (provider != providerGemini &&
          provider != providerGroq &&
          provider != providerOllama &&
          provider != providerOpenRouter) {
        throw Exception('Provider không hợp lệ: $provider');
      }
      if (model.trim().isEmpty) throw Exception('Model không được để trống');
      await ProfileMetadataService.setAnalyticsConfig(
        provider: provider,
        model: model.trim(),
      );
      return true;
    } catch (e) {
      AppLogger.error('❌ [API Key Service] setAnalyticsConfig failed: $e');
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────

  /// Lấy Ollama base URL (mặc định: http://localhost:11434)
  ///
  /// Priority:
  /// 1. Từ ProfileMetadataService (user custom)
  /// 2. Từ Secure Storage (fallback)
  /// 3. Default: http://localhost:11434
  static Future<String> getOllamaBaseUrl() async {
    try {
      // 1. Ưu tiên lấy từ metadata
      try {
        final url = await ProfileMetadataService.getOllamaBaseUrl();
        if (url != null && url.isNotEmpty) {
          AppLogger.debug(
            '🔗 [API Key Service] Using Ollama URL from profile metadata: $url',
          );
          return url;
        }
      } catch (e) {
        AppLogger.debug('🔵 [API Key Service] Could not get Ollama URL from metadata: $e');
      }

      // 2. Fallback về Secure Storage
      final storedUrl = await _storage.read(key: _ollamaBaseUrlKey);
      if (storedUrl != null && storedUrl.isNotEmpty) {
        AppLogger.debug(
          '🔗 [API Key Service] Using Ollama URL from Secure Storage: $storedUrl',
        );
        return storedUrl;
      }

      // 3. No default - return empty
      AppLogger.debug(
        '🔗 [API Key Service] No Ollama URL configured (user must enter manually)',
      );
      return '';
    } catch (e) {
      AppLogger.error('❌ [API Key Service] Error reading Ollama base URL: $e');
      return '';
    }
  }

  /// Lưu Ollama base URL
  ///
  /// [baseUrl] - URL của Ollama server (e.g., http://localhost:11434 hoặc http://192.168.1.100:11434)
  /// [model] - Model Ollama mặc định (optional)
  /// [setActive] - Nếu true, set Ollama làm active provider
  ///
  /// Returns: Map với 'saved' (bool), 'tested' (bool), 'testSuccess' (bool?), 'error' (String?)
  static Future<Map<String, dynamic>> setOllamaBaseUrl(
    String baseUrl, {
    String? model,
    bool setActive = false,
  }) async {
    try {
      if (baseUrl.trim().isEmpty) {
        return {
          'saved': false,
          'tested': false,
          'error': 'Ollama URL không được để trống',
        };
      }

      // Normalize URL (remove trailing slash)
      final normalizedUrl = baseUrl.trim().replaceAll(RegExp(r'/$'), '');

      // Test Ollama connection
      final testResult = await testOllamaConnection(normalizedUrl);
      final testSuccess = testResult['success'] as bool;
      final testError = testResult['error'] as String?;
      final availableModels =
          testResult['models'] as List<String>? ?? [];

      // Lưu vào metadata (thông qua ProfileMetadataService)
      try {
        final saved = await ProfileMetadataService.setOllamaBaseUrl(normalizedUrl);
        if (saved) {
          if (setActive) {
            final selectedModel =
                model ?? (availableModels.isNotEmpty ? availableModels.first
                : defaultOllamaModel);
            await ProfileMetadataService.setAiConfig(
              provider: providerOllama,
              model: selectedModel,
            );
          }
          AppLogger.info(
            '✅ [API Key Service] Ollama base URL saved: $normalizedUrl',
          );
          return {
            'saved': true,
            'tested': true,
            'testSuccess': testSuccess,
            'error': testError,
            'models': availableModels,
          };
        }
      } catch (e) {
        AppLogger.warning(
          '⚠️ [API Key Service] Could not save to metadata: $e, using Secure Storage',
        );
      }

      // Fallback về Secure Storage
      await _storage.write(key: _ollamaBaseUrlKey, value: normalizedUrl);
      if (setActive) {
        final selectedModel =
            model ?? (availableModels.isNotEmpty ? availableModels.first
            : defaultOllamaModel);
        await ProfileMetadataService.setAiConfig(
          provider: providerOllama,
          model: selectedModel,
        );
      }
      AppLogger.info(
        '✅ [API Key Service] Ollama base URL saved to Secure Storage',
      );
      return {
        'saved': true,
        'tested': true,
        'testSuccess': testSuccess,
        'error': testError,
        'models': availableModels,
      };
    } catch (e) {
      AppLogger.error('❌ [API Key Service] Error saving Ollama base URL: $e');
      return {
        'saved': false,
        'tested': false,
        'error': 'Lỗi khi lưu: ${e.toString()}',
      };
    }
  }

  /// Test kết nối đến Ollama server qua /api/tags
  ///
  /// [cancelToken] - Tùy chọn: cho phép hủy request đang chờ
  /// Returns: Map with keys 'success', 'error', 'models' (List of String)
  static Future<Map<String, dynamic>> testOllamaConnection(
    String baseUrl, {
    CancelToken? cancelToken,
  }) async {
    if (baseUrl.trim().isEmpty) {
      return {
        'success': false,
        'error': 'Base URL không được để trống',
        'models': <String>[],
      };
    }
    final url =
        '${baseUrl.trim().replaceAll(RegExp(r'/$'), '')}/api/tags';
    AppLogger.debug('🔗 [Ollama] Testing: $url');
    try {
      final response = await _ollamaDio.get(url, cancelToken: cancelToken);

      if (response.statusCode != 200) {
        final msg = _parseHttpError(response.statusCode, response.data);
        AppLogger.error('❌ [Ollama] $msg');
        return {'success': false, 'error': msg, 'models': <String>[]};
      }

      final models = _parseOllamaModels(response.data);
      AppLogger.info('✅ [Ollama] Connected. ${models.length} models: $models');
      return {'success': true, 'error': null, 'models': models};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return {'success': false, 'cancelled': true, 'error': 'Cancelled', 'models': <String>[]};
      }
      final msg = _parseDioNetworkError(e, server: 'Ollama');
      AppLogger.error('❌ [Ollama] $msg', error: e);
      return {'success': false, 'error': msg, 'models': <String>[]};
    } catch (e) {
      AppLogger.error('❌ [Ollama] Unexpected: $e', error: e);
      return {'success': false, 'error': e.toString(), 'models': <String>[]};
    }
  }

  /// Parse danh sách model từ Ollama /api/tags response
  static List<String> _parseOllamaModels(dynamic data) {
    try {
      final Map<String, dynamic> map;
      if (data is Map<String, dynamic>) {
        map = data;
      } else if (data is String) {
        map = jsonDecode(data) as Map<String, dynamic>;
      } else {
        return [];
      }
      return (map['models'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((m) => m['name'] as String?)
              .whereType<String>()
              .where((n) => n.isNotEmpty)
              .toList() ??
          [];
    } catch (e) {
      AppLogger.error('❌ [Ollama] Model parse error: $e', error: e);
      return [];
    }
  }

  /// Xóa Ollama base URL khỏi storage
  static Future<bool> clearOllamaBaseUrl() async {
    try {
      try {
        await ProfileMetadataService.removeOllamaBaseUrl();
      } catch (_) {}
      await _storage.delete(key: _ollamaBaseUrlKey);
      AppLogger.info('✅ [API Key Service] Ollama base URL cleared');
      return true;
    } catch (e) {
      AppLogger.error('❌ [API Key Service] Error clearing Ollama base URL: $e');
      return false;
    }
  }

  /// Lấy danh sách models available từ Ollama server
  ///
  /// Returns: List of models (String) hoặc empty list nếu không thể kết nối
  static Future<List<String>> getOllamaAvailableModels() async {
    try {
      final baseUrl = await getOllamaBaseUrl();
      final result = await testOllamaConnection(baseUrl);
      return result['models'] as List<String>;
    } catch (e) {
      AppLogger.error(
        '❌ [API Key Service] Error getting Ollama models: $e',
      );
      return [];
    }
  }

  /// Xóa Gemini API key khỏi metadata và Secure Storage
  ///
  /// Sau khi xóa, sẽ fallback về .env file
  ///
  /// Returns: true nếu xóa thành công
  static Future<bool> clearGeminiApiKey() async {
    try {
      // Xóa khỏi metadata (sử dụng ProfileMetadataService)
      try {
        await ProfileMetadataService.removeGeminiApiKey();
        AppLogger.info(
          '✅ [API Key Service] Gemini API key cleared from metadata',
        );
      } catch (e) {
        AppLogger.warning(
          '⚠️ [API Key Service] Error clearing from metadata: $e',
        );
      }

      // Xóa khỏi Secure Storage
      await _storage.delete(key: _geminiApiKeyKey);
      AppLogger.info(
        '✅ [API Key Service] Gemini API key cleared from Secure Storage',
      );
      return true;
    } catch (e) {
      AppLogger.error(
        '❌ [API Key Service] Error clearing Gemini API key: $e',
        error: e,
      );
      return false;
    }
  }

  /// Kiểm tra xem có API key trong metadata hoặc storage không
  ///
  /// Returns: true nếu có API key
  static Future<bool> hasGeminiApiKey() async {
    try {
      // Kiểm tra trong metadata (sử dụng ProfileMetadataService với cache)
      final hasKey = await ProfileMetadataService.hasGeminiApiKey();
      if (hasKey) return true;

      // Kiểm tra trong Secure Storage
      final storedKey = await _storage.read(key: _geminiApiKeyKey);
      return storedKey != null && storedKey.isNotEmpty;
    } catch (e) {
      AppLogger.error(
        '❌ [API Key Service] Error checking Gemini API key: $e',
        error: e,
      );
      return false;
    }
  }

  /// Lấy AI API key (generic AI API, không phải Gemini)
  ///
  /// Priority:
  /// 1. Từ metadata của profile trong database (có cache)
  /// 2. Từ Secure Storage (fallback)
  /// 3. Từ .env file (fallback)
  ///
  /// Returns: API key hoặc empty string nếu không có
  static Future<String> getAiApiKey() async {
    try {
      // 1. Ưu tiên lấy từ metadata (sử dụng ProfileMetadataService)
      try {
        final aiKey = await ProfileMetadataService.getAiApiKey();
        if (aiKey != null && aiKey.isNotEmpty) {
          return aiKey;
        }
      } catch (e) {
        // Continue to fallback
      }

      // 2. Fallback về Secure Storage
      final storedKey = await _storage.read(key: _aiApiKeyKey);
      if (storedKey != null && storedKey.isNotEmpty) {
        return storedKey;
      }

      // 3. Fallback về .env
      return Env.aiApiKey;
    } catch (e) {
      AppLogger.error(
        '❌ [API Key Service] Error reading AI API key: $e',
        error: e,
      );
      return Env.aiApiKey;
    }
  }

  /// Lưu AI API key vào metadata của profile trong database
  ///
  /// [apiKey] - API key cần lưu
  ///
  /// Returns: true nếu lưu thành công
  static Future<bool> setAiApiKey(String apiKey) async {
    try {
      if (apiKey.isEmpty) {
        return false;
      }

      // Sử dụng ProfileMetadataService để lưu
      final saved = await ProfileMetadataService.setAiApiKey(apiKey);

      if (saved) {
        AppLogger.info(
          '✅ [API Key Service] AI API key saved to profile metadata',
        );
        return true;
      }

      // Fallback về Secure Storage
      await _storage.write(key: _aiApiKeyKey, value: apiKey);
      return true;
    } catch (e) {
      AppLogger.error(
        '❌ [API Key Service] Error saving AI API key: $e',
        error: e,
      );
      // Fallback về Secure Storage
      try {
        await _storage.write(key: _aiApiKeyKey, value: apiKey);
        return true;
      } catch (storageError) {
        return false;
      }
    }
  }

  /// Xóa tất cả API keys khỏi Secure Storage
  ///
  /// Returns: true nếu xóa thành công
  static Future<bool> clearAllApiKeys() async {
    try {
      await _storage.delete(key: _geminiApiKeyKey);
      await _storage.delete(key: _groqApiKeyKey);
      await _storage.delete(key: _ollamaBaseUrlKey);
      await _storage.delete(key: _aiApiKeyKey);
      await _storage.delete(key: _openRouterApiKeyKey);
      AppLogger.info('✅ [API Key Service] All API keys cleared');
      return true;
    } catch (e) {
      AppLogger.error(
        '❌ [API Key Service] Error clearing all API keys: $e',
        error: e,
      );
      return false;
    }
  }

  // ── OpenRouter ────────────────────────────────────────────────────────────

  /// Lấy OpenRouter API key (metadata → SecureStorage)
  static Future<String> getOpenRouterApiKey() async {
    try {
      try {
        final key = await ProfileMetadataService.getOpenRouterApiKey();
        if (key != null && key.isNotEmpty) return key;
      } catch (_) {}
      final stored = await _storage.read(key: _openRouterApiKeyKey);
      return stored ?? '';
    } catch (e) {
      AppLogger.error('❌ [API Key Service] Error reading OpenRouter API key: $e');
      return '';
    }
  }

  static Future<bool> hasOpenRouterApiKey() async {
    try {
      if (await ProfileMetadataService.hasOpenRouterApiKey()) return true;
      final stored = await _storage.read(key: _openRouterApiKeyKey);
      return stored != null && stored.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Lưu OpenRouter API key vào metadata + optional set active provider/model
  static Future<Map<String, dynamic>> setOpenRouterApiKey(
    String apiKey, {
    String? model,
    bool setActive = false,
    bool skipTest = false,
  }) async {
    try {
      if (apiKey.isEmpty) {
        return {
          'saved': false,
          'tested': false,
          'error': 'API key không được để trống',
        };
      }
      bool testSuccess = false;
      String? testError;
      if (!skipTest) {
        final testResult = await testOpenRouterApiKey(apiKey, model: model);
        testSuccess = testResult['success'] as bool;
        testError = testResult['error'] as String?;
      }
      final saved = await ProfileMetadataService.setOpenRouterApiKey(apiKey);
      if (setActive) {
        await ProfileMetadataService.setAiConfig(
          provider: providerOpenRouter,
          model: model ?? defaultOpenRouterModel,
        );
      }
      if (saved) {
        return {
          'saved': true,
          'tested': !skipTest,
          'testSuccess': skipTest ? null : testSuccess,
          'error': testError,
        };
      }
      await _storage.write(key: _openRouterApiKeyKey, value: apiKey);
      return {
        'saved': true,
        'tested': !skipTest,
        'testSuccess': skipTest ? null : testSuccess,
        'error': testError,
      };
    } catch (e) {
      AppLogger.error('❌ [API Key Service] Error saving OpenRouter API key: $e');
      return {'saved': false, 'tested': false, 'error': e.toString()};
    }
  }

  static Future<bool> clearOpenRouterApiKey() async {
    try {
      try {
        await ProfileMetadataService.removeOpenRouterApiKey();
      } catch (_) {}
      await _storage.delete(key: _openRouterApiKeyKey);
      return true;
    } catch (e) {
      AppLogger.error('❌ [API Key Service] Error clearing OpenRouter API key: $e');
      return false;
    }
  }

  /// Test OpenRouter API key (OpenAI-compatible)
  static Future<Map<String, dynamic>> testOpenRouterApiKey(
    String apiKey, {
    String? model,
  }) async {
    if (apiKey.isEmpty) {
      return {'success': false, 'error': 'API key không được để trống'};
    }
    try {
      final usedModel = model ?? defaultOpenRouterModel;
      final response = await _openRouterDio.post(
        _openRouterChatUrl,
        options: Options(headers: {
          'Authorization': 'Bearer $apiKey',
          'HTTP-Referer': 'https://ai-lms.app',
        }),
        data: {
          'model': usedModel,
          'max_tokens': 5,
          'messages': [
            {'role': 'user', 'content': 'test'},
          ],
        },
      );
      if (response.statusCode == 200) {
        AppLogger.info('✅ [OpenRouter] API key test OK');
        return {'success': true};
      }
      final msg = _parseHttpError(response.statusCode, response.data);
      AppLogger.error('❌ [OpenRouter] $msg');
      return {'success': false, 'error': msg};
    } on DioException catch (e) {
      final msg = _parseDioNetworkError(e, server: 'OpenRouter');
      AppLogger.error('❌ [OpenRouter] $msg', error: e);
      return {'success': false, 'error': msg};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Fetch danh sách models từ Gemini API (chỉ lấy models hỗ trợ generateContent)
  ///
  /// Returns: `List<String>` model names, hoặc [] nếu lỗi
  static Future<List<String>> fetchGeminiModels(String apiKey) async {
    if (apiKey.isEmpty) return [];
    try {
      final response = await _geminiDio.get(
        '$_geminiBaseUrl/models',
        queryParameters: {'key': apiKey},
      );
      if (response.statusCode != 200) return [];
      final data = response.data;
      final Map<String, dynamic> map = data is String
          ? (jsonDecode(data) as Map<String, dynamic>? ?? {})
          : (data as Map<String, dynamic>? ?? {});
      final models = (map['models'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .where((m) {
                final methods = (m['supportedGenerationMethods'] as List?)
                        ?.whereType<String>()
                        .toList() ??
                    [];
                return methods.contains('generateContent');
              })
              .map((m) => (m['name'] as String?)?.replaceFirst('models/', '') ?? '')
              .where((n) => n.isNotEmpty)
              .toList() ??
          [];
      AppLogger.info('✅ [Gemini] Fetched ${models.length} models');
      return models;
    } catch (e) {
      AppLogger.error('❌ [Gemini] fetchGeminiModels: $e', error: e);
      return [];
    }
  }

  /// Fetch danh sách models từ Groq API
  ///
  /// Returns: `List<String>` model IDs, hoặc [] nếu lỗi
  static Future<List<String>> fetchGroqModels(String apiKey) async {
    if (apiKey.isEmpty) return [];
    try {
      final response = await _groqDio.get(
        'https://api.groq.com/openai/v1/models',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      );
      if (response.statusCode != 200) return [];
      final data = response.data;
      final Map<String, dynamic> map = data is String
          ? (jsonDecode(data) as Map<String, dynamic>? ?? {})
          : (data as Map<String, dynamic>? ?? {});
      final models = (map['data'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((m) => m['id'] as String?)
              .whereType<String>()
              .where((n) => n.isNotEmpty)
              .toList() ??
          [];
      AppLogger.info('✅ [Groq] Fetched ${models.length} models');
      return models;
    } catch (e) {
      AppLogger.error('❌ [Groq] fetchGroqModels: $e', error: e);
      return [];
    }
  }

  /// Fetch danh sách models từ OpenRouter (public endpoint, không cần auth)
  ///
  /// Returns: List<Map> với keys: id, name, isFree
  static Future<List<Map<String, dynamic>>> fetchOpenRouterModels() async {
    try {
      final response = await _openRouterDio.get(
        '$_openRouterBaseUrl/models',
      );
      if (response.statusCode != 200) return [];
      final data = response.data;
      final Map<String, dynamic> map = data is String
          ? (jsonDecode(data) as Map<String, dynamic>? ?? {})
          : (data as Map<String, dynamic>? ?? {});
      final models = (map['data'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((m) {
                final id = m['id'] as String? ?? '';
                final name = m['name'] as String? ?? id;
                final pricing = m['pricing'] as Map<String, dynamic>?;
                final promptPrice = pricing?['prompt']?.toString() ?? '1';
                final isFree = id.endsWith(':free') || promptPrice == '0';
                return {'id': id, 'name': name, 'isFree': isFree};
              })
              .where((m) => (m['id'] as String).isNotEmpty)
              .toList() ??
          [];
      AppLogger.info('✅ [OpenRouter] Fetched ${models.length} models');
      return models;
    } catch (e) {
      AppLogger.error('❌ [OpenRouter] fetchOpenRouterModels: $e', error: e);
      return [];
    }
  }
}
