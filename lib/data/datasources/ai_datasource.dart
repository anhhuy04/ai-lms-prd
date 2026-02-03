import 'package:ai_mls/core/services/ai_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';

/// DataSource cho AI API để generate questions
///
/// DataSource này sử dụng AiService để:
/// - Lấy prompts từ Prompt Registry
/// - Gọi AI API thông qua AiService
/// - Tuân theo Clean Architecture: DataSource chỉ làm data access, không có business logic
class AiDataSource {
  /// Initialize AI Service nếu chưa được init
  ///
  /// DataSource đảm bảo service đã được init trước khi sử dụng
  AiDataSource() {
    // Ensure AiService is initialized
    // Note: AiService.initialize() is safe to call multiple times
    AiService.initialize();
    AppLogger.info('📦 [AI DataSource] Initialized with AiService');
  }

  /// Generate questions từ AI API
  ///
  /// Parameters:
  /// - topic: Chủ đề câu hỏi
  /// - quantity: Số lượng câu hỏi cần tạo
  /// - difficulty: Mức độ khó (1-5, nullable)
  ///
  /// Returns: Raw response từ API (Map hoặc String)
  ///
  /// Implementation: Sử dụng AiService.generateQuestions() để:
  /// 1. Lấy prompt từ Prompt Registry
  /// 2. Gọi AI API với prompt đã được render
  /// 3. Trả về raw response để Repository parse
  Future<dynamic> generateQuestions({
    required String topic,
    required int quantity,
    int? difficulty,
  }) async {
    try {
      // Sử dụng specialized method từ AiService
      // Method này tự động:
      // - Lấy prompt từ registry
      // - Render template với variables
      // - Gọi API
      final response = await AiService.generateQuestions(
        topic: topic,
        quantity: quantity,
        difficulty: difficulty,
      );

      return response;
    } catch (e) {
      // Re-throw để Repository layer xử lý error translation
      AppLogger.error(
        '❌ [AI DataSource] Error generating questions: $e',
        error: e,
      );
      rethrow;
    }
  }
}
