import 'package:ai_mls/core/utils/app_logger.dart';

/// Hành động khi câu sinh ra quá giống câu mẫu.
enum SimilarityAction { pass, warn, regenerate, drop }

/// Kết quả verify 1 câu sinh so với toàn bộ tập câu mẫu.
class TemplateSimilarityResult {
  const TemplateSimilarityResult({
    required this.questionIndex,
    required this.maxScore,
    required this.matchedTemplateIdx,
    required this.action,
  });

  /// Index của câu sinh trong batch (0-based).
  final int questionIndex;

  /// Điểm similarity max so với mọi câu mẫu (0..1).
  final double maxScore;

  /// Index câu mẫu match cao nhất (-1 nếu không có template).
  final int matchedTemplateIdx;

  /// Hành động khuyến nghị: pass | warn | regenerate | drop.
  final SimilarityAction action;
}

/// Verifier so sánh câu AI sinh với câu mẫu để chống đạo đề.
///
/// Hoàn toàn model-agnostic — chỉ dùng CPU để tính 2 metric:
/// - Levenshtein normalized: bắt gần-trùng-từng-ký-tự (math drill đổi số).
/// - Jaccard bigram: bắt paraphrase nhẹ (đảo từ, đổi từ đồng nghĩa nhẹ).
/// Score = max(2 metric) → conservative.
///
/// Không cần network, không cần embedding model → an toàn cho mọi model
/// (Groq/Gemini/OpenAI/Anthropic/Ollama) user setup.
class TemplateSimilarityVerifier {
  TemplateSimilarityVerifier({
    this.warnThreshold = 0.55,
    this.regenerateThreshold = 0.75,
    this.dropThreshold = 0.88,
  });

  final double warnThreshold;
  final double regenerateThreshold;
  final double dropThreshold;

  /// Check toàn bộ batch sinh ra. Trả về list cùng độ dài với `generated`.
  ///
  /// Nếu `templateQuestions` rỗng/null → tất cả pass (skip verify).
  List<TemplateSimilarityResult> verifyAgainstTemplate({
    required List<Map<String, dynamic>> generated,
    required List<Map<String, dynamic>> templateQuestions,
  }) {
    if (templateQuestions.isEmpty) {
      return List.generate(
        generated.length,
        (i) => TemplateSimilarityResult(
          questionIndex: i,
          maxScore: 0,
          matchedTemplateIdx: -1,
          action: SimilarityAction.pass,
        ),
      );
    }

    final templateTexts = templateQuestions
        .map((q) => _extractText(q).toLowerCase().trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final results = <TemplateSimilarityResult>[];
    for (var i = 0; i < generated.length; i++) {
      final genText = _extractText(generated[i]).toLowerCase().trim();

      double maxScore = 0;
      int matchedIdx = -1;
      if (genText.isNotEmpty) {
        for (var j = 0; j < templateTexts.length; j++) {
          final score = similarity(genText, templateTexts[j]);
          if (score > maxScore) {
            maxScore = score;
            matchedIdx = j;
          }
        }
      }

      final action = _classify(maxScore);
      results.add(
        TemplateSimilarityResult(
          questionIndex: i,
          maxScore: maxScore,
          matchedTemplateIdx: matchedIdx,
          action: action,
        ),
      );

      if (action != SimilarityAction.pass) {
        AppLogger.warning(
          '⚠️ [Similarity] Q${i + 1} vs template[$matchedIdx]: '
          'score=${maxScore.toStringAsFixed(3)} → ${action.name}',
        );
      }
    }
    return results;
  }

  /// Public: cho test + có thể reuse ở chỗ khác.
  /// Score = max(Levenshtein normalized, Jaccard bigram).
  double similarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0;
    if (a == b) return 1;
    final lev = _levenshteinNormalized(a, b);
    final jac = _jaccardBigram(a, b);
    return lev > jac ? lev : jac;
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  SimilarityAction _classify(double score) {
    if (score >= dropThreshold) return SimilarityAction.drop;
    if (score >= regenerateThreshold) return SimilarityAction.regenerate;
    if (score >= warnThreshold) return SimilarityAction.warn;
    return SimilarityAction.pass;
  }

  /// Lấy text câu hỏi từ question map (hỗ trợ nhiều shape).
  String _extractText(Map<String, dynamic> q) {
    final overrideText = q['override_text'] as String?;
    if (overrideText != null && overrideText.trim().isNotEmpty) {
      return overrideText;
    }
    final content = q['content'];
    if (content is Map<String, dynamic>) {
      final text = content['text'] as String?;
      if (text != null && text.isNotEmpty) return text;
    }
    final text = q['text'] as String?;
    if (text != null && text.isNotEmpty) return text;
    return '';
  }

  /// Levenshtein normalized: 1 - dist / max(len).
  double _levenshteinNormalized(String a, String b) {
    final dist = _levenshtein(a, b);
    final maxLen = a.length > b.length ? a.length : b.length;
    if (maxLen == 0) return 0;
    return 1 - (dist / maxLen);
  }

  /// Levenshtein edit distance — implementation chuẩn.
  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final m = a.length;
    final n = b.length;
    var prev = List<int>.generate(n + 1, (i) => i);
    var curr = List<int>.filled(n + 1, 0);

    for (var i = 1; i <= m; i++) {
      curr[0] = i;
      for (var j = 1; j <= n; j++) {
        final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        final del = prev[j] + 1;
        final ins = curr[j - 1] + 1;
        final sub = prev[j - 1] + cost;
        curr[j] = del < ins ? (del < sub ? del : sub) : (ins < sub ? ins : sub);
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[n];
  }

  /// Jaccard similarity trên tập bigram của 2 chuỗi.
  /// Bigram = cặp 2 ký tự liên tiếp (sau strip diacritic-insensitive lowercase).
  double _jaccardBigram(String a, String b) {
    final ba = _bigrams(a);
    final bb = _bigrams(b);
    if (ba.isEmpty || bb.isEmpty) return 0;
    final intersection = ba.intersection(bb).length;
    final union = ba.union(bb).length;
    return union == 0 ? 0 : intersection / union;
  }

  Set<String> _bigrams(String s) {
    final cleaned = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length < 2) return {cleaned};
    final result = <String>{};
    for (var i = 0; i < cleaned.length - 1; i++) {
      result.add(cleaned.substring(i, i + 2));
    }
    return result;
  }
}
