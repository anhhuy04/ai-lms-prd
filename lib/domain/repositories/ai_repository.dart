/// Repository interface cho AI service
abstract class AiRepository {
  /// Generate questions từ AI
  ///
  /// Parameters:
  /// - topic: Chủ đề câu hỏi
  /// - quantity: Số lượng câu hỏi cần tạo
  /// - difficulty: Mức độ khó (1-5, nullable)
  ///
  /// Returns: List<Map<String, dynamic>> - Danh sách questions đã được parse
  /// Format mỗi question:
  /// {
  ///   'type': QuestionType,
  ///   'text': String,
  ///   'options': List<Map<String, dynamic>>? (cho multiple choice),
  ///   'difficulty': int? (1-5),
  ///   'tags': List<String>?,
  ///   'learningObjectives': List<String>?,
  ///   'explanation': String?,
  ///   'hints': List<String>?,
  /// }
  Future<List<Map<String, dynamic>>> generateQuestions({
    required String topic,
    required int quantity,
    int? difficulty,
    void Function(String rawJson)? onRawResponse,
  });
}
