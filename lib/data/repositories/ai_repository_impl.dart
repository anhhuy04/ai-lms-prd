import 'dart:convert';

import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/error_translation_utils.dart';
import 'package:ai_mls/data/datasources/ai_datasource.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
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
    void Function(String rawJson)? onRawResponse,
  }) async {
    try {
      // Quantity lớn (vd: 20/40) dễ bị output cắt cụt -> JSON invalid -> fallback.
      // Giải pháp: chia lô nhỏ và gộp kết quả.
      const int maxBatchSize = 10;

      if (quantity <= maxBatchSize) {
        final response = await _dataSource.generateQuestions(
          topic: topic,
          quantity: quantity,
          difficulty: difficulty,
        );

        try {
          final rawJson = response is String ? response : jsonEncode(response);
          onRawResponse?.call(rawJson);
        } catch (_) {}

        final questions = _parseAiResponse(response, quantity);
        AppLogger.info('✅ [AI REPO] Generated ${questions.length} questions');
        return questions;
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
        remaining -= batchSize;
      }

      // Trim nếu vượt quá quantity do retry
      if (all.length > quantity) {
        all.removeRange(quantity, all.length);
      }

      AppLogger.info('✅ [AI REPO] Generated ${all.length} questions (batched)');
      return all;
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

      // Handle different response formats
      if (response is Map<String, dynamic>) {
        // Try common keys
        questionsList =
            response['questions'] as List<dynamic>? ??
            response['data'] as List<dynamic>? ??
            response['results'] as List<dynamic>?;
      } else if (response is List) {
        questionsList = response;
      } else if (response is String) {
        // Try to parse as JSON string
        final parsed = _tryParseJson(response);
        if (parsed is Map<String, dynamic>) {
          questionsList =
              parsed['questions'] as List<dynamic>? ??
              parsed['data'] as List<dynamic>?;
        } else if (parsed is List) {
          questionsList = parsed;
        }
      }

      if (questionsList == null || questionsList.isEmpty) {
        AppLogger.warning(
          '⚠️ [AI REPO] No questions found in response, using fallback',
        );
        return _generateFallbackQuestions(expectedQuantity);
      }

      // Convert to question format
      final questions = <Map<String, dynamic>>[];
      for (var i = 0; i < questionsList.length && i < expectedQuantity; i++) {
        final q = questionsList[i];
        if (q is Map<String, dynamic>) {
          questions.add(_mapAiQuestionToStandardFormat(q, i + 1));
        } else {
          // Nếu không phải Map, tạo question mặc định
          questions.add({
            'type': QuestionType.multipleChoice,
            'text': 'Câu hỏi ${i + 1} (cần chỉnh sửa)',
            'options': [
              {'text': 'Lựa chọn A', 'isCorrect': false},
              {'text': 'Lựa chọn B', 'isCorrect': false},
              {'text': 'Lựa chọn C', 'isCorrect': false},
              {'text': 'Lựa chọn D', 'isCorrect': false},
            ],
          });
        }
      }

      // Nếu không đủ số lượng, tạo thêm fallback questions
      if (questions.length < expectedQuantity) {
        final remaining = expectedQuantity - questions.length;
        questions.addAll(_generateFallbackQuestions(remaining));
      }

      return questions;
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

  /// Map AI question response sang format chuẩn của app
  ///
  /// Format từ AI:
  /// - content: {text, images, latex}
  /// - choices: [{id, content: {text, image}, is_correct}]
  /// - answer: {text, correct_choices, explanation}
  /// - learning_objectives: [{description, subject_code, code}]
  /// - grading_rubric: {criteria: [{name, max_points, description}], total_points}
  Map<String, dynamic> _mapAiQuestionToStandardFormat(
    Map<String, dynamic> aiQuestion,
    int index,
  ) {
    // Extract type
    final typeStr = (aiQuestion['type'] as String? ?? 'multiple_choice')
        .toLowerCase()
        .replaceAll(' ', '_');
    final questionType = _parseQuestionType(typeStr);

    // Extract content (new format: {text, images, latex})
    Map<String, dynamic> content;
    if (aiQuestion['content'] is Map<String, dynamic>) {
      // New format: content object
      final contentObj = aiQuestion['content'] as Map<String, dynamic>;
      content = {
        'text': contentObj['text'] as String? ?? '',
        'images': contentObj['images'] as List<dynamic>? ?? [],
        if (contentObj['latex'] != null)
          'latex': contentObj['latex'] as String?,
      };
    } else {
      // Legacy format: text string (backward compatibility)
      final text =
          aiQuestion['text'] as String? ??
          aiQuestion['question'] as String? ??
          aiQuestion['content'] as String? ??
          'Câu hỏi $index';
      content = {'text': text, 'images': []};
    }

    // Extract answer (new format: {text, correct_choices, explanation})
    Map<String, dynamic>? answer;
    if (aiQuestion['answer'] is Map<String, dynamic>) {
      answer = Map<String, dynamic>.from(aiQuestion['answer'] as Map);
    } else {
      // Legacy: extract explanation separately
      final explanation =
          aiQuestion['explanation'] as String? ??
          aiQuestion['explanation_rich_text'] as String?;
      if (explanation != null) {
        answer = {'explanation': explanation};
      }
    }

    // Parse choices cho multiple choice (new format: [{id, content: {text, image}, is_correct}])
    List<Map<String, dynamic>>? choices;
    if (questionType == QuestionType.multipleChoice) {
      final choicesList =
          aiQuestion['choices'] as List<dynamic>? ??
          aiQuestion['options'] as List<dynamic>?; // Backward compatibility

      if (choicesList != null) {
        choices = [];
        for (var i = 0; i < choicesList.length; i++) {
          final choice = choicesList[i];
          if (choice is Map<String, dynamic>) {
            // New format: {id, content: {text, image}, is_correct}
            final choiceId = choice['id'] as int? ?? i;
            final choiceContent = choice['content'] as Map<String, dynamic>?;

            if (choiceContent != null) {
              // New format
              choices.add({
                'id': choiceId,
                'content': {
                  'text': choiceContent['text'] as String? ?? '',
                  if (choiceContent['image'] != null)
                    'image': choiceContent['image'] as String?,
                },
                'is_correct':
                    choice['is_correct'] as bool? ??
                    choice['isCorrect'] as bool? ??
                    false,
              });
            } else {
              // Legacy format: {text, isCorrect}
              choices.add({
                'id': choiceId,
                'content': {
                  'text':
                      choice['text'] as String? ??
                      choice['label'] as String? ??
                      '',
                },
                'is_correct':
                    choice['is_correct'] as bool? ??
                    choice['isCorrect'] as bool? ??
                    false,
              });
            }
          } else if (choice is String) {
            // Legacy: string format
            choices.add({
              'id': i,
              'content': {'text': choice},
              'is_correct': false,
            });
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

    // VALIDATION: Đảm bảo đáp án trắc nghiệm chính xác 100%
    if (questionType == QuestionType.multipleChoice &&
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
        // Tự động sửa: set choice đầu tiên làm đáp án đúng
        if (choices.isNotEmpty) {
          choices[0]['is_correct'] = true;
        }
      } else if (correctCount > 1) {
        AppLogger.warning(
          '⚠️ [AI REPO] Question $index: Có $correctCount đáp án đúng '
          '(chỉ được phép 1). Giữ lại đáp án đúng đầu tiên.',
        );
        // Tự động sửa: chỉ giữ lại đáp án đúng đầu tiên
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
      if (answer is Map<String, dynamic>) {
        final correctChoices = answer['correct_choices'] as List<dynamic>?;
        if (correctChoices != null) {
          // Tìm choice có is_correct = true
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
              // Tự động sửa answer.correct_choices
              answer['correct_choices'] = [actualCorrectIndex];
            }
          }
        } else {
          // Nếu không có correct_choices, tự động thêm
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

  /// Parse question type từ string
  QuestionType _parseQuestionType(String typeStr) {
    switch (typeStr) {
      case 'multiple_choice':
      case 'multiplechoice':
      case 'mcq':
        return QuestionType.multipleChoice;
      case 'short_answer':
      case 'shortanswer':
        return QuestionType.shortAnswer;
      case 'essay':
        return QuestionType.essay;
      case 'math':
      case 'mathematics':
        return QuestionType.math;
      default:
        return QuestionType.multipleChoice;
    }
  }

  /// Try parse JSON string
  dynamic _tryParseJson(String jsonString) {
    String s = jsonString.trim();
    if (s.isEmpty) return null;

    // 1) Remove common Markdown code fences (```json ... ``` or ``` ... ```)
    // Keep best-effort: if fences exist, extract inner content.
    final fenceMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```', caseSensitive: false)
        .firstMatch(s);
    if (fenceMatch != null) {
      s = (fenceMatch.group(1) ?? '').trim();
    }

    // 2) Try direct decode first
    try {
      return jsonDecode(s);
    } catch (_) {
      // continue
    }

    // 3) Heuristic: extract first JSON object/array substring from noisy text
    // Find first '{' or '['
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

    // Find last '}' or ']'
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
    final candidate = s.substring(start, end + 1).trim();

    try {
      return jsonDecode(candidate);
    } catch (_) {
      return null;
    }
  }

  /// Generate fallback questions khi AI API không trả về đúng format
  List<Map<String, dynamic>> _generateFallbackQuestions(int quantity) {
    return List.generate(quantity, (index) {
      return {
        'type': QuestionType.multipleChoice,
        'text': 'Câu hỏi ${index + 1} (cần chỉnh sửa)',
        'options': [
          {'text': 'Lựa chọn A', 'isCorrect': false},
          {'text': 'Lựa chọn B', 'isCorrect': false},
          {'text': 'Lựa chọn C', 'isCorrect': false},
          {'text': 'Lựa chọn D', 'isCorrect': false},
        ],
      };
    });
  }
}
