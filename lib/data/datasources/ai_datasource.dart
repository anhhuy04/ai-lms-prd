import 'package:ai_mls/core/services/ai_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/domain/entities/template_mode.dart';

/// DataSource cho AI API để generate questions
class AiDataSource {
  AiDataSource() {
    AiService.initialize();
    AppLogger.info('📦 [AI DataSource] Initialized with AiService');
  }

  Future<dynamic> generateQuestions({
    required String topic,
    required int quantity,
    int? difficulty,
    String? questionType,
    String? documentContext,
    bool useAsStyleTemplate = false,
    TemplateMode? templateMode,
  }) async {
    try {
      final response = await AiService.generateQuestions(
        topic: topic,
        quantity: quantity,
        difficulty: difficulty,
        questionType: questionType,
        documentContext: documentContext,
        useAsStyleTemplate: useAsStyleTemplate,
        templateMode: templateMode,
      );
      return response;
    } catch (e) {
      AppLogger.error(
        '❌ [AI DataSource] Error generating questions: $e',
        error: e,
      );
      rethrow;
    }
  }
}
