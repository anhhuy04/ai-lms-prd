// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/services/ai_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/presentation/providers/ai_providers.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/learning_objective_providers.dart';
import 'package:ai_mls/presentation/providers/question_bank_providers.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình tạo câu hỏi bằng AI
class TeacherAiGenerateQuestionScreen extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>>? questions; // Danh sách câu hỏi hiện tại

  const TeacherAiGenerateQuestionScreen({super.key, this.questions});

  @override
  ConsumerState<TeacherAiGenerateQuestionScreen> createState() =>
      _TeacherAiGenerateQuestionScreenState();
}

class _TeacherAiGenerateQuestionScreenState
    extends ConsumerState<TeacherAiGenerateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _quantityController = TextEditingController(text: '5');
  int? _difficulty; // 1-5

  bool _isGenerating = false;
  String? _rawApiResponse;
  String? _rawApiResponsePretty;
  List<Map<String, dynamic>>? _generatedQuestions;
  bool _isSavingToBank = false;

  // Multi-select loại câu hỏi — rỗng = tự động
  final Set<String> _selectedTypes = {};
  // Số lượng theo từng loại (key = typeKey)
  final Map<String, int> _typeQuantities = {};
  // Phân nhóm kết quả theo loại (để hiển thị section header)
  final List<({String typeKey, String label, int startIndex, int count})>
  _sections = [];

  // Batch progress
  String? _batchProgress;

  // Index đang regenerate đơn lẻ
  int? _regeneratingIndex;

  // Gợi ý làm bài
  bool _explanationFeatureEnabled = false; // Global toggle — tiết kiệm token
  final Set<int> _expandedExplanations = {};
  final Set<int> _regeneratingExplanationSet = {};

  @override
  void dispose() {
    _topicController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveToQuestionBank() async {
    final questions = _generatedQuestions;
    if (questions == null || questions.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lưu vào Ngân hàng câu hỏi'),
        content: Text(
          'Bạn muốn lưu ${questions.length} câu hỏi vừa tạo vào Question Bank?\n\n'
          'Hệ thống sẽ tự tạo/cập nhật Learning Objectives nếu cần.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSavingToBank = true);
    try {
      final questionRepo = ref.read(questionRepositoryProvider);
      final loRepo = ref.read(learningObjectiveRepositoryProvider);

      // Cache objectives theo subject_code để giảm query
      final Map<String, List<dynamic>> objectivesCache = {};

      int success = 0;
      final List<String> errors = [];
      for (var i = 0; i < questions.length; i++) {
        try {
          final params = await _mapAiQuestionToCreateQuestionParams(
            questions[i],
            loRepo: loRepo,
            objectivesCache: objectivesCache,
            // Chỉ lưu explanation nếu user đã tích checkbox cho câu này
            includeExplanation: _expandedExplanations.contains(i),
          );
          await questionRepo.createQuestion(params);
          success++;
        } catch (e) {
          errors.add('Câu ${i + 1}: ${e.toString().replaceAll('Exception: ', '')}');
        }
      }

      if (!mounted) return;
      if (errors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã lưu $success câu hỏi vào Question Bank'),
            backgroundColor: DesignColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(success > 0 ? 'Lưu một phần ($success/${questions.length} câu)' : 'Lưu thất bại'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (success > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('✅ Đã lưu thành công: $success câu', style: const TextStyle(color: Colors.green)),
                    ),
                  Text('❌ Lỗi:\n${errors.join('\n')}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Lưu thất bại'),
          content: SingleChildScrollView(
            child: Text(e.toString().replaceAll('Exception: ', '')),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isSavingToBank = false);
    }
  }

  Future<CreateQuestionParams> _mapAiQuestionToCreateQuestionParams(
    Map<String, dynamic> q, {
    required dynamic loRepo,
    required Map<String, List<dynamic>> objectivesCache,
    bool includeExplanation = false,
  }) async {
    // type
    final QuestionType type = (q['type'] is QuestionType)
        ? (q['type'] as QuestionType)
        : QuestionType.multipleChoice;

    // Format mới: override_text + choices (KHÔNG lồng trong content)
    // content chỉ chứa metadata như images, difficulty, tags...
    final content = <String, dynamic>{};
    final contentRaw = q['content'];
    if (contentRaw is Map) {
      content.addAll(Map<String, dynamic>.from(contentRaw));
    }

    // Override text - ưu tiên: q['text'] (đã mapped) → q['override_text'] (AI raw) → content fields
    final questionText = (q['text'] as String?)?.trim().isNotEmpty == true
        ? (q['text'] as String).trim()
        : (q['override_text'] as String?)?.trim().isNotEmpty == true
        ? (q['override_text'] as String).trim()
        : (content['override_text'] ?? content['text'] ?? '').toString();
    content['override_text'] = questionText;
    content['images'] = content['images'] is List ? content['images'] : [];

    // choices + answer - ưu tiên q['choices'] (đầy đủ) trước q['options'] (backward compat)
    Map<String, dynamic>? answer;
    List<Map<String, dynamic>>? choices;
    if (type == QuestionType.multipleChoice || type == QuestionType.trueFalse) {
      // Ưu tiên q['choices'] (format đầy đủ từ repo) trước q['options'] (backward compat)
      final rawList =
          (q['choices'] as List?)?.cast<Map<String, dynamic>>() ??
          (q['options'] as List?)?.cast<Map<String, dynamic>>() ??
          const <Map<String, dynamic>>[];

      choices = rawList.asMap().entries.map((entry) {
        final idx = entry.key;
        final opt = entry.value;
        // Extract text: hỗ trợ cả format {content: {text}} và {text}
        final choiceContent = opt['content'];
        final text = (choiceContent is Map<String, dynamic>
                ? choiceContent['text']
                : null) ??
            opt['text'] ??
            '';
        final isCorrect =
            opt['is_correct'] == true || opt['isCorrect'] == true;
        // Build với format chuẩn DB: {id: int, content: {text}, is_correct: bool}
        return <String, dynamic>{
          'id': idx,
          'content': {'text': text.toString()},
          'is_correct': isCorrect,
        };
      }).toList();

      final correctIds = <int>[];
      for (var i = 0; i < choices.length; i++) {
        if (choices[i]['is_correct'] == true) correctIds.add(i);
      }
      answer = <String, dynamic>{'correct_choice_ids': correctIds};
    } else {
      final a = q['answer'];
      if (a is Map) {
        answer = Map<String, dynamic>.from(a);
      }
    }

    // Gắn general_explanation vào answer (Data Contract: tách khỏi content)
    // Chỉ lưu nếu user đã bật checkbox gợi ý cho câu này
    if (includeExplanation) {
      final explanationForSave =
          (q['explanation'] as String?)?.trim() ??
          (q['answer'] is Map ? (q['answer'] as Map)['general_explanation']?.toString().trim() : null);
      if (explanationForSave != null && explanationForSave.isNotEmpty) {
        answer ??= {};
        answer['general_explanation'] = explanationForSave;
      }
    }

    // difficulty/tags
    final difficulty = q['difficulty'] is int ? q['difficulty'] as int : null;
    final tags = (q['tags'] as List?)?.map((e) => e.toString()).toList();

    // learning objectives => objectiveIds
    final objectiveIds = <String>[];
    final losRaw = q['learningObjectives'];
    if (losRaw is List) {
      for (final item in losRaw) {
        if (item is! Map) continue;
        final m = Map<String, dynamic>.from(item);
        final desc = (m['description'] ?? '').toString().trim();
        if (desc.isEmpty) continue;
        final subjectCode = (m['subject_code'] ?? m['subjectCode'] ?? 'GEN')
            .toString()
            .trim();
        final code = (m['code'] ?? 'GEN.${desc.hashCode.abs()}')
            .toString()
            .trim();

        // Load cache cho subjectCode
        objectivesCache[subjectCode] ??= await loRepo.getObjectives(
          subjectCode: subjectCode,
        );

        final existing = (objectivesCache[subjectCode] ?? [])
            .whereType<dynamic>()
            .cast<dynamic>()
            .firstWhere((o) {
              try {
                final obj = o;
                final objCode = (obj.code ?? '').toString();
                final objDesc = (obj.description ?? '').toString();
                return (objCode == code) || (objDesc == desc);
              } catch (_) {
                return false;
              }
            }, orElse: () => null);

        if (existing != null) {
          try {
            objectiveIds.add(existing.id as String);
            continue;
          } catch (_) {}
        }

        final userId = ref.read(currentUserIdProvider);
        final created = await loRepo.createObjective({
          'subject_code': subjectCode,
          'code': code,
          'description': desc,
          'is_global': false,       // private của GV này
          'source': 'ai_generated', // track provenance
          'created_by': userId,     // BẮT BUỘC để RLS không nuốt mất
        });
        objectiveIds.add(created.id as String);

        // update cache
        objectivesCache[subjectCode] = [
          ...(objectivesCache[subjectCode] ?? []),
          created,
        ];
      }
    }

    return CreateQuestionParams(
      type: type,
      content: content,
      answer: answer,
      difficulty: difficulty,
      tags: tags,
      objectiveIds: objectiveIds.isEmpty ? null : objectiveIds,
      choices: choices,
      isPublic: false,
      defaultPoints: 1,
    );
  }

  Future<void> _handleGenerate() async {
    AppLogger.info('🔵 [Generate] _handleGenerate called');
    AppLogger.info('🔵 [Generate] topic="${_topicController.text.trim()}", '
        '_isGenerating=$_isGenerating, _isQtyMismatch=$_isQtyMismatch, '
        '_selectedTypes=$_selectedTypes, _totalTypedQty=$_totalTypedQty, _limitQty=$_limitQty');

    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      AppLogger.warning('🟡 [Generate] EXIT: topic empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập chủ đề câu hỏi'),
          backgroundColor: DesignColors.error,
        ),
      );
      return;
    }

    // Validate quantity
    final formState = _formKey.currentState;
    AppLogger.info('🔵 [Generate] formState=$formState');
    if (formState == null) {
      AppLogger.error('🔴 [Generate] EXIT: _formKey.currentState is NULL!');
      return;
    }
    final isValid = formState.validate();
    AppLogger.info('🔵 [Generate] form.validate()=$isValid');
    if (!isValid) {
      AppLogger.warning('🟡 [Generate] EXIT: form validation failed');
      return;
    }
    // Guard mismatch (button đã disable nhưng thêm guard để chắc chắn)
    if (_isQtyMismatch) {
      AppLogger.warning('🟡 [Generate] EXIT: _isQtyMismatch=true');
      return;
    }

    setState(() {
      _isGenerating = true;
      _batchProgress = null;
      _rawApiResponse = null;
      _rawApiResponsePretty = null;
      _sections.clear();
      _explanationFeatureEnabled = false;
      _expandedExplanations.clear();
      _regeneratingExplanationSet.clear();
    });

    try {
      final aiRepository = ref.read(aiRepositoryProvider);
      int batchCount = 0;

      void appendRaw(String raw) {
        String pretty = raw;
        try {
          pretty = const JsonEncoder.withIndent('  ').convert(jsonDecode(raw));
        } catch (_) {}
        if (mounted) {
          setState(() {
            _rawApiResponse = _rawApiResponse == null ? raw : '${_rawApiResponse!}\n\n$raw';
            _rawApiResponsePretty = _rawApiResponsePretty == null ? pretty : '${_rawApiResponsePretty!}\n\n$pretty';
          });
        }
      }

      List<Map<String, dynamic>> generatedQuestions;

      if (_selectedTypes.isEmpty) {
        // ── Auto mode: single call ──────────────────────────────────────────
        final quantity = int.tryParse(_quantityController.text.trim()) ?? 5;
        generatedQuestions = await aiRepository.generateQuestions(
          topic: topic,
          quantity: quantity,
          difficulty: _difficulty,
          questionType: null,
          onRawResponse: (raw) {
            batchCount++;
            if (mounted) setState(() => _batchProgress = quantity > 10 ? 'Đang tạo lô $batchCount...' : null);
            appendRaw(raw);
          },
        );
      } else {
        // ── Multi-type mode: call per type, collect sections ────────────────
        generatedQuestions = [];
        final typeList = _selectedTypes.toList();
        for (var i = 0; i < typeList.length; i++) {
          final typeKey = typeList[i];
          final qty = _typeQuantities[typeKey] ?? 3;
          if (mounted) {
            setState(() => _batchProgress =
                'Đang tạo ${_typeLabel(typeKey)} ($qty câu) — ${i + 1}/${typeList.length}...');
          }
          final results = await aiRepository.generateQuestions(
            topic: topic,
            quantity: qty,
            difficulty: _difficulty,
            questionType: typeKey,
            onRawResponse: (raw) {
              batchCount++;
              appendRaw(raw);
            },
          );
          if (!mounted) return;
          final startIndex = generatedQuestions.length;
          generatedQuestions.addAll(results);
          setState(() {
            _sections.add((
              typeKey: typeKey,
              label: _typeLabel(typeKey),
              startIndex: startIndex,
              count: results.length,
            ));
          });
        }
      }

      if (!mounted) return;

      setState(() {
        _generatedQuestions = generatedQuestions;
        _batchProgress = null;
      });

      // KHÔNG pop tự động - để user có thể test nhiều lần
      // User sẽ click "Xác nhận" để pop và trả về questions
    } catch (e) {
      if (!mounted) return;

      // Parse error message để hiển thị thân thiện hơn
      String errorMessage = e.toString();
      if (errorMessage.contains('Quota đã hết') ||
          errorMessage.contains('quota') ||
          errorMessage.contains('429')) {
        // Hiển thị dialog cho lỗi quota để user đọc được đầy đủ thông tin
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text('Quota đã hết'),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(
                errorMessage.replaceAll('Exception: ', ''),
                style: const TextStyle(height: 1.5),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đã hiểu'),
              ),
            ],
          ),
        );
      } else if (errorMessage.contains('GEMINI_API_KEY chưa được cấu hình') ||
          errorMessage.contains('API key')) {
        // Hiển thị dialog hướng dẫn đến Settings khi chưa có API key
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.settings_outlined, color: DesignColors.primary),
                SizedBox(width: 8),
                Text('Chưa cấu hình API Key'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bạn cần cấu hình Gemini API Key để sử dụng tính năng tạo câu hỏi bằng AI.',
                  style: DesignTypography.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Vui lòng vào Cài đặt → Cài đặt API Key để thêm API key của bạn.',
                  style: DesignTypography.bodySmall.copyWith(
                    color: DesignColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push(AppRoute.apiKeySetupPath);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Đến Cài đặt'),
              ),
            ],
          ),
        );
      } else {
        // Hiển thị SnackBar cho các lỗi khác
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tạo câu hỏi: ${e.toString()}'),
            backgroundColor: DesignColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  String _extractQuestionText(Map<String, dynamic> q) {
    final isMath = _isMathQuestion(q);

    String render(String t) => _renderBlankPlaceholders(t.trim(), isMath: isMath);

    // Ưu tiên format mới: override_text tại top-level (AI format)
    final overrideText = q['override_text'] as String?;
    if (overrideText != null && overrideText.trim().isNotEmpty) {
      return render(overrideText);
    }

    // Format chuẩn mà repo map ra: q['text']
    final direct = q['text'] as String?;
    if (direct != null && direct.trim().isNotEmpty) return render(direct);

    // content object (new format)
    final content = q['content'];
    if (content is Map<String, dynamic>) {
      final t = content['text'] as String?;
      if (t != null && t.trim().isNotEmpty) return render(t);
      final ot = content['override_text'] as String?;
      if (ot != null && ot.trim().isNotEmpty) return render(ot);
    }

    // Fallback: title
    final title = q['title'] as String?;
    if (title != null && title.trim().isNotEmpty) return title.trim();

    return 'Câu hỏi (không có nội dung)';
  }

  /// Nhận biết câu hỏi toán học dựa vào type hoặc nội dung
  bool _isMathQuestion(Map<String, dynamic> q) {
    final typeRaw = q['type'];
    final typeStr = typeRaw is String
        ? typeRaw
        : typeRaw is QuestionType
        ? typeRaw.dbValue
        : '';
    if (typeStr == 'math' || typeStr == 'problem_solving') return true;

    // Kiểm tra topic / tags chứa từ khóa toán
    final tags = q['tags'];
    if (tags is List) {
      final tagStr = tags.join(' ').toLowerCase();
      if (RegExp(r'toán|math|số|phép|tính|cộng|trừ|nhân|chia|đại số|hình học|phương trình')
          .hasMatch(tagStr)) { return true; }
    }

    // Kiểm tra text có chứa phép toán (số + ký tự toán học)
    final text = (q['override_text'] ?? q['text'] ?? '').toString();
    return RegExp(r'[\d]+\s*[+\-×÷*/=<>]|\b[xy]\s*=').hasMatch(text);
  }

  /// Thay thế [blank_N] / [___N] thành:
  /// - Toán: x, y, z, a, b, c (có nghĩa hơn cho phương trình)
  /// - Khác: ô trống trực quan "______"
  String _renderBlankPlaceholders(String text, {bool isMath = false}) {
    final mathVars = ['x', 'y', 'z', 'a', 'b', 'c', 'n', 'm'];
    int blankCount = 0;

    return text.replaceAllMapped(
      RegExp(r'\[___\d+\]|\[blank_\d+\]|\[blank\s*\d+\]', caseSensitive: false),
      (match) {
        if (isMath) {
          final v = blankCount < mathVars.length ? mathVars[blankCount] : '?';
          blankCount++;
          return v;
        } else {
          blankCount++;
          return '______';
        }
      },
    );
  }

  /// Format danh sách blanks thành dạng dễ đọc.
  /// Toán: x = ..., y = ... | Khác: Ô 1: ..., Ô 2: ...
  List<Widget> _formatBlanksDisplay(
    dynamic blanks,
    bool isDark, {
    bool isMath = false,
  }) {
    if (blanks is! List) return [];
    const mathVars = ['x', 'y', 'z', 'a', 'b', 'c', 'n', 'm'];
    final widgets = <Widget>[];
    for (var i = 0; i < blanks.length; i++) {
      final blank = blanks[i];
      if (blank is! Map) continue;
      final values = blank['correct_values'];
      final valStr = values is List
          ? values.map((v) => v.toString()).join(' / ')
          : values?.toString() ?? '';
      final label = isMath
          ? '${i < mathVars.length ? mathVars[i] : '?'} = $valStr'
          : 'Ô ${i + 1}: $valStr';
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: DesignColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(DesignRadius.sm),
              border: Border.all(color: DesignColors.success.withValues(alpha: 0.3)),
            ),
            child: Text(
              label,
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.white : DesignColors.textPrimary,
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  // ─── Computed helpers ────────────────────────────────────────────────────
  int get _limitQty => int.tryParse(_quantityController.text.trim()) ?? 5;
  int get _totalTypedQty =>
      _typeQuantities.values.fold(0, (a, b) => a + b);
  bool get _isQtyMismatch =>
      _selectedTypes.isNotEmpty && _totalTypedQty != _limitQty;

  // ─── Xóa câu hỏi đơn lẻ ─────────────────────────────────────────────────
  void _handleRemoveQuestion(int index) {
    setState(() {
      _generatedQuestions = List.from(_generatedQuestions!)..removeAt(index);
    });
  }

  // ─── Regenerate 1 câu ────────────────────────────────────────────────────
  /// Tìm typeKey của câu hỏi tại [index] dựa vào _sections
  String? _typeKeyForIndex(int index) {
    for (final s in _sections) {
      if (index >= s.startIndex && index < s.startIndex + s.count) {
        return s.typeKey;
      }
    }
    return null; // auto
  }

  Future<void> _handleRegenerateSingle(int index) async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    setState(() => _regeneratingIndex = index);
    try {
      final aiRepository = ref.read(aiRepositoryProvider);
      final result = await aiRepository.generateQuestions(
        topic: topic,
        quantity: 1,
        difficulty: _difficulty,
        questionType: _typeKeyForIndex(index),
      );
      if (result.isNotEmpty && mounted) {
        setState(() {
          final updated = List<Map<String, dynamic>>.from(_generatedQuestions!);
          updated[index] = result.first;
          _generatedQuestions = updated;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tạo lại thất bại: $e'),
          backgroundColor: DesignColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _regeneratingIndex = null);
    }
  }

  // ─── Regenerate gợi ý làm bài cho 1 câu ────────────────────────────────
  Future<void> _handleRegenerateExplanation(int index) async {
    final questions = _generatedQuestions;
    if (questions == null || index >= questions.length) return;
    final q = questions[index];
    final questionText = _extractQuestionText(q);

    setState(() => _regeneratingExplanationSet.add(index));
    try {
      final prompt =
          'Viết giải thích/gợi ý làm bài ngắn gọn (1-2 câu, tối đa 35 từ) cho câu hỏi sau. '
          'Chỉ trả về nội dung giải thích thuần túy, không JSON, không tiêu đề.\n\n'
          'Câu hỏi: "$questionText"\n\nGiải thích:';

      final result = await AiService.callActiveAi(prompt);
      final newExplanation = _extractPlainTextFromAiResult(result);

      if (newExplanation != null && mounted) {
        final current = _generatedQuestions;
        if (current != null && index < current.length) {
          setState(() {
            final updated = List<Map<String, dynamic>>.from(current);
            updated[index] = {...updated[index], 'explanation': newExplanation};
            _generatedQuestions = updated;
            _expandedExplanations.add(index);
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tạo lại gợi ý thất bại: $e'),
          backgroundColor: DesignColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _regeneratingExplanationSet.remove(index));
    }
  }

  /// Parse plain text từ AI result (hỗ trợ Gemini, Groq, Ollama)
  String? _extractPlainTextFromAiResult(dynamic result) {
    if (result is! String) return null;
    var text = result.trim();
    // Strip markdown code fences nếu AI wrap trong ```...```
    text = text.replaceAll(RegExp(r'^```[a-zA-Z]*\n?', multiLine: false), '');
    text = text.replaceAll(RegExp(r'\n?```$', multiLine: false), '').trim();
    // Thử parse JSON nếu AI trả về JSON wrapper
    try {
      final parsed = jsonDecode(text);
      if (parsed is Map) {
        // Hỗ trợ: Gemini/Groq (explanation/text/content), Ollama (response)
        final v = parsed['explanation'] ??
            parsed['text'] ??
            parsed['content'] ??
            parsed['response'];
        return v?.toString().trim().isEmpty == true ? null : v?.toString().trim();
      }
      if (parsed is String) return parsed.trim().isEmpty ? null : parsed.trim();
    } catch (_) {}
    // Plain text - remove markdown artifacts
    text = text
        .replaceAll(RegExp(r'^#+\s*', multiLine: true), '')
        .replaceAll(RegExp(r'\*\*|__'), '')
        .replaceAll(RegExp(r'(?<!\*)\*(?!\*)'), '') // bold/italic asterisk
        .replaceAll(RegExp(r'^[-*]\s*', multiLine: true), '')
        .trim();
    return text.isEmpty ? null : text;
  }

  // ─── Chỉnh sửa câu hỏi ──────────────────────────────────────────────────
  Future<void> _handleEditQuestion(int index) async {
    final q = Map<String, dynamic>.from(_generatedQuestions![index]);
    final type = q['type'] is QuestionType
        ? (q['type'] as QuestionType)
        : QuestionType.multipleChoice;

    await showDialog<void>(
      context: context,
      builder: (ctx) => _EditQuestionDialog(
        question: q,
        questionType: type,
        onSave: (updated) {
          setState(() {
            final list = List<Map<String, dynamic>>.from(_generatedQuestions!);
            list[index] = updated;
            _generatedQuestions = list;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF1A2632) : Colors.white)
                      .withValues(alpha: 0.95),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: statusBarHeight + 8,
                  bottom: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(DesignRadius.full),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 24,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Tạo câu hỏi bằng AI',
                        style: DesignTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : DesignColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Nút cài đặt (navigate đến Settings)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.pushNamed(AppRoute.aiQuestionSettings),
                        borderRadius: BorderRadius.circular(DesignRadius.full),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.settings_rounded,
                            size: 24,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(DesignSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Topic Input (Textarea)
                        _buildTopicSection(context, isDark),
                        SizedBox(height: DesignSpacing.xxl),

                        // Giới hạn tổng số câu (luôn hiển thị)
                        _buildQuantitySection(context, isDark),
                        SizedBox(height: DesignSpacing.md),

                        // Per-type qty steppers (hiện khi có loại được chọn)
                        if (_selectedTypes.isNotEmpty) ...[
                          _buildPerTypeQtySection(context, isDark),
                          SizedBox(height: DesignSpacing.xxl),
                        ] else
                          SizedBox(height: DesignSpacing.lg),

                        // Difficulty Selector
                        _buildDifficultySection(context, isDark),
                        SizedBox(height: DesignSpacing.xxl),

                        // Question Type Selector (multi-select chips)
                        _buildQuestionTypeSection(context, isDark),

                        // AI Response Section (hiển thị sau khi generate)
                        if (_generatedQuestions != null) ...[
                          SizedBox(height: DesignSpacing.xxl),
                          _buildAiResponseSection(context, isDark),
                        ],

                        // Raw API Response Section (chỉ debug mode)
                        if (kDebugMode &&
                            (_rawApiResponse != null ||
                                _rawApiResponsePretty != null)) ...[
                          SizedBox(height: DesignSpacing.lg),
                          _buildRawApiResponseSection(context, isDark),
                        ],

                        SizedBox(height: 100), // Space for button
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Action Buttons
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: DesignSpacing.lg,
            right: DesignSpacing.lg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning khi tổng chưa khớp
                if (_isQtyMismatch) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: DesignColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(DesignRadius.lg),
                      border: Border.all(color: DesignColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 16, color: DesignColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tổng số câu ($_totalTypedQty) chưa khớp giới hạn ($_limitQty). Chỉnh lại để tạo.',
                            style: TextStyle(fontSize: 12, color: DesignColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Generate/Reset Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isGenerating || _isQtyMismatch) ? null : _handleGenerate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          DesignRadius.lg * 1.5,
                        ),
                      ),
                      elevation: 8,
                      shadowColor: DesignColors.primary.withValues(alpha: 0.3),
                    ),
                    child: _isGenerating
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Tạo câu hỏi',
                                style: DesignTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                // Confirm và Reset buttons (hiển thị sau khi generate)
                if (_generatedQuestions != null &&
                    _generatedQuestions!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Reset để test lại
                            setState(() {
                              _rawApiResponse = null;
                              _generatedQuestions = null;
                              _rawApiResponsePretty = null;
                              _explanationFeatureEnabled = false;
                              _expandedExplanations.clear();
                              _regeneratingExplanationSet.clear();
                              _sections.clear();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            side: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                DesignRadius.lg * 1.5,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.refresh, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Reset',
                                style: DesignTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (_isSavingToBank || _isGenerating)
                              ? null
                              : _handleSaveToQuestionBank,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                DesignRadius.lg * 1.5,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isSavingToBank
                                    ? Icons.hourglass_top_rounded
                                    : Icons.cloud_upload_outlined,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isSavingToBank ? 'Đang lưu...' : 'Lưu Bank',
                                style: DesignTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _generatedQuestions != null
                              ? () {
                                  // Pop và trả về generated questions
                                  context.pop(_generatedQuestions);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                DesignRadius.lg * 1.5,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Xác nhận',
                                style: DesignTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Loading overlay
          if (_isGenerating)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      if (_batchProgress != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(DesignRadius.lg),
                          ),
                          child: Text(
                            _batchProgress!,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopicSection(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'CHỦ ĐỀ CÂU HỎI',
              style: TextStyle(
                fontSize: DesignTypography.labelSmallSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ).copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
          TextFormField(
            controller: _topicController,
            minLines: 5,
            maxLines: null,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập chủ đề câu hỏi';
              }
              return null;
            },
            style: DesignTypography.bodyMedium.copyWith(
              color: isDark ? Colors.white : DesignColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText:
                  'Ví dụ: Tạo cho tôi các câu hỏi liên quan đến phép cộng lớp 3',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.grey[800]!.withValues(alpha: 0.5)
                  : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                borderSide: BorderSide(color: DesignColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'GIỚI HẠN TỔNG SỐ CÂU',
                  style: TextStyle(
                    fontSize: DesignTypography.labelSmallSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _selectedTypes.isEmpty
                    ? 'chế độ tự động'
                    : 'tổng phải đúng con số này',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}), // rebuild để cập nhật badge
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập số lượng câu hỏi';
              }
              final quantity = int.tryParse(value.trim());
              if (quantity == null || quantity <= 0) {
                return 'Số lượng phải lớn hơn 0';
              }
              if (quantity > 50) {
                return 'Số lượng tối đa là 50';
              }
              return null;
            },
            style: DesignTypography.bodyLarge.copyWith(
              color: isDark ? Colors.white : DesignColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Nhập số lượng...',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.grey[800]!.withValues(alpha: 0.5)
                  : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                borderSide: BorderSide(color: DesignColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySection(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'MỨC ĐỘ KHÓ',
              style: TextStyle(
                fontSize: DesignTypography.labelSmallSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ).copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
          Row(
            children: [
              ...List.generate(5, (index) {
                final difficulty = index + 1;
                final isSelected = _difficulty == difficulty;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _difficulty = _difficulty == difficulty
                            ? null
                            : difficulty;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? DesignColors.primary.withValues(alpha: 0.1)
                            : (isDark
                                  ? Colors.grey[800]!.withValues(alpha: 0.5)
                                  : Colors.grey[50]),
                        borderRadius: BorderRadius.circular(DesignRadius.lg),
                        border: Border.all(
                          color: isSelected
                              ? DesignColors.primary
                              : (isDark
                                    ? Colors.grey[700]!
                                    : Colors.grey[200]!),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 24,
                            color: isSelected
                                ? DesignColors.primary
                                : (isDark
                                      ? Colors.grey[600]
                                      : Colors.grey[300]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            difficulty.toString(),
                            style: DesignTypography.bodySmall.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? DesignColors.primary
                                  : (isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          if (_difficulty != null) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                ['Rất dễ', 'Dễ', 'Trung bình', 'Khó', 'Rất khó'][_difficulty! -
                    1],
                style: DesignTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DesignColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Danh sách loại câu hỏi có thể chọn
  // TODO: Tạm ẩn các loại chưa hỗ trợ — chỉ giữ Trắc nghiệm
  static const _kTypeOptions = [
    ('multiple_choice', 'Trắc nghiệm', Icons.check_box_outlined),
    // ('true_false', 'Đúng / Sai', Icons.toggle_on_outlined),
    // ('essay', 'Tự luận', Icons.edit_note_outlined),
    // ('short_answer', 'Trả lời ngắn', Icons.short_text_rounded),
    // ('fill_blank', 'Điền khuyết', Icons.text_fields_rounded),
    // ('math', 'Bài toán', Icons.calculate_outlined),
  ];

  String _typeLabel(String key) {
    return _kTypeOptions
        .firstWhere((t) => t.$1 == key, orElse: () => (key, key, Icons.help))
        .$2;
  }

  void _toggleType(String key, bool selected) {
    setState(() {
      if (selected) {
        _selectedTypes.add(key);
        _typeQuantities.putIfAbsent(key, () => 3);
      } else {
        _selectedTypes.remove(key);
        _typeQuantities.remove(key);
      }
      // Reset kết quả cũ khi đổi cấu hình
      _generatedQuestions = null;
      _sections.clear();
    });
  }

  Widget _buildQuestionTypeSection(BuildContext context, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1A2632) : Colors.white;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[200]!;
    final labelColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(
                'LOẠI CÂU HỎI',
                style: TextStyle(
                  fontSize: DesignTypography.labelSmallSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: labelColor,
                ),
              ),
              const SizedBox(width: 8),
              if (_selectedTypes.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: DesignColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(DesignRadius.full),
                  ),
                  child: Text(
                    'Tự động',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: DesignColors.primary,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: DesignColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(DesignRadius.full),
                  ),
                  child: Text(
                    '${_selectedTypes.length} loại · ${_typeQuantities.values.fold(0, (a, b) => a + b)} câu',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: DesignColors.success,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Multi-select chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kTypeOptions.map((t) {
              final (key, label, icon) = t;
              final isSelected = _selectedTypes.contains(key);
              return GestureDetector(
                onTap: () => _toggleType(key, !isSelected),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DesignColors.primary.withValues(alpha: 0.12)
                        : (isDark ? Colors.grey[800]!.withValues(alpha: 0.5) : Colors.grey[50]),
                    borderRadius: BorderRadius.circular(DesignRadius.lg),
                    border: Border.all(
                      color: isSelected ? DesignColors.primary : borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.check_circle_rounded, size: 14, color: DesignColors.primary),
                        ),
                      Icon(icon, size: 15,
                          color: isSelected ? DesignColors.primary : labelColor),
                      const SizedBox(width: 5),
                      Text(label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? DesignColors.primary : (isDark ? Colors.grey[300] : Colors.grey[700]),
                          )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

        ],
      ),
    );
  }

  /// Section riêng cho per-type qty — nằm ngay dưới ô giới hạn
  Widget _buildPerTypeQtySection(BuildContext context, bool isDark) {
    final total = _totalTypedQty;
    final limit = _limitQty;
    final isMatch = total == limit;
    final isOver = total > limit;
    final cardColor = isDark ? const Color(0xFF1A2632) : Colors.white;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[200]!;

    // Màu badge tổng
    final badgeColor = isMatch
        ? DesignColors.success
        : isOver
        ? DesignColors.error
        : DesignColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        border: Border.all(
          color: isMatch
              ? DesignColors.success.withValues(alpha: 0.4)
              : isOver
              ? DesignColors.error.withValues(alpha: 0.4)
              : borderColor,
          width: (isMatch || isOver) ? 1.5 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: label + tổng badge
          Row(
            children: [
              Text(
                'SỐ CÂU THEO LOẠI',
                style: TextStyle(
                  fontSize: DesignTypography.labelSmallSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const Spacer(),
              // Badge tổng: "6 / 10 câu"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(DesignRadius.full),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'Tổng: $total / $limit câu',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Per-type steppers
          ..._selectedTypes.map((key) {
            final qty = _typeQuantities[key] ?? 1;
            final canAdd = total < limit;
            final remaining = limit - total; // số câu còn trống
            final canFill = remaining > 0; // có thể fill thêm
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _typeLabel(key),
                      style: DesignTypography.bodyMedium.copyWith(
                        color: isDark ? Colors.white : DesignColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Nút fill tới giới hạn
                  if (canFill) ...[
                    GestureDetector(
                      onTap: () => setState(
                        () => _typeQuantities[key] = qty + remaining,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: DesignColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(DesignRadius.md),
                          border: Border.all(color: DesignColors.primary.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.vertical_align_top_rounded, size: 13, color: DesignColors.primary),
                            const SizedBox(width: 3),
                            Text(
                              '+$remaining',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: DesignColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800]!.withValues(alpha: 0.5) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(DesignRadius.lg),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStepBtn(
                          icon: Icons.remove_rounded,
                          enabled: qty > 1,
                          onTap: () => setState(() => _typeQuantities[key] = qty - 1),
                          isDark: isDark,
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '$qty',
                            textAlign: TextAlign.center,
                            style: DesignTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : DesignColors.textPrimary,
                            ),
                          ),
                        ),
                        _buildStepBtn(
                          icon: Icons.add_rounded,
                          enabled: canAdd,
                          onTap: () => setState(() => _typeQuantities[key] = qty + 1),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          // Thông báo lỗi / gợi ý
          if (!isMatch) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isOver ? Icons.error_outline_rounded : Icons.info_outline_rounded,
                  size: 14,
                  color: isOver ? DesignColors.error : DesignColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isOver
                        ? 'Tổng câu ($total) vượt quá giới hạn ($limit). Hãy giảm bớt.'
                        : 'Còn ${limit - total} câu chưa phân bổ. Tổng phải đúng $limit.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOver ? DesignColors.error : DesignColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? DesignColors.primary
              : (isDark ? Colors.grey[600] : Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildAiResponseSection(BuildContext context, bool isDark) {
    final questions = _generatedQuestions ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2632) : Colors.white,
            borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, size: 20, color: DesignColors.primary),
              const SizedBox(width: 8),
              Text(
                'KẾT QUẢ AI TRẢ VỀ',
                style: TextStyle(
                  fontSize: DesignTypography.labelSmallSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ).copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const Spacer(),
              // Global toggle gợi ý làm bài
              GestureDetector(
                onTap: () {
                  setState(() {
                    _explanationFeatureEnabled = !_explanationFeatureEnabled;
                    // Khi tắt: ẩn tất cả per-card (không xóa data đã generate)
                    if (!_explanationFeatureEnabled) {
                      _expandedExplanations.clear();
                    }
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _explanationFeatureEnabled
                          ? Icons.lightbulb_rounded
                          : Icons.lightbulb_outline_rounded,
                      size: 16,
                      color: _explanationFeatureEnabled
                          ? DesignColors.warning
                          : (isDark ? Colors.grey[500] : Colors.grey[400]),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Gợi ý',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _explanationFeatureEnabled
                            ? DesignColors.warning
                            : (isDark ? Colors.grey[500] : Colors.grey[400]),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _explanationFeatureEnabled
                          ? Icons.toggle_on_rounded
                          : Icons.toggle_off_rounded,
                      size: 26,
                      color: _explanationFeatureEnabled
                          ? DesignColors.warning
                          : (isDark ? Colors.grey[600] : Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.full),
                  border: Border.all(
                    color: DesignColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${questions.length} câu',
                  style: TextStyle(
                    fontSize: DesignTypography.labelSmallSize,
                    fontWeight: FontWeight.bold,
                    color: DesignColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...() {
          final widgets = <Widget>[];
          // Tập sections để insert header trước mỗi nhóm
          final sectionStarts = {
            for (final s in _sections) s.startIndex: s.label,
          };

          for (var index = 0; index < questions.length; index++) {
            // Section header nếu đây là đầu nhóm
            if (sectionStarts.containsKey(index)) {
              final sec = _sections.firstWhere((s) => s.startIndex == index);
              widgets.add(_buildSectionHeader(sec.label, sec.count, isDark));
            }

            final q = questions[index];
            final type = q['type'] is QuestionType
                ? (q['type'] as QuestionType)
                : QuestionType.multipleChoice;
            final text = _extractQuestionText(q);
            final options = q['options'] as List<dynamic>?;
            final castedOptions = options
                ?.map(
                  (o) => o is Map<String, dynamic>
                      ? o
                      : o is Map
                      ? Map<String, dynamic>.from(o)
                      : <String, dynamic>{},
                )
                .toList();
            final answerRaw = q['answer'];
            final answer = answerRaw is Map<String, dynamic>
                ? answerRaw
                : answerRaw is Map
                ? Map<String, dynamic>.from(answerRaw)
                : null;
            // Lấy explanation: ưu tiên top-level q['explanation'], fallback answer['general_explanation']
            final explanation =
                (q['explanation'] as String?)?.trim().isNotEmpty == true
                    ? (q['explanation'] as String).trim()
                    : (answer?['general_explanation'] as String?)?.trim().isNotEmpty == true
                    ? (answer!['general_explanation'] as String).trim()
                    : null;
            final isRegenerating = _regeneratingIndex == index;
            final isRegeneratingExpl = _regeneratingExplanationSet.contains(index);
            final isExplExpanded = _expandedExplanations.contains(index);
            // Số thứ tự trong section (hoặc toàn bộ nếu auto)
            final sectionNum = _sections.isEmpty
                ? index + 1
                : (() {
                    for (final s in _sections) {
                      if (index >= s.startIndex && index < s.startIndex + s.count) {
                        return index - s.startIndex + 1;
                      }
                    }
                    return index + 1;
                  })();

            widgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Stack(
                  children: [
                    _buildQuestionPreviewCard(
                      context,
                      isDark,
                      questionNumber: sectionNum,
                      questionType: type,
                      questionText: text,
                      options: castedOptions,
                      answer: answer,
                      explanation: explanation,
                      isExplanationExpanded: isExplExpanded,
                      onToggleExplanation: _explanationFeatureEnabled
                          ? () {
                              final willAutoGenerate = !isExplExpanded &&
                                  explanation == null &&
                                  !_regeneratingExplanationSet.contains(index);
                              setState(() {
                                if (isExplExpanded) {
                                  _expandedExplanations.remove(index);
                                } else {
                                  _expandedExplanations.add(index);
                                  // Mark loading ngay để tránh flash "Chưa có gợi ý"
                                  if (willAutoGenerate) {
                                    _regeneratingExplanationSet.add(index);
                                  }
                                }
                              });
                              if (willAutoGenerate) {
                                _handleRegenerateExplanation(index);
                              }
                            }
                          : null,
                      onRefreshExplanation: _explanationFeatureEnabled
                          ? () => _handleRegenerateExplanation(index)
                          : null,
                      isRefreshingExplanation: isRegeneratingExpl,
                    ),
                // Action buttons overlay (top-right)
                Positioned(
                  top: 8,
                  right: 8,
                  child: isRegenerating
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCardActionBtn(
                              icon: Icons.refresh_rounded,
                              color: DesignColors.primary,
                              tooltip: 'Tạo lại câu này',
                              onTap: () => _handleRegenerateSingle(index),
                            ),
                            const SizedBox(width: 4),
                            _buildCardActionBtn(
                              icon: Icons.edit_outlined,
                              color: DesignColors.textSecondary,
                              tooltip: 'Chỉnh sửa',
                              onTap: () => _handleEditQuestion(index),
                            ),
                            const SizedBox(width: 4),
                            _buildCardActionBtn(
                              icon: Icons.close_rounded,
                              color: DesignColors.error,
                              tooltip: 'Xóa câu này',
                              onTap: () => _handleRemoveQuestion(index),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
            );
          }
          return widgets;
        }(),
      ],
    );
  }

  Widget _buildSectionHeader(String label, int count, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: DesignColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.full),
              border: Border.all(color: DesignColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.layers_outlined, size: 14, color: DesignColors.primary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: DesignColors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: DesignColors.primary,
                    borderRadius: BorderRadius.circular(DesignRadius.full),
                  ),
                  child: Text(
                    '$count câu',
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Divider(color: isDark ? Colors.grey[700] : Colors.grey[300], indent: 8)),
        ],
      ),
    );
  }

  Widget _buildQuestionPreviewCard(
    BuildContext context,
    bool isDark, {
    required int questionNumber,
    required QuestionType questionType,
    required String questionText,
    List<Map<String, dynamic>>? options,
    Map<String, dynamic>? answer,
    String? explanation,
    bool isExplanationExpanded = false,
    VoidCallback? onToggleExplanation,
    VoidCallback? onRefreshExplanation,
    bool isRefreshingExplanation = false,
  }) {
    final borderRadius = BorderRadius.circular(DesignRadius.lg * 1.5);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: borderRadius,
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(color: questionType.color),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // paddingRight 96px để tránh bị che bởi 3 nút action overlay (top-right)
                  Padding(
                    padding: const EdgeInsets.only(right: 96),
                    child: Text(
                      'CÂU $questionNumber • ${questionType.label}',
                      style: TextStyle(
                        fontSize: DesignTypography.labelSmallSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    questionText,
                    style: DesignTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : DesignColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  // Hiển thị expected_answer cho essay/short_answer
                  if ((options == null || options.isEmpty) && answer != null) ...[
                    const SizedBox(height: 10),
                    if (answer['expected_answer'] != null) ...[
                      Text(
                        'Đáp án mẫu:',
                        style: DesignTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: DesignColors.success.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(DesignRadius.md),
                          border: Border.all(color: DesignColors.success.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          answer['expected_answer'].toString(),
                          style: DesignTypography.bodySmall.copyWith(
                            color: isDark ? Colors.white : DesignColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                    if (answer['blanks'] != null) ...[
                      Text(
                        'Đáp án chỗ trống:',
                        style: DesignTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      ..._formatBlanksDisplay(
                        answer['blanks'],
                        isDark,
                        isMath: questionType == QuestionType.math ||
                            questionType == QuestionType.problemSolving,
                      ),
                    ],
                  ],
                  if (options != null && options.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Column(
                      children: options.map((option) {
                        final optionText = option['text'] as String? ?? '';
                        final isCorrect =
                            option['isCorrect'] == true ||
                            option['is_correct'] == true;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCorrect
                                      ? DesignColors.success
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isCorrect
                                        ? DesignColors.success
                                        : (isDark
                                              ? Colors.grey[600]!
                                              : Colors.grey[300]!),
                                    width: 2,
                                  ),
                                ),
                                child: isCorrect
                                    ? Icon(
                                        Icons.check,
                                        size: 10,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: DesignTypography.bodySmall.copyWith(
                                    color: isCorrect
                                        ? DesignColors.success
                                        : (isDark
                                              ? Colors.white
                                              : DesignColors.textPrimary),
                                    fontWeight: isCorrect
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // ── Gợi ý làm bài (toggle + nội dung) ──────────────────
                  if (onToggleExplanation != null) ...[
                    const SizedBox(height: 10),
                    Divider(
                      color: isDark ? Colors.grey[700] : Colors.grey[200],
                      height: 1,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onToggleExplanation,
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isExplanationExpanded
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                size: 18,
                                color: isExplanationExpanded
                                    ? DesignColors.primary
                                    : (isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[400]),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Gợi ý làm bài',
                                style: DesignTypography.labelSmall.copyWith(
                                  color: isExplanationExpanded
                                      ? DesignColors.primary
                                      : (isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600]),
                                  fontWeight: isExplanationExpanded
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isExplanationExpanded &&
                            onRefreshExplanation != null) ...[
                          const Spacer(),
                          GestureDetector(
                            onTap: isRefreshingExplanation
                                ? null
                                : onRefreshExplanation,
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                isRefreshingExplanation
                                    ? SizedBox(
                                        width: 13,
                                        height: 13,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          color: DesignColors.primary,
                                        ),
                                      )
                                    : Icon(
                                        Icons.refresh_rounded,
                                        size: 14,
                                        color: DesignColors.primary,
                                      ),
                                const SizedBox(width: 4),
                                Text(
                                  'Làm mới',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: DesignColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isExplanationExpanded) ...[
                      const SizedBox(height: 8),
                      if (isRefreshingExplanation && explanation == null)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: DesignColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Đang tạo gợi ý...',
                                style: DesignTypography.bodySmall.copyWith(
                                  color: DesignColors.primary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (explanation != null && explanation.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: DesignColors.primary.withValues(alpha: 0.06),
                            borderRadius:
                                BorderRadius.circular(DesignRadius.md),
                            border: Border.all(
                              color:
                                  DesignColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                size: 14,
                                color: DesignColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  explanation,
                                  style: DesignTypography.bodySmall.copyWith(
                                    color: isDark
                                        ? Colors.grey[300]
                                        : DesignColors.textSecondary,
                                    height: 1.4,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            'Chưa có gợi ý. Bấm "Làm mới" để tạo.',
                            style: DesignTypography.bodySmall.copyWith(
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[400],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRawApiResponseSection(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.code, size: 20, color: DesignColors.primary),
              const SizedBox(width: 8),
              Text(
                'RAW JSON API RESPONSE (TEST)',
                style: TextStyle(
                  fontSize: DesignTypography.labelSmallSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ).copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Copy JSON',
                onPressed: () async {
                  final text = _rawApiResponsePretty ?? _rawApiResponse ?? '';
                  await Clipboard.setData(ClipboardData(text: text));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Đã copy JSON'),
                      backgroundColor: DesignColors.success,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey[800]!.withValues(alpha: 0.5)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(DesignRadius.lg),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              ),
            ),
            child: SelectableText(
              _rawApiResponsePretty ?? _rawApiResponse ?? '',
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontFamily: 'monospace',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardActionBtn({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog chỉnh sửa câu hỏi inline
// ─────────────────────────────────────────────────────────────────────────────
class _EditQuestionDialog extends StatefulWidget {
  final Map<String, dynamic> question;
  final QuestionType questionType;
  final void Function(Map<String, dynamic> updated) onSave;

  const _EditQuestionDialog({
    required this.question,
    required this.questionType,
    required this.onSave,
  });

  @override
  State<_EditQuestionDialog> createState() => _EditQuestionDialogState();
}

class _EditQuestionDialogState extends State<_EditQuestionDialog> {
  late TextEditingController _textCtrl;
  late TextEditingController _expectedAnswerCtrl;
  // Persistent controllers cho từng choice (tránh bug tạo lại mỗi rebuild)
  late List<TextEditingController> _choiceControllers;
  late List<bool> _choiceCorrect;
  int _correctIndex = 0;

  bool get _isChoiceType =>
      widget.questionType == QuestionType.multipleChoice ||
      widget.questionType == QuestionType.trueFalse ||
      widget.questionType == QuestionType.math;

  @override
  void initState() {
    super.initState();
    final q = widget.question;

    // Question text
    final text = (q['text'] as String?)?.trim().isNotEmpty == true
        ? q['text'] as String
        : (q['override_text'] as String? ?? '');
    _textCtrl = TextEditingController(text: text);

    // Choices
    final rawList = (q['options'] as List?) ?? (q['choices'] as List?) ?? [];
    final parsed = rawList.map((o) {
      final m = o is Map<String, dynamic> ? o : Map<String, dynamic>.from(o as Map);
      final cc = m['content'];
      final t = (cc is Map ? cc['text'] : null) ?? m['text'] ?? '';
      final correct = m['isCorrect'] == true || m['is_correct'] == true;
      return (text: t.toString(), correct: correct);
    }).toList();

    _choiceControllers = parsed.map((c) => TextEditingController(text: c.text)).toList();
    _choiceCorrect = parsed.map((c) => c.correct).toList();
    _correctIndex = _choiceCorrect.indexWhere((c) => c);
    if (_correctIndex < 0) _correctIndex = 0;

    // Expected answer
    final ans = q['answer'];
    final ea = (ans is Map) ? (ans['expected_answer'] as String? ?? '') : '';
    _expectedAnswerCtrl = TextEditingController(text: ea);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _expectedAnswerCtrl.dispose();
    for (final c in _choiceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final updated = Map<String, dynamic>.from(widget.question);
    final newText = _textCtrl.text.trim();
    updated['text'] = newText;
    updated['override_text'] = newText;

    if (_isChoiceType && _choiceControllers.isNotEmpty) {
      final opts = _choiceControllers.asMap().entries.map((e) {
        final isCorrect = e.key == _correctIndex;
        return <String, dynamic>{
          'id': e.key,
          'text': e.value.text.trim(),
          'isCorrect': isCorrect,
          'is_correct': isCorrect,
        };
      }).toList();
      updated['options'] = opts;
      updated['choices'] = opts.map((o) => <String, dynamic>{
            'id': o['id'],
            'content': {'text': o['text']},
            'is_correct': o['is_correct'],
          }).toList();
    } else {
      final ans = updated['answer'];
      final ansMap = ans is Map<String, dynamic>
          ? Map<String, dynamic>.from(ans)
          : <String, dynamic>{};
      ansMap['expected_answer'] = _expectedAnswerCtrl.text.trim();
      updated['answer'] = ansMap;
    }
    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenH = MediaQuery.of(context).size.height;
    final typeColor = widget.questionType.color;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      child: Container(
        constraints: BoxConstraints(maxHeight: screenH * 0.88),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1923) : Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.lg * 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ───────────��──────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: isDark ? 0.15 : 0.07),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(DesignRadius.lg * 2)),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(DesignRadius.lg),
                    ),
                    child: Icon(Icons.edit_rounded, size: 18, color: typeColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chỉnh sửa câu hỏi',
                          style: DesignTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : DesignColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(DesignRadius.full),
                          ),
                          child: Text(
                            widget.questionType.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable content ───────────────────────────���───────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section: Nội dung câu hỏi
                    _buildSectionLabel(
                      icon: Icons.help_outline_rounded,
                      label: 'NỘI DUNG CÂU HỎI',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _textCtrl,
                      hintText: 'Nhập nội dung câu hỏi...',
                      maxLines: 4,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 20),

                    // Section: Đáp án
                    if (_isChoiceType && _choiceControllers.isNotEmpty) ...[
                      Row(
                        children: [
                          _buildSectionLabelWidget(
                            icon: Icons.radio_button_checked_rounded,
                            label: 'CÁC ĐÁP ÁN',
                            isDark: isDark,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: DesignColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(DesignRadius.full),
                              border: Border.all(color: DesignColors.success.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              'Tap ✓ để chọn đúng',
                              style: TextStyle(
                                fontSize: 11,
                                color: DesignColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(_choiceControllers.length, (i) {
                        final isCorrect = i == _correctIndex;
                        final label = String.fromCharCode(65 + i); // A,B,C,D
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () => setState(() => _correctIndex = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? DesignColors.success.withValues(alpha: isDark ? 0.12 : 0.07)
                                    : (isDark ? const Color(0xFF1A2632) : Colors.grey[50]),
                                borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
                                border: Border.all(
                                  color: isCorrect
                                      ? DesignColors.success
                                      : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
                                  width: isCorrect ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Check icon
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Icon(
                                      isCorrect ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                                      color: isCorrect ? DesignColors.success : (isDark ? Colors.grey[600] : Colors.grey[400]),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Label badge
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: isCorrect
                                          ? DesignColors.success
                                          : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isCorrect ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[600]),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Text input
                                  Expanded(
                                    child: TextField(
                                      controller: _choiceControllers[i],
                                      style: DesignTypography.bodyMedium.copyWith(
                                        color: isDark ? Colors.white : DesignColors.textPrimary,
                                        fontWeight: isCorrect ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Đáp án $label...',
                                        hintStyle: TextStyle(
                                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ] else ...[
                      _buildSectionLabel(
                        icon: Icons.task_alt_rounded,
                        label: 'ĐÁP ÁN MẪU',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _expectedAnswerCtrl,
                        hintText: 'Nhập đáp án mẫu...',
                        maxLines: 4,
                        isDark: isDark,
                        fillColor: DesignColors.success.withValues(alpha: 0.05),
                        borderColor: DesignColors.success.withValues(alpha: 0.3),
                      ),
                    ],

                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),

            // ── Footer buttons ─────────────────────��─────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1923) : Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(DesignRadius.lg * 2)),
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: isDark ? Colors.grey[400] : Colors.grey[600],
                        side: BorderSide(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: DesignTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 4,
                        shadowColor: DesignColors.primary.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Lưu thay đổi',
                            style: DesignTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return _buildSectionLabelWidget(icon: icon, label: label, isDark: isDark);
  }

  Widget _buildSectionLabelWidget({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: DesignColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignRadius.sm),
          ),
          child: Icon(icon, size: 14, color: DesignColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: DesignTypography.labelSmallSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required int maxLines,
    required bool isDark,
    Color? fillColor,
    Color? borderColor,
  }) {
    final bc = borderColor ?? (isDark ? Colors.grey[700]! : Colors.grey[200]!);
    final fc = fillColor ?? (isDark ? Colors.grey[800]!.withValues(alpha: 0.5) : Colors.grey[50]!);
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: DesignTypography.bodyMedium.copyWith(
        color: isDark ? Colors.white : DesignColors.textPrimary,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
        filled: true,
        fillColor: fc,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
          borderSide: BorderSide(color: bc),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
          borderSide: BorderSide(color: bc),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
          borderSide: BorderSide(color: DesignColors.primary, width: 2),
        ),
      ),
    );
  }
}
