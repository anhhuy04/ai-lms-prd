import 'dart:convert';

import 'package:ai_mls/core/services/ai_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Background AI processor chạy phía teacher app.
///
/// Luồng: Ollama (local) trước → fallback Groq nếu Ollama không kết nối được.
/// Hoàn toàn silent — không có UI callback, không setState, không ref.
///
/// Được khởi tạo và quản lý bởi [TeacherAiQueueProvider].
class TeacherAiQueueProcessor {
  final SupabaseClient _supabase;

  TeacherAiQueueProcessor(this._supabase);

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Xử lý một item trong ai_queue. Silent — mọi lỗi đều được log, không throw ra ngoài.
  Future<void> processItem(Map<String, dynamic> item) async {
    final itemId = item['id'] as String;
    final requestType = item['request_type'] as String;
    final submissionAnswerId = item['submission_answer_id'] as String?;
    final currentAttempts = (item['attempts'] as int?) ?? 0;
    final newAttempts = currentAttempts + 1;

    try {
      await _supabase.from('ai_queue').update({
        'status': 'processing',
        'attempts': newAttempts,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', itemId);

      if (requestType == 'feedback' && submissionAnswerId != null) {
        final sessionId = await _handleFeedback(submissionAnswerId);
        await _markCompleted(itemId);
        if (sessionId != null) await _maybeMarkSessionGraded(sessionId);
      } else if (requestType == 'analysis') {
        // 5a-R1: EDGE (process-ai-queue) là generator CANONICAL của recommendations.
        // Dart KHÔNG sinh recommendations: insert teacher-authed teacher_id=NULL bị RLS chặn
        // (null_local=0 suốt thời gian qua) + tránh nguồn-trùng với edge. Chỉ mark completed
        // để queue 'analysis' không kẹt nếu edge chết.
        await _markCompleted(itemId);
      } else {
        // score → deferred (chờ phase 3)
        await _supabase.from('ai_queue').update({
          'status': 'deferred',
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', itemId);
      }

      AppLogger.info('[TeacherAI] Item $itemId processed (type=$requestType)');
    } catch (e) {
      AppLogger.error('[TeacherAI] Item $itemId failed: $e');
      await _supabase.from('ai_queue').update({
        'status': newAttempts >= 3 ? 'failed' : 'pending',
        'attempts': newAttempts,
        'result': {'error': e.toString(), 'failed_at': DateTime.now().toIso8601String()},
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', itemId);
    }
  }

  // ── Feedback handler ───────────────────────────────────────────────────────

  Future<String?> _handleFeedback(String submissionAnswerId) async {
    // Fetch answer + question (dùng !left vì custom questions có question_id=null)
    final ctx = await _supabase
        .from('submission_answers')
        .select('''
          id, answer, final_score, session_id,
          assignment_question_id,
          assignment_questions!inner (
            points, custom_content, question_id,
            questions!left (
              content,
              question_choices ( id, content, is_correct )
            )
          )
        ''')
        .eq('id', submissionAnswerId)
        .single();

    final aq = ctx['assignment_questions'] as Map<String, dynamic>;
    final customContent = aq['custom_content'] as Map<String, dynamic>?;
    final linkedQ = aq['questions'] as Map<String, dynamic>?;
    final maxPoints = (aq['points'] as num?)?.toDouble() ?? 1.0;

    final questionText = _extractQuestionText(customContent, linkedQ);
    final choices = _extractChoices(customContent, linkedQ);

    final studentAnswer = ctx['answer'] as Map<String, dynamic>?;
    final selectedIds = ((studentAnswer?['selected_choice_ids'] as List?) ?? [])
        .map((e) => e.toString())
        .toList();
    final finalScore = (ctx['final_score'] as num?)?.toDouble() ?? 0;
    final isCorrect = maxPoints > 0 && finalScore >= maxPoints;

    final selectedChoices = choices
        .where((c) => selectedIds.contains((c['id'] ?? '').toString()))
        .toList();

    final tags = (customContent?['tags'] as List?)?.cast<String>() ?? [];
    final prompt = _buildPrompt(
      questionText: questionText,
      choices: choices,
      selectedChoices: selectedChoices,
      isCorrect: isCorrect,
      finalScore: finalScore,
      maxPoints: maxPoints,
      tags: tags,
    );

    // Ollama trước → Groq fallback
    final rawResponse = await _callWithFallback(prompt);

    final feedback = _parseFeedbackJson(rawResponse, isCorrect);
    await _supabase
        .from('submission_answers')
        .update({'ai_feedback': feedback})
        .eq('id', submissionAnswerId);

    AppLogger.info('[TeacherAI] Feedback written for $submissionAnswerId — correct=$isCorrect');
    return ctx['session_id'] as String?;
  }

  // ── Analysis handler ───────────────────────────────────────────────────────

  /// @deprecated 5a-R1: KHÔNG còn được gọi. Edge (process-ai-queue) là generator
  /// canonical của recommendations. Giữ lại để tham chiếu logic rule-based; sẽ xoá ở 5b.
  // ignore: unused_element
  Future<void> _handleAnalysis(Map<String, dynamic> item) async {
    final sessionId = (item['payload'] as Map<String, dynamic>?)?['session_id'] as String?;
    if (sessionId == null) {
      AppLogger.warning('[TeacherAI] Analysis item missing session_id');
      return;
    }

    final session = await _supabase
        .from('work_sessions')
        .select('student_id')
        .eq('id', sessionId)
        .maybeSingle();
    if (session == null) return;

    final masteryRows = await _supabase
        .from('student_skill_mastery')
        .select('objective_id, mastery_level, attempts, correct, learning_objectives(code, description)')
        .eq('student_id', session['student_id'] as String)
        .lt('mastery_level', 0.6)
        .order('mastery_level', ascending: true)
        .limit(5);

    if (masteryRows.isEmpty) {
      AppLogger.info('[TeacherAI] No weak skills for session $sessionId');
      return;
    }

    final now = DateTime.now().toIso8601String();
    for (final m in masteryRows) {
      final lo = m['learning_objectives'] as Map<String, dynamic>?;
      final code = lo?['code'] as String? ?? 'OBJ-${(m['objective_id'] as String).substring(0, 8)}';
      final desc = lo?['description'] as String? ?? 'Kỹ năng cần cải thiện';
      final masteryPct = ((m['mastery_level'] as num) * 100).round();

      await _supabase.from('ai_recommendations').insert({
        'student_id': session['student_id'],
        'type': 'individual',
        'priority': ((1 - (m['mastery_level'] as num)) * 5).clamp(1, 5).round(),
        'title': 'Ôn tập: $code',
        'description': '$desc — tỷ lệ thành thạo $masteryPct%, cần cải thiện.',
        'resources': {
          'objective_id': m['objective_id'],
          'mastery_level': m['mastery_level'],
          'attempts': m['attempts'],
          'correct_count': m['correct'],
          'generated_at': now,
          'source': 'teacher_local_processor',
        },
        'dismissed': false,
        'created_at': now,
      });
    }

    AppLogger.info('[TeacherAI] Analysis done for $sessionId — ${masteryRows.length} recs inserted');
  }

  // ── AI call: Ollama → Groq fallback ────────────────────────────────────────

  Future<String> _callWithFallback(String prompt) async {
    // 1. Thử Ollama trước (local, miễn phí)
    try {
      final result = await AiService.callOllamaChat(prompt);
      if (result.isNotEmpty) {
        AppLogger.info('[TeacherAI] Ollama responded successfully');
        return result;
      }
    } catch (e) {
      AppLogger.warning('[TeacherAI] Ollama failed, falling back to Groq: $e');
    }

    // 2. Fallback Groq
    try {
      final result = await AiService.callGroqChat(prompt);
      if (result.isNotEmpty) {
        AppLogger.info('[TeacherAI] Groq responded successfully');
        return result;
      }
    } catch (e) {
      AppLogger.error('[TeacherAI] Groq also failed: $e');
    }

    throw Exception('Cả Ollama và Groq đều không phản hồi');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _extractQuestionText(
    Map<String, dynamic>? customContent,
    Map<String, dynamic>? linkedQ,
  ) {
    return (customContent?['override_text'] as String?) ??
        (customContent?['text'] as String?) ??
        ((linkedQ?['content'] as Map<String, dynamic>?)?['text'] as String?) ??
        'Câu hỏi không có nội dung';
  }

  List<Map<String, dynamic>> _extractChoices(
    Map<String, dynamic>? customContent,
    Map<String, dynamic>? linkedQ,
  ) {
    final custom = (customContent?['choices'] ?? customContent?['options']) as List?;
    if (custom != null && custom.isNotEmpty) {
      return custom.cast<Map<String, dynamic>>();
    }
    final linked = (linkedQ?['question_choices'] as List?) ?? [];
    return linked.map((c) {
      final m = c as Map<String, dynamic>;
      return {
        'id': m['id'],
        'text': (m['content'] as Map<String, dynamic>?)?['text'] ?? '',
        'isCorrect': m['is_correct'],
      };
    }).toList();
  }

  String _buildPrompt({
    required String questionText,
    required List<Map<String, dynamic>> choices,
    required List<Map<String, dynamic>> selectedChoices,
    required bool isCorrect,
    required double finalScore,
    required double maxPoints,
    required List<String> tags,
  }) {
    final tagLine = tags.isNotEmpty ? 'Chủ đề: ${tags.join(", ")}.' : '';
    final choicesText = choices.map((c) {
      final correct = c['isCorrect'] == true || c['is_correct'] == true;
      return '[${correct ? "ĐÚNG" : "SAI"}] ${c['text']}';
    }).join('\n');
    final selectedText = selectedChoices.isNotEmpty
        ? selectedChoices.map((c) => c['text']).join(', ')
        : 'Không chọn gì';

    return '''Bạn là giáo viên AI đang đánh giá bài làm học sinh. Phân tích câu trả lời này và trả về JSON.

CÂU HỎI: $questionText
$tagLine

CÁC LỰA CHỌN:
$choicesText

HỌC SINH ĐÃ CHỌN: $selectedText
KẾT QUẢ: ${isCorrect ? "ĐÚNG ✓" : "SAI ✗"} ($finalScore/$maxPoints điểm)

Trả về JSON (không markdown, không giải thích thêm):
{
  "summary": "<1 câu kết luận: học sinh đúng/sai vì lý do cốt lõi>",
  "explanation": "<2-3 câu giải thích tại sao đáp án đúng là đúng>",
  "misconception": "<Nếu sai: lý do nhầm. Nếu đúng: chuỗi rỗng>",
  "tip": "<1 câu gợi ý học tập cụ thể>",
  "encouragement": "<1 câu động viên>"
}''';
  }

  Map<String, dynamic> _parseFeedbackJson(String raw, bool isCorrect) {
    final provider = 'local'; // sẽ được ghi đè sau khi biết provider thực
    final base = <String, dynamic>{
      'status': 'completed',
      'provider': provider,
      'model': 'ollama/groq-fallback',
      'is_correct': isCorrect,
      'summary': '',
      'explanation': '',
      'misconception': '',
      'tip': '',
      'encouragement': '',
    };

    try {
      final cleaned = raw
          .replaceAll(RegExp(r'```json\s*', caseSensitive: false), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();
      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
      return {...base, ...parsed};
    } catch (_) {
      AppLogger.warning('[TeacherAI] Could not parse JSON, storing raw as summary');
      return {...base, 'summary': raw.substring(0, raw.length.clamp(0, 800))};
    }
  }

  Future<void> _markCompleted(String itemId) async {
    await _supabase.from('ai_queue').update({
      'status': 'completed',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', itemId);
  }

  Future<void> _maybeMarkSessionGraded(String sessionId) async {
    final answers = await _supabase
        .from('submission_answers')
        .select('id')
        .eq('session_id', sessionId);
    if (answers.isEmpty) return;

    final answerIds = answers.map((a) => a['id'] as String).toList();
    final stillPending = await _supabase
        .from('ai_queue')
        .select('id')
        .inFilter('submission_answer_id', answerIds)
        .eq('request_type', 'feedback')
        .inFilter('status', ['pending', 'processing']);

    if (stillPending.isEmpty) {
      await _supabase
          .from('work_sessions')
          .update({'status': 'graded', 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', sessionId)
          .eq('status', 'ai_processing');
      AppLogger.info('[TeacherAI] Session $sessionId → graded');
    }
  }
}
