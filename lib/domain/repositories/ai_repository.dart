/// Repository interface cho AI service
abstract class AiRepository {
  /// Generate questions từ AI
  ///
  /// Parameters:
  /// - topic: Chủ đề câu hỏi
  /// - quantity: Số lượng câu hỏi cần tạo
  /// - difficulty: Mức độ khó (1-5, nullable)
  ///
  /// Returns: List of Map - Danh sách questions đã được parse
  /// Format mỗi question:
  /// ```
  /// {
  ///   'type': QuestionType,
  ///   'text': String,
  ///   'options': List (cho multiple choice),
  ///   'difficulty': int (1-5),
  ///   'tags': List,
  ///   'learningObjectives': List,
  ///   'explanation': String,
  ///   'hints': List,
  /// }
  /// ```
  Future<List<Map<String, dynamic>>> generateQuestions({
    required String topic,
    required int quantity,
    int? difficulty,
    void Function(String rawJson)? onRawResponse,
  });
}
