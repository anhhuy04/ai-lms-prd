import 'dart:convert';

import 'package:ai_mls/core/services/ai_service.dart';
import 'package:ai_mls/core/services/template_similarity_verifier.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/error_translation_utils.dart';
import 'package:ai_mls/data/datasources/ai_datasource.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/domain/entities/template_mode.dart';
import 'package:ai_mls/domain/repositories/ai_repository.dart';

/// Implementation của AiRepository
///
/// Mapping từ AI Response → Database:
/// - AI Response: {content: {text, images, latex}, choices: [{id, content: {text, image}, is_correct}], ...}
/// - Database questions: content jsonb = {text, images, latex}
/// - Database question_choices: id (0..n), content jsonb = {text, image}, is_correct
/// - Database question_objectives: objective_id (UUID) - cần lookup từ learning_objectives.description
/// - Database assignment_questions.rubric: {criteria: [{name, max_points, description}], total_points}
class AiRepositoryImpl implements AiRepository {
  final AiDataSource _dataSource;

  AiRepositoryImpl(this._dataSource);

  @override
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
  }) async {
    // Resolve sub-mode: caller cũ chỉ truyền boolean → coi là styleOnly (an toàn).
    final TemplateMode? resolvedTemplateMode = useAsStyleTemplate
        ? (templateMode ?? TemplateMode.styleOnly)
        : null;
    AppLogger.info(
      '🔧 [AI REPO] generateQuestions: qty=$quantity type=$questionType '
      'useTemplate=$useAsStyleTemplate resolvedMode=${resolvedTemplateMode?.name ?? "null"} '
      'templateQCount=${templateQuestions?.length ?? 0}',
    );

    try {
      const int maxBatchSize = 10;

      if (quantity <= maxBatchSize) {
        final response = await _dataSource.generateQuestions(
          topic: topic,
          quantity: quantity,
          difficulty: difficulty,
          questionType: questionType,
          documentContext: documentContext,
          useAsStyleTemplate: useAsStyleTemplate,
          templateMode: resolvedTemplateMode,
          templateCount: templateCount,
        );

        try {
          final rawJson = response is String ? response : jsonEncode(response);
          onRawResponse?.call(rawJson);
        } catch (_) {}

        var questions = _parseAiResponse(response, quantity);
        questions = await _applyTemplateVerification(
          generated: questions,
          topic: topic,
          difficulty: difficulty,
          questionType: questionType,
          documentContext: documentContext,
          useAsStyleTemplate: useAsStyleTemplate,
          templateMode: resolvedTemplateMode,
          templateQuestions: templateQuestions,
          templateCount: templateCount,
          onRawResponse: onRawResponse,
        );
        questions = await _applyDomainFilterAndRefill(
          generated: questions,
          topic: topic,
          quantity: quantity,
          difficulty: difficulty,
          questionType: questionType,
          documentContext: documentContext,
          useAsStyleTemplate: useAsStyleTemplate,
          templateMode: resolvedTemplateMode,
          templateQuestions: templateQuestions,
          templateCount: templateCount,
          onRawResponse: onRawResponse,
        );
        AppLogger.info('✅ [AI REPO] Generated ${questions.length} questions');
        return await _maybeApplyHighAccuracyCritique(
          questions: questions,
          topic: topic,
          enabled: highAccuracyMode,
        );
      }

      final all = <Map<String, dynamic>>[];
      int remaining = quantity;
      int batchIndex = 0;

      while (remaining > 0) {
        batchIndex++;
        final batchSize = remaining >= maxBatchSize ? maxBatchSize : remaining;

        // Gọi theo lô
        final response = await _dataSource.generateQuestions(
          topic: topic,
          quantity: batchSize,
          difficulty: difficulty,
          questionType: questionType,
          documentContext: documentContext,
          useAsStyleTemplate: useAsStyleTemplate,
          templateMode: resolvedTemplateMode,
          templateCount: templateCount,
        );

        try {
          final rawJson = response is String ? response : jsonEncode(response);
          onRawResponse?.call(
            '/* batch $batchIndex size=$batchSize */\n$rawJson',
          );
        } catch (_) {}

        // Parse lô hiện tại
        var parsed = _parseAiResponse(response, batchSize);

        // Nếu bị fallback nhiều (text chứa "cần chỉnh sửa"), retry 1 lần với batch nhỏ hơn
        final fallbackCount = parsed
            .where(
              (q) => (q['text'] as String? ?? '').contains('(cần chỉnh sửa)'),
            )
            .length;
        if (fallbackCount >= (batchSize / 2).ceil() && batchSize > 5) {
          AppLogger.warning(
            '⚠️ [AI REPO] Batch $batchIndex seems truncated/fallback. Retrying with smaller batch=5',
          );
          final retryResponse = await _dataSource.generateQuestions(
            topic: topic,
            quantity: 5,
            difficulty: difficulty,
            questionType: questionType,
            documentContext: documentContext,
            useAsStyleTemplate: useAsStyleTemplate,
            templateMode: resolvedTemplateMode,
            templateCount: templateCount,
          );
          try {
            final rawJson = retryResponse is String
                ? retryResponse
                : jsonEncode(retryResponse);
            onRawResponse?.call('/* batch $batchIndex retry size=5 */\n$rawJson');
          } catch (_) {}
          parsed = _parseAiResponse(retryResponse, 5);
        }

        all.addAll(parsed);
        // Dùng actual parsed count (retry có thể trả ít hơn batchSize)
        remaining -= parsed.length;
        if (remaining < 0) remaining = 0;
      }

      // Trim nếu vượt quá quantity do retry
      if (all.length > quantity) {
        all.removeRange(quantity, all.length);
      }

      // Verify similarity post-hoc cho toàn bộ batch
      var verified = await _applyTemplateVerification(
        generated: all,
        topic: topic,
        difficulty: difficulty,
        questionType: questionType,
        documentContext: documentContext,
        useAsStyleTemplate: useAsStyleTemplate,
        templateMode: resolvedTemplateMode,
        templateQuestions: templateQuestions,
        templateCount: templateCount,
        onRawResponse: onRawResponse,
      );
      verified = await _applyDomainFilterAndRefill(
        generated: verified,
        topic: topic,
        quantity: quantity,
        difficulty: difficulty,
        questionType: questionType,
        documentContext: documentContext,
        useAsStyleTemplate: useAsStyleTemplate,
        templateMode: resolvedTemplateMode,
        templateQuestions: templateQuestions,
        templateCount: templateCount,
        onRawResponse: onRawResponse,
      );

      AppLogger.info('✅ [AI REPO] Generated ${verified.length} questions (batched)');
      return await _maybeApplyHighAccuracyCritique(
        questions: verified,
        topic: topic,
        enabled: highAccuracyMode,
      );
    } on AiUncertaintyException {
      // PROPAGATE TO UI — don't translate via generic error mapping.
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [AI REPO ERROR] generateQuestions: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorTranslationUtils.translateError(e, 'Tạo câu hỏi bằng AI');
    }
  }

  /// Parse AI response thành format questions chuẩn
  ///
  /// Hỗ trợ nhiều format response khác nhau:
  /// - Format 1: { "questions": [...] }
  /// - Format 2: { "data": [...] }
  /// - Format 3: Direct array [...]
  /// - Format 4: String JSON cần parse
  List<Map<String, dynamic>> _parseAiResponse(
    dynamic response,
    int expectedQuantity,
  ) {
    try {
      List<dynamic>? questionsList;

      // Handle different response formats — wrapper keys phổ biến cho mọi model
      const wrapperKeys = [
        'questions',
        'data',
        'results',
        'items',
        'list',
        'output',
      ];

      List<dynamic>? findListInMap(Map<String, dynamic> m) {
        for (final k in wrapperKeys) {
          final v = m[k];
          if (v is List<dynamic>) return v;
        }
        return null;
      }

      if (response is Map<String, dynamic>) {
        _checkAiErrorResponse(response);
        questionsList = findListInMap(response);
      } else if (response is List) {
        questionsList = response;
      } else if (response is String) {
        final parsed = _tryParseJson(response);
        if (parsed is Map<String, dynamic>) {
          _checkAiErrorResponse(parsed);
          questionsList = findListInMap(parsed);
        } else if (parsed is List) {
          questionsList = parsed;
        }
      }

      if (questionsList == null || questionsList.isEmpty) {
        final rawStr = response is String
            ? response
            : response?.toString() ?? '';
        AppLogger.warning(
          '⚠️ [AI REPO] No questions found. Đã thử wrapper keys: '
          '${wrapperKeys.join(", ")}. Raw response (500 chars):\n'
          '${rawStr.substring(0, rawStr.length.clamp(0, 500))}',
        );
        return _generateFallbackQuestions(expectedQuantity);
      }

      // Convert to question format — track skip reason để debug
      final questions = <Map<String, dynamic>>[];
      int skippedNonMap = 0;
      int skippedEmptyText = 0;
      for (var i = 0; i < questionsList.length && i < expectedQuantity; i++) {
        final q = questionsList[i];
        if (q is Map<String, dynamic>) {
          final mapped = _mapAiQuestionToStandardFormat(q, i + 1);
          if (mapped != null) {
            questions.add(mapped);
          } else {
            skippedEmptyText++;
          }
        } else {
          skippedNonMap++;
          AppLogger.warning(
            '[AI REPO] Question ${i + 1}: format không phải Map '
            '(${q.runtimeType}), bỏ qua. Raw: ${q.toString().substring(0, q.toString().length.clamp(0, 100))}',
          );
        }
      }

      if (questions.isEmpty) {
        AppLogger.warning(
          '🔴 [AI REPO] Không parse được câu hỏi nào từ ${questionsList.length} '
          'phần tử (skipped: $skippedNonMap non-Map, $skippedEmptyText empty-text). '
          'Schema có thể khác — kiểm tra _mapAiQuestionToStandardFormat.',
        );
        return _generateFallbackQuestions(expectedQuantity);
      }

      if (questions.length < expectedQuantity) {
        AppLogger.info(
          '⚠️ [AI REPO] Parse được ${questions.length}/$expectedQuantity câu '
          '(skipped: $skippedNonMap non-Map, $skippedEmptyText empty-text).',
        );
      }

      return questions;
    } on AiUncertaintyException {
      // Don't swallow into fallback — let UI handle uncertainty error.
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [AI REPO] Error parsing response: $e',
        error: e,
        stackTrace: stackTrace,
      );
      // Fallback: tạo questions mẫu
      return _generateFallbackQuestions(expectedQuantity);
    }
  }

  /// Detect AI uncertainty error response — AI trả `{error, message}` thay vì array.
  /// Throws `AiUncertaintyException` để UI hiển thị reason cho user.
  void _checkAiErrorResponse(Map<String, dynamic> decoded) {
    if (!decoded.containsKey('error')) return;
    // Skip if it looks like a wrapped envelope `{error: {message: ...}}` from API errors.
    final errVal = decoded['error'];
    final code = errVal is String
        ? errVal
        : (errVal is Map<String, dynamic>
            ? (errVal['code']?.toString() ?? errVal['type']?.toString() ?? 'unknown')
            : 'unknown');
    // Only treat as uncertainty if code matches one of allowed AI codes
    const allowedCodes = {
      'missing_subject',
      'ambiguous_schema',
      'insufficient_context',
    };
    if (!allowedCodes.contains(code)) return;
    final message = decoded['message']?.toString()
        ?? 'AI không thể tạo câu hỏi với thông tin hiện tại.';
    AppLogger.warning('[AI] Uncertainty error: $code — $message');
    throw AiUncertaintyException(message, code: code);
  }

  /// Map AI question response sang format chuẩn của app
  ///
  /// Format từ AI:
  /// - content: {text, images, latex}
  /// - choices: [{id, content: {text, image}, is_correct}]
  /// - answer: {text, correct_choices, explanation}
  /// - learning_objectives: [{description, subject_code, code}]
  /// - grading_rubric: {criteria: [{name, max_points, description}], total_points}
  Map<String, dynamic>? _mapAiQuestionToStandardFormat(
    Map<String, dynamic> aiQuestion,
    int index,
  ) {
    // Extract type
    final typeStr = (aiQuestion['type'] as String? ?? 'multiple_choice')
        .toLowerCase()
        .replaceAll(' ', '_');
    final questionType = _parseQuestionType(typeStr);

    // Extract question text — try nhiều key variants để tolerate mọi model.
    // Priority: override_text → content.text → text → question → prompt → body → statement.
    Map<String, dynamic> content;
    final overrideText = aiQuestion['override_text'] as String?;
    if (overrideText != null && overrideText.trim().isNotEmpty) {
      content = {'text': overrideText.trim(), 'images': []};
    } else if (aiQuestion['content'] is Map<String, dynamic>) {
      final contentObj = aiQuestion['content'] as Map<String, dynamic>;
      final contentText = (contentObj['text'] as String? ?? '').trim();
      if (contentText.isNotEmpty) {
        content = {
          'text': contentText,
          'images': contentObj['images'] as List<dynamic>? ?? [],
          if (contentObj['latex'] != null)
            'latex': contentObj['latex'] as String?,
        };
      } else {
        // content.text rỗng, fall through sang legacy fallback
        final text = _extractQuestionText(aiQuestion) ?? 'Câu hỏi $index';
        content = {'text': text, 'images': []};
      }
    } else {
      final text = _extractQuestionText(aiQuestion) ?? 'Câu hỏi $index';
      content = {'text': text, 'images': []};
    }

    // Extract answer (new format: {text, correct_choices, explanation})
    Map<String, dynamic>? answer;
    if (aiQuestion['answer'] is Map<String, dynamic>) {
      answer = Map<String, dynamic>.from(aiQuestion['answer'] as Map);
    } else {
      // Essay/short_answer: AI outputs expected_answer + ai_grading_keywords at top level
      final expectedAnswer = aiQuestion['expected_answer'] as String?;
      final gradingKeywords = aiQuestion['ai_grading_keywords'] as List<dynamic>?;
      final explanation =
          aiQuestion['explanation'] as String? ??
          aiQuestion['explanation_rich_text'] as String?;
      if (expectedAnswer != null || gradingKeywords != null || explanation != null) {
        answer = {};
        if (expectedAnswer != null) answer['expected_answer'] = expectedAnswer;
        if (gradingKeywords != null) answer['ai_grading_keywords'] = gradingKeywords;
        // Không lưu 'explanation' vào answer ở đây — sẽ được chuẩn hóa thành
        // 'general_explanation' bởi block bên dưới (tránh duplicate key)
      }
    }

    // Extract explanation cho MỌI loại câu hỏi (→ general_explanation trong answer)
    final explanationStr =
        aiQuestion['explanation'] as String? ??
        aiQuestion['explanation_rich_text'] as String?;
    if (explanationStr != null && explanationStr.trim().isNotEmpty) {
      answer ??= {};
      // Lưu vào general_explanation theo Data Contract (tách khỏi content để tránh data leakage)
      answer['general_explanation'] = explanationStr.trim();
    }

    // Parse fill_blank: blanks → answer
    if (questionType == QuestionType.fillBlank) {
      final blanks = aiQuestion['blanks'] as List<dynamic>?;
      if (blanks != null) {
        answer ??= {};
        answer['blanks'] = blanks;
      }
    }

    // Parse choices cho multiple choice / true_false.
    // Hỗ trợ NHIỀU schema khác nhau từ các model:
    // - Gemini: `options: [{label, content, correct}]`
    // - Groq:   `choices: [{id, text, isCorrect}]`
    // - OpenRouter free: thường giống Groq nhưng có model trả `answers: [...]`
    // - Plain string list: `["choice 1", "choice 2", ...]` + `correct_answer: "A"`
    List<Map<String, dynamic>>? choices;
    if (questionType == QuestionType.multipleChoice ||
        questionType == QuestionType.trueFalse) {
      final choicesList = aiQuestion['choices'] as List<dynamic>? ??
          aiQuestion['options'] as List<dynamic>? ??
          aiQuestion['answers'] as List<dynamic>? ??
          aiQuestion['alternatives'] as List<dynamic>?;

      if (choicesList != null) {
        choices = [];
        for (var i = 0; i < choicesList.length; i++) {
          final choice = choicesList[i];
          if (choice is Map<String, dynamic>) {
            final choiceId = choice['id'] as int? ?? i;
            final choiceContent = choice['content'] as Map<String, dynamic>?;

            // Text key fallback: content.text → text → label → value → option
            String text = '';
            if (choiceContent != null) {
              text = (choiceContent['text'] as String? ?? '').trim();
            }
            if (text.isEmpty) {
              text = ((choice['text'] as String?) ??
                      (choice['label'] as String?) ??
                      (choice['value'] as String?) ??
                      (choice['option'] as String?) ??
                      (choice['content'] is String
                          ? choice['content'] as String
                          : null) ??
                      '')
                  .trim();
            }

            // Correct flag fallback: is_correct → isCorrect → correct → correctAnswer
            final isCorrect = (choice['is_correct'] as bool?) ??
                (choice['isCorrect'] as bool?) ??
                (choice['correct'] as bool?) ??
                (choice['correctAnswer'] as bool?) ??
                false;

            choices.add({
              'id': choiceId,
              'content': {
                'text': text,
                if (choiceContent?['image'] != null)
                  'image': choiceContent!['image'] as String?,
              },
              'is_correct': isCorrect,
            });
          } else if (choice is String) {
            // Plain string list — không có field is_correct, sẽ derive từ
            // `correct_answer` ở top-level sau.
            choices.add({
              'id': i,
              'content': {'text': choice.trim()},
              'is_correct': false,
            });
          }
        }

        // Derive is_correct từ top-level `correct_answer` / `answer` letter
        // ("A"/"B"/"C"/"D") hoặc index (0/1/2/3). Áp dụng khi NO choice có
        // is_correct=true (vd plain string list trên).
        final hasAnyCorrect =
            choices.any((c) => (c['is_correct'] as bool?) == true);
        if (!hasAnyCorrect) {
          final rawCorrect = aiQuestion['correct_answer'] ??
              aiQuestion['correctAnswer'] ??
              aiQuestion['answer_letter'] ??
              (aiQuestion['answer'] is String ? aiQuestion['answer'] : null);
          int? correctIndex;
          if (rawCorrect is num) {
            correctIndex = rawCorrect.toInt();
          } else if (rawCorrect is String) {
            final letter = rawCorrect.trim().toUpperCase();
            if (letter.length == 1 &&
                letter.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
                letter.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) {
              correctIndex = letter.codeUnitAt(0) - 'A'.codeUnitAt(0);
            } else if (int.tryParse(letter) != null) {
              correctIndex = int.parse(letter);
            }
          }
          if (correctIndex != null &&
              correctIndex >= 0 &&
              correctIndex < choices.length) {
            choices[correctIndex]['is_correct'] = true;
            AppLogger.info(
              '🔧 [AI REPO] Question $index: derived is_correct từ '
              'correct_answer="$rawCorrect" → index=$correctIndex.',
            );
          }
        }
      }
    }

    // Extract other fields
    final difficulty = aiQuestion['difficulty'] as int?;
    final tags =
        (aiQuestion['tags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // Extract learning_objectives (new format: [{description, subject_code, code}])
    List<Map<String, dynamic>>? learningObjectives;
    final objectivesList =
        aiQuestion['learning_objectives'] as List<dynamic>? ??
        aiQuestion['learningObjectives']
            as List<dynamic>?; // Backward compatibility

    if (objectivesList != null) {
      learningObjectives = objectivesList.map((obj) {
        if (obj is Map<String, dynamic>) {
          // New format: object with description, subject_code, code
          return {
            'description': obj['description'] as String? ?? '',
            'subject_code': obj['subject_code'] as String?,
            'code': obj['code'] as String?,
          };
        } else {
          // Legacy format: string description
          return {
            'description': obj.toString(),
            'subject_code': null,
            'code': null,
          };
        }
      }).toList();
    }

    final hints = (aiQuestion['hints'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList();

    // Note: grading_rubric không cần thiết vì giáo viên sẽ tự tạo ở UI sau
    // Không parse grading_rubric từ AI response - giáo viên sẽ tự tạo khi lưu vào assignment

    // VALIDATION: question text không được rỗng — bỏ qua thay vì dùng placeholder
    final contentText = content['text'] as String? ?? '';
    if (contentText.trim().isEmpty) {
      AppLogger.warning('⚠️ [AI REPO] Question $index: content.text rỗng, bỏ qua.');
      return null;
    }

    // VALIDATION STEP 1: Dedup + count fix phải chạy TRƯỚC correct-count check
    if (choices != null &&
        (questionType == QuestionType.multipleChoice ||
            questionType == QuestionType.trueFalse)) {
      // 1a. Dedup theo text (giữ thứ tự, bỏ trùng)
      final seenTexts = <String>{};
      choices = choices.where((c) {
        final t = ((c['content'] as Map?)?['text'] as String? ?? '').trim();
        return seenTexts.add(t);
      }).toList();

      // 1b. Trim true_false xuống còn 2
      if (questionType == QuestionType.trueFalse && choices.length > 2) {
        AppLogger.warning(
          '⚠️ [AI REPO] Question $index: true_false có ${choices.length} choices. Trim → 2.',
        );
        // Giữ choice correct nếu có, sau đó fill tới 2
        final correct = choices.where((c) => c['is_correct'] == true).toList();
        final wrong = choices.where((c) => c['is_correct'] != true).toList();
        final kept = [...correct, ...wrong];
        choices = kept.sublist(0, 2);
      }

      // 1c. Pad MCQ lên 4 nếu thiếu
      if (questionType == QuestionType.multipleChoice && choices.length < 4) {
        AppLogger.warning(
          '⚠️ [AI REPO] Question $index: MCQ có ${choices.length} choices. Thêm dummy → 4.',
        );
        while (choices.length < 4) {
          choices.add({
            'id': choices.length,
            'content': {'text': 'Không có đáp án nào phù hợp'},
            'is_correct': false,
          });
        }
      }
    }

    // VALIDATION STEP 2: Đảm bảo đáp án trắc nghiệm chính xác 100%
    if ((questionType == QuestionType.multipleChoice ||
            questionType == QuestionType.trueFalse) &&
        choices != null &&
        choices.isNotEmpty) {
      // Đếm số đáp án đúng
      final correctCount = choices.where((c) {
        return c['is_correct'] as bool? ?? false;
      }).length;

      if (correctCount == 0) {
        AppLogger.warning(
          '⚠️ [AI REPO] Question $index: Không có đáp án đúng nào! '
          'Tự động set choice đầu tiên làm đáp án đúng.',
        );
        choices[0]['is_correct'] = true;
      } else if (correctCount > 1) {
        AppLogger.warning(
          '⚠️ [AI REPO] Question $index: Có $correctCount đáp án đúng '
          '(chỉ được phép 1). Giữ lại đáp án đúng đầu tiên.',
        );
        var foundFirst = false;
        for (var i = 0; i < choices.length; i++) {
          if (choices[i]['is_correct'] as bool? ?? false) {
            if (foundFirst) {
              choices[i]['is_correct'] = false;
            } else {
              foundFirst = true;
            }
          }
        }
      }

      // Validate answer.correct_choices khớp với choices[].is_correct
      if (answer != null) {
        final correctChoices = answer['correct_choices'] as List<dynamic>?;
        if (correctChoices != null) {
          final actualCorrectIndex = choices.indexWhere(
            (c) => c['is_correct'] as bool? ?? false,
          );
          if (actualCorrectIndex >= 0) {
            final expectedIndex = correctChoices.isNotEmpty
                ? (correctChoices[0] as num?)?.toInt()
                : null;
            if (expectedIndex != actualCorrectIndex) {
              AppLogger.warning(
                '⚠️ [AI REPO] Question $index: answer.correct_choices ($expectedIndex) '
                'không khớp với choices[].is_correct (index $actualCorrectIndex). '
                'Tự động sửa answer.correct_choices.',
              );
              answer['correct_choices'] = [actualCorrectIndex];
            }
          }
        } else {
          final correctIndex = choices.indexWhere(
            (c) => c['is_correct'] as bool? ?? false,
          );
          if (correctIndex >= 0) {
            answer['correct_choices'] = [correctIndex];
          }
        }
      }
    }

    // Build result map với format chuẩn cho app
    return {
      'type': questionType,
      'content': content, // {text, images, latex}
      if (answer != null) 'answer': answer,
      if (choices != null && choices.isNotEmpty) 'choices': choices,
      if (difficulty != null) 'difficulty': difficulty,
      if (tags.isNotEmpty) 'tags': tags,
      if (learningObjectives != null && learningObjectives.isNotEmpty)
        'learningObjectives': learningObjectives,
      if (hints != null && hints.isNotEmpty) 'hints': hints,
      // Expose explanation ở top-level để UI screen dễ đọc
      if (explanationStr != null && explanationStr.trim().isNotEmpty)
        'explanation': explanationStr.trim(),
      // Note: grading_rubric không cần thiết vì giáo viên sẽ tự tạo ở UI
      // if (gradingRubric != null) 'grading_rubric': gradingRubric,
      // Backward compatibility: also include 'text' for legacy code
      'text': content['text'] as String? ?? '',
      // Backward compatibility: also include 'options' for legacy code
      if (choices != null && choices.isNotEmpty)
        'options': choices.map((c) {
          final content = c['content'];
          return {
            'text': (content is Map<String, dynamic>)
                ? (content['text'] as String? ?? '')
                : '',
            'isCorrect': c['is_correct'] as bool? ?? false,
          };
        }).toList(),
    };
  }

  /// Extract question text từ AI response — try nhiều key variants.
  /// Trả `null` nếu không tìm thấy field nào có text non-empty.
  /// Các key thử (theo thứ tự ưu tiên): text → question → prompt → body →
  /// statement → query → content (nếu là String).
  String? _extractQuestionText(Map<String, dynamic> q) {
    const candidates = [
      'text',
      'question',
      'question_text',
      'questionText',
      'prompt',
      'body',
      'statement',
      'query',
      'q',
    ];
    for (final key in candidates) {
      final v = q[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    // content có thể là String (legacy format)
    final content = q['content'];
    if (content is String && content.trim().isNotEmpty) return content.trim();
    return null;
  }

  /// Parse question type từ string
  QuestionType _parseQuestionType(String typeStr) {
    switch (typeStr) {
      case 'multiple_choice':
      case 'multiplechoice':
      case 'mcq':
        return QuestionType.multipleChoice;
      case 'true_false':
      case 'truefalse':
      case 'boolean':
        return QuestionType.trueFalse;
      case 'short_answer':
      case 'shortanswer':
        return QuestionType.shortAnswer;
      case 'essay':
        return QuestionType.essay;
      case 'fill_blank':
      case 'fill_in_blank':
      case 'fillblank':
        return QuestionType.fillBlank;
      case 'matching':
        return QuestionType.matching;
      case 'math':
      case 'mathematics':
        return QuestionType.math;
      case 'problem_solving':
      case 'problemsolving':
        return QuestionType.problemSolving;
      case 'file_upload':
      case 'fileupload':
        return QuestionType.fileUpload;
      default:
        return QuestionType.multipleChoice;
    }
  }

  /// Try parse JSON từ AI response — robust với nhiều dạng malformed.
  ///
  /// Mỗi AI model (Gemini / Groq / OpenRouter free models) có quirks khác
  /// nhau khi gen JSON. Parser phải tolerate:
  /// - Markdown code fences (```json ... ```)
  /// - `<think>...</think>` blocks (DeepSeek-R1, QwQ reasoning models)
  /// - Smart quotes "" '' từ AI tự "sửa" content
  /// - Trailing commas `,}` `,]` (AI hay add)
  /// - LaTeX backslash chưa escape `\frac` (_sanitizeLatexInJson)
  /// - Unbalanced brackets (truncate giữa output)
  /// - Plain text noise trước/sau JSON
  ///
  /// Strategy: thử nhiều variant lần lượt, trả null nếu tất cả fail.
  /// Khi fail, log raw 300 chars đầu để debug.
  dynamic _tryParseJson(String jsonString) {
    String s = _preCleanResponse(jsonString);
    if (s.isEmpty) return null;

    // Mảng các transformer thử áp dụng tăng dần. Mỗi step return string
    // mới, sau đó thử jsonDecode. Stop khi decode success.
    final attempts = <String Function(String)>[
      (x) => x, // 1. raw
      _sanitizeLatexInJson, // 2. fix LaTeX backslash
      _removeTrailingCommas, // 3. fix `,}` `,]`
      (x) => _removeTrailingCommas(_sanitizeLatexInJson(x)), // 4. combo
      _autoCloseBrackets, // 5. fix unbalanced
      (x) => _autoCloseBrackets(
            _removeTrailingCommas(_sanitizeLatexInJson(x)),
          ), // 6. combo all
    ];

    for (final fn in attempts) {
      try {
        return jsonDecode(fn(s));
      } catch (_) {
        // try next
      }
    }

    // Fallback: extract first JSON object/array substring from noisy text
    final candidate = _extractJsonSubstring(s);
    if (candidate == null) {
      _logParseFailure(s);
      return null;
    }
    for (final fn in attempts) {
      try {
        return jsonDecode(fn(candidate));
      } catch (_) {
        // try next
      }
    }

    _logParseFailure(s);
    return null;
  }

  /// Tiền xử lý response: strip thinking blocks, code fences, BOM, smart quotes.
  String _preCleanResponse(String input) {
    String s = input.trim();
    if (s.isEmpty) return s;

    // Strip BOM, zero-width chars, NBSP — vô hình mà gây jsonDecode fail.
    s = s.replaceAll('﻿', '').replaceAll('​', '').replaceAll(' ', ' ');

    // Strip <think>...</think> (DeepSeek-R1, QwQ, Claude reasoning models)
    s = s
        .replaceAll(
          RegExp(r'<think>[\s\S]*?</think>', caseSensitive: false),
          '',
        )
        .trim();

    // Strip markdown code fences ```json ... ``` (multi-fence tolerant)
    // Lấy phần inner của fence dài nhất nếu có nhiều.
    final fences = RegExp(r'```(?:json|JSON)?\s*([\s\S]*?)\s*```')
        .allMatches(s)
        .toList();
    if (fences.isNotEmpty) {
      final longest = fences.reduce(
        (a, b) =>
            (a.group(1)?.length ?? 0) >= (b.group(1)?.length ?? 0) ? a : b,
      );
      s = (longest.group(1) ?? '').trim();
    }

    // Smart quotes (curly) → ASCII straight — AI sometimes inserts these
    // trong content "tự nhiên" rồi parser thấy chuỗi không khép kín.
    s = s
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('‘', "'")
        .replaceAll('’', "'");

    return s.trim();
  }

  /// Remove trailing commas — AI thường thêm `,` cuối phần tử cuối:
  /// `[1, 2, 3,]` `{"a":1,}` → fix thành `[1,2,3]` `{"a":1}`.
  String _removeTrailingCommas(String input) {
    return input.replaceAll(RegExp(r',(\s*[}\]])'), r'$1');
  }

  /// Auto-close unbalanced brackets — AI thỉnh thoảng truncate response
  /// giữa chừng (vd reach max_tokens). Dùng stack để track nesting và
  /// close theo thứ tự ĐÚNG (innermost first).
  ///
  /// VD `[{"options":[{"a":1` → close `}]}]` (reverse stack: `{`, `[`, `{`, `[`).
  ///
  /// Best-effort: không guarantee semantic đúng nhưng giúp jsonDecode parse
  /// được phần đầu, các phần tử bị truncate sau sẽ thiếu nhưng còn parse được.
  String _autoCloseBrackets(String input) {
    final stack = <String>[];
    bool inString = false;
    bool escape = false;
    for (final c in input.runes) {
      final ch = String.fromCharCode(c);
      if (escape) {
        escape = false;
        continue;
      }
      if (ch == r'\') {
        escape = true;
        continue;
      }
      if (ch == '"') {
        inString = !inString;
        continue;
      }
      if (inString) continue;
      if (ch == '{' || ch == '[') {
        stack.add(ch);
      } else if (ch == '}') {
        if (stack.isNotEmpty && stack.last == '{') stack.removeLast();
      } else if (ch == ']') {
        if (stack.isNotEmpty && stack.last == '[') stack.removeLast();
      }
    }
    // Nếu chuỗi đang dở dang giữa 1 string (chưa close ") → append `"`
    // trước. Phần content bị cắt sẽ là literal string không hoàn chỉnh
    // nhưng JSON parse được.
    final buf = StringBuffer(input);
    if (inString) buf.write('"');
    // Close brackets theo reverse stack.
    for (int i = stack.length - 1; i >= 0; i--) {
      buf.write(stack[i] == '{' ? '}' : ']');
    }
    return buf.toString();
  }

  /// Extract substring từ first `{` or `[` đến last `}` or `]`.
  String? _extractJsonSubstring(String s) {
    final firstObj = s.indexOf('{');
    final firstArr = s.indexOf('[');
    int start = -1;
    if (firstObj == -1 && firstArr == -1) return null;
    if (firstObj == -1) {
      start = firstArr;
    } else if (firstArr == -1) {
      start = firstObj;
    } else {
      start = firstObj < firstArr ? firstObj : firstArr;
    }

    final lastObj = s.lastIndexOf('}');
    final lastArr = s.lastIndexOf(']');
    int end = -1;
    if (lastObj == -1 && lastArr == -1) return null;
    if (lastObj == -1) {
      end = lastArr;
    } else if (lastArr == -1) {
      end = lastObj;
    } else {
      end = lastObj > lastArr ? lastObj : lastArr;
    }

    if (start < 0 || end <= start) return null;
    return s.substring(start, end + 1).trim();
  }

  void _logParseFailure(String s) {
    final preview = s.length > 300 ? '${s.substring(0, 300)}...' : s;
    AppLogger.warning(
      '🔴 [AI REPO] _tryParseJson: tất cả attempts thất bại. '
      'Raw response preview (300 chars):\n$preview',
    );
  }

  /// Escape backslash trong JSON string không phải escape JSON hợp lệ.
  /// AI generators (Groq llama, Gemini) thường trả LaTeX trong JSON string
  /// KHÔNG escape backslash → `jsonDecode` xử lý sai.
  ///
  /// Hai trường hợp cần xử lý:
  /// 1. LaTeX command 2+ chữ cái (`\frac`, `\beta`, `\theta`, `\nabla`,
  ///    `\sqrt`, `\sum`, `\Delta`, `\to`, `\rho`...) — escape vì:
  ///    - `\f`, `\b`, `\n`, `\r`, `\t` LÀ valid JSON escape (form-feed,
  ///      backspace, newline, CR, tab) → `jsonDecode` sẽ ăn ký tự đó và
  ///      mất chữ cái kế tiếp. VD `\frac` → `<FF>rac` → render literal đỏ.
  ///    - Cần escape cho dù chữ cái sau backslash nằm trong whitelist JSON.
  /// 2. Ký tự đặc biệt LaTeX 1-char (`\,`, `\;`, `\!`, `\#`, `\$`, `\|`...):
  ///    - Không phải JSON escape hợp lệ → `jsonDecode` throw ngay.
  ///    - Escape thành `\\,` để pass decode, render OK.
  ///
  /// JSON valid escapes giữ nguyên: `\"` `\\` `\/` `\u` và single `\b` `\f`
  /// `\n` `\r` `\t` không theo sau letter (control chars hợp lệ).
  String _sanitizeLatexInJson(String input) {
    return input.replaceAllMapped(
      // Match 1: \\ followed by 2+ letters (LaTeX command like \frac, \beta)
      // Match 2: \\ followed by char NOT in JSON escape whitelist (\, \; \!)
      RegExp(r'\\(?=[a-zA-Z]{2,}|[^"\\/bfnrtu])'),
      (_) => r'\\',
    );
  }

  /// Generate fallback questions khi AI API không trả về đúng format
  List<Map<String, dynamic>> _generateFallbackQuestions(int quantity) {
    return List.generate(quantity, (index) {
      return {
        'type': QuestionType.multipleChoice,
        'text': 'Câu hỏi ${index + 1} (cần chỉnh sửa)',
        'options': [
          {'text': 'Lựa chọn A (cần chỉnh sửa)', 'isCorrect': true},
          {'text': 'Lựa chọn B', 'isCorrect': false},
          {'text': 'Lựa chọn C', 'isCorrect': false},
          {'text': 'Lựa chọn D', 'isCorrect': false},
        ],
      };
    });
  }

  /// Hậu kiểm similarity post-hoc + retry cho câu vượt threshold.
  ///
  /// Skip nếu không phải template flow hoặc templateQuestions rỗng.
  /// Hoạt động hoàn toàn trên CPU (không gọi API thêm cho check), nhưng
  /// nếu có câu vượt regenerate threshold sẽ gọi 1 batch retry duy nhất
  /// (budget=1) để tránh tăng cost không kiểm soát.
  Future<List<Map<String, dynamic>>> _applyTemplateVerification({
    required List<Map<String, dynamic>> generated,
    required String topic,
    required int? difficulty,
    required String? questionType,
    required String? documentContext,
    required bool useAsStyleTemplate,
    required TemplateMode? templateMode,
    required List<Map<String, dynamic>>? templateQuestions,
    required int? templateCount,
    required void Function(String rawJson)? onRawResponse,
  }) async {
    // Skip nếu không phải template flow
    if (!useAsStyleTemplate ||
        templateQuestions == null ||
        templateQuestions.isEmpty ||
        generated.isEmpty) {
      return generated;
    }

    // F-017: nới threshold khi templateCount thấp (≤3) hoặc mode sameForm.
    // Lý do: 1-3 mẫu → AI buộc clone cấu trúc (score 0.93+), giáo viên CHỦ ĐÍCH
    // muốn vậy. Threshold mặc định (drop=0.88) sẽ drop sạch → 0 câu render.
    // styleOnly với nhiều mẫu (≥4) vẫn giữ strict để chống regurgitate.
    final isLowTemplate = templateQuestions.length <= 3;
    final isStructuralIntent =
        isLowTemplate || templateMode == TemplateMode.sameForm;
    final verifier = isStructuralIntent
        ? TemplateSimilarityVerifier(
            warnThreshold: 0.70,
            regenerateThreshold: 0.92,
            dropThreshold: 0.985,
          )
        : TemplateSimilarityVerifier();
    AppLogger.info(
      '🔍 [Similarity] templates=${templateQuestions.length} mode=${templateMode?.name} '
      '→ ${isStructuralIntent ? "LOOSE (warn=0.70 regen=0.92 drop=0.985)" : "STRICT (default)"}',
    );
    final results = verifier.verifyAgainstTemplate(
      generated: generated,
      templateQuestions: templateQuestions,
    );

    final dropIdx = <int>{};
    final regenIdx = <int>[];
    for (final r in results) {
      switch (r.action) {
        case SimilarityAction.drop:
          dropIdx.add(r.questionIndex);
          break;
        case SimilarityAction.regenerate:
          regenIdx.add(r.questionIndex);
          break;
        case SimilarityAction.warn:
          // Gắn cờ vào câu để UI render badge — không block
          generated[r.questionIndex]['_similarityWarning'] = {
            'score': r.maxScore,
            'matchedTemplateIdx': r.matchedTemplateIdx,
          };
          break;
        case SimilarityAction.pass:
          break;
      }
    }

    final dropCount = dropIdx.length;
    final regenCount = regenIdx.length;

    if (dropCount == 0 && regenCount == 0) return generated;

    AppLogger.warning(
      '⚠️ [AI REPO] Similarity: drop=$dropCount, regenerate=$regenCount '
      'của ${generated.length} câu. Bắt đầu retry budget=1.',
    );

    // Retry budget = 1: gọi 1 lần duy nhất với prompt mạnh hơn
    final needRetry = dropCount + regenCount;
    List<Map<String, dynamic>> replacements = [];
    if (needRetry > 0) {
      try {
        final retryResponse = await _dataSource.generateQuestions(
          topic: topic.isEmpty ? 'Câu hỏi từ tài liệu' : topic,
          quantity: needRetry,
          difficulty: difficulty,
          questionType: questionType,
          documentContext: documentContext,
          useAsStyleTemplate: useAsStyleTemplate,
          templateMode: templateMode,
          templateCount: templateCount,
        );
        try {
          final rawJson = retryResponse is String
              ? retryResponse
              : jsonEncode(retryResponse);
          onRawResponse?.call('/* similarity-retry size=$needRetry */\n$rawJson');
        } catch (_) {}
        replacements = _parseAiResponse(retryResponse, needRetry);

        // Chạy verify trên replacements để tránh retry câu vẫn giống mẫu
        final retryResults = verifier.verifyAgainstTemplate(
          generated: replacements,
          templateQuestions: templateQuestions,
        );
        // Loại replacements vẫn vi phạm → không thay vào
        for (var i = retryResults.length - 1; i >= 0; i--) {
          final action = retryResults[i].action;
          if (action == SimilarityAction.drop ||
              action == SimilarityAction.regenerate) {
            replacements.removeAt(i);
          } else if (action == SimilarityAction.warn) {
            replacements[i]['_similarityWarning'] = {
              'score': retryResults[i].maxScore,
              'matchedTemplateIdx': retryResults[i].matchedTemplateIdx,
            };
          }
        }
      } catch (e) {
        AppLogger.warning(
          '⚠️ [AI REPO] Similarity retry failed: $e — giữ batch gốc, gắn warn.',
        );
      }
    }

    // Build kết quả: giữ câu pass/warn, thay regen bằng replacements, drop hẳn
    final out = <Map<String, dynamic>>[];
    var replacementCursor = 0;
    for (var i = 0; i < generated.length; i++) {
      if (dropIdx.contains(i)) {
        // Drop: thay bằng replacement nếu còn, nếu hết → bỏ qua
        if (replacementCursor < replacements.length) {
          out.add(replacements[replacementCursor++]);
        }
        continue;
      }
      if (regenIdx.contains(i)) {
        // Regen: thay bằng replacement nếu còn, nếu hết → giữ câu gốc + warn
        if (replacementCursor < replacements.length) {
          out.add(replacements[replacementCursor++]);
        } else {
          generated[i]['_similarityWarning'] = {
            'score': results[i].maxScore,
            'matchedTemplateIdx': results[i].matchedTemplateIdx,
            'note': 'retry_exhausted',
          };
          out.add(generated[i]);
        }
        continue;
      }
      out.add(generated[i]);
    }

    AppLogger.info(
      '✅ [AI REPO] Similarity verify done: out=${out.length} '
      '(drop=$dropCount, regen=$regenCount, replaced=$replacementCursor)',
    );
    return out;
  }

  // ────────────────────────────────────────────────────────────────────────
  // F-014/F-015: Domain filter + auto-refill
  // ────────────────────────────────────────────────────────────────────────

  /// Top-level subject keyword map. Một câu được phân loại vào domain nào
  /// nếu tags hoặc text chứa BẤT KỲ keyword nào của domain đó.
  static const Map<String, List<String>> _domainKeywords = {
    'toán': [
      'toán', 'đại số', 'hình học', 'phương trình', 'số học', 'giải tích',
      'lượng giác', 'cộng', 'trừ', 'nhân', 'chia', 'diện tích', 'chu vi',
      'thể tích', 'tam giác', 'hình tròn', 'hình vuông', 'hình chữ nhật',
    ],
    'lý': [
      'vật lý', 'vận tốc', 'lực', 'gia tốc', 'năng lượng', 'điện', 'từ trường',
      'quang học', 'cơ học', 'newton', 'rơi tự do', 'khối lượng',
    ],
    'hóa': [
      'hóa', 'hoá', 'axit', 'bazơ', 'phản ứng', 'nguyên tố', 'phân tử',
      'hno', 'hcl', 'h2so4', 'naoh', 'h_2so_4', 'hno_3', 'co_2', 'h_2o',
    ],
    'sinh': [
      'sinh học', 'tế bào', 'quang hợp', 'hô hấp', 'động vật', 'thực vật',
      'gen', 'tiến hóa', 'lớp thú', 'lục lạp', 'diệp lục',
    ],
    'văn': [
      'văn học', 'bài thơ', 'truyện', 'tác giả', 'tác phẩm', 'nhân vật',
      'cốt truyện', 'truyện kiều', 'nguyễn du',
    ],
    'sử': [
      'lịch sử', 'triều đại', 'cách mạng', 'đảng cộng sản', 'chiến tranh',
      'hồ chí minh', 'việt minh', 'kháng chiến',
    ],
    'địa': [
      'địa lý', 'thủ đô', 'tỉnh', 'sông', 'núi', 'khí hậu', 'dân số',
      'thành phố', 'quốc gia',
    ],
    'anh': ['tiếng anh', 'english', 'grammar', 'vocabulary'],
    'tin': ['tin học', 'lập trình', 'thuật toán', 'máy tính'],
  };

  /// Phân loại domain của 1 tập câu hỏi từ tags + text.
  /// Trả về tập domain (top-level) mà câu đó thuộc về.
  Set<String> _detectDomains(List<Map<String, dynamic>> questions) {
    final detected = <String>{};
    for (final q in questions) {
      final tags = (q['tags'] as List?)
              ?.map((t) => t.toString().toLowerCase())
              .toList() ??
          const <String>[];
      final text = (_extractQuestionText(q) ?? '').toLowerCase();
      final haystack = '${tags.join(' ')} $text';
      for (final entry in _domainKeywords.entries) {
        for (final kw in entry.value) {
          if (haystack.contains(kw)) {
            detected.add(entry.key);
            break;
          }
        }
      }
    }
    return detected;
  }

  /// Filter câu drift domain + auto-refill nếu thiếu.
  ///
  /// Chỉ chạy khi `useAsStyleTemplate=true` và `templateQuestions` không rỗng.
  /// Mục đích: chống AI sinh câu lệch môn (mẫu Toán → AI sinh Hóa).
  /// Sau filter, nếu count < quantity sẽ gọi AI thêm tối đa 2 lần để bù.
  Future<List<Map<String, dynamic>>> _applyDomainFilterAndRefill({
    required List<Map<String, dynamic>> generated,
    required String topic,
    required int quantity,
    required int? difficulty,
    required String? questionType,
    required String? documentContext,
    required bool useAsStyleTemplate,
    required TemplateMode? templateMode,
    required List<Map<String, dynamic>>? templateQuestions,
    required int? templateCount,
    required void Function(String rawJson)? onRawResponse,
  }) async {
    if (!useAsStyleTemplate ||
        templateQuestions == null ||
        templateQuestions.isEmpty ||
        generated.isEmpty) {
      return generated;
    }

    final templateDomains = _detectDomains(templateQuestions);
    if (templateDomains.isEmpty) {
      AppLogger.info(
        '🧭 [Domain] template không xác định được domain → skip filter',
      );
      return generated;
    }
    AppLogger.info('🧭 [Domain] template domains: $templateDomains');

    final filtered = <Map<String, dynamic>>[];
    for (final q in generated) {
      final qDomains = _detectDomains([q]);
      if (qDomains.isEmpty) {
        filtered.add(q);
        continue;
      }
      if (qDomains.intersection(templateDomains).isNotEmpty) {
        filtered.add(q);
      } else {
        final preview = (_extractQuestionText(q) ?? '').padRight(60).substring(0, 60);
        AppLogger.warning(
          '🧭 [Domain] DROP drift: $qDomains ⊄ $templateDomains | "$preview"',
        );
      }
    }

    final dropped = generated.length - filtered.length;
    AppLogger.info(
      '🧭 [Domain] filter: input=${generated.length} kept=${filtered.length} drop=$dropped',
    );

    // Auto-refill: nếu thiếu, gọi AI thêm tối đa 2 lần
    var result = filtered;
    var attempts = 0;
    const maxAttempts = 2;
    while (result.length < quantity && attempts < maxAttempts) {
      attempts++;
      final missing = quantity - result.length;
      AppLogger.info(
        '🧭 [Domain] auto-refill attempt $attempts: cần thêm $missing câu',
      );
      try {
        final retryResponse = await _dataSource.generateQuestions(
          topic: topic.isEmpty ? 'Câu hỏi từ tài liệu' : topic,
          quantity: missing,
          difficulty: difficulty,
          questionType: questionType,
          documentContext: documentContext,
          useAsStyleTemplate: useAsStyleTemplate,
          templateMode: templateMode,
          templateCount: templateCount,
        );
        try {
          final rawJson = retryResponse is String
              ? retryResponse
              : jsonEncode(retryResponse);
          onRawResponse?.call(
            '/* domain-refill attempt=$attempts size=$missing */\n$rawJson',
          );
        } catch (_) {}
        final parsed = _parseAiResponse(retryResponse, missing);
        final kept = <Map<String, dynamic>>[];
        for (final q in parsed) {
          final qDomains = _detectDomains([q]);
          if (qDomains.isEmpty ||
              qDomains.intersection(templateDomains).isNotEmpty) {
            kept.add(q);
          }
        }
        AppLogger.info(
          '🧭 [Domain] refill $attempts: parsed=${parsed.length} kept=${kept.length}',
        );
        result.addAll(kept);
      } catch (e) {
        AppLogger.warning(
          '🧭 [Domain] refill attempt $attempts FAIL: $e — break loop',
        );
        break;
      }
    }

    if (result.length > quantity) {
      result = result.sublist(0, quantity);
    }
    AppLogger.info('🧭 [Domain] final: ${result.length}/$quantity câu');
    return result;
  }

  /// "Chế độ chính xác cao" — sau khi gen xong, gọi AI lần 2 self-critique.
  ///
  /// Khi `enabled=false` (default): no-op, ZERO change behavior, KHÔNG AI call.
  /// Khi `enabled=true`: gắn `_critique: {pass, reason}` vào từng câu. Critique
  /// tự graceful — nếu fail/throw, [AiService.critiqueQuestions] trả pass-all
  /// nên không bao giờ block flow chính.
  Future<List<Map<String, dynamic>>> _maybeApplyHighAccuracyCritique({
    required List<Map<String, dynamic>> questions,
    required String topic,
    required bool enabled,
  }) async {
    if (!enabled || questions.isEmpty) return questions;
    AppLogger.info(
      '[Repo] high-accuracy on → critique ${questions.length} câu',
    );
    final critiques = await AiService.critiqueQuestions(
      questions,
      topic: topic.isEmpty ? null : topic,
    );
    for (var i = 0; i < questions.length; i++) {
      if (i < critiques.length) {
        questions[i]['_critique'] = critiques[i];
      }
    }
    return questions;
  }
}
