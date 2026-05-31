import 'dart:convert';

import 'package:ai_mls/core/env/env.dart';
import 'package:ai_mls/core/services/api_key_service.dart';
import 'package:ai_mls/core/services/profile_metadata_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/domain/entities/template_mode.dart';
import 'package:dio/dio.dart';

/// AI báo lỗi không thể gen — thường khi không xác định được môn/cấu trúc.
/// UI nên catch và hiển thị `reason` cho user thay vì silent fail.
class AiUncertaintyException implements Exception {
  final String reason;
  final String code; // missing_subject | ambiguous_schema | insufficient_context | unknown

  AiUncertaintyException(this.reason, {this.code = 'unknown'});

  @override
  String toString() => 'AiUncertaintyException [$code]: $reason';
}

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
  static const String providerOllama = ApiKeyService.providerOllama;
  static const String providerOpenRouter = ApiKeyService.providerOpenRouter;

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
  // Prompt templates — xem getGenerateQuestionsPrompt() để biết cách build
  static const Map<String, String> _promptTemplates = {};

  /// Persona "giáo viên VN sư phạm" — prepend đầu mỗi prompt Mode 3 để định
  /// hình văn phong + ràng buộc chất lượng distractor. Cùng số AI call,
  /// chỉ tăng ~120 token/prompt nhưng nâng độ chính xác sư phạm.
  static const String _vnTeacherPersona =
      '''Bạn là giáo viên VN có 10+ năm kinh nghiệm soạn đề. Câu hỏi PHẢI:
- Dùng tiếng Việt sư phạm, văn phong rõ ràng, đúng cấp học (lớp 9-12).
- BÁM CHẶT MÔN HỌC trong tài liệu mẫu — KHÔNG tự suy sang môn khác (vd có mẫu Toán → KHÔNG tạo Địa lý).
- Distractor (đáp án sai) phải là lỗi sai HỢP LÝ học sinh thường mắc — không tạo distractor vô nghĩa.
- KHÔNG dùng từ Hán Việt khó hiểu, KHÔNG copy từ tài liệu nước ngoài.

LATEX BẮT BUỘC cho công thức:
- Mọi công thức toán/lý/hóa có biến/mũ/căn/phân số/sigma/tích phân: PHẢI kẹp `\$...\$` (inline) hoặc `\$\$...\$\$` (display).
- Vd ĐÚNG: `\$y = x^2\$`, `\$F = ma\$`, `\$\\frac{a}{b}\$`, `\$\\sqrt{49}\$`, `\$H_2SO_4\$`, `\$x_1 + x_2 = -b/a\$`.
- Vd SAI (KHÔNG được dùng): `y = x^2` (ASCII không LaTeX), `H2SO4` (không có chỉ số dưới), `x²` (Unicode không trong LaTeX wrap).
- Plain text bình thường (không công thức): viết tiếng Việt, KHÔNG cần LaTeX.''';

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
    const envFile = String.fromEnvironment(
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

  /// Get Dio client instance (synchronous fallback — không gọi async initialize())
  static Dio get _client {
    if (_dio == null) {
      // Synchronous fallback: tạo Dio mặc định ngay lập tức thay vì await async initialize()
      _dio = Dio()
        ..options = BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          headers: {'Content-Type': 'application/json'},
        );
      _isInitialized = true;
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
  // ignore: unused_element
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

  /// Phát hiện tài liệu có cấu trúc câu hỏi mẫu rõ ràng.
  ///
  /// Trả về true nếu thoả 1 trong 2:
  ///   (A) ≥ 2 marker câu hỏi rõ ràng (VN/EN + số):
  ///       "Câu 1:", "Bài 1.", "Bài tập 1)", "Bài toán 1:", "Câu hỏi 1:",
  ///       "Ví dụ 1:", "Question 1:", "Exercise 1:", "Problem 1:", "Ex 1:", "Q1:".
  ///   (B) Cấu trúc trắc nghiệm rõ ràng: ≥ 4 dòng bắt đầu "A./B./C./D." VÀ
  ///       có ≥ 1 marker đáp án ("Đáp án:", "Trả lời:", "Answer:").
  ///
  /// CỐ Ý KHÔNG nhận diện chỉ bằng numbered list ("1.", "1)") vì pattern này
  /// rất phổ biến trong tài liệu lý thuyết đánh số mục → dễ false positive.
  ///
  /// LƯU Ý: Excel template (`.xlsx`) sau khi extract thành tab-separated rows
  /// KHÔNG có literal "Câu N:" → hàm này luôn trả false. Caller phải check
  /// `parsedQuestions != null` riêng cho Excel template trước khi gọi.
  static bool isTemplateStyleDoc(String text) {
    if (text.trim().isEmpty) return false;

    // (A) Marker câu hỏi tường minh — VN/EN + số.
    final explicitMarkers = RegExp(
      r'(?:câu(?:\s*hỏi)?|bài(?:\s*(?:tập|toán))?|ví\s*dụ|question|exercise|problem|example|ex|q)\s*\.?\s*\d+\s*[:\.\)]',
      caseSensitive: false,
    ).allMatches(text).length;
    if (explicitMarkers >= 2) return true;

    // (B) MCQ structure: ≥ 4 dòng bắt đầu A./B./C./D. (cho phép a)/b)/c)/d))
    final mcqMarkers = RegExp(
      r'(?:^|\n)\s*[A-Da-d]\s*[\.\)]\s+\S',
      multiLine: true,
    ).allMatches(text).length;
    final answerMarkers = RegExp(
      r'(?:đáp\s*án|trả\s*lời|answer)\s*[:\.]',
      caseSensitive: false,
    ).allMatches(text).length;
    if (mcqMarkers >= 4 && answerMarkers >= 1) return true;

    // (C) Math expression: bắt 1-câu math drill kiểu "1+1=2" / "15 + 27 = ?".
    final mathExpr = RegExp(r'\d+\s*[+\-×÷*/=]\s*\d+');
    if (mathExpr.hasMatch(text)) return true;

    return false;
  }

  /// Cắt ngắn tài liệu nếu vượt giới hạn an toàn.
  /// Chiến lược: giữ 60% đầu + 40% cuối để bảo toàn phần mở và kết.
  static ({String text, bool wasTruncated, int totalChars, int usedChars})
      smartTruncate(String text, {int maxChars = 40000}) {
    if (text.length <= maxChars) {
      return (text: text, wasTruncated: false, totalChars: text.length, usedChars: text.length);
    }
    final head = (maxChars * 0.6).toInt();
    final tail = maxChars - head;
    final truncated = '${text.substring(0, head)}\n\n[... nội dung giữa đã lược bỏ ...]\n\n'
        '${text.substring(text.length - tail)}';
    return (text: truncated, wasTruncated: true, totalChars: text.length, usedChars: maxChars);
  }

  /// Build prompt tối ưu cho mọi loại model (kể cả model yếu).
  ///
  /// Nguyên tắc:
  /// - Câu ngắn, rõ ràng, không mơ hồ
  /// - Không suy luận domain — bám sát topic người dùng nhập
  /// - Số rules tối thiểu, ví dụ JSON cụ thể
  /// - questionType explicit (không để AI đoán từ keyword)
  static String getGenerateQuestionsPrompt({
    required String topic,
    required int quantity,
    int? difficulty,
    String? questionType, // null = tự động chọn type phù hợp
    String? documentContext, // nội dung tài liệu local
    bool useAsStyleTemplate = false, // true = tài liệu là khuôn mẫu, không phải nguồn nội dung
    // Sub-mode khi useAsStyleTemplate=true. null + useAsStyleTemplate=true
    // → backward-compat: rơi về `styleOnly` (an toàn).
    TemplateMode? templateMode,
    int? templateCount,
  }) {
    final difficultyLine = _buildDifficultyLine(difficulty);
    final typeRule = _buildTypeRule(questionType);
    final formatExample = _buildFormatExample(questionType);
    final hasDoc = documentContext != null && documentContext.isNotEmpty;

    // ── Chế độ khuôn mẫu: tài liệu định nghĩa văn phong + cấu trúc ─────────
    if (useAsStyleTemplate && hasDoc) {
      // Resolve sub-mode: null = legacy caller → mặc định styleOnly (an toàn).
      final resolvedMode = templateMode ?? TemplateMode.styleOnly;
      AppLogger.info(
        '🧠 [Prompt] Template mode → branch=${resolvedMode.name} '
        'qty=$quantity type=$questionType',
      );
      final hasFocusHint = topic.isNotEmpty && topic != 'Câu hỏi từ tài liệu';
      final topicLine = hasFocusHint
          ? 'BẮT BUỘC tập trung vào "$topic" (yêu cầu giáo viên)'
          : 'Tự suy từ tags trong schema — tạo câu đa dạng cùng lĩnh vực';

      String prompt;
      switch (resolvedMode) {
        case TemplateMode.styleOnly:
          prompt = _buildStyleOnlyPrompt(
            topic: topic,
            quantity: quantity,
            difficultyLine: difficultyLine,
            topicLine: topicLine,
            documentContext: documentContext,
            formatExample: formatExample,
            typeRule: typeRule,
            // Đã biết môn (user nhập focus / tự suy từ mẫu / schema có liệt kê
            // "CÁC MÔN HỌC TRONG MẪU") → bỏ lời mời trả lỗi, ép model tự tin
            // sinh. Model thông minh (70b/qwen) hay lạm dụng clause AN TOÀN để
            // bail khi schema chỉ có metadata → trả missing_subject/ambiguous.
            subjectKnown: hasFocusHint ||
                documentContext.contains('CÁC MÔN HỌC TRONG MẪU'),
          );
        case TemplateMode.sameForm:
          prompt = _buildSameFormPrompt(
            topic: topic,
            quantity: quantity,
            difficultyLine: difficultyLine,
            topicLine: topicLine,
            documentContext: documentContext,
            formatExample: formatExample,
            templateCount: templateCount,
          );
      }
      AppLogger.info(
        '🧠 [Prompt] Built ${resolvedMode.name} prompt: ${prompt.length} chars. '
        'Preview:\n${prompt.substring(0, prompt.length.clamp(0, 400))}…',
      );
      return prompt;
    }

    // ── Chế độ nguồn nội dung: tài liệu cung cấp kiến thức để tạo câu hỏi ──
    final contextSection = hasDoc
        ? '''Dựa vào nội dung tài liệu sau đây để tạo câu hỏi:

--- NỘI DUNG TÀI LIỆU ---
$documentContext
--- KẾT THÚC TÀI LIỆU ---

'''
        : '';

    final hasFocusHint = hasDoc && topic != 'Câu hỏi từ tài liệu' && topic.isNotEmpty;
    final topicRule = hasDoc
        ? (hasFocusHint
            ? 'Câu hỏi PHẢI đúng chủ đề/nội dung: "$topic" (yêu cầu bắt buộc của giáo viên). Lấy kiến thức từ NỘI DUNG TÀI LIỆU ở trên để xây dựng câu hỏi.'
            : 'Câu hỏi dựa trên NỘI DUNG TÀI LIỆU ở trên. Chọn kiến thức quan trọng, đa dạng từ tài liệu.')
        : 'Câu hỏi PHẢI nói về "$topic". Không được lạc sang chủ đề khác.';

    final openingLine = hasDoc
        ? (hasFocusHint
            ? 'Tạo $quantity câu hỏi về "$topic" từ nội dung tài liệu.'
            : 'Tạo $quantity câu hỏi từ nội dung tài liệu.')
        : 'Tạo $quantity câu hỏi về: "$topic".';

    return '''$_vnTeacherPersona

$contextSection$openingLine
$difficultyLine

${hasDoc ? 'CHỐNG SAO CHÉP (ưu tiên cao nhất): TUYỆT ĐỐI KHÔNG sao chép, diễn đạt lại, hay đảo vị trí đáp án của bất kỳ câu nào trong tài liệu. Dùng tài liệu làm nguồn kiến thức — câu hỏi PHẢI MỚI hoàn toàn về ngôn từ và cấu trúc.\n\n' : ''}QUY TẮC (bắt buộc tuân thủ):
1. $topicRule
2. $typeRule
3. Trả về JSON ARRAY. Không có markdown, không giải thích, không ký tự thừa.
4. Mỗi câu hỏi là 1 object trong array.
5. ${hasDoc ? 'ĐA DẠNG HÓA: lấy kiến thức từ nhiều ĐOẠN KHÁC NHAU trong tài liệu, đừng chỉ khai thác một đoạn. Kết hợp câu nhận biết, câu hiểu, câu vận dụng.' : 'ĐA DẠNG HÓA câu hỏi: kết hợp câu cơ bản, câu cần suy luận 2-3 bước, câu áp dụng thực tế. Không tạo toàn câu đơn giản.'}
6. KIỂM TRA ĐÁP ÁN ĐÚNG: trước khi xuất JSON, xác nhận lại rằng choice có isCorrect=true là đúng về mặt kiến thức. Các choice sai phải là lựa chọn có vẻ hợp lý nhưng thực sự sai (nhiễu tốt).
7. ĐA DẠNG VỊ TRÍ ĐÁP ÁN ĐÚNG: trong toàn bộ $quantity câu, phân bố đáp án đúng đều ở các id 0, 1, 2, 3. Tuyệt đối không để đáp án đúng ở cùng id cho mọi câu.

AN TOÀN — KHI BẠN KHÔNG CHẮC:
Nếu bạn KHÔNG xác định được môn học, KHÔNG đủ thông tin từ tài liệu, HOẶC schema mơ hồ → KHÔNG được tự đoán và KHÔNG được tạo câu hỏi sai.
Thay vào đó, trả về JSON object lỗi (KHÔNG phải array):
{"error": "missing_subject", "message": "Tài liệu không nêu rõ môn học. Vui lòng thêm marker [TRẮC NGHIỆM — Toán học] hoặc nhập chủ đề trong ô gợi ý."}

Mã lỗi cho phép: missing_subject | ambiguous_schema | insufficient_context

Trả error tốt hơn nhiều so với gen 10 câu sai môn — tiết kiệm token người dùng.

$formatExample

RÀNG BUỘC FORMAT:
- MỌI loại câu: LUÔN có field "override_text" chứa nội dung câu hỏi đầy đủ.
- multiple_choice: override_text + 4 choices (id 0,1,2,3), đúng 1 cái isCorrect=true, 3 cái isCorrect=false.
- true_false: override_text + 2 choices: {"id":0,"text":"Đúng","isCorrect":true/false} và {"id":1,"text":"Sai","isCorrect":false/true}.
- essay/short_answer: override_text (nội dung câu hỏi) + expected_answer (chuỗi văn bản đáp án mẫu).
- fill_blank: override_text dùng [___1], [___2]... để đánh dấu chỗ trống. blanks liệt kê đáp án đúng với id khớp. **TUYỆT ĐỐI KHÔNG đặt [___N] BÊN TRONG \$...\$** — phải ĐÓNG \$ trước [___N] và mở lại \$ sau. Ví dụ ĐÚNG: "Giá trị của \$x\$ là [___1]." — Ví dụ SAI: "\$x = [___1]\$".
- tags: 1-3 từ khóa liên quan topic.
- KHÔNG tạo field "explanation" — giáo viên sẽ tự tạo gợi ý riêng cho từng câu.

JSON HỢP LỆ — BẮT BUỘC:
- Output PHẢI bắt đầu bằng `[` và kết thúc bằng `]`. KHÔNG có chữ trước/sau, KHÔNG có ```markdown fence```.
- **TUYỆT ĐỐI KHÔNG bọc trong object** như `{"questions": [...]}` hay `{"fill_blank": [...]}`. Root PHẢI là ARRAY thuần.
- fill_blank PHẢI có cả 2 field: `override_text` (chứa [___N]) VÀ `blanks` (list correct_values cho từng N). Thiếu blanks → câu hỏi VÔ DỤNG.
- KHÔNG dùng smart quotes (“ ” ‘ ’) — chỉ dùng dấu nháy thẳng " và '.
- Bên trong giá trị text (override_text/expected_answer…): nếu cần trích dẫn hãy dùng nháy đơn ' hoặc « » — KHÔNG đặt dấu nháy kép " chưa escape (sẽ làm vỡ JSON).
- Viết mỗi giá trị text trên 1 dòng — KHÔNG xuống dòng thật bên trong chuỗi (nếu cần xuống dòng dùng \\n).
- KHÔNG có trailing comma trước `]` hoặc `}` (vd `,]` `,}` SAI).
- LaTeX trong text: escape backslash thành `\\\\` để JSON hợp lệ (vd viết `\\\\frac{1}{2}` chứ không phải `\\frac{1}{2}`).
- KHÔNG cắt JSON giữa chừng — nếu sắp hết token, giảm số câu chứ KHÔNG truncate.''';
  }

  static String _buildDifficultyLine(int? difficulty) {
    if (difficulty == null || difficulty < 1 || difficulty > 5) return '';
    const labels = ['Rất dễ', 'Dễ', 'Trung bình', 'Khó', 'Rất khó'];
    return 'Độ khó: ${labels[difficulty - 1]} ($difficulty/5).';
  }

  static String _buildTypeRule(String? questionType) {
    if (questionType == null || questionType == 'auto') {
      return 'Chọn type phù hợp nhất với nội dung câu hỏi. Ưu tiên "multiple_choice" nếu không rõ.';
    }
    final label = {
      'multiple_choice': 'trắc nghiệm 4 đáp án',
      'true_false': 'đúng/sai',
      'essay': 'tự luận',
      'short_answer': 'trả lời ngắn',
      'fill_blank': 'điền vào chỗ trống',
      'matching': 'nối cặp',
      'math': 'bài toán',
    }[questionType] ?? questionType;
    return 'Tất cả câu phải là type="$questionType" ($label). Không dùng type khác.';
  }

  static String _buildFormatExample(String? questionType) {
    final type = (questionType == null || questionType == 'auto')
        ? 'multiple_choice'
        : questionType;

    switch (type) {
      case 'true_false':
        return '''VÍ DỤ OUTPUT (2 câu):
[
  {"type":"true_false","override_text":"Trái Đất quay quanh Mặt Trời theo quỹ đạo hình elip.","choices":[{"id":0,"text":"Đúng","isCorrect":true},{"id":1,"text":"Sai","isCorrect":false}],"tags":["thiên văn"]},
  {"type":"true_false","override_text":"Nước sôi ở 90°C dưới áp suất khí quyển tiêu chuẩn.","choices":[{"id":0,"text":"Đúng","isCorrect":false},{"id":1,"text":"Sai","isCorrect":true}],"tags":["vật lý"]}
]''';

      case 'essay':
        return '''VÍ DỤ OUTPUT (1 câu):
[
  {"type":"essay","override_text":"Hãy phân tích tác động của biến đổi khí hậu đối với nông nghiệp Việt Nam.","expected_answer":"Biến đổi khí hậu gây ra lũ lụt, hạn hán, xâm nhập mặn ảnh hưởng đến năng suất lúa và cây trồng.","ai_grading_keywords":[{"id":0,"keyword":"lũ lụt","weight":0.3},{"id":1,"keyword":"hạn hán","weight":0.3},{"id":2,"keyword":"xâm nhập mặn","weight":0.4}],"tags":["môi trường","nông nghiệp"]}
]''';

      case 'short_answer':
        return '''VÍ DỤ OUTPUT (1 câu):
[
  {"type":"short_answer","override_text":"Thủ đô của Nhật Bản là thành phố nào?","expected_answer":"Tokyo","tags":["địa lý","châu Á"]}
]''';

      case 'fill_blank':
        return '''VÍ DỤ OUTPUT (1 câu):
[
  {"type":"fill_blank","override_text":"[___1] là thủ đô của Việt Nam.","blanks":[{"id":"[___1]","correct_values":["Hà Nội","Ha Noi"],"case_sensitive":false}],"tags":["tag1"]}
]''';

      case 'math':
        return '''GỢI Ý: Nếu câu có công thức toán phức tạp (phân số, mũ, căn, sigma, integral...), dùng LaTeX inline kẹp `\$...\$` (vd `\$x^2+y^2=r^2\$`, `\$\\frac{a}{b}\$`, `\$\\sqrt{x}\$`). Câu số học đơn giản (cộng/trừ/nhân/chia hai số) viết thẳng không cần LaTeX.
VÍ DỤ OUTPUT (1 câu — DẠNG TỰ LUẬN/GIẢI BÀI: học sinh tự trình bày lời giải, KHÔNG dùng choices):
[
  {"type":"math","override_text":"Một cửa hàng có 15 hộp bút, mỗi hộp 27 chiếc. Hỏi tổng cộng có bao nhiêu chiếc bút?","expected_answer":"15 × 27 = 405 (chiếc bút)","tags":["tag1"]}
]''';

      case 'matching':
        return '''VÍ DỤ OUTPUT (1 câu NỐI CẶP — ghép mỗi mục cột trái với 1 mục cột phải):
[
  {"type":"matching","override_text":"Nối mỗi quốc gia với thủ đô tương ứng:","pairs":[{"left_text":"Việt Nam","right_text":"Hà Nội"},{"left_text":"Nhật Bản","right_text":"Tokyo"},{"left_text":"Pháp","right_text":"Paris"}],"distractors":[{"right_text":"Bắc Kinh"}],"tags":["địa lý"]}
]
RÀNG BUỘC: pairs là các cặp ĐÚNG (left_text ghép right_text). Tối thiểu 3 cặp. distractors (tuỳ chọn) là phương án cột phải gây nhiễu, KHÔNG khớp left nào.''';

      default: // multiple_choice
        return '''VÍ DỤ OUTPUT (2 câu — lưu ý LaTeX trong override_text và choices):
[
  {"type":"multiple_choice","override_text":"Nghiệm phương trình \$x^2 - 5x + 6 = 0\$ là:","choices":[{"id":0,"text":"\$x = 2\$ hoặc \$x = 3\$","isCorrect":true},{"id":1,"text":"\$x = -2\$ hoặc \$x = -3\$","isCorrect":false},{"id":2,"text":"\$x = 1\$ hoặc \$x = 6\$","isCorrect":false},{"id":3,"text":"\$x = 5\$","isCorrect":false}],"tags":["toán học","phương trình"]},
  {"type":"multiple_choice","override_text":"Công thức hóa học của axit sulfuric là:","choices":[{"id":0,"text":"\$HCl\$","isCorrect":false},{"id":1,"text":"\$HNO_3\$","isCorrect":false},{"id":2,"text":"\$H_2SO_4\$","isCorrect":true},{"id":3,"text":"\$NaOH\$","isCorrect":false}],"tags":["hóa học","axit"]}
]''';
    }
  }

  /// Prompt cho TemplateMode.styleOnly — anti-leak strict.
  ///
  /// Context AI nhận: schema-only (KHÔNG có text câu hỏi gốc) — chỉ tags +
  /// difficulty + type. AI buộc phải tạo nội dung MỚI hoàn toàn dựa trên
  /// gợi ý chủ đề từ tags.
  ///
  /// Universal prompt: hoạt động với mọi LLM hỗ trợ JSON output (Gemini,
  /// Groq Llama, OpenAI, Anthropic, Ollama). Rule cấm sao chép đặt ở primacy
  /// VÀ recency để cover middle-context drop trên model yếu.
  static String _buildStyleOnlyPrompt({
    required String topic,
    required int quantity,
    required String difficultyLine,
    required String topicLine,
    required String documentContext,
    required String formatExample,
    required String typeRule,
    bool subjectKnown = false,
  }) {
    return '''$_vnTeacherPersona

OUTPUT: JSON ARRAY thuần túy. KHÔNG text giải thích, KHÔNG markdown fence, KHÔNG ký tự nào trước dấu "[" đầu tiên.

NHIỆM VỤ: Tạo $quantity câu hỏi MỚI HOÀN TOÀN, kế thừa CHỈ phong cách từ schema mẫu (loại câu, độ khó, chủ đề).
Schema CHỈ có metadata — bạn KHÔNG biết câu mẫu nói gì, KHÔNG sao chép/đoán nội dung.

TỐI THƯỢNG — BÁM SÁT MÔN HỌC:
Schema có ghi "CÁC MÔN HỌC TRONG MẪU" → bạn PHẢI tạo câu thuộc các môn đó.
Nếu schema không ghi môn rõ → tự đoán môn từ Tags/Chủ đề. CẤM tự ý đổi sang môn khác.
Lệch môn = câu sai 100%.

--- SCHEMA BÀI MẪU ---
$documentContext
--- HẾT SCHEMA ---

${difficultyLine.isNotEmpty ? 'Gợi ý độ khó chung (ưu tiên độ khó từng slot trong schema): $difficultyLine' : ''}
Chủ đề: $topicLine.
Loại câu: $typeRule

QUY TẮC:
1. Mỗi câu = chủ đề CON khác nhau trong cùng lĩnh vực. Không lặp key concept.
2. Giữ ĐÚNG: loại câu, số lựa chọn, độ khó tương ứng từng slot trong schema.
3. MCQ: đúng 1 isCorrect=true, 3 false. Phân bố đáp án đúng đều id 0,1,2,3 qua $quantity câu.
4. KIỂM TRA trước khi xuất: xác nhận isCorrect=true là đúng kiến thức. Distractor phải sai có lý do.
5. override_text = câu hỏi thực sự, BÁM CHỦ ĐỀ schema (VD đúng cho schema Vật lý lớp 10: "Tính vận tốc của vật rơi tự do sau 3 giây" — VD sai: "câu hỏi vật lý" hay "câu hỏi 1"). **CẤM dùng nội dung lệch domain với schema mẫu** — schema VN thì câu hỏi VN, schema Toán thì câu Toán.

${subjectKnown ? '''HÃY TỰ TIN TẠO CÂU:
Bạn ĐÃ có đủ thông tin: môn học (xem "Chủ đề" + "CÁC MÔN HỌC TRONG MẪU"), loại câu, độ khó từng slot. Schema metadata như vậy là ĐỦ để sáng tác câu MỚI.
TUYỆT ĐỐI KHÔNG trả về JSON lỗi (missing_subject/ambiguous_schema/insufficient_context) và KHÔNG đòi thêm thông tin. Hãy tạo ĐỦ $quantity câu hỏi mới thuộc đúng môn/chủ đề.''' : '''AN TOÀN — KHI BẠN KHÔNG CHẮC:
Nếu bạn KHÔNG xác định được môn học, KHÔNG đủ thông tin từ tài liệu, HOẶC schema mơ hồ → KHÔNG được tự đoán và KHÔNG được tạo câu hỏi sai.
Thay vào đó, trả về JSON object lỗi (KHÔNG phải array):
{"error": "missing_subject", "message": "Tài liệu không nêu rõ môn học. Vui lòng thêm marker [TRẮC NGHIỆM — Toán học] hoặc nhập chủ đề trong ô gợi ý."}

Mã lỗi cho phép: missing_subject | ambiguous_schema | insufficient_context

Trả error tốt hơn nhiều so với gen 10 câu sai môn — tiết kiệm token người dùng.'''}

$formatExample

RÀNG BUỘC FORMAT:
- MỌI loại câu: LUÔN có "override_text" = câu hỏi thực đầy đủ, KHÔNG phải nhãn hay placeholder.
- multiple_choice: override_text + 4 choices (id 0,1,2,3), đúng 1 isCorrect=true.
- true_false: override_text + 2 choices id 0/1 với text "Đúng"/"Sai".
- essay/short_answer: override_text + expected_answer.
- fill_blank: override_text dùng [___1], [___2]…; blanks liệt kê đáp án. KHÔNG đặt [___N] trong \$...\$ — phải ngoài LaTeX.
- tags: 1-3 từ khóa chủ đề.
- KHÔNG tạo field "explanation".
- Bên trong override_text/expected_answer: KHÔNG dùng dấu nháy kép thẳng (") để trích dẫn — hãy dùng nháy đơn (') hoặc « » để JSON không bị vỡ. KHÔNG xuống dòng thật trong chuỗi (nếu cần dùng \\n).

NHẮC LẠI: Trả về JSON ARRAY $quantity object. override_text = câu hỏi thực, không phải nhãn.''';
  }

  /// Prompt cho TemplateMode.sameForm — math drill / structure clone.
  ///
  /// Context AI nhận: text + options đã shuffle (ẩn isCorrect). AI giữ
  /// NGUYÊN cấu trúc câu hỏi, CHỈ đổi giá trị cụ thể (số/dữ kiện), TÍNH
  /// LẠI 4 lựa chọn theo giá trị mới.
  ///
  /// Universal prompt: 3 ví dụ chain-of-thought rõ ràng để cover model yếu
  /// về math reasoning (8B trở xuống thường drift sang dạng khác).
  static String _buildSameFormPrompt({
    required String topic,
    required int quantity,
    required String difficultyLine,
    required String topicLine,
    required String documentContext,
    required String formatExample,
    int? templateCount,
  }) {
    final String scarcityNote;
    if (templateCount == null || templateCount >= quantity) {
      scarcityNote = '';
    } else if (templateCount == 1) {
      scarcityNote =
          '\n\nLƯU Ý QUAN TRỌNG (1 mẫu → $quantity câu):\n'
          'Bạn CHỈ có 1 câu mẫu. PHẢI tạo đủ $quantity câu, TẤT CẢ cùng dạng/cấu trúc với mẫu đó. '
          'Mỗi câu là 1 biến thể KHÁC NHAU rõ rệt về số liệu/dữ kiện cụ thể (vừa nhỏ vừa lớn vừa thập phân nếu phù hợp). '
          'KHÔNG được trả ít hơn $quantity câu. KHÔNG được lặp bộ số gần giống nhau giữa các câu.';
    } else {
      // 2+ mẫu nhưng chưa đủ — vòng lặp round-robin: mẫu[i % templateCount]
      final perTemplate = (quantity / templateCount).ceil();
      scarcityNote =
          '\n\nLƯU Ý QUAN TRỌNG ($templateCount mẫu → $quantity câu, ROUND-ROBIN SO LE):\n'
          'Bạn có $templateCount câu mẫu nhưng cần $quantity câu. Tạo SO LE theo thứ tự sau:\n'
          '  • Câu 1 ← dạng mẫu #1; Câu 2 ← dạng mẫu #2; ... Câu $templateCount ← dạng mẫu #$templateCount.\n'
          '  • Câu ${templateCount + 1} ← lại dạng mẫu #1; Câu ${templateCount + 2} ← dạng mẫu #2; cứ vòng lặp đều như vậy đến đủ $quantity câu.\n'
          'Tức là MỖI mẫu sinh khoảng $perTemplate biến thể khác nhau, phân phối ĐỀU, KHÔNG dồn hết về 1 mẫu. '
          'Mỗi biến thể phải khác rõ rệt về số liệu/dữ kiện. KHÔNG được trả ít hơn $quantity câu.';
    }
    return '''$_vnTeacherPersona

NHIỆM VỤ: Bạn nhận các câu hỏi MẪU dưới đây. Tạo $quantity câu hỏi MỚI giữ NGUYÊN CẤU TRÚC nhưng ĐỔI GIÁ TRỊ CỤ THỂ rồi TÍNH LẠI 4 LỰA CHỌN.

QUY TRÌNH BẮT BUỘC (làm đúng thứ tự cho TỪNG câu):
BƯỚC 1 — PHÂN TÍCH STRUCTURE: tách câu mẫu thành (a) khung cố định = khái niệm/công thức/dạng đề; (b) biến thay đổi được = số/tên/đơn vị/dữ liệu cụ thể.
BƯỚC 2 — ĐỔI VALUE: thay biến (b) bằng giá trị mới hợp lý (cùng phạm vi độ khó, không quá lệch).
BƯỚC 3 — TÍNH LẠI 4 OPTIONS: tự giải đáp án mới, sinh 3 distractor là lỗi sai HỢP LÝ (cộng/trừ thiếu, quên đơn vị, nhầm công thức tương tự…).

--- TÀI LIỆU MẪU ---
$documentContext
--- HẾT MẪU ---

${difficultyLine.isNotEmpty ? 'Gợi ý độ khó chung (ưu tiên độ khó từng câu trong mẫu): $difficultyLine' : ''}
Chủ đề: $topicLine.

QUY TRÌNH BẮT BUỘC CHO MATH (làm cẩn thận từng câu, KHÔNG bỏ bước):
BƯỚC 0 — XÁC ĐỊNH PHẠM VI: trả lời thầm "kiến thức này thuộc lớp mấy của VN?" — nếu lớp 9 không dùng tích phân, lớp 12 không dùng "x là số tự nhiên đơn giản".
BƯỚC 1 — TÍNH TRƯỚC, VIẾT SAU: tự giải đáp án ĐÚNG bằng tính toán cẩn thận. KHÔNG ghi câu hỏi nếu chưa biết đáp án.
BƯỚC 2 — KIỂM TRA LẠI: thay đáp án vào câu hỏi → có khớp không? Nếu không → tính lại.
BƯỚC 3 — DISTRACTOR THỰC TẾ: 3 đáp án sai phải là lỗi cụ thể (cộng thiếu nhớ, quên đơn vị, đảo dấu, nhầm công thức tương tự). Không bịa số ngẫu nhiên.

QUY TẮC CỨNG:
1. GIỮ NGUYÊN: dạng đề, công thức, đơn vị tổng quát, độ dài câu hỏi, **CHỦ ĐỀ/DOMAIN/QUỐC GIA** trong câu mẫu.
2. ĐỔI: **chỉ đổi số liệu hoặc dữ kiện cụ thể CÙNG DOMAIN** (ví dụ: số → số khác, tên nhân vật VN → nhân vật VN khác, năm → năm khác). **CẤM** đổi sang domain khác (Việt Nam → Pháp, Toán → Lý, Lịch sử → Địa lý).
3. NẾU MẪU LÀ NON-NUMERIC (không có số/công thức): chỉ đổi 4 OPTIONS thành phương án mới HỢP LÝ CÙNG CHỦ ĐỀ, **GIỮ NGUYÊN CÂU HỎI** hoặc paraphrase rất nhẹ. Tuyệt đối KHÔNG đổi quốc gia/môn học/lĩnh vực trong câu hỏi.
4. PHÂN TÍCH STRUCTURE TRƯỚC, ĐỔI VALUE SAU, TÍNH LẠI 4 OPTIONS — không bao giờ copy options từ mẫu.
5. Đúng 1 isCorrect=true. Distractor phải khác đáp án đúng và khác nhau từng đôi một, **CÙNG DOMAIN với mẫu**.
6. Phân bố đáp án đúng đều id 0,1,2,3 qua $quantity câu.
7. Output JSON ARRAY thuần. KHÔNG markdown, KHÔNG giải thích.$scarcityNote

--- VÍ DỤ 1 (Toán cộng) ---
Mẫu: "Tính 12 + 8 = ?"  Options: 18/20/22/24
Phân tích: khung "Tính A + B = ?", biến A=12, B=8.
Đổi: A=15, B=7. Tính: 15+7=22. Distractors: 21 (cộng thiếu), 23 (cộng dư), 20 (nhớ nhầm).
Output: [{"type":"multiple_choice","override_text":"Tính 15 + 7 = ?","choices":[{"id":0,"text":"21","isCorrect":false},{"id":1,"text":"22","isCorrect":true},{"id":2,"text":"23","isCorrect":false},{"id":3,"text":"20","isCorrect":false}],"tags":["toán","cộng"]}]

--- VÍ DỤ 2 (Hình học) ---
Mẫu: "Diện tích hình tròn bán kính r=5cm là?"  Options: 25π/10π/50/15π
Phân tích: khung "Diện tích hình tròn r=R", công thức S=π·R². Biến R=5.
Đổi: R=7. Tính: π·49 = 49π. Distractors: 14π (nhầm chu vi 2πR), 49 (quên π), 7π (nhầm π·R).
Output: [{"type":"multiple_choice","override_text":"Diện tích hình tròn bán kính r=7cm là?","choices":[{"id":0,"text":"14π cm²","isCorrect":false},{"id":1,"text":"49 cm²","isCorrect":false},{"id":2,"text":"49π cm²","isCorrect":true},{"id":3,"text":"7π cm²","isCorrect":false}],"tags":["hình học","diện tích"]}]

--- VÍ DỤ 3 (Đại số) ---
Mẫu: "Giải 2x+3=11, x=?"  Options: 4/5/3/8
Phân tích: khung "ax+b=c, x=?", giải x=(c-b)/a. Biến a=2, b=3, c=11.
Đổi: a=3, b=5, c=20. Tính: x=(20-5)/3=5. Distractors: 15 (quên chia), 6 (chia sai), 25/3 (cộng b thay vì trừ).
Output: [{"type":"multiple_choice","override_text":"Giải phương trình 3x+5=20, x=?","choices":[{"id":0,"text":"6","isCorrect":false},{"id":1,"text":"15","isCorrect":false},{"id":2,"text":"5","isCorrect":true},{"id":3,"text":"25/3","isCorrect":false}],"tags":["đại số","phương trình"]}]

--- VÍ DỤ 4 (Non-numeric — GIỮ NGUYÊN DOMAIN/QUỐC GIA) ---
Mẫu: "Thủ đô của nước Việt Nam là thành phố nào?"  Options: TP.HCM/Hà Nội/Đà Nẵng/Huế
Phân tích: khung "Thủ đô của X là?", domain = ĐỊA LÝ VIỆT NAM. **CẤM đổi X sang quốc gia khác** (KHÔNG được hỏi "Thủ đô Pháp/Anh/Mỹ").
Đổi: GIỮ câu hỏi, đổi sang câu khác CÙNG ĐỊA LÝ VIỆT NAM. Ví dụ "Tỉnh nào của Việt Nam có diện tích lớn nhất?" với options là 4 tỉnh thực tế của VN.
Output: [{"type":"multiple_choice","override_text":"Tỉnh nào của Việt Nam có diện tích lớn nhất?","choices":[{"id":0,"text":"Nghệ An","isCorrect":true},{"id":1,"text":"Hà Giang","isCorrect":false},{"id":2,"text":"Thanh Hóa","isCorrect":false},{"id":3,"text":"Quảng Nam","isCorrect":false}],"tags":["địa lý","Việt Nam"]}]

--- VÍ DỤ 5 (Non-numeric — Văn học VN) ---
Mẫu: "Tác giả của bài thơ 'Truyện Kiều' là ai?"  Options: Nguyễn Du/Hồ Xuân Hương/Nguyễn Trãi/Tố Hữu
Phân tích: khung "Tác giả của <tác phẩm VN> là ai?", domain = VĂN HỌC VIỆT NAM. **CẤM đổi sang văn học nước ngoài** (KHÔNG "Tác giả Hamlet/Romeo and Juliet").
Đổi: GIỮ domain văn học VN, đổi sang tác phẩm khác. Distractors là tác giả VN có thật.
Output: [{"type":"multiple_choice","override_text":"Tác giả của tập 'Nhật ký trong tù' là ai?","choices":[{"id":0,"text":"Tố Hữu","isCorrect":false},{"id":1,"text":"Xuân Diệu","isCorrect":false},{"id":2,"text":"Hồ Chí Minh","isCorrect":true},{"id":3,"text":"Nguyễn Du","isCorrect":false}],"tags":["văn học","Việt Nam"]}]

AN TOÀN — KHI BẠN KHÔNG CHẮC:
Nếu bạn KHÔNG xác định được môn học, KHÔNG đủ thông tin từ tài liệu, HOẶC schema mơ hồ → KHÔNG được tự đoán và KHÔNG được tạo câu hỏi sai.
Thay vào đó, trả về JSON object lỗi (KHÔNG phải array):
{"error": "missing_subject", "message": "Tài liệu không nêu rõ môn học. Vui lòng thêm marker [TRẮC NGHIỆM — Toán học] hoặc nhập chủ đề trong ô gợi ý."}

Mã lỗi cho phép: missing_subject | ambiguous_schema | insufficient_context

Trả error tốt hơn nhiều so với gen 10 câu sai môn — tiết kiệm token người dùng.

$formatExample

RÀNG BUỘC FORMAT:
- MỌI câu: LUÔN có "override_text" = câu hỏi thực đầy đủ (không phải nhãn hay placeholder).
- multiple_choice: override_text + 4 choices (id 0,1,2,3), đúng 1 isCorrect=true.
- true_false: override_text + 2 choices id 0/1 với text "Đúng"/"Sai".
- tags: 1-3 từ khóa chủ đề.
- KHÔNG tạo field "explanation".
- Bên trong text: KHÔNG dùng nháy kép " chưa escape (dùng ' hoặc « »); KHÔNG xuống dòng thật trong chuỗi (dùng \\n).
- Output JSON ARRAY thuần, KHÔNG markdown, KHÔNG text trước "[".

NHẮC LẠI: PHÂN TÍCH STRUCTURE TRƯỚC, ĐỔI VALUE SAU, TÍNH LẠI 4 OPTIONS. **GIỮ NGUYÊN DOMAIN/QUỐC GIA/CHỦ ĐỀ của mẫu** — KHÔNG drift sang nước khác hay môn khác. Trả về JSON ARRAY $quantity object đúng format ví dụ.''';
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
    String? questionType, // null hoặc 'auto' = AI tự chọn
    String? documentContext,
    bool useAsStyleTemplate = false,
    TemplateMode? templateMode,
    int? templateCount,
  }) async {
    final prompt = getGenerateQuestionsPrompt(
      topic: topic,
      quantity: quantity,
      difficulty: difficulty,
      questionType: questionType,
      documentContext: documentContext,
      useAsStyleTemplate: useAsStyleTemplate,
      templateMode: templateMode,
      templateCount: templateCount,
    );
    return await callActiveAi(prompt);
  }

  /// Call AI theo provider/model đang được cấu hình trong metadata (Settings)
  static Future<dynamic> callActiveAi(
    String prompt, {
    int maxRetries = 3,
  }) async {
    final provider = await ApiKeyService.getActiveProvider();
    final model = await ApiKeyService.getActiveModel();

    if (provider == providerOllama) {
      return await callOllamaChat(prompt, model: model);
    }

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

    if (provider == providerOpenRouter) {
      return await callOpenRouterChat(prompt, model: model);
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
          : await ApiKeyService.getActiveModelFor(
              providerGemini,
              forceRefresh: true,
            );
      final geminiUrl = getGeminiEndpoint(usedModel);

      // Tạo Dio client riêng cho Gemini (không dùng baseUrl)
      final dio = Dio();
      dio.options = BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120),
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
        // Force pure JSON output — tránh Gemini bọc JSON trong markdown/text thừa
        'generationConfig': {
          'responseMimeType': 'application/json',
          'temperature': 0.2,
          // FIX-ESSAY-3: set tường minh maxOutputTokens rộng rãi để lô câu nặng
          // (tự luận 5 câu + expected_answer dài + ai_grading_keywords) KHÔNG bị
          // cắt cụt giữa JSON. Gemini 1.5/2.0 flash hỗ trợ tới 8192 output tokens.
          'maxOutputTokens': 8192,
        },
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

  /// Call Ollama local API (/api/generate)
  static Future<String> callOllamaChat(String prompt, {String? model}) async {
    final baseUrl = await ApiKeyService.getOllamaBaseUrl();
    if (baseUrl.isEmpty) {
      throw Exception('Ollama URL chưa được cấu hình. Vào Settings → Cài đặt API Key.');
    }
    final usedModel = (model != null && model.isNotEmpty)
        ? model
        : await ApiKeyService.getActiveModelFor(
            providerOllama,
            forceRefresh: true,
          );

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 120),
        headers: {'Content-Type': 'application/json'},
        validateStatus: (s) => s != null,
      ),
    );

    final url = '${baseUrl.replaceAll(RegExp(r'/$'), '')}/api/generate';
    AppLogger.info('🤖 [AI Service] Calling Ollama... url=$url model=$usedModel');

    try {
      final response = await dio.post(url, data: {
        'model': usedModel,
        'prompt': prompt,
        'stream': false,
      });

      if (response.statusCode != 200) {
        throw Exception('Ollama trả về lỗi HTTP ${response.statusCode}');
      }

      final data = response.data;
      final Map<String, dynamic> map = data is String
          ? (jsonDecode(data) as Map<String, dynamic>? ?? {})
          : (data as Map<String, dynamic>? ?? {});
      final text = map['response'] as String?;
      if (text == null || text.isEmpty) {
        throw Exception('Ollama không trả về nội dung (response rỗng)');
      }

      AppLogger.info('✅ [AI Service] Ollama response received');
      return text;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Timeout kết nối Ollama. Model đang load hoặc quá lâu — thử lại.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Không thể kết nối Ollama ($baseUrl). Kiểm tra URL và Ollama đang chạy.');
      }
      throw Exception('Lỗi Ollama: ${e.message}');
    } catch (e) {
      AppLogger.error('❌ [AI Service] Ollama error: $e', error: e);
      rethrow;
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
          : await ApiKeyService.getActiveModelFor(
              providerGroq,
              forceRefresh: true,
            );

      final dio = Dio();
      dio.options = BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 90),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $groqApiKey',
        },
      );

      // FIX-ANYMODEL: ép JSON mode — Groq áp grammar constraint, model yếu
      // (llama-8b) BUỘC xuất JSON hợp lệ thay vì văn xuôi lảm nhảm. Prompt đã
      // chứa "JSON" (điều kiện bắt buộc của json_object mode).
      Future<Response<dynamic>> callGroq({required bool jsonMode}) {
        final payload = {
          'model': usedModel,
          'temperature': 0.1,
          'max_tokens': _groqMaxTokensFromPrompt(prompt),
          if (jsonMode) 'response_format': {'type': 'json_object'},
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        };
        return dio.post(_groqChatUrl, data: payload);
      }

      AppLogger.info('🤖 [AI Service] Calling Groq API... model=$usedModel');
      Response<dynamic> response;
      try {
        response = await callGroq(jsonMode: true);
      } on DioException catch (e) {
        // FIX-JSONMODE: 400 'json_validate_failed' (Groq hết max_tokens TRƯỚC
        // khi JSON hợp lệ hoàn tất — fail cứng) → retry KHÔNG json mode → model
        // trả partial → parser đã siết (escapeInnerQuotes/removeTrailingCommas/
        // autoClose) tự cứu. Best-of-both: JSON mode khi được, salvage khi fail.
        final body = e.response?.data?.toString() ?? '';
        if (e.response?.statusCode == 400 &&
            body.contains('json_validate_failed')) {
          AppLogger.warning(
            '[Groq] json_validate_failed → retry KHÔNG json mode',
          );
          response = await callGroq(jsonMode: false);
        } else {
          rethrow;
        }
      }

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

  /// Call OpenRouter Chat Completions (OpenAI-compatible)
  static Future<String> callOpenRouterChat(String prompt, {String? model}) async {
    try {
      final apiKey = await ApiKeyService.getOpenRouterApiKey();
      if (apiKey.isEmpty) {
        throw Exception(
          'OpenRouter API key chưa được cấu hình. Vui lòng thêm API key trong Settings.',
        );
      }

      // forceRefresh: bypass cache 5 phút để đảm bảo dùng model user vừa save
      // trong Settings — tránh case "đổi model rồi vẫn dùng model cũ".
      var usedModel = (model != null && model.isNotEmpty)
          ? model
          : await ApiKeyService.getActiveModelFor(
              providerOpenRouter,
              forceRefresh: true,
            );

      final dio = Dio();
      dio.options = BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 180),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'HTTP-Referer': 'https://ai-lms.app',
        },
        // Cho phép 4xx response qua để có thể bắt 404 "No endpoints found"
        // và auto-fallback sang defaultOpenRouterModel (model OpenRouter
        // hết đời rất thường xuyên).
        validateStatus: (s) => s != null && s < 500,
      );

      Map<String, dynamic> payload() => {
            'model': usedModel,
            'temperature': 0.1,
            'max_tokens': _openRouterMaxTokensFromPrompt(prompt),
            // FIX-ANYMODEL: ép JSON mode (OpenAI-compatible) — model yếu buộc
            // xuất JSON hợp lệ. Model không hỗ trợ thì OpenRouter bỏ qua param.
            'response_format': {'type': 'json_object'},
            'messages': [
              {'role': 'user', 'content': prompt},
            ],
          };

      AppLogger.info('🤖 [AI Service] Calling OpenRouter... model=$usedModel');
      var response = await dio.post(
        'https://openrouter.ai/api/v1/chat/completions',
        data: payload(),
      );

      // Fallback live-resolve: nếu model user chọn đã bị OpenRouter remove
      // (404 "No endpoints found"), fetch live model list, pick model :free
      // đầu tiên còn sống, save vào profile metadata để lần sau không lỗi,
      // rồi retry. KHÔNG dùng hardcode default (vì cũng có thể đã chết).
      if (response.statusCode == 404) {
        final originalModel = usedModel;
        final resolved = await _resolveLiveOpenRouterModel(exclude: usedModel);
        if (resolved != null) {
          AppLogger.warning(
            '⚠️ [OpenRouter] Model "$originalModel" không khả dụng (404). '
            'Auto-resolve sang "$resolved" (fetched live).',
          );
          usedModel = resolved;
          // Persist để lần sau dùng thẳng model live, không cần retry
          await ProfileMetadataService.setAiConfig(
            provider: providerOpenRouter,
            model: resolved,
          );
          response = await dio.post(
            'https://openrouter.ai/api/v1/chat/completions',
            data: payload(),
          );
        }
      }

      // Sau fallback, nếu vẫn lỗi → throw để UI hiển thị
      if (response.statusCode != null && response.statusCode! >= 400) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('OpenRouter API response không hợp lệ');
      }
      final choices = data['choices'] as List<dynamic>?;
      final first = (choices != null && choices.isNotEmpty)
          ? choices.first as Map<String, dynamic>
          : null;
      final message = first?['message'] as Map<String, dynamic>?;
      final content = message?['content'] as String?;
      if (content == null || content.trim().isEmpty) {
        throw Exception('OpenRouter API response content rỗng');
      }
      return content;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Kết nối đến OpenRouter quá lâu. Vui lòng thử lại.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Không thể kết nối đến OpenRouter. Kiểm tra mạng.');
      }
      if (e.response != null) {
        final status = e.response!.statusCode;
        final body = e.response!.data;
        throw Exception('Lỗi $status từ OpenRouter: ${body?.toString() ?? ''}');
      }
      throw Exception('Lỗi khi gọi OpenRouter: ${e.message}');
    }
  }

  /// Fetch live OpenRouter model list, pick model `:free` đầu tiên KHÁC với
  /// [exclude] (model đang gãy). Dùng cho auto-resolve khi nhận 404.
  ///
  /// Returns null nếu fetch thất bại hoặc list rỗng — caller sẽ throw lỗi gốc.
  static Future<String?> _resolveLiveOpenRouterModel({
    required String exclude,
  }) async {
    try {
      final models = await ApiKeyService.fetchOpenRouterModels();
      if (models.isEmpty) return null;
      // Ưu tiên :free khác model đang gãy
      for (final m in models) {
        final id = m['id'] as String? ?? '';
        final isFree = m['isFree'] as bool? ?? false;
        if (isFree && id.isNotEmpty && id != exclude) return id;
      }
      // Nếu không có :free, lấy model đầu tiên khác exclude (paid)
      for (final m in models) {
        final id = m['id'] as String? ?? '';
        if (id.isNotEmpty && id != exclude) return id;
      }
      return null;
    } catch (e) {
      AppLogger.warning('[OpenRouter] _resolveLiveOpenRouterModel failed: $e');
      return null;
    }
  }

  static int _groqMaxTokensFromPrompt(String prompt) {
    final m = RegExp(
      r'tạo\s+(\d+)\s+câu\s+hỏi',
      caseSensitive: false,
    ).firstMatch(prompt);
    final qty = int.tryParse(m?.group(1) ?? '') ?? 10;
    // FIX-ESSAY-3: budget token THEO LOẠI CÂU. Hệ số 220 tok/câu chỉ đúng cho
    // MCQ/true_false (nhẹ). Câu tự luận/trả lời ngắn/giải toán/nối cặp NẶNG hơn
    // nhiều (expected_answer dài + ai_grading_keywords lồng + pairs...) → 220
    // làm output bị CẮT CỤT → JSON hỏng → parse fail → fallback. Nhận diện loại
    // qua type rule trong prompt ("type=\"essay\"" ...) → dùng hệ số cao hơn.
    final isHeavyType = RegExp(
      r'type="(essay|short_answer|math|matching|problem_solving)"',
      caseSensitive: false,
    ).hasMatch(prompt);
    final perQ = isHeavyType ? 650 : 220;
    final maxCap = isHeavyType ? 12000 : 6000;
    final estimated = 400 + (qty * perQ);
    // FIX-JSONMODE: floor cao (2048). Khi bật response_format json_object,
    // Groq trả 400 'json_validate_failed: max completion tokens reached' NẾU
    // max_tokens hết trước khi JSON hợp lệ hoàn tất (fail cứng, không cắt cụt
    // cho parser cứu). Batch nhỏ (vd refill 2 câu = 840) dễ dính → cho dư chỗ.
    const floor = 2048;
    if (estimated < floor) return floor;
    if (estimated > maxCap) return maxCap;
    return estimated;
  }

  /// Max tokens cho OpenRouter — cộng thêm 6000 thinking budget cho reasoning models
  /// (DeepSeek-R1, QwQ, v.v. dùng `<think>` block trước JSON nên cần nhiều token hơn)
  static int _openRouterMaxTokensFromPrompt(String prompt) {
    final base = _groqMaxTokensFromPrompt(prompt);
    // Thinking overhead ~ 4000-6000 tokens; cap tổng ở 16000 để đủ cho mọi model
    final withThinking = base + 6000;
    return withThinking.clamp(4000, 16000);
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

  /// Tự đánh giá danh sách câu hỏi vừa generate. Trả về list result song song
  /// với input — mỗi entry là `{pass: bool, reason: String}`.
  ///
  /// Cost: 1 AI call duy nhất (batch verify), khoảng 800-1500 token output cho
  /// 10 câu. Latency thêm ~5-10s.
  ///
  /// Khi nào pass=false:
  /// - Kiến thức sai (vd phép tính sai)
  /// - Đáp án ĐÚNG không thực sự đúng
  /// - Distractor không hợp lý hoặc trùng đáp án
  /// - Lỗi chính tả/ngữ pháp tiếng Việt nặng
  /// - Không phù hợp cấp học VN (vd lớp 9 mà yêu cầu tích phân)
  ///
  /// Graceful: nếu parse fail hoặc API throw, trả về toàn bộ pass=true để
  /// KHÔNG block flow generate chính.
  static Future<List<Map<String, dynamic>>> critiqueQuestions(
    List<Map<String, dynamic>> questions, {
    String? topic,
    int? gradeLevel,
  }) async {
    if (questions.isEmpty) return const [];
    final passAll = List<Map<String, dynamic>>.generate(
      questions.length,
      (_) => {'pass': true, 'reason': ''},
    );
    try {
      final prompt = _buildCritiquePrompt(
        questions: questions,
        topic: topic,
        gradeLevel: gradeLevel,
      );
      final raw = await callActiveAi(prompt);
      final parsed = _parseCritiqueResponse(raw, questions.length);
      final fails = parsed.where((e) => e['pass'] == false).length;
      AppLogger.info(
        '[Critique] N=${questions.length}, fails=$fails',
      );
      return parsed;
    } catch (e, st) {
      AppLogger.warning(
        '⚠️ [Critique] Lỗi self-critique, bỏ qua (pass-all): $e',
      );
      AppLogger.error('[Critique] error', error: e, stackTrace: st);
      return passAll;
    }
  }

  /// Build prompt critique batch.
  static String _buildCritiquePrompt({
    required List<Map<String, dynamic>> questions,
    String? topic,
    int? gradeLevel,
  }) {
    final buf = StringBuffer();
    for (var i = 0; i < questions.length; i++) {
      buf.write('[${i + 1}] ');
      buf.writeln(_critiqueFormatQuestion(questions[i]));
    }
    final topicLine = (topic != null && topic.trim().isNotEmpty)
        ? 'Chủ đề: "$topic".'
        : '';
    final gradeLine = (gradeLevel != null)
        ? 'Cấp học mục tiêu: lớp $gradeLevel.'
        : 'Cấp học mục tiêu: trung học VN (lớp 9-12).';
    return '''Bạn là giáo viên VN có 15 năm kinh nghiệm chấm bài. Hãy đánh giá NGẮN GỌN từng câu hỏi sau.
$topicLine
$gradeLine

DANH SÁCH CÂU HỎI:
${buf.toString().trimRight()}

Với MỖI câu, kiểm:
A. Kiến thức có đúng không (đáp án đúng có thực sự đúng)?
B. Distractor có hợp lý không (không trùng đáp án, không vô nghĩa)?
C. Phù hợp cấp học VN không?
D. Văn phong tiếng Việt OK không?

Trả về JSON ARRAY thuần, đủ ${questions.length} entry, idx khớp số thứ tự:
[{"idx":1,"pass":true,"reason":""},{"idx":2,"pass":false,"reason":"Đáp án sai: 2+3=5 chứ không phải 6"}]

KHÔNG markdown, KHÔNG giải thích thừa. CHỈ JSON ARRAY.''';
  }

  /// Format 1 câu hỏi cho prompt critique (compact).
  static String _critiqueFormatQuestion(Map<String, dynamic> q) {
    final text = (q['override_text'] as String?)
        ?? (q['text'] as String?)
        ?? ((q['content'] is Map<String, dynamic>)
            ? (q['content'] as Map<String, dynamic>)['text'] as String?
            : null)
        ?? '';
    final type = q['type']?.toString() ?? 'multiple_choice';
    final buf = StringBuffer()..writeln('[$type] ${text.trim()}');
    final choices = q['choices'] as List<dynamic>?;
    if (choices != null && choices.isNotEmpty) {
      for (var i = 0; i < choices.length; i++) {
        final c = choices[i];
        if (c is! Map<String, dynamic>) continue;
        final cText = (c['text'] as String?)
            ?? ((c['content'] is Map<String, dynamic>)
                ? (c['content'] as Map<String, dynamic>)['text'] as String?
                : null)
            ?? '';
        final isCorrect = (c['isCorrect'] as bool?) ?? (c['is_correct'] as bool?) ?? false;
        buf.writeln('  ${String.fromCharCode(65 + i)}. $cText${isCorrect ? "  ✓" : ""}');
      }
    }
    final expected = q['expected_answer'] as String?;
    if (expected != null && expected.trim().isNotEmpty) {
      buf.writeln('  Đáp án mẫu: ${expected.trim()}');
    }
    return buf.toString().trimRight();
  }

  /// Parse JSON array critique → list `{pass, reason}` đúng độ dài N.
  static List<Map<String, dynamic>> _parseCritiqueResponse(
    dynamic raw,
    int expectedLen,
  ) {
    final fallback = List<Map<String, dynamic>>.generate(
      expectedLen,
      (_) => {'pass': true, 'reason': ''},
    );
    try {
      dynamic decoded = raw;
      if (raw is String) {
        decoded = _stripJsonFences(raw);
        decoded = jsonDecode(decoded as String);
      }
      List<dynamic>? arr;
      if (decoded is List) {
        arr = decoded;
      } else if (decoded is Map<String, dynamic>) {
        arr = (decoded['results'] as List<dynamic>?)
            ?? (decoded['data'] as List<dynamic>?);
      }
      if (arr == null) return fallback;

      final out = List<Map<String, dynamic>>.from(fallback);
      for (final item in arr) {
        if (item is! Map<String, dynamic>) continue;
        final idx = (item['idx'] as num?)?.toInt();
        if (idx == null || idx < 1 || idx > expectedLen) continue;
        out[idx - 1] = {
          'pass': (item['pass'] as bool?) ?? true,
          'reason': (item['reason'] as String?)?.trim() ?? '',
        };
      }
      return out;
    } catch (e) {
      AppLogger.warning('⚠️ [Critique] parse fail: $e');
      return fallback;
    }
  }

  /// Strip markdown fences + extract JSON substring (defensive).
  static String _stripJsonFences(String s) {
    var t = s.trim();
    t = t.replaceAll(
      RegExp(r'<think>[\s\S]*?</think>', caseSensitive: false),
      '',
    ).trim();
    final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```', caseSensitive: false)
        .firstMatch(t);
    if (fence != null) t = (fence.group(1) ?? '').trim();
    final start = t.indexOf('[');
    final end = t.lastIndexOf(']');
    if (start >= 0 && end > start) return t.substring(start, end + 1);
    return t;
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
