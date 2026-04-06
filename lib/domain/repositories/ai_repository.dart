/// Repository interface cho AI service
abstract class AiRepository {
  /// Generate questions từ AI
  ///
  /// [topic]        — Chủ đề câu hỏi (free text)
  /// [quantity]     — Số lượng câu hỏi
  /// [difficulty]   — Mức độ khó 1-5 (nullable)
  /// [questionType] — Loại câu hỏi: 'multiple_choice' | 'true_false' | 'essay' |
  ///                  'short_answer' | 'fill_blank' | 'math' | null (= tự động)
  /// [onRawResponse] — Callback nhận raw JSON từng batch (để debug/preview)
  Future<List<Map<String, dynamic>>> generateQuestions({
    required String topic,
    required int quantity,
    int? difficulty,
    String? questionType,
    void Function(String rawJson)? onRawResponse,
  });
}
