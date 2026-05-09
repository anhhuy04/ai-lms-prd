import 'package:ai_mls/domain/entities/template_mode.dart';

/// Repository interface cho AI service
abstract class AiRepository {
  /// Generate questions từ AI
  ///
  /// [topic]        — Chủ đề câu hỏi (free text)
  /// [quantity]     — Số lượng câu hỏi
  /// [difficulty]   — Mức độ khó 1-5 (nullable)
  /// [questionType] — Loại câu hỏi: 'multiple_choice' | 'true_false' | 'essay' |
  ///                  'short_answer' | 'fill_blank' | 'math' | null (= tự động)
  /// [documentContext]     — Nội dung tài liệu local để đưa vào prompt (extraction mode)
  /// [useAsStyleTemplate]  — true = tài liệu là khuôn mẫu về văn phong/cấu trúc
  /// [templateMode]        — Sub-mode khi `useAsStyleTemplate == true`. null +
  ///                         `useAsStyleTemplate == true` → mặc định styleOnly
  ///                         (an toàn, backward-compat).
  /// [templateQuestions]   — Câu mẫu gốc (Excel parsed) để hậu kiểm similarity
  ///                         post-hoc. null/rỗng = bỏ qua kiểm tra.
  /// [templateCount]       — Số câu mẫu gốc thực có (để prompt cảnh báo
  ///                         scarcity khi templateCount < quantity / 2). null
  ///                         = bỏ qua scarcity note.
  /// [onRawResponse]       — Callback nhận raw JSON từng batch (để debug/preview)
  /// [highAccuracyMode]    — true = sau khi gen xong, gọi AI lần 2 self-critique
  ///                         từng câu (đính kèm `_critique: {pass, reason}`).
  ///                         Default false (KHÔNG đổi behavior cũ, KHÔNG tốn
  ///                         thêm AI call). Opt-in từ UI.
  Future<List<Map<String, dynamic>>> generateQuestions({
    required String topic,
    required int quantity,
    int? difficulty,
    String? questionType,
    String? documentContext,
    bool useAsStyleTemplate = false,
    TemplateMode? templateMode,
    List<Map<String, dynamic>>? templateQuestions,
    int? templateCount,
    void Function(String rawJson)? onRawResponse,
    bool highAccuracyMode = false,
  });
}
