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

  // Default models (fallback)
  static const String defaultGeminiModel = 'gemini-1.5-flash';
  static const String defaultGroqModel = 'llama-3.1-8b-instant';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys cho Secure Storage (fallback)
  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _groqApiKeyKey = 'groq_api_key';
  static const String _aiApiKeyKey = 'ai_api_key';

  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _groqChatUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  static String _geminiEndpointFromModel(String model) {
    return '$_geminiBaseUrl/models/$model:generateContent';
  }

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

  /// Test Gemini API key bằng cách gọi API với request đơn giản
  ///
  /// [apiKey] - API key cần test
  /// [model] - model Gemini để test (optional)
  ///
  /// Returns: Map với 'success' (bool) và 'error' (String?) nếu có lỗi
  static Future<Map<String, dynamic>> testGeminiApiKey(
    String apiKey, {
    String? model,
  }) async {
    try {
      if (apiKey.isEmpty) {
        return {'success': false, 'error': 'API key không được để trống'};
      }

      final usedModel = model ?? await getActiveModelFor(providerGemini);
      final endpoint = _geminiEndpointFromModel(usedModel);

      // Gọi Gemini API với một request test đơn giản
      final dio = Dio();
      final response = await dio
          .post(
            endpoint,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'X-goog-api-key': apiKey,
              },
            ),
            data: {
              'contents': [
                {
                  'parts': [
                    {'text': 'Say "test" if you can read this.'},
                  ],
                },
              ],
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw DioException(
                requestOptions: RequestOptions(path: ''),
                error: 'Timeout: API không phản hồi sau 10 giây',
              );
            },
          );

      if (response.statusCode == 200) {
        AppLogger.info('✅ [API Key Service] Gemini API key test successful');
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': 'API trả về status code: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      String errorMessage = 'Lỗi không xác định';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        if (statusCode == 400) {
          errorMessage = 'API key không hợp lệ hoặc định dạng sai';
        } else if (statusCode == 401) {
          errorMessage =
              'API key không được xác thực. Vui lòng kiểm tra lại key.';
        } else if (statusCode == 403) {
          errorMessage =
              'API key không có quyền truy cập. Vui lòng kiểm tra quyền của key.';
        } else if (statusCode == 429) {
          errorMessage =
              'Quota đã hết hoặc rate limit. Vui lòng kiểm tra billing và quota.';
        } else {
          errorMessage =
              'Lỗi $statusCode: ${responseData?.toString() ?? e.message ?? 'Unknown error'}';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            'Timeout: Không thể kết nối đến API. Vui lòng kiểm tra kết nối internet.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            'Lỗi kết nối: Không thể kết nối đến server. Vui lòng kiểm tra internet.';
      } else {
        errorMessage = e.message ?? 'Lỗi không xác định khi test API key';
      }

      AppLogger.error(
        '❌ [API Key Service] Gemini API key test failed: $errorMessage',
        error: e,
      );

      return {'success': false, 'error': errorMessage};
    } catch (e) {
      AppLogger.error(
        '❌ [API Key Service] Unexpected error testing Gemini API key: $e',
        error: e,
      );
      return {'success': false, 'error': 'Lỗi không xác định: ${e.toString()}'};
    }
  }

  /// Test Groq API key bằng cách gọi Chat Completions (OpenAI-compatible)
  ///
  /// [apiKey] - Groq API key cần test
  /// [model] - Model Groq để test (nếu null sẽ dùng model active hoặc default)
  static Future<Map<String, dynamic>> testGroqApiKey(
    String apiKey, {
    String? model,
  }) async {
    try {
      if (apiKey.isEmpty) {
        return {'success': false, 'error': 'API key không được để trống'};
      }

      final usedModel = model ?? await getActiveModelFor(providerGroq);
      final dio = Dio();
      final response = await dio
          .post(
            _groqChatUrl,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $apiKey',
              },
            ),
            data: {
              'model': usedModel,
              'temperature': 0,
              'messages': [
                {'role': 'user', 'content': 'Reply with exactly: test'},
              ],
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw DioException(
                requestOptions: RequestOptions(path: ''),
                error: 'Timeout: API không phản hồi sau 10 giây',
              );
            },
          );

      if (response.statusCode == 200) {
        AppLogger.info('✅ [API Key Service] Groq API key test successful');
        return {'success': true};
      }

      return {
        'success': false,
        'error': 'API trả về status code: ${response.statusCode}',
      };
    } on DioException catch (e) {
      String errorMessage = 'Lỗi không xác định';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        if (statusCode == 400) {
          errorMessage = 'Request không hợp lệ (model có thể không đúng).';
        } else if (statusCode == 401) {
          errorMessage =
              'API key không được xác thực. Vui lòng kiểm tra lại key.';
        } else if (statusCode == 403) {
          errorMessage =
              'API key không có quyền truy cập. Vui lòng kiểm tra quyền của key.';
        } else if (statusCode == 429) {
          errorMessage =
              'Rate limit/quota. Vui lòng kiểm tra quota và thử lại sau.';
        } else {
          errorMessage =
              'Lỗi $statusCode: ${responseData?.toString() ?? e.message ?? 'Unknown error'}';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            'Timeout: Không thể kết nối đến API. Vui lòng kiểm tra kết nối internet.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            'Lỗi kết nối: Không thể kết nối đến server. Vui lòng kiểm tra internet.';
      } else {
        errorMessage = e.message ?? 'Lỗi không xác định khi test API key';
      }

      AppLogger.error(
        '❌ [API Key Service] Groq API key test failed: $errorMessage',
        error: e,
      );
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      AppLogger.error(
        '❌ [API Key Service] Unexpected error testing Groq API key: $e',
        error: e,
      );
      return {'success': false, 'error': 'Lỗi không xác định: ${e.toString()}'};
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

  /// Provider/model đang active để AiService dùng khi gọi API
  static Future<String> getActiveProvider() async {
    final provider = await ProfileMetadataService.getAiProvider();
    return provider?.isNotEmpty == true ? provider! : providerGemini;
  }

  static Future<String> getActiveModel() async {
    final provider = await getActiveProvider();
    return getActiveModelFor(provider);
  }

  static Future<String> getActiveModelFor(String provider) async {
    // Lưu ý: `ai.model` là model của provider đang active.
    // Nếu hỏi model cho provider KHÁC provider active, trả về default để tránh
    // việc lấy nhầm model (vd: active = groq, model = llama... nhưng test Gemini).
    final activeProvider = await getActiveProvider();
    if (activeProvider == provider) {
      final model = await ProfileMetadataService.getAiModel();
      if (model != null && model.isNotEmpty) return model;
    }
    return provider == providerGroq ? defaultGroqModel : defaultGeminiModel;
  }

  /// Set provider/model đang active (không đụng đến API key).
  ///
  /// Dùng cho UI Settings: user có thể lưu cả Gemini và Groq key,
  /// rồi chọn provider/model nào sẽ được dùng cho toàn dự án.
  static Future<bool> setActiveAiConfig({
    required String provider,
    required String model,
  }) async {
    try {
      if (provider != providerGemini && provider != providerGroq) {
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
      await _storage.delete(key: _aiApiKeyKey);
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
}
