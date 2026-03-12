import 'package:ai_mls/core/env/env.dart';
import 'package:ai_mls/core/services/api_key_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:dio/dio.dart';

/// AI Service tập trung để quản lý tất cả AI API calls và prompts
///
/// Service này tuân theo pattern của SupabaseService và ErrorReportingService:
/// - Singleton pattern với static methods
/// - Quản lý prompts ở một nơi (Prompt Registry)
/// - Template engine với variable substitution
/// - Specialized methods cho từng use case
///
/// Usage:
/// ```dart
/// // Initialize trong main.dart (optional, auto-initialized on first use)
/// await AiService.initialize();
///
/// // Sử dụng trong DataSource
/// final prompt = AiService.getGenerateQuestionsPrompt(
///   topic: 'Phép cộng lớp 3',
///   quantity: 5,
///   difficulty: 2,
/// );
/// final response = await AiService.callApi('/generate-questions', {'prompt': prompt});
/// ```
class AiService {
  AiService._();

  static Dio? _dio;
  static bool _isInitialized = false;

  /// Default models (fallback nếu user chưa cấu hình trong Settings)
  static const String defaultGeminiModel = ApiKeyService.defaultGeminiModel;
  static const String defaultGroqModel = ApiKeyService.defaultGroqModel;

  /// Provider constants
  static const String providerGemini = ApiKeyService.providerGemini;
  static const String providerGroq = ApiKeyService.providerGroq;

  /// Gemini base URL
  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  static String getGeminiEndpoint(String model) {
    return '$_geminiBaseUrl/models/$model:generateContent';
  }

  static const String _groqChatUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  /// Prompt Registry - Tất cả prompts được quản lý ở đây
  ///
  /// Format: Simple string templates với {variable} placeholders
  /// Hoặc sử dụng function-based prompts cho complex cases
  static const Map<String, String> _promptTemplates = {
    'generate_questions_base': '''
Bạn là hệ thống tạo câu hỏi cho LMS.
Nhiệm vụ: tạo {quantity} câu hỏi về "{topic}". Độ khó: {difficulty_instruction}.

Suy luận ngữ cảnh từ "{topic}". Nếu có CNTT/IT/Flutter/Dart/mobile/app ⇒ câu hỏi phải đúng domain Flutter/Dart (biến, kiểu dữ liệu như int, widget tree, async/await, state, layout, navigation...).

CHỌN TYPE (bắt keyword, kể cả sai chính tả):
- Nếu "{topic}" có: trắc nghiệm | trắc nhiệm | MCQ | multiple choice | chọn đáp án ⇒ tất cả câu là type="multiple_choice".
- Nếu "{topic}" có: đúng/sai | true/false ⇒ tất cả câu là type="true_false".
- Nếu "{topic}" có: tự luận | essay ⇒ tất cả câu là type="essay".
- Nếu "{topic}" có: trả lời ngắn | short answer ⇒ tất cả câu là type="short_answer".
- Nếu "{topic}" có: điền khuyết | fill in blank ⇒ tất cả câu là type="fill_blank".
- Nếu "{topic}" có: nối khớp | matching ⇒ tất cả câu là type="matching".
- Nếu "{topic}" có: bài toán | tính toán | công thức ⇒ ưu tiên type="math" hoặc "problem_solving".
- Nếu không rõ ⇒ mặc định multiple_choice.
KHÔNG xoay vòng type. Chỉ trộn type khi user yêu cầu rõ.

OUTPUT: chỉ trả về JSON ARRAY (không markdown, không chữ thừa).
Format mới (assignment_questions.custom_content):
{
  "type": "multiple_choice",
  "override_text": "Nội dung câu hỏi",
  "choices": [
    {"id": 0, "text": "Đáp án A", "isCorrect": true},
    {"id": 1, "text": "Đáp án B", "isCorrect": false}
  ],
  "difficulty": 1..5,
  "tags": ["Flutter", "Dart"],
  "explanation": "Giải thích ngắn"
}

Với essay/short_answer:
{
  "type": "essay",
  "override_text": "Câu hỏi tự luận...",
  "expected_answer": "Đáp án mẫu...",
  "ai_grading_keywords": [
    {"id": 0, "keyword": "từ khóa 1", "weight": 0.5},
    {"id": 1, "keyword": "từ khóa 2", "weight": 0.5}
  ]
}

Với fill_blank:
{
  "type": "fill_blank",
  "override_text": "Câu có [blank_1] và [blank_2]...",
  "blanks": [
    {"id": "blank_1", "correct_values": ["đáp án 1", "dap an 1"], "case_sensitive": false},
    {"id": "blank_2", "correct_values": ["đáp án 2"], "case_sensitive": false}
  ]
}

RÀNG BUỘC:
- explanation tối đa 1 câu ngắn.
- Với multiple_choice/true_false: đúng 4 choices (id=0..3), đúng 1 isCorrect=true.
- tags: 1-3 strings.
- Nếu user yêu cầu trắc nghiệm mà có câu không phải ⇒ sửa lại trước khi trả JSON.
''',
  };

  /// Initialize AI Service với Dio client
  ///
  /// Nên được gọi trong main.dart, nhưng sẽ auto-initialize nếu chưa được gọi
  static Future<void> initialize({
    Dio? dio,
    String? baseUrl,
    String? apiKey,
  }) async {
    if (_isInitialized && _dio != null) {
      // Debug: Check Gemini API Key even if already initialized
      final geminiKey = Env.geminiApiKey;
      AppLogger.info(
        '🤖 [AI Service] Already initialized - Gemini Key length: ${geminiKey.length}, '
        'isEmpty: ${geminiKey.isEmpty}',
      );
      return;
    }

    // Debug: Check ENV_FILE environment variable
    final envFile = String.fromEnvironment(
      'ENV_FILE',
      defaultValue: '.env.dev',
    );
    AppLogger.info(
      '📋 [AI Service] ENV_FILE from environment: "$envFile" '
      '(default: .env.dev)',
    );

    final finalBaseUrl = baseUrl ?? Env.aiApiBaseUrl;
    final finalApiKey = apiKey ?? Env.aiApiKey;

    // Debug: Check Gemini API Key
    final geminiKey = Env.geminiApiKey;
    AppLogger.info(
      '🔑 [AI Service] Gemini API Key - length: ${geminiKey.length}, '
      'isEmpty: ${geminiKey.isEmpty}',
    );

    if (finalBaseUrl.isEmpty) {
      AppLogger.warning(
        '⚠️ [AI Service] AI_API_BASE_URL chưa được cấu hình. '
        'Một số tính năng AI có thể không hoạt động.',
      );
    }

    _dio = dio ?? Dio();
    _dio!.options = BaseOptions(
      baseUrl: finalBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        if (finalApiKey.isNotEmpty) 'Authorization': 'Bearer $finalApiKey',
      },
    );

    // Add request/response interceptors for logging
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.info(
            '🤖 [AI Service] Request: ${options.method} ${options.path}',
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.info(
            '✅ [AI Service] Response: ${response.statusCode} '
            '${response.requestOptions.path}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.error(
            '❌ [AI Service] Error: ${error.message}',
            error: error,
          );
          handler.next(error);
        },
      ),
    );

    _isInitialized = true;
    AppLogger.info('✅ [AI Service] Initialized successfully');
  }

  /// Get Dio client instance (auto-initialize nếu chưa)
  static Dio get _client {
    if (!_isInitialized || _dio == null) {
      // Auto-initialize với default config
      initialize();
    }
    return _dio!;
  }

  /// Template Engine: Replace variables trong prompt template
  ///
  /// Example:
  /// ```dart
  /// final prompt = _renderTemplate(
  ///   'Hello {name}, you have {count} messages',
  ///   {'name': 'John', 'count': '5'},
  /// );
  /// // Returns: "Hello John, you have 5 messages"
  /// ```
  static String _renderTemplate(
    String template,
    Map<String, String> variables,
  ) {
    String result = template;
    variables.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  /// Get prompt cho generate questions (function-based prompt)
  ///
  /// Function-based prompts cho phép logic phức tạp hơn so với simple templates
  static String getGenerateQuestionsPrompt({
    required String topic,
    required int quantity,
    int? difficulty,
  }) {
    // Get base template
    final baseTemplate = _promptTemplates['generate_questions_base'] ?? '';

    // Build difficulty instruction
    String difficultyInstruction = '';
    if (difficulty != null && difficulty >= 1 && difficulty <= 5) {
      final difficultyLabels = ['Rất dễ', 'Dễ', 'Trung bình', 'Khó', 'Rất khó'];
      difficultyInstruction =
          'Mức độ khó: ${difficultyLabels[difficulty - 1]} ($difficulty/5)';
    } else {
      difficultyInstruction = 'Mức độ khó: Không xác định (tự động điều chỉnh)';
    }

    // Render template với variables
    return _renderTemplate(baseTemplate, {
      'topic': topic,
      'quantity': quantity.toString(),
      'difficulty_instruction': difficultyInstruction,
    });
  }

  /// Call AI API với endpoint và payload
  ///
  /// Generic method để gọi bất kỳ AI API endpoint nào
  ///
  /// [endpoint] - API endpoint (e.g., '/generate-questions')
  /// [payload] - Request payload (Map hoặc any serializable object)
  /// [method] - HTTP method (default: POST)
  ///
  /// Returns: Raw response data (Map, List, hoặc String)
  static Future<dynamic> callApi(
    String endpoint, {
    dynamic payload,
    String method = 'POST',
  }) async {
    try {
      final client = _client;

      Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await client.get(endpoint, queryParameters: payload);
          break;
        case 'POST':
          response = await client.post(endpoint, data: payload);
          break;
        case 'PUT':
          response = await client.put(endpoint, data: payload);
          break;
        case 'DELETE':
          response = await client.delete(endpoint, data: payload);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Kết nối đến AI service quá lâu. Vui lòng thử lại.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Không thể kết nối đến AI service. Vui lòng kiểm tra kết nối mạng.',
        );
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorMessage =
            e.response!.data?['message'] ??
            e.response!.data?['error'] ??
            'Lỗi từ AI service';
        throw Exception('Lỗi $statusCode: $errorMessage');
      } else {
        throw Exception('Lỗi không xác định: ${e.message}');
      }
    } catch (e) {
      AppLogger.error('❌ [AI Service] Unexpected error: $e', error: e);
      throw Exception('Lỗi khi gọi AI service: ${e.toString()}');
    }
  }

  /// Specialized method: Generate questions using Gemini API
  ///
  /// High-level method kết hợp prompt generation + Gemini API call
  /// Sử dụng Google Gemini API để generate questions
  ///
  /// Returns: Raw response từ Gemini API (cần parse ở Repository layer)
  static Future<dynamic> generateQuestions({
    required String topic,
    required int quantity,
    int? difficulty,
  }) async {
    // Get prompt từ registry
    final prompt = getGenerateQuestionsPrompt(
      topic: topic,
      quantity: quantity,
      difficulty: difficulty,
    );

    // Gọi AI provider đang active (Gemini/Groq)
    return await callActiveAi(prompt);
  }

  /// Call AI theo provider/model đang được cấu hình trong metadata (Settings)
  static Future<dynamic> callActiveAi(
    String prompt, {
    int maxRetries = 3,
  }) async {
    final provider = await ApiKeyService.getActiveProvider();
    final model = await ApiKeyService.getActiveModel();

    if (provider == providerGroq) {
      int attempt = 0;
      while (attempt <= maxRetries) {
        try {
          return await callGroqChat(prompt, model: model);
        } on DioException catch (e) {
          if (e.response?.statusCode == 429 && attempt < maxRetries) {
            final waitSeconds = _extractGroqRetryAfterSeconds(e.response?.data);
            attempt++;
            final delay = waitSeconds ?? (attempt * 2);
            AppLogger.warning(
              '⏳ [AI Service] Groq rate limited, retrying in ${delay}s (attempt $attempt/$maxRetries)',
            );
            await Future.delayed(Duration(seconds: delay));
            continue;
          }
          rethrow;
        }
      }
      throw Exception('Failed after $maxRetries retries');
    }
    // Default: Gemini
    return await callGeminiApi(prompt, model: model, maxRetries: maxRetries);
  }

  static int? _extractGroqRetryAfterSeconds(dynamic responseData) {
    try {
      final msg = (responseData is Map<String, dynamic>)
          ? (responseData['error']?['message']?.toString() ??
                responseData['message']?.toString() ??
                responseData.toString())
          : responseData?.toString();
      if (msg == null) return null;
      final m = RegExp(
        r'try again in\s+([0-9.]+)s',
        caseSensitive: false,
      ).firstMatch(msg);
      final v = double.tryParse(m?.group(1) ?? '');
      if (v == null) return null;
      // ceil để chắc chắn đủ thời gian
      return v.ceil();
    } catch (_) {
      return null;
    }
  }

  /// Call Google Gemini API với retry logic tự động
  ///
  /// [prompt] - Prompt text để gửi đến Gemini
  /// [maxRetries] - Số lần retry tối đa (mặc định: 3)
  ///
  /// Returns: Raw response từ Gemini API
  static Future<dynamic> callGeminiApi(
    String prompt, {
    String? model,
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    while (attempt <= maxRetries) {
      try {
        return await _callGeminiApiOnce(prompt, model: model);
      } on DioException catch (e) {
        // Chỉ retry cho lỗi 429 (Quota/Rate Limit)
        if (e.response?.statusCode == 429 && attempt < maxRetries) {
          // Nếu limit = 0, không retry vì free tier đã bị disable
          if (_isQuotaExhausted(e.response?.data)) {
            throw _createQuotaExhaustedException(e.response?.data);
          }

          final retryDelay = _extractRetryDelay(e.response?.data);
          attempt++;
          final delaySeconds =
              retryDelay ?? (attempt * 2); // Exponential backoff
          AppLogger.warning(
            '⏳ [AI Service] Quota exceeded, retrying in ${delaySeconds}s (attempt $attempt/$maxRetries)',
          );
          await Future.delayed(Duration(seconds: delaySeconds));
          continue;
        }
        // Nếu là lỗi 429 nhưng đã hết retries, throw exception với message rõ ràng
        if (e.response?.statusCode == 429) {
          throw _createQuotaExhaustedException(e.response?.data);
        }
        // Re-throw các lỗi khác
        rethrow;
      } catch (e) {
        // Re-throw các lỗi khác (không phải DioException)
        rethrow;
      }
    }
    // Không bao giờ đến đây, nhưng để type-safe
    throw Exception('Failed after $maxRetries retries');
  }

  /// Internal method: Gọi Gemini API một lần (không retry)
  static Future<dynamic> _callGeminiApiOnce(
    String prompt, {
    String? model,
  }) async {
    try {
      // Lấy API key từ ApiKeyService (ưu tiên storage, fallback về .env)
      final geminiApiKey = await ApiKeyService.getGeminiApiKey();
      final keyPreview = geminiApiKey.isNotEmpty
          ? geminiApiKey.substring(
              0,
              geminiApiKey.length > 10 ? 10 : geminiApiKey.length,
            )
          : 'empty';
      AppLogger.info(
        '🔑 [AI Service] Gemini API Key - length: ${geminiApiKey.length}, '
        'isEmpty: ${geminiApiKey.isEmpty}, preview: $keyPreview...',
      );
      if (geminiApiKey.isEmpty) {
        throw Exception(
          'GEMINI_API_KEY chưa được cấu hình. '
          'Vui lòng thêm API key trong Settings hoặc file .env.',
        );
      }

      // Gemini API endpoint (từ model config, fallback default)
      final usedModel = (model != null && model.isNotEmpty)
          ? model
          : await ApiKeyService.getActiveModelFor(providerGemini);
      final geminiUrl = getGeminiEndpoint(usedModel);

      // Tạo Dio client riêng cho Gemini (không dùng baseUrl)
      final dio = Dio();
      dio.options = BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'X-goog-api-key': geminiApiKey,
        },
      );

      // Gemini API request format
      final payload = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
      };

      AppLogger.info('🤖 [AI Service] Calling Gemini API...');
      final response = await dio.post(geminiUrl, data: payload);

      // Parse Gemini response
      // Format: {candidates: [{content: {parts: [{text: response}]}}]}
      final responseData = response.data as Map<String, dynamic>;
      final candidates = responseData['candidates'] as List<dynamic>?;

      if (candidates == null || candidates.isEmpty) {
        throw Exception('Gemini API không trả về kết quả');
      }

      final firstCandidate = candidates[0] as Map<String, dynamic>;
      final content = firstCandidate['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;

      if (parts == null || parts.isEmpty) {
        throw Exception('Gemini API response không có content');
      }

      final textPart = parts[0] as Map<String, dynamic>;
      final responseText = textPart['text'] as String?;

      if (responseText == null || responseText.isEmpty) {
        throw Exception('Gemini API response text rỗng');
      }

      AppLogger.info('✅ [AI Service] Gemini API response received');

      // Trả về text response để parse JSON
      return responseText;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Kết nối đến Gemini API quá lâu. Vui lòng thử lại.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Không thể kết nối đến Gemini API. Vui lòng kiểm tra kết nối mạng.',
        );
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data as Map<String, dynamic>?;

        // Xử lý lỗi 429 (Quota Exceeded) đặc biệt
        // Note: Re-throw DioException để retry logic ở callGeminiApi có thể xử lý
        if (statusCode == 429) {
          // Re-throw DioException để retry logic có thể catch
          rethrow;
        }

        // Xử lý các lỗi khác
        final errorMessage =
            errorData?['error']?['message'] ??
            errorData?['message'] ??
            'Lỗi từ Gemini API';
        throw Exception('Lỗi $statusCode: $errorMessage');
      } else {
        throw Exception('Lỗi không xác định: ${e.message}');
      }
    } catch (e) {
      AppLogger.error('❌ [AI Service] Gemini API error: $e', error: e);
      throw Exception('Lỗi khi gọi Gemini API: ${e.toString()}');
    }
  }

  /// Call Groq Chat Completions (OpenAI-compatible)
  static Future<String> callGroqChat(String prompt, {String? model}) async {
    try {
      final groqApiKey = await ApiKeyService.getGroqApiKey();
      if (groqApiKey.isEmpty) {
        throw Exception(
          'GROQ_API_KEY chưa được cấu hình. Vui lòng thêm API key trong Settings.',
        );
      }

      final usedModel = (model != null && model.isNotEmpty)
          ? model
          : await ApiKeyService.getActiveModelFor(providerGroq);

      final dio = Dio();
      dio.options = BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $groqApiKey',
        },
      );

      final payload = {
        'model': usedModel,
        // giữ temperature thấp để giảm "lạc đề"
        'temperature': 0.1,
        // Token-optimized: giới hạn output để giảm TPM, vẫn đủ cho batch nhỏ.
        'max_tokens': _groqMaxTokensFromPrompt(prompt),
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      };

      AppLogger.info('🤖 [AI Service] Calling Groq API... model=$usedModel');
      final response = await dio.post(_groqChatUrl, data: payload);

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Groq API response không hợp lệ');
      }
      final choices = data['choices'] as List<dynamic>?;
      final first = (choices != null && choices.isNotEmpty)
          ? choices.first as Map<String, dynamic>
          : null;
      final message = first?['message'] as Map<String, dynamic>?;
      final content = message?['content'] as String?;
      if (content == null || content.trim().isEmpty) {
        throw Exception('Groq API response content rỗng');
      }
      return content;
    } on DioException catch (e) {
      // Cho phép retry ở tầng cao hơn khi dính rate limit
      if (e.response?.statusCode == 429) {
        rethrow;
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Kết nối đến Groq API quá lâu. Vui lòng thử lại.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Không thể kết nối đến Groq API. Kiểm tra mạng.');
      }
      if (e.response != null) {
        final status = e.response!.statusCode;
        final body = e.response!.data;
        throw Exception('Lỗi $status từ Groq API: ${body?.toString() ?? ''}');
      }
      throw Exception('Lỗi khi gọi Groq API: ${e.message}');
    }
  }

  static int _groqMaxTokensFromPrompt(String prompt) {
    // Heuristic: cố gắng đọc số lượng câu trong prompt để ước lượng output.
    // Mục tiêu: giảm TPM + tránh lãng phí token. Batch đang chạy ~10 câu.
    final m = RegExp(
      r'Tạo\s+ra\s+(\d+)\s+câu',
      caseSensitive: false,
    ).firstMatch(prompt);
    final qty = int.tryParse(m?.group(1) ?? '') ?? 10;
    // Mỗi câu MCQ gọn: ~80-120 tokens output. Dự phòng chút.
    final estimated = 250 + (qty * 110);
    // Hard cap để tránh request TPM quá lớn
    if (estimated < 600) return 600;
    if (estimated > 1400) return 1400;
    return estimated;
  }

  /// Extract retry delay từ error response (seconds)
  static int? _extractRetryDelay(Map<String, dynamic>? errorData) {
    if (errorData == null) return null;

    final errorObj = errorData['error'] as Map<String, dynamic>?;
    final details = errorObj?['details'] as List<dynamic>?;

    if (details != null) {
      for (var detail in details) {
        if (detail is Map<String, dynamic>) {
          final retryDelay = detail['retryDelay'] as String?;
          if (retryDelay != null) {
            // Parse "16.661059299s" -> 17 seconds
            try {
              final seconds = double.parse(retryDelay.replaceAll('s', ''));
              return seconds.ceil();
            } catch (e) {
              AppLogger.warning(
                '⚠️ [AI Service] Cannot parse retryDelay: $retryDelay',
              );
            }
          }
        }
      }
    }
    return null;
  }

  /// Kiểm tra xem quota có bị exhausted hoàn toàn không (limit = 0)
  static bool _isQuotaExhausted(Map<String, dynamic>? errorData) {
    if (errorData == null) return false;

    final errorObj = errorData['error'] as Map<String, dynamic>?;
    final details = errorObj?['details'] as List<dynamic>?;

    if (details != null) {
      for (var detail in details) {
        if (detail is Map<String, dynamic>) {
          final limit = detail['limit'] as num?;
          if (limit != null && limit == 0) {
            return true; // Free tier đã bị disable
          }
        }
      }
    }
    return false;
  }

  /// Tạo exception cho quota exhausted
  static Exception _createQuotaExhaustedException(
    Map<String, dynamic>? errorData,
  ) {
    final errorObj = errorData?['error'] as Map<String, dynamic>?;
    final errorMessage = errorObj?['message'] as String? ?? '';
    final details = errorObj?['details'] as List<dynamic>?;

    String quotaMessage = 'Đã vượt quá giới hạn sử dụng Gemini API miễn phí.';
    if (errorMessage.isNotEmpty) {
      quotaMessage = errorMessage;
    }

    // Kiểm tra xem có phải limit = 0 không
    bool isQuotaDisabled = false;
    String retryInfo = '';

    if (details != null) {
      for (var detail in details) {
        if (detail is Map<String, dynamic>) {
          final limit = detail['limit'] as num?;
          if (limit != null && limit == 0) {
            isQuotaDisabled = true;
            quotaMessage =
                'Tài khoản Gemini API free tier đã hết quota hoàn toàn (limit = 0).';
          }

          final retryDelay = detail['retryDelay'] as String?;
          if (retryDelay != null && !isQuotaDisabled) {
            retryInfo = '\nVui lòng thử lại sau $retryDelay.';
            break;
          }
        }
      }
    }

    String solution = isQuotaDisabled
        ? 'Vui lòng nâng cấp tài khoản Gemini API tại: https://ai.google.dev/pricing'
        : 'Để tiếp tục sử dụng, bạn có thể:\n'
              '1. Đợi một lúc rồi thử lại\n'
              '2. Nâng cấp tài khoản Gemini API tại: https://ai.google.dev/pricing';

    return Exception('Quota đã hết: $quotaMessage$retryInfo\n\n$solution');
  }

  /// Get prompt template by key (for advanced usage)
  ///
  /// Cho phép access trực tiếp vào prompt templates nếu cần customize
  static String? getPromptTemplate(String key) {
    return _promptTemplates[key];
  }

  /// Add custom prompt template (for runtime extension)
  ///
  /// Cho phép thêm prompts mới tại runtime (ví dụ: từ database hoặc config)
  /// Note: Templates được thêm sẽ không persist sau app restart
  static void addPromptTemplate(String key, String template) {
    // Note: _promptTemplates là const, nên cần tạo mutable copy nếu muốn runtime modification
    // Hiện tại chỉ support compile-time templates
    AppLogger.warning(
      '⚠️ [AI Service] Runtime prompt templates not yet supported. '
      'Add templates to _promptTemplates map at compile time.',
    );
  }

  /// Reset service (for testing)
  static void reset() {
    _dio = null;
    _isInitialized = false;
  }
}
