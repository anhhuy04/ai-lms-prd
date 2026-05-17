// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/services/ai_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/file_exporter.dart';
import 'package:ai_mls/core/utils/excel_template_generator.dart';
import 'package:ai_mls/core/utils/word_template_generator.dart';
import 'package:ai_mls/data/models/local_temp_file.dart' show FileRole;
import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/learning_objective.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/domain/entities/template_mode.dart';
import 'package:ai_mls/presentation/providers/ai_generation_settings_notifier.dart';
import 'package:ai_mls/presentation/providers/ai_providers.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/learning_objective_providers.dart';
import 'package:ai_mls/presentation/providers/local_temp_file_notifier.dart';
import 'package:ai_mls/presentation/providers/question_bank_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/ai_settings_drawer.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/context_sources_section.dart';
import 'package:ai_mls/widgets/editor/rich_text_toolbar.dart';
import 'package:ai_mls/widgets/objective_selector/objective_selector_sheet.dart';
import 'package:ai_mls/widgets/text/math_text.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

/// Màn hình tạo câu hỏi bằng AI
class TeacherAiGenerateQuestionScreen extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>>? questions; // Danh sách câu hỏi hiện tại

  /// Optional: ID đề thi. Nếu có, StagingAreaWidget sẽ cho phép
  /// "Lưu và Thêm vào Đề thi" (gọi save_questions_to_assignment với p_assignment_id).
  final String? assignmentId;

  const TeacherAiGenerateQuestionScreen({
    super.key,
    this.questions,
    this.assignmentId,
  });

  @override
  ConsumerState<TeacherAiGenerateQuestionScreen> createState() =>
      _TeacherAiGenerateQuestionScreenState();
}

class _TeacherAiGenerateQuestionScreenState
    extends ConsumerState<TeacherAiGenerateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _topicController = TextEditingController();
  final _quantityController = TextEditingController();
  final _focusHintController = TextEditingController();
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

  // Batch progress message (vd "Đang tạo lô 2/3...") — set khi qty > 10
  // và AI gen theo nhiều lô. Hiển thị trong skeleton header thay thế phase
  // text mặc định khi có giá trị (ưu tiên info cụ thể hơn rotate generic).
  String? _batchProgress;

  // Style-template mode: tài liệu là khuôn mẫu về văn phong/cấu trúc
  bool _useAsStyleTemplate = false;

  // Sub-mode cuối cùng dùng khi gọi AI (đã apply auto-downgrade nếu cần).
  // Reset null mỗi lần generate; chỉ set khi Mode 3 + template detect.
  TemplateMode? _effectiveTemplateMode;

  // Câu mẫu gốc dùng cho similarity verification post-hoc.
  List<Map<String, dynamic>>? _templateQuestionsForVerify;

  // Index đang regenerate đơn lẻ
  int? _regeneratingIndex;

  // Gợi ý làm bài
  bool _explanationFeatureEnabled = false; // Global toggle — tiết kiệm token
  final Set<int> _expandedExplanations = {};
  final Set<int> _regeneratingExplanationSet = {};

  // ─── Skeleton loader: rotate phase text trong khi AI gen ─────────────────
  // AI gen mất 5-15s; thay vì button spinner đứng yên, hiện skeleton list +
  // text mô tả tiến độ → user thấy app "đang làm gì đó", giảm cảm giác chậm.
  Timer? _loadingPhaseTimer;
  int _loadingPhase = 0;
  static const List<String> _loadingPhrases = [
    'Đang chuẩn bị yêu cầu cho AI...',
    'AI đang phân tích chủ đề...',
    'Đang sinh câu hỏi & các đáp án...',
    'Đang kiểm tra chất lượng câu hỏi...',
    'Sắp hoàn tất, chỉ vài giây nữa...',
  ];

  void _startLoadingPhases() {
    _loadingPhase = 0;
    _loadingPhaseTimer?.cancel();
    _loadingPhaseTimer = Timer.periodic(const Duration(seconds: 3), (t) {
      // Self-cancel khi gen xong (_isGenerating đã set false ở nhiều chỗ)
      // — tránh phải nhớ stop timer ở mỗi exit path của _handleGenerate.
      if (!mounted || !_isGenerating) {
        t.cancel();
        return;
      }
      setState(() {
        // Dừng ở phase cuối, không loop về 0 — tránh nhấp nháy nếu AI lâu
        _loadingPhase = (_loadingPhase + 1).clamp(
          0,
          _loadingPhrases.length - 1,
        );
      });
    });
  }

  @override
  void dispose() {
    _loadingPhaseTimer?.cancel();
    _topicController.dispose();
    _quantityController.dispose();
    _focusHintController.dispose();
    super.dispose();
  }

  // ── Debug logging ─────────────────────────────────────────────────────────

  void _logGeneratedQuestions(List<Map<String, dynamic>> questions) {
    AppLogger.info('📝 [Result] ══ Generated ${questions.length} câu ══');
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final type =
          (q['type'] as QuestionType?)?.name ?? q['type']?.toString() ?? '?';
      final rawText =
          (q['text'] as String?) ??
          ((q['content'] as Map?)?['text'] as String?) ??
          '';
      final preview = rawText.length > 90
          ? '${rawText.substring(0, 90)}…'
          : rawText;
      // B-003: derive label A/B/C/D từ index, không phụ thuộc field 'label' (AI không gen field này).
      final opts = (q['options'] as List?) ?? (q['choices'] as List?);
      String optStr = '';
      int correctIdx = -1;
      if (opts != null && opts.isNotEmpty) {
        optStr = opts
            .take(4)
            .toList()
            .asMap()
            .entries
            .map((e) {
              final o = e.value;
              final lbl = String.fromCharCode(65 + e.key); // A, B, C, D
              if (o is Map) {
                final txt =
                    (o['text'] as String?) ??
                    ((o['content'] is Map
                            ? (o['content'] as Map)['text']
                            : null)
                        as String?) ??
                    o.toString();
                if (o['isCorrect'] == true || o['is_correct'] == true) {
                  correctIdx = e.key;
                }
                return '$lbl.$txt'.trim();
              }
              return '$lbl.${o.toString()}';
            })
            .join(' | ');
        if (optStr.length > 120) optStr = '${optStr.substring(0, 120)}…';
      }
      // B-002: derive answer từ correct choice index thay vì q['answer'] (AI gen không có field này).
      final answer = correctIdx >= 0
          ? String.fromCharCode(65 + correctIdx)
          : (q['answer'] is Map &&
                    (q['answer'] as Map)['expected_answer'] != null
                ? '"${((q['answer'] as Map)['expected_answer'] as String).substring(0, ((q['answer'] as Map)['expected_answer'] as String).length.clamp(0, 40))}…"'
                : '?');
      final sim = q['_similarityWarning'] is Map
          ? ' ⚠sim=${(q['_similarityWarning'] as Map)['score']}% (tpl#${(q['_similarityWarning'] as Map)['templateIndex']})'
          : '';
      final tags = (q['tags'] as List?)?.join(',') ?? '';
      AppLogger.info(
        '  Q${i + 1}[$type|diff=${q['difficulty']}] $preview\n'
        '       → ans=$answer${optStr.isNotEmpty ? ' | opts: $optStr' : ''}$sim\n'
        '       → tags: $tags',
      );
    }
    AppLogger.info('📝 [Result] ══ End ══');
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
          errors.add(
            'Câu ${i + 1}: ${e.toString().replaceAll('Exception: ', '')}',
          );
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
            title: Text(
              success > 0
                  ? 'Lưu một phần ($success/${questions.length} câu)'
                  : 'Lưu thất bại',
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (success > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '✅ Đã lưu thành công: $success câu',
                        style: const TextStyle(color: DesignColors.success),
                      ),
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

  /// Xuất danh sách câu hỏi đã generate ra file Word .docx.
  /// LaTeX inline (`$...$`) được convert sang OMML để Word render đúng phân số/mũ/căn.
  /// Hiển thị bottom sheet chọn định dạng tải về (Word/Excel).
  Future<void> _showExportSheet() async {
    final questions = _generatedQuestions;
    if (questions == null || questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa có câu hỏi để xuất. Hãy tạo trước.'),
          backgroundColor: DesignColors.warning,
        ),
      );
      return;
    }

    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignRadius.lg * 1.5),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: MediaQuery(
          // Reset textScaler về 1.0 — bottom sheet content có font size chuẩn,
          // không bị scale theo Accessibility setting toàn app.
          data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.noScaling),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text(
                  'Chọn định dạng tải về',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              _ExportSheetTile(
                icon: Icons.description_rounded,
                color: Colors.blue,
                title: 'Word (.docx)',
                subtitle: 'In ấn đề với LaTeX render đẹp',
                onTap: () => Navigator.pop(ctx, 'word'),
              ),
              _ExportSheetTile(
                icon: Icons.table_chart_rounded,
                color: Colors.green,
                title: 'Excel (.xlsx)',
                subtitle: 'Bảng dữ liệu — STT, loại, nội dung, đáp án',
                onTap: () => Navigator.pop(ctx, 'excel'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (!mounted || choice == null) return;
    if (choice == 'word') {
      await _handleExportToWord();
    } else if (choice == 'excel') {
      await _handleExportToExcel();
    }
  }

  Future<void> _handleExportToExcel() async {
    final questions = _generatedQuestions;
    if (questions == null || questions.isEmpty) return;

    try {
      AppLogger.info('[ExportExcel] Bắt đầu xuất ${questions.length} câu');
      final topic = _topicController.text.trim();
      final title = topic.isNotEmpty ? topic : 'Đề kiểm tra AI';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'de_ai_$timestamp.xlsx';

      final bytes = ExcelTemplateGenerator.exportQuestions(
        questions,
        title: title,
      );
      if (bytes == null) {
        throw Exception('Không tạo được file Excel');
      }

      final saved = await exportFile(Uint8List.fromList(bytes), fileName);
      if (!mounted) return;

      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xuất $fileName (${questions.length} câu)'),
            backgroundColor: DesignColors.success,
          ),
        );
        AppLogger.info(
          '[ExportExcel] Saved: $fileName, ${bytes.length} bytes',
        );
      } else {
        AppLogger.info('[ExportExcel] User canceled save dialog');
      }
    } catch (e, st) {
      AppLogger.error('[ExportExcel] Failed: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xuất Excel: $e'),
          backgroundColor: DesignColors.error,
        ),
      );
    }
  }

  Future<void> _handleExportToWord() async {
    final questions = _generatedQuestions;
    if (questions == null || questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa có câu hỏi để xuất. Hãy tạo trước.'),
          backgroundColor: DesignColors.warning,
        ),
      );
      return;
    }

    try {
      AppLogger.info('[ExportWord] Bắt đầu xuất ${questions.length} câu');
      final topic = _topicController.text.trim();
      final title = topic.isNotEmpty ? topic : 'Đề kiểm tra AI';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'de_ai_$timestamp.docx';

      final bytes = WordTemplateGenerator.generateFromQuestions(
        questions,
        title: title,
        includeAnswerKey: true,
      );

      final saved = await exportFile(bytes, fileName);
      if (!mounted) return;

      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xuất $fileName (${questions.length} câu)'),
            backgroundColor: DesignColors.success,
          ),
        );
        AppLogger.info('[ExportWord] Saved: $fileName, ${bytes.length} bytes');
      } else {
        AppLogger.info('[ExportWord] User canceled save dialog');
      }
    } catch (e, st) {
      AppLogger.error('[ExportWord] Failed: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xuất Word: $e'),
          backgroundColor: DesignColors.error,
        ),
      );
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
        final text =
            (choiceContent is Map<String, dynamic>
                ? choiceContent['text']
                : null) ??
            opt['text'] ??
            '';
        final isCorrect = opt['is_correct'] == true || opt['isCorrect'] == true;
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
          (q['answer'] is Map
              ? (q['answer'] as Map)['general_explanation']?.toString().trim()
              : null);
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
          'is_global': false, // private của GV này
          'source': 'ai_generated', // track provenance
          'created_by': userId, // BẮT BUỘC để RLS không nuốt mất
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

    // Read mode first — determines validation path
    final aiSettings = ref.read(aiGenerationSettingsNotifierProvider);
    final currentMode = aiSettings.processingMode;

    // Mode 1 only: validate topic + form fields
    var topic = _topicController.text.trim();
    if (currentMode == ProcessingMode.promptOnly) {
      AppLogger.info(
        '🔵 [Generate] topic="$topic", _isQtyMismatch=$_isQtyMismatch, '
        '_selectedTypes=$_selectedTypes, _totalTypedQty=$_totalTypedQty, _limitQty=$_limitQty',
      );

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
      if (_isQtyMismatch) {
        AppLogger.warning('🟡 [Generate] EXIT: _isQtyMismatch=true');
        return;
      }
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
      _useAsStyleTemplate = false; // reset mỗi lần generate
      _effectiveTemplateMode = null;
      _templateQuestionsForVerify = null;
    });
    _startLoadingPhases(); // Rotate text "Đang chuẩn bị... → Sắp xong..."

    try {
      // D-07~D-11: Log selected file IDs and processing mode for Plan 07 wiring
      AppLogger.info(
        '[Generate] processingMode=${currentMode.name}, '
        'selectedFileIds(${aiSettings.selectedFileIds.length})=${aiSettings.selectedFileIds}',
      );

      // documentContext: text extracted from local files for extraction mode
      String? documentContext;

      if (currentMode == ProcessingMode.extraction) {
        final selectedIds = aiSettings.selectedFileIds;
        if (selectedIds.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Vui lòng chọn ít nhất 1 tài liệu ở Nguồn Dữ Liệu trước khi trích xuất.',
              ),
              backgroundColor: DesignColors.warning,
            ),
          );
          setState(() => _isGenerating = false);
          return;
        }

        // ── Excel template: parse trực tiếp, không cần AI ─────────────────
        final templateQuestions = ref
            .read(localTempFilesProvider.notifier)
            .getTemplateQuestionsForIds(selectedIds);

        if (templateQuestions.isNotEmpty) {
          if (mounted) {
            setState(() {
              _generatedQuestions = templateQuestions;
              _isGenerating = false;
              _batchProgress = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Đã tải ${templateQuestions.length} câu hỏi từ file Excel',
                ),
                backgroundColor: DesignColors.success,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        // ── Word (.docx): extract text → AI ───────────────────────────────
        final docText = ref
            .read(localTempFilesProvider.notifier)
            .getExtractedTextForIds(selectedIds);

        if (docText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'File Excel không đúng định dạng mẫu và file Word không có nội dung đọc được. '
                'Vui lòng dùng file mẫu Excel hoặc file Word có nội dung.',
              ),
              backgroundColor: DesignColors.warning,
            ),
          );
          setState(() => _isGenerating = false);
          return;
        }

        // Smart truncate nếu tài liệu quá dài
        final truncated = AiService.smartTruncate(docText);
        if (truncated.wasTruncated && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tài liệu dài (${truncated.totalChars} ký tự) — '
                'đã dùng ${truncated.usedChars} ký tự để tránh tràn context AI.',
              ),
              backgroundColor: DesignColors.warning,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        documentContext = truncated.text;

        // Phát hiện tài liệu mẫu (có cấu trúc "Câu N:") → dùng style-template mode
        _useAsStyleTemplate = AiService.isTemplateStyleDoc(docText);
        AppLogger.info(
          '[Generate] useAsStyleTemplate=$_useAsStyleTemplate, '
          'docChars=${truncated.usedChars}/${truncated.totalChars}',
        );

        // Tiếp tục xuống AI generation bên dưới (KHÔNG return)
        if (topic.isEmpty) topic = 'Câu hỏi từ tài liệu';
      }

      if (currentMode == ProcessingMode.ragGeneration) {
        final selectedIds = aiSettings.selectedFileIds;
        AppLogger.info(
          '[Mode3] selectedIds(${selectedIds.length})=$selectedIds',
        );

        // Log trạng thái từng file trong provider để debug
        final allFiles = ref.read(localTempFilesProvider);
        for (final f in allFiles) {
          AppLogger.info(
            '[Mode3] file=${f.filename} | id=${f.id} | mime=${f.mimeType} '
            '| extractedChars=${f.extractedText?.length ?? 0} '
            '| parsedQty=${f.parsedQuestions?.length ?? 0} '
            '| isExtracting=${f.isExtracting} '
            '| selected=${selectedIds.contains(f.id)}',
          );
        }

        if (selectedIds.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Vui lòng chọn ít nhất 1 tài liệu ở Nguồn Dữ Liệu.',
              ),
              backgroundColor: DesignColors.warning,
            ),
          );
          setState(() => _isGenerating = false);
          return;
        }

        // Mode 3 — tách 2 đường text:
        //   • rawText (getExtractedTextForIds): tab-separated rows nguyên xi
        //     → CHỈ dùng để detect (regex isTemplateStyleDoc).
        //   • aiText (getKnowledgeContextForIds khi template): cùng 1 file,
        //     options đã shuffle + KHÔNG có cột "Đáp án đúng" + có header
        //     "[Tài liệu mẫu — Hãy tạo câu hỏi MỚI]" → ngăn AI bê nguyên đề
        //     và đáp án từ Excel template.
        //   • aiText khi không phải template: rớt về raw extractedText (RAG
        //     thuần) — không đổi behavior cho .docx/.pdf lý thuyết.
        final notifier = ref.read(localTempFilesProvider.notifier);
        final rawText = notifier.getExtractedTextForIds(selectedIds);

        AppLogger.info('[Mode3] rawText → ${rawText.length} chars');

        if (rawText.isEmpty) {
          final selectedFiles = allFiles.where(
            (f) => selectedIds.contains(f.id),
          );
          for (final f in selectedFiles) {
            AppLogger.warning(
              '[Mode3] EMPTY reason: ${f.filename} '
              'extractedChars=${f.extractedText?.length ?? 0} '
              'parsedQty=${f.parsedQuestions?.length ?? 0}',
            );
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tài liệu chưa có nội dung đọc được. '
                'Hỗ trợ: Word (.docx), Excel (.xlsx), PDF (.pdf).',
              ),
              backgroundColor: DesignColors.warning,
            ),
          );
          setState(() => _isGenerating = false);
          return;
        }

        // Detect file mẫu: phải có parsedQuestions VÀ effectiveRole = template.
        // Trước đây bỏ qua role → file bị đổi sang KT vẫn kích hoạt template mode.
        final hasExcelTemplate = allFiles.any(
          (f) =>
              selectedIds.contains(f.id) &&
              f.parsedQuestions != null &&
              f.parsedQuestions!.isNotEmpty &&
              f.effectiveRole == FileRole.template,
        );
        // isTemplateStyleDoc chỉ dùng rawText của file KT (không có parsedQ) →
        // chỉ kích hoạt khi file Word có cấu trúc "Câu N:" và role là template.
        final hasDocxTemplate =
            AiService.isTemplateStyleDoc(rawText) &&
            allFiles.any(
              (f) =>
                  selectedIds.contains(f.id) &&
                  f.effectiveRole == FileRole.template &&
                  f.parsedQuestions == null,
            );
        _useAsStyleTemplate = hasExcelTemplate || hasDocxTemplate;
        AppLogger.info(
          '[Mode3] hasExcelTemplate=$hasExcelTemplate, '
          'hasDocxTemplate=$hasDocxTemplate → '
          'useAsStyleTemplate=$_useAsStyleTemplate',
        );

        // Lấy templateMode từ provider — quyết định schema-only vs full text.
        // Default styleOnly (an toàn) nếu user chưa tương tác.
        final templateMode = ref
            .read(aiGenerationSettingsNotifierProvider)
            .templateMode;

        // FIX-V3V2: Khi user đánh dấu file role = template (qua badge Mẫu)
        // → ép template active dù file ngắn / không match isTemplateStyleDoc.
        // Tránh hệ thống tự đẩy từ "Cùng dạng" sang "Tạo mới" khi tài liệu
        // mẫu chỉ có 1-2 câu. Thay thế toggle "Coi tài liệu là MẪU" cũ.
        if (!_useAsStyleTemplate) {
          final hasAnyTemplateRoleFile = allFiles.any(
            (f) =>
                selectedIds.contains(f.id) &&
                f.effectiveRole == FileRole.template,
          );
          if (hasAnyTemplateRoleFile) {
            _useAsStyleTemplate = true;
            AppLogger.info(
              '[Mode3] User-marked template role → useAsStyleTemplate=true '
              '(submode=${templateMode.name})',
            );
          }
        }
        // FIX-V3V2: BỎ auto-downgrade sameForm → styleOnly.
        // User chọn sameForm hay styleOnly → tôn trọng, không tự chuyển
        // (kể cả khi tài liệu mẫu ngắn hoặc không phải toàn MCQ).
        final templateQuestionsForCheck = notifier.getTemplateQuestionsForIds(
          selectedIds,
        );
        final effectiveTemplateMode = templateMode;
        // Lưu state để dùng ở các call site sau (similarity verify, regenerate).
        _effectiveTemplateMode = _useAsStyleTemplate
            ? effectiveTemplateMode
            : null;
        _templateQuestionsForVerify =
            _useAsStyleTemplate && templateQuestionsForCheck.isNotEmpty
            ? templateQuestionsForCheck
            : null;
        // GAP-4: warn khi qty > templateSize * 3 trong sameForm
        if (effectiveTemplateMode == TemplateMode.sameForm && mounted) {
          final qty = _limitQty;
          final templateSize = templateQuestionsForCheck.length;
          if (templateSize > 0 && qty > templateSize * 3) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Yêu cầu $qty câu từ mẫu $templateSize câu '
                  '— AI có thể bị lặp. Nên giảm xuống ≤ ${templateSize * 3} câu.',
                ),
                backgroundColor: DesignColors.warning,
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
        // Build aiText: template-style dùng knowledge context (anti-leak), còn lại raw.
        final aiText = _useAsStyleTemplate
            ? notifier.getKnowledgeContextForIds(
                selectedIds,
                templateMode: effectiveTemplateMode,
              )
            : rawText;

        final truncated = AiService.smartTruncate(aiText);
        AppLogger.info(
          '[Mode3] smartTruncate: total=${truncated.totalChars}, used=${truncated.usedChars}, '
          'wasTruncated=${truncated.wasTruncated}',
        );

        if (truncated.wasTruncated && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tài liệu dài (${truncated.totalChars} ký tự) — '
                'đã dùng ${truncated.usedChars} ký tự để tránh tràn context AI.',
              ),
              backgroundColor: DesignColors.warning,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        documentContext = truncated.text;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _useAsStyleTemplate
                    ? 'Phát hiện tài liệu bài mẫu — AI sẽ tạo câu cùng dạng, nội dung mới.'
                    : 'Phát hiện tài liệu lý thuyết — AI sẽ tạo câu dựa trên kiến thức trong tài liệu.',
              ),
              backgroundColor: _useAsStyleTemplate
                  ? DesignColors.success
                  : DesignColors.primary,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        // Topic từ focus hint, fallback về tài liệu
        final focusHint = _focusHintController.text.trim();
        topic = focusHint.isNotEmpty ? focusHint : 'Câu hỏi từ tài liệu';
        AppLogger.info(
          '[Mode3] useAsStyleTemplate=$_useAsStyleTemplate, '
          'docChars=${truncated.usedChars}, topic="$topic"',
        );
      }

      final aiRepository = ref.read(aiRepositoryProvider);
      int batchCount = 0;

      void appendRaw(String raw) {
        String pretty = raw;
        try {
          pretty = const JsonEncoder.withIndent('  ').convert(jsonDecode(raw));
        } catch (_) {}
        if (mounted) {
          setState(() {
            _rawApiResponse = _rawApiResponse == null
                ? raw
                : '${_rawApiResponse!}\n\n$raw';
            _rawApiResponsePretty = _rawApiResponsePretty == null
                ? pretty
                : '${_rawApiResponsePretty!}\n\n$pretty';
          });
        }
      }

      List<Map<String, dynamic>> generatedQuestions;

      if (_selectedTypes.isEmpty) {
        // ── Auto mode: single call ──────────────────────────────────────────
        final quantity = int.tryParse(_quantityController.text.trim()) ?? 10;
        generatedQuestions = await aiRepository.generateQuestions(
          topic: topic,
          quantity: quantity,
          difficulty: _difficulty,
          questionType: null,
          documentContext: documentContext,
          useAsStyleTemplate: _useAsStyleTemplate,
          templateMode: _effectiveTemplateMode,
          templateQuestions: _templateQuestionsForVerify,
          templateCount: _templateQuestionsForVerify?.length,
          highAccuracyMode: aiSettings.highAccuracyMode,
          onRawResponse: (raw) {
            batchCount++;
            if (mounted) {
              setState(
                () => _batchProgress = quantity > 10
                    ? 'Đang tạo lô $batchCount...'
                    : null,
              );
            }
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
            setState(
              () => _batchProgress =
                  'Đang tạo ${_typeLabel(typeKey)} ($qty câu) — ${i + 1}/${typeList.length}...',
            );
          }
          final results = await aiRepository.generateQuestions(
            topic: topic,
            quantity: qty,
            difficulty: _difficulty,
            questionType: typeKey,
            documentContext: documentContext,
            useAsStyleTemplate: _useAsStyleTemplate,
            templateMode: _effectiveTemplateMode,
            templateQuestions: _templateQuestionsForVerify,
            templateCount: _templateQuestionsForVerify?.length,
            highAccuracyMode: aiSettings.highAccuracyMode,
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

      _logGeneratedQuestions(generatedQuestions);
      // KHÔNG pop tự động - để user có thể test nhiều lần
      // User sẽ click "Xác nhận" để pop và trả về questions
    } on AiUncertaintyException catch (e) {
      AppLogger.warning('[Generate] AI uncertainty: ${e.code} — ${e.reason}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '⚠ AI cần thêm thông tin',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(e.reason, style: const TextStyle(color: Colors.white)),
              ],
            ),
            backgroundColor: DesignColors.warning,
            duration: const Duration(seconds: 8),
          ),
        );
      }
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
                Icon(Icons.warning_amber_rounded, color: DesignColors.warning),
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
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  String _extractQuestionText(Map<String, dynamic> q) {
    final isMath = _isMathQuestion(q);

    String render(String t) =>
        _renderBlankPlaceholders(t.trim(), isMath: isMath);

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
      if (RegExp(
        r'toán|math|số|phép|tính|cộng|trừ|nhân|chia|đại số|hình học|phương trình',
      ).hasMatch(tagStr)) {
        return true;
      }
    }

    // Kiểm tra text có chứa phép toán (số + ký tự toán học)
    final text = (q['override_text'] ?? q['text'] ?? '').toString();
    if (RegExp(r'[\d]+\s*[+\-×÷*/=<>]|\b[xy]\s*=').hasMatch(text)) return true;
    // LaTeX commands phổ biến → xác định là math
    if (RegExp(
      r'\\(frac|sqrt|sum|int|alpha|beta|theta|pi|infty|leq|geq|neq|cdot|times|div|pm)|\$[^\$]+\$',
    ).hasMatch(text)) {
      return true;
    }
    return false;
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
              border: Border.all(
                color: DesignColors.success.withValues(alpha: 0.3),
              ),
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
  int get _limitQty => int.tryParse(_quantityController.text.trim()) ?? 10;
  int get _totalTypedQty => _typeQuantities.values.fold(0, (a, b) => a + b);
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

  /// Nếu [fresh] thiếu/null/empty cho [key] thì copy từ [old] (giữ user edit).
  void _carryOverIfMissing(
    Map<String, dynamic> fresh,
    Map<String, dynamic> old,
    String key,
    bool Function(dynamic) hasValue,
  ) {
    final freshVal = fresh[key];
    if (!hasValue(freshVal) && hasValue(old[key])) {
      fresh[key] = old[key];
    }
  }

  Future<void> _handleRegenerateSingle(int index) async {
    final aiSettings = ref.read(aiGenerationSettingsNotifierProvider);
    final currentMode = aiSettings.processingMode;

    String topic;
    String? documentContext;
    bool regenUseAsStyleTemplate = false;
    TemplateMode? regenTemplateMode;

    if (currentMode == ProcessingMode.ragGeneration) {
      // Mode 3: re-detect template state tại thời điểm regen (GAP-3 fix)
      final focusHint = _focusHintController.text.trim();
      topic = focusHint.isNotEmpty ? focusHint : 'Câu hỏi từ tài liệu';
      final selectedIds = aiSettings.selectedFileIds;
      if (selectedIds.isNotEmpty) {
        final allFiles = ref.read(localTempFilesProvider);
        final notifier = ref.read(localTempFilesProvider.notifier);
        // Re-detect live từ role hiện tại của file (không dùng cached state)
        regenUseAsStyleTemplate = allFiles.any(
          (f) =>
              selectedIds.contains(f.id) &&
              f.parsedQuestions != null &&
              f.parsedQuestions!.isNotEmpty &&
              f.effectiveRole == FileRole.template,
        );
        regenTemplateMode = regenUseAsStyleTemplate
            ? aiSettings.templateMode
            : null;
        final docText = regenUseAsStyleTemplate
            ? notifier.getKnowledgeContextForIds(
                selectedIds,
                templateMode: aiSettings.templateMode,
              )
            : notifier.getExtractedTextForIds(selectedIds);
        if (docText.isNotEmpty) {
          documentContext = AiService.smartTruncate(docText).text;
        }
      }
    } else if (currentMode == ProcessingMode.extraction) {
      // Mode 2: lấy raw text từ tài liệu
      final selectedIds = aiSettings.selectedFileIds;
      if (selectedIds.isEmpty) return;
      final docText = ref
          .read(localTempFilesProvider.notifier)
          .getExtractedTextForIds(selectedIds);
      if (docText.isEmpty) return;
      documentContext = AiService.smartTruncate(docText).text;
      topic = 'Câu hỏi từ tài liệu';
    } else {
      // Mode 1: dùng topic từ ô nhập
      topic = _topicController.text.trim();
      if (topic.isEmpty) return;
    }

    setState(() => _regeneratingIndex = index);
    try {
      final aiRepository = ref.read(aiRepositoryProvider);
      final result = await aiRepository.generateQuestions(
        topic: topic,
        quantity: 1,
        difficulty: _difficulty,
        questionType: _typeKeyForIndex(index),
        documentContext: documentContext,
        useAsStyleTemplate: regenUseAsStyleTemplate,
        templateMode: regenTemplateMode,
        templateQuestions: regenUseAsStyleTemplate
            ? _templateQuestionsForVerify
            : null,
        templateCount: regenUseAsStyleTemplate
            ? _templateQuestionsForVerify?.length
            : null,
        highAccuracyMode: aiSettings.highAccuracyMode,
      );
      if (result.isNotEmpty && mounted) {
        setState(() {
          final updated = List<Map<String, dynamic>>.from(_generatedQuestions!);
          final old = updated[index];
          final fresh = Map<String, dynamic>.from(result.first);
          // Merge: AI có thể bỏ qua metadata (tags/difficulty/learningObjectives/hints)
          // → giữ lại giá trị user đã đặt thay vì xoá sạch.
          _carryOverIfMissing(fresh, old, 'tags', (v) => v is List && v.isNotEmpty);
          _carryOverIfMissing(fresh, old, 'difficulty', (v) => v is num);
          _carryOverIfMissing(
            fresh,
            old,
            'learningObjectives',
            (v) => v is List && v.isNotEmpty,
          );
          _carryOverIfMissing(fresh, old, 'hints', (v) => v is List && v.isNotEmpty);
          updated[index] = fresh;
          _generatedQuestions = updated;
        });
      }
    } on AiUncertaintyException catch (e) {
      AppLogger.warning(
        '[RegenSingle] AI uncertainty: ${e.code} — ${e.reason}',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠ AI cần thêm thông tin: ${e.reason}'),
          backgroundColor: DesignColors.warning,
          duration: const Duration(seconds: 6),
        ),
      );
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
        final v =
            parsed['explanation'] ??
            parsed['text'] ??
            parsed['content'] ??
            parsed['response'];
        return v?.toString().trim().isEmpty == true
            ? null
            : v?.toString().trim();
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
    final aiSettings = ref.watch(aiGenerationSettingsNotifierProvider);
    final mode = aiSettings.processingMode;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    // GAP-7: disable Generate khi tất cả file đã chọn không có nội dung
    final allFiles = ref.watch(localTempFilesProvider);
    final selectedFileIds = aiSettings.selectedFileIds.toSet();
    final allSelectedFilesEmpty =
        mode == ProcessingMode.ragGeneration &&
        selectedFileIds.isNotEmpty &&
        allFiles
            .where((f) => selectedFileIds.contains(f.id))
            .every(
              (f) =>
                  !f.isExtracting &&
                  (f.extractedText?.isEmpty ?? true) &&
                  (f.parsedQuestions?.isEmpty ?? true),
            );

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: DesignColors.moonLight,
      endDrawer: const AiSettingsDrawer(),
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
                    IconButton(
                      onPressed: () =>
                          _scaffoldKey.currentState?.openEndDrawer(),
                      icon: Icon(
                        Icons.more_vert,
                        size: DesignIcons.mdSize,
                        color: isDark
                            ? DesignColors.white
                            : DesignColors.textSecondary,
                      ),
                      tooltip: 'Cài đặt AI',
                    ),
                  ],
                ),
              ),

              _buildModeTabsSection(context, isDark),

              // Form Content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      DesignSpacing.lg,
                      DesignSpacing.lg,
                      DesignSpacing.lg,
                      // Đủ chỗ cho bottom action bar (tối đa 2 hàng nút ~102px) + safe area
                      MediaQuery.of(context).padding.bottom + 112,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Modes 2 & 3: hint card + inline ContextSourcesSection
                        if (mode != ProcessingMode.promptOnly) ...[
                          _buildModeHintCard(context, mode, isDark),
                          SizedBox(height: DesignSpacing.lg),
                          ContextSourcesSection(
                            onSelectionChanged: (ids) => ref
                                .read(
                                  aiGenerationSettingsNotifierProvider.notifier,
                                )
                                .setSelectedFileIds(ids),
                            // Badge Mẫu/Kiến thức chỉ có nghĩa ở Mode 3
                            showRoleBadge: mode == ProcessingMode.ragGeneration,
                            isTemplateActive: _useAsStyleTemplate,
                          ),
                          SizedBox(height: DesignSpacing.lg),
                        ],

                        // Mode 3 only: focus instruction field
                        if (mode == ProcessingMode.ragGeneration) ...[
                          Text(
                            'Lệnh hướng dẫn AI (tùy chọn)',
                            style: DesignTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : DesignColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: DesignSpacing.xs),
                          RichTextToolbar(controller: _focusHintController),
                          SizedBox(height: DesignSpacing.sm),
                          TextFormField(
                            controller: _focusHintController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText:
                                  'VD: Chỉ hỏi về chương 3 – quang hợp, ưu tiên câu suy luận',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.grey[800]!.withValues(alpha: 0.5)
                                  : Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  DesignRadius.md,
                                ),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  DesignRadius.md,
                                ),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: DesignSpacing.xl),
                        ],

                        // Mode 1 only: topic input
                        if (mode == ProcessingMode.promptOnly) ...[
                          _buildTopicSection(context, isDark),
                          SizedBox(height: DesignSpacing.xxl),
                        ],

                        // Quantity — modes 1 and 3 (not extraction)
                        if (mode != ProcessingMode.extraction) ...[
                          _buildQuantitySection(context, isDark),
                          SizedBox(height: DesignSpacing.md),
                          if (_selectedTypes.isNotEmpty &&
                              mode != ProcessingMode.extraction) ...[
                            _buildPerTypeQtySection(context, isDark),
                            SizedBox(height: DesignSpacing.xxl),
                          ] else
                            SizedBox(height: DesignSpacing.lg),
                        ],

                        // Difficulty + Type chips — Modes 1 & 3
                        if (mode != ProcessingMode.extraction) ...[
                          _buildDifficultySection(context, isDark),
                          SizedBox(height: DesignSpacing.xxl),
                          _buildQuestionTypeSection(context, isDark),
                          SizedBox(height: DesignSpacing.xxl),
                        ],

                        // Skeleton loader (Cách 2) — ưu tiên hơn result cũ.
                        // Khi user bấm "Tạo lại", _generatedQuestions vẫn còn
                        // data cũ → nếu render result section, user nghĩ app
                        // "đơ" trong 5-15s đợi AI mà không có loading visual.
                        // Đặt skeleton TRƯỚC để ẩn data cũ trong khi gen.
                        if (_isGenerating) ...[
                          SizedBox(height: DesignSpacing.xxl),
                          _buildSkeletonResponseSection(context, isDark),
                        ]
                        // AI Response (all modes — shows after generate done)
                        else if (_generatedQuestions != null) ...[
                          SizedBox(height: DesignSpacing.xxl),
                          _buildAiResponseSection(context, isDark),
                        ],

                        // Raw API debug (all modes)
                        if (kDebugMode &&
                            (_rawApiResponse != null ||
                                _rawApiResponsePretty != null)) ...[
                          SizedBox(height: DesignSpacing.lg),
                          _buildRawApiResponseSection(context, isDark),
                        ],

                        SizedBox(height: DesignSpacing.md),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Compact Bottom Action Bar ──────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2632) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Warning khi tổng chưa khớp — compact inline
                      if (_isQtyMismatch)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 14,
                                color: DesignColors.error,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Tổng $_totalTypedQty ≠ $_limitQty câu. Chỉnh lại để tạo.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: DesignColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Trạng thái 1: Chưa generate → nút Generate đơn
                      if (_generatedQuestions == null ||
                          _generatedQuestions!.isEmpty)
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            key: const ValueKey('btn_generate'),
                            onPressed:
                                (_isGenerating ||
                                    _isQtyMismatch ||
                                    allSelectedFilesEmpty)
                                ? null
                                : _handleGenerate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isGenerating
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        mode == ProcessingMode.extraction
                                            ? Icons.content_paste_search_rounded
                                            : mode ==
                                                  ProcessingMode.ragGeneration
                                            ? Icons.auto_stories_rounded
                                            : Icons.auto_awesome,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        mode == ProcessingMode.extraction
                                            ? 'Trích xuất câu hỏi'
                                            : mode ==
                                                  ProcessingMode.ragGeneration
                                            ? 'Sinh từ tài liệu'
                                            : 'Tạo câu hỏi',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                      // Trạng thái 2: Đã generate → 2 hàng nút
                      if (_generatedQuestions != null &&
                          _generatedQuestions!.isNotEmpty)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Hàng 1: Reset + Tạo lại
                            SizedBox(
                              height: 38,
                              child: Row(
                                children: [
                                  // Reset — icon-only
                                  SizedBox(
                                    width: 38,
                                    height: 38,
                                    child: OutlinedButton(
                                      onPressed: () {
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
                                        padding: EdgeInsets.zero,
                                        foregroundColor: DesignColors.error,
                                        side: BorderSide(
                                          color: DesignColors.error.withValues(
                                            alpha: 0.4,
                                          ),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 18,
                                        color: DesignColors.error,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Tải xuống — icon-only, mở bottom sheet chọn Word/Excel
                                  Tooltip(
                                    message:
                                        'Tải xuống danh sách câu hỏi (Word hoặc Excel)',
                                    child: Semantics(
                                      label: 'Tải xuống',
                                      button: true,
                                      child: SizedBox(
                                        width: 38,
                                        height: 38,
                                        child: OutlinedButton(
                                          key: const ValueKey(
                                            'btn_export_word',
                                          ),
                                          onPressed:
                                              (_generatedQuestions == null ||
                                                  _generatedQuestions!
                                                      .isEmpty ||
                                                  _isSavingToBank ||
                                                  _isGenerating)
                                              ? null
                                              : _showExportSheet,
                                          style: OutlinedButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            foregroundColor:
                                                DesignColors.primary,
                                            side: BorderSide(
                                              color: DesignColors.primary
                                                  .withValues(alpha: 0.4),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.file_download_rounded,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Tạo lại
                                  Expanded(
                                    child: SizedBox(
                                      height: 38,
                                      child: OutlinedButton.icon(
                                        key: const ValueKey(
                                          'btn_regenerate_all',
                                        ),
                                        onPressed:
                                            (_isGenerating ||
                                                _isQtyMismatch ||
                                                allSelectedFilesEmpty)
                                            ? null
                                            : _handleGenerate,
                                        icon: Icon(
                                          Icons.auto_awesome,
                                          size: 15,
                                          color: _isGenerating
                                              ? Colors.grey
                                              : DesignColors.primary,
                                        ),
                                        label: Text(
                                          'Tạo lại',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: _isGenerating
                                                ? Colors.grey
                                                : DesignColors.primary,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: DesignColors.primary
                                                .withValues(alpha: 0.4),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Hàng 2: Lưu Bank + Xác nhận
                            SizedBox(
                              height: 38,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 38,
                                      child: OutlinedButton.icon(
                                        onPressed:
                                            (_isSavingToBank || _isGenerating)
                                            ? null
                                            : _handleSaveToQuestionBank,
                                        icon: Icon(
                                          _isSavingToBank
                                              ? Icons.hourglass_top_rounded
                                              : Icons.cloud_upload_outlined,
                                          size: 15,
                                        ),
                                        label: Text(
                                          _isSavingToBank
                                              ? 'Đang lưu...'
                                              : 'Lưu vào Bank',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: DesignColors.primary,
                                          side: BorderSide(
                                            color: DesignColors.primary
                                                .withValues(alpha: 0.4),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: SizedBox(
                                      height: 38,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          context.pop(_generatedQuestions);
                                        },
                                        icon: const Icon(
                                          Icons.check_rounded,
                                          size: 15,
                                        ),
                                        label: const Text(
                                          'Xác nhận',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: DesignColors.success,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // [Xóa overlay đen full-screen] — trước đây hiển thị spinner +
          // _batchProgress dạng modal che cả màn không scroll được. Giờ thay
          // bằng skeleton inline (_buildSkeletonResponseSection) — user thấy
          // tiến độ MÀ vẫn scroll được toàn UI, không bị block.
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
          RichTextToolbar(controller: _topicController),
          SizedBox(height: DesignSpacing.sm),
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
            keyboardType: const TextInputType.numberWithOptions(
              signed: false,
              decimal: false,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
            ],
            onChanged: (_) => setState(() {}), // rebuild để cập nhật badge
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return null; // trống = auto
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
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white : DesignColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Để trống = tự động',
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
  static const _kTypeOptions = [
    ('multiple_choice', 'Trắc nghiệm', Icons.check_box_outlined),
    ('true_false', 'Đúng / Sai', Icons.toggle_on_outlined),
    ('essay', 'Tự luận', Icons.edit_note_outlined),
    ('short_answer', 'Trả lời ngắn', Icons.short_text_rounded),
    ('fill_blank', 'Điền khuyết', Icons.text_fields_rounded),
    ('math', 'Bài toán', Icons.calculate_outlined),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DesignColors.primary.withValues(alpha: 0.12)
                        : (isDark
                              ? Colors.grey[800]!.withValues(alpha: 0.5)
                              : Colors.grey[50]),
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
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: DesignColors.primary,
                          ),
                        ),
                      Icon(
                        icon,
                        size: 15,
                        color: isSelected ? DesignColors.primary : labelColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? DesignColors.primary
                              : (isDark ? Colors.grey[300] : Colors.grey[700]),
                        ),
                      ),
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

  Widget _buildModeTabsSection(BuildContext context, bool isDark) {
    final mode = ref.watch(aiGenerationSettingsNotifierProvider).processingMode;

    return Container(
      color: isDark ? const Color(0xFF1A2632) : DesignColors.white,
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF243040) : DesignColors.moonLight,
          borderRadius: BorderRadius.circular(DesignRadius.md),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildModeTab(
              context,
              isDark,
              mode: ProcessingMode.promptOnly,
              selected: mode,
              icon: Icons.edit_note_rounded,
              label: 'Nhập Prompt',
            ),
            _buildModeTab(
              context,
              isDark,
              mode: ProcessingMode.extraction,
              selected: mode,
              icon: Icons.content_paste_search_rounded,
              label: 'Trích xuất',
            ),
            _buildModeTab(
              context,
              isDark,
              mode: ProcessingMode.ragGeneration,
              selected: mode,
              icon: Icons.auto_stories_rounded,
              label: 'Tài liệu',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab(
    BuildContext context,
    bool isDark, {
    required ProcessingMode mode,
    required ProcessingMode selected,
    required IconData icon,
    required String label,
  }) {
    final isSelected = mode == selected;
    return Expanded(
      child: GestureDetector(
        key: ValueKey('tab_${mode.name}'),
        onTap: () => ref
            .read(aiGenerationSettingsNotifierProvider.notifier)
            .setMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            vertical: DesignSpacing.sm + 2,
            horizontal: DesignSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected ? DesignColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(DesignRadius.sm),
            boxShadow: isSelected ? [DesignElevation.level1] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: DesignIcons.smSize,
                color: isSelected
                    ? DesignColors.white
                    : (isDark
                          ? DesignColors.textSecondary
                          : DesignColors.textSecondary),
              ),
              SizedBox(width: DesignSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  style: DesignTypography.bodyMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? DesignColors.white
                        : (isDark
                              ? DesignColors.textSecondary
                              : DesignColors.textSecondary),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeHintCard(
    BuildContext context,
    ProcessingMode mode,
    bool isDark,
  ) {
    final isExtraction = mode == ProcessingMode.extraction;
    final icon = isExtraction
        ? Icons.content_paste_search_rounded
        : Icons.auto_stories_rounded;
    final color = isExtraction ? DesignColors.warning : DesignColors.success;
    final title = isExtraction ? 'Chế độ Trích xuất' : 'Chế độ Từ Tài liệu';
    final subtitle = isExtraction
        ? 'AI sẽ đọc file và trích xuất câu hỏi có sẵn. Không sáng tác thêm.'
        : 'AI sáng tác câu hỏi dựa trên nội dung tài liệu (RAG pipeline).';

    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: DesignIcons.mdSize),
              SizedBox(width: DesignSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: DesignTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    SizedBox(height: DesignSpacing.xs),
                    Text(
                      subtitle,
                      style: DesignTypography.bodySmall.copyWith(
                        color: isDark
                            ? Colors.grey[300]
                            : DesignColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // FIX-V3V2: BỎ SwitchListTile "Coi tài liệu là MẪU" — redundant.
          // User chọn chip "Cùng dạng"/"Tạo mới" sẽ tự động kích hoạt template mode.
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: DesignColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(DesignRadius.md),
                          border: Border.all(
                            color: DesignColors.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.vertical_align_top_rounded,
                              size: 13,
                              color: DesignColors.primary,
                            ),
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
                      color: isDark
                          ? Colors.grey[800]!.withValues(alpha: 0.5)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(DesignRadius.lg),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStepBtn(
                          icon: Icons.remove_rounded,
                          enabled: qty > 1,
                          onTap: () =>
                              setState(() => _typeQuantities[key] = qty - 1),
                          isDark: isDark,
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '$qty',
                            textAlign: TextAlign.center,
                            style: DesignTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : DesignColors.textPrimary,
                            ),
                          ),
                        ),
                        _buildStepBtn(
                          icon: Icons.add_rounded,
                          enabled: canAdd,
                          onTap: () =>
                              setState(() => _typeQuantities[key] = qty + 1),
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
                  isOver
                      ? Icons.error_outline_rounded
                      : Icons.info_outline_rounded,
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

  /// Skeleton loader hiển thị trong khi AI gen — UX trick để giảm cảm giác
  /// "đứng hình" khi đợi 5-15s. Render N shimmer card placeholder (N = qty user
  /// chọn, default 5) + text mô tả phase đang chạy.
  Widget _buildSkeletonResponseSection(BuildContext context, bool isDark) {
    final qty = _limitQty.clamp(1, 10);
    // Ưu tiên _batchProgress (vd "Đang tạo lô 2/3...") nếu có — info cụ thể
    // hơn phase text rotate. Fallback: phase text generic.
    final phase = _batchProgress ?? _loadingPhrases[_loadingPhase];
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header card với phase text + spinner
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2632) : Colors.white,
            borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Row(
            children: [
              const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    phase,
                    key: ValueKey<int>(_loadingPhase),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$qty câu',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: DesignColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: DesignSpacing.md),

        // Shimmer placeholder cards (N items)
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          period: const Duration(milliseconds: 1500),
          child: Column(
            children: List.generate(
              qty,
              (i) => Padding(
                padding: EdgeInsets.only(bottom: DesignSpacing.md),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A2632) : Colors.white,
                    borderRadius: BorderRadius.circular(DesignRadius.lg),
                    border: Border.all(color: baseColor),
                  ),
                  padding: EdgeInsets.all(DesignSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: "CÂU N • Trắc nghiệm"
                      Container(width: 120, height: 12, color: baseColor),
                      SizedBox(height: DesignSpacing.md),
                      // Question text — 2 dòng
                      Container(
                        width: double.infinity,
                        height: 14,
                        color: baseColor,
                      ),
                      const SizedBox(height: 6),
                      Container(width: 220, height: 14, color: baseColor),
                      SizedBox(height: DesignSpacing.md),
                      // 4 options
                      ...List.generate(
                        4,
                        (j) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: baseColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(height: 12, color: baseColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiResponseSection(BuildContext context, bool isDark) {
    final questions = _generatedQuestions ?? [];
    final mode = ref.watch(aiGenerationSettingsNotifierProvider).processingMode;
    return Column(
      key: const ValueKey('ai_response_section'),
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
        // Banner trạng thái template — chỉ hiện ở Mode 3 (Phase 1.4)
        if (mode == ProcessingMode.ragGeneration) ...[
          const SizedBox(height: 8),
          _buildTemplateStatusBanner(isDark),
        ],
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
                : (answer?['general_explanation'] as String?)
                          ?.trim()
                          .isNotEmpty ==
                      true
                ? (answer!['general_explanation'] as String).trim()
                : null;
            final isRegenerating = _regeneratingIndex == index;
            final isRegeneratingExpl = _regeneratingExplanationSet.contains(
              index,
            );
            final isExplExpanded = _expandedExplanations.contains(index);
            // Số thứ tự trong section (hoặc toàn bộ nếu auto)
            final sectionNum = _sections.isEmpty
                ? index + 1
                : (() {
                    for (final s in _sections) {
                      if (index >= s.startIndex &&
                          index < s.startIndex + s.count) {
                        return index - s.startIndex + 1;
                      }
                    }
                    return index + 1;
                  })();

            widgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Card + action buttons overlay
                    Stack(
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
                          critiquePass: (q['_critique'] is Map)
                              ? (q['_critique'] as Map)['pass'] as bool?
                              : null,
                          critiqueReason: (q['_critique'] is Map)
                              ? (q['_critique'] as Map)['reason'] as String?
                              : null,
                          onToggleExplanation: _explanationFeatureEnabled
                              ? () {
                                  final willAutoGenerate =
                                      !isExplExpanded &&
                                      explanation == null &&
                                      !_regeneratingExplanationSet.contains(
                                        index,
                                      );
                                  setState(() {
                                    if (isExplExpanded) {
                                      _expandedExplanations.remove(index);
                                    } else {
                                      _expandedExplanations.add(index);
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
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildCardActionBtn(
                                      icon: Icons.refresh_rounded,
                                      color: DesignColors.primary,
                                      tooltip: 'Tạo lại câu này',
                                      onTap: () =>
                                          _handleRegenerateSingle(index),
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
                    // Badge cảnh báo similarity — bên dưới card, không chèn lên nội dung
                    if (q['_similarityWarning'] is Map)
                      ...() {
                        final sw =
                            q['_similarityWarning'] as Map<String, dynamic>;
                        final score = ((sw['score'] as num?) ?? 0) * 100;
                        final tplIdx =
                            (sw['matchedTemplateIdx'] as int? ?? -1) + 1;
                        return [
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: DesignColors.warning.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(
                                DesignRadius.md,
                              ),
                              border: Border.all(
                                color: DesignColors.warning.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            child: Text(
                              '⚠ Tương tự mẫu #$tplIdx (${score.toStringAsFixed(0)}%)',
                              style: TextStyle(
                                fontSize: 11,
                                color: DesignColors.warning,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ];
                      }(),
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

  /// Banner trạng thái template (Phase 1.4) — render trong _buildAiResponseSection
  /// chỉ khi Mode 3 active. Phản ánh state SAU khi đã chạy Generate (hoặc init).
  Widget _buildTemplateStatusBanner(bool isDark) {
    final IconData icon;
    final Color color;
    final String text;
    if (_useAsStyleTemplate &&
        _templateQuestionsForVerify != null &&
        _templateQuestionsForVerify!.isNotEmpty) {
      icon = Icons.check_circle;
      color = DesignColors.success;
      text =
          'Đã phát hiện ${_templateQuestionsForVerify!.length} câu mẫu — chế độ Cùng Dạng sẵn sàng';
    } else {
      icon = Icons.info_outline;
      color = DesignColors.info;
      text =
          'Tài liệu được dùng làm nguồn kiến thức — câu hỏi MỚI hoàn toàn (không cùng dạng)';
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: DesignIcons.smSize),
          SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: DesignTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
              border: Border.all(
                color: DesignColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.layers_outlined,
                  size: 14,
                  color: DesignColors.primary,
                ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: DesignColors.primary,
                    borderRadius: BorderRadius.circular(DesignRadius.full),
                  ),
                  child: Text(
                    '$count câu',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Divider(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              indent: 8,
            ),
          ),
        ],
      ),
    );
  }

  /// Chip chọn sub-mode template: "Tạo mới" (styleOnly) / "Cùng dạng" (sameForm).
  /// Chỉ hiển thị sau khi detect được file Excel mẫu (_useAsStyleTemplate=true).
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
    bool? critiquePass,
    String? critiqueReason,
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
                  MathText(
                    questionText,
                    style: DesignTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : DesignColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  // Hiển thị expected_answer cho essay/short_answer
                  if ((options == null || options.isEmpty) &&
                      answer != null) ...[
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
                          border: Border.all(
                            color: DesignColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: MathText(
                          answer['expected_answer'].toString(),
                          style: DesignTypography.bodySmall.copyWith(
                            color: isDark
                                ? Colors.white
                                : DesignColors.textPrimary,
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
                        isMath:
                            questionType == QuestionType.math ||
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
                                child: MathText(
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

                  // ── Critique badge (Chế độ chính xác cao) ────────────────
                  if (critiquePass == false) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: DesignColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DesignRadius.md),
                        border: Border.all(
                          color: DesignColors.warning.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: DesignColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI đánh dấu cần kiểm tra',
                                  style: DesignTypography.labelSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: DesignColors.warning,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (critiqueReason?.trim().isNotEmpty == true)
                                      ? critiqueReason!.trim()
                                      : 'Có thể có lỗi kiến thức',
                                  style: DesignTypography.bodySmall.copyWith(
                                    color: isDark
                                        ? Colors.white
                                        : DesignColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                            borderRadius: BorderRadius.circular(
                              DesignRadius.md,
                            ),
                            border: Border.all(
                              color: DesignColors.primary.withValues(
                                alpha: 0.2,
                              ),
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
class _EditQuestionDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> question;
  final QuestionType questionType;
  final void Function(Map<String, dynamic> updated) onSave;

  const _EditQuestionDialog({
    required this.question,
    required this.questionType,
    required this.onSave,
  });

  @override
  ConsumerState<_EditQuestionDialog> createState() =>
      _EditQuestionDialogState();
}

class _EditQuestionDialogState extends ConsumerState<_EditQuestionDialog> {
  late TextEditingController _textCtrl;
  late TextEditingController _expectedAnswerCtrl;
  late TextEditingController _explanationCtrl;
  late TextEditingController _tagInputCtrl;
  // Persistent controllers cho từng choice (tránh bug tạo lại mỗi rebuild)
  late List<TextEditingController> _choiceControllers;
  late List<bool> _choiceCorrect;
  int _correctIndex = 0;

  // Metadata mở rộng (đồng bộ với teacher_create_question_screen)
  int? _difficulty; // 1..5
  List<String> _tags = [];
  List<String> _learningObjectiveIds = [];
  List<LearningObjective> _selectedObjectives = [];
  bool _objectivesLoading = false;
  late List<TextEditingController> _hintControllers;

  /// Toggle split-view (chỉ có ý nghĩa trên web/PC rộng).
  /// null = auto (theo screen width). Khi user bấm nút sẽ thành true/false.
  bool? _splitView;

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
      final m = o is Map<String, dynamic>
          ? o
          : Map<String, dynamic>.from(o as Map);
      final cc = m['content'];
      final t = (cc is Map ? cc['text'] : null) ?? m['text'] ?? '';
      final correct = m['isCorrect'] == true || m['is_correct'] == true;
      return (text: t.toString(), correct: correct);
    }).toList();

    _choiceControllers = parsed
        .map((c) => TextEditingController(text: c.text))
        .toList();
    _choiceCorrect = parsed.map((c) => c.correct).toList();
    _correctIndex = _choiceCorrect.indexWhere((c) => c);
    if (_correctIndex < 0) _correctIndex = 0;

    // Expected answer
    final ans = q['answer'];
    final ea = (ans is Map) ? (ans['expected_answer'] as String? ?? '') : '';
    _expectedAnswerCtrl = TextEditingController(text: ea);

    // Explanation: ưu tiên top-level, fallback answer.general_explanation
    final topExpl = (q['explanation'] as String?)?.trim();
    final ansExpl = (ans is Map)
        ? (ans['general_explanation'] as String?)?.trim()
        : null;
    final initialExpl =
        (topExpl != null && topExpl.isNotEmpty) ? topExpl : (ansExpl ?? '');
    _explanationCtrl = TextEditingController(text: initialExpl);

    // Difficulty (int 1..5) — chấp nhận int hoặc num
    final rawDiff = q['difficulty'];
    if (rawDiff is int) {
      _difficulty = rawDiff;
    } else if (rawDiff is num) {
      _difficulty = rawDiff.toInt();
    }

    // Tags — đảm bảo List<String>
    final rawTags = q['tags'];
    if (rawTags is List) {
      _tags = rawTags.map((e) => e.toString()).toList();
    }
    _tagInputCtrl = TextEditingController();

    // Hints
    final rawHints = q['hints'];
    final hintsList = rawHints is List
        ? rawHints.map((e) => e.toString()).toList()
        : <String>[];
    _hintControllers = hintsList
        .map((h) => TextEditingController(text: h))
        .toList();

    // Learning objectives — AI có thể trả về dạng List<Map> (description/code/subject_code)
    // hoặc List<String> (ids). Chỉ chấp nhận id để selector hoạt động đúng.
    final rawLos = q['learningObjectives'];
    if (rawLos is List) {
      for (final item in rawLos) {
        if (item is String) {
          _learningObjectiveIds.add(item);
        } else if (item is Map) {
          // AI trả về dạng object — chưa có id thật, bỏ qua (selector chỉ làm việc với id).
          // Giữ nguyên để khi save vẫn passthrough cho pipeline upload.
        }
      }
    }

    if (_learningObjectiveIds.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadObjectives());
    }
  }

  Future<void> _loadObjectives() async {
    if (_objectivesLoading || !mounted) return;
    setState(() => _objectivesLoading = true);
    try {
      final repo = ref.read(learningObjectiveRepositoryProvider);
      final all = await repo.getObjectives();
      final loaded = all
          .where((o) => _learningObjectiveIds.contains(o.id))
          .toList();
      if (mounted) setState(() => _selectedObjectives = loaded);
    } catch (_) {
      // Bỏ qua — chips sẽ chỉ hiện id nếu load lỗi
    } finally {
      if (mounted) setState(() => _objectivesLoading = false);
    }
  }

  Future<void> _openObjectiveSelector() async {
    final selected = await ObjectiveSelectorSheet.show(
      context,
      selectedIds: _learningObjectiveIds,
      allowCreate: true,
    );
    if (selected == null || !mounted) return;
    setState(() {
      _selectedObjectives = selected;
      _learningObjectiveIds = selected.map((o) => o.id).toList();
    });
  }

  void _addTag() {
    final tag = _tagInputCtrl.text.trim();
    if (tag.isEmpty || _tags.contains(tag)) return;
    setState(() {
      _tags.add(tag);
      _tagInputCtrl.clear();
    });
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _addHint() {
    setState(() => _hintControllers.add(TextEditingController()));
  }

  void _removeHint(int index) {
    setState(() {
      _hintControllers[index].dispose();
      _hintControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _expectedAnswerCtrl.dispose();
    _explanationCtrl.dispose();
    _tagInputCtrl.dispose();
    for (final c in _choiceControllers) {
      c.dispose();
    }
    for (final c in _hintControllers) {
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
      updated['choices'] = opts
          .map(
            (o) => <String, dynamic>{
              'id': o['id'],
              'content': {'text': o['text']},
              'is_correct': o['is_correct'],
            },
          )
          .toList();
    } else {
      final ans = updated['answer'];
      final ansMap = ans is Map<String, dynamic>
          ? Map<String, dynamic>.from(ans)
          : <String, dynamic>{};
      ansMap['expected_answer'] = _expectedAnswerCtrl.text.trim();
      updated['answer'] = ansMap;
    }

    // Explanation: ghi cả 2 nơi để pipeline lưu vào answer.general_explanation đọc được.
    final newExpl = _explanationCtrl.text.trim();
    if (newExpl.isEmpty) {
      updated.remove('explanation');
      if (updated['answer'] is Map) {
        (updated['answer'] as Map).remove('general_explanation');
      }
    } else {
      updated['explanation'] = newExpl;
      final ans = updated['answer'];
      final ansMap = ans is Map<String, dynamic>
          ? Map<String, dynamic>.from(ans)
          : <String, dynamic>{};
      ansMap['general_explanation'] = newExpl;
      updated['answer'] = ansMap;
    }

    // Difficulty
    if (_difficulty == null) {
      updated.remove('difficulty');
    } else {
      updated['difficulty'] = _difficulty;
    }

    // Tags
    if (_tags.isEmpty) {
      updated.remove('tags');
    } else {
      updated['tags'] = List<String>.from(_tags);
    }

    // Hints
    final hints = _hintControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (hints.isEmpty) {
      updated.remove('hints');
    } else {
      updated['hints'] = hints;
    }

    // Learning objectives: pipeline upload hỗ trợ cả List<Map>{description/code/subject_code}
    // và List<String>{ids}. Khi user chọn từ selector, ta có objects đầy đủ — convert sang
    // dạng Map để upstream resolve về id (đồng bộ với phần xử lý ở dòng ~595).
    if (_selectedObjectives.isNotEmpty) {
      updated['learningObjectives'] = _selectedObjectives
          .map(
            (o) => {
              'description': o.description,
              'code': o.code,
              'subject_code': o.subjectCode,
              'id': o.id,
            },
          )
          .toList();
    } else if (_learningObjectiveIds.isEmpty) {
      updated.remove('learningObjectives');
    }

    widget.onSave(updated);
    Navigator.of(context).pop();
  }


  /// Tab Xem trước (Task 7a) — render live preview dùng MathText.
  Widget _buildPreviewTab(bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _textCtrl,
        _expectedAnswerCtrl,
        ..._choiceControllers,
      ]),
      builder: (context, _) {
        final textStyle = DesignTypography.bodyMedium.copyWith(
          color: isDark ? Colors.white : DesignColors.textPrimary,
          height: 1.5,
          fontWeight: FontWeight.w500,
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel(
                icon: Icons.help_outline_rounded,
                label: 'CÂU HỎI',
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              MathText(
                _textCtrl.text.isEmpty ? '(chưa có nội dung)' : _textCtrl.text,
                style: textStyle,
              ),
              const SizedBox(height: 16),
              Divider(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                height: 1,
              ),
              const SizedBox(height: 16),
              if (_isChoiceType && _choiceControllers.isNotEmpty) ...[
                _buildSectionLabel(
                  icon: Icons.radio_button_checked_rounded,
                  label: 'CÁC ĐÁP ÁN',
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                ...List.generate(_choiceControllers.length, (i) {
                  final isCorrect = i == _correctIndex;
                  final label = String.fromCharCode(65 + i);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? DesignColors.success
                                : (isDark
                                      ? Colors.grey[700]!
                                      : Colors.grey[200]!),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isCorrect
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[600]),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MathText(
                            _choiceControllers[i].text.isEmpty
                                ? '(trống)'
                                : _choiceControllers[i].text,
                            style: DesignTypography.bodyMedium.copyWith(
                              color: isCorrect
                                  ? DesignColors.success
                                  : (isDark
                                        ? Colors.white
                                        : DesignColors.textPrimary),
                              fontWeight: isCorrect
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
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
                MathText(
                  _expectedAnswerCtrl.text.isEmpty
                      ? '(chưa có)'
                      : _expectedAnswerCtrl.text,
                  style: DesignTypography.bodySmall.copyWith(
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;
    final screenW = mq.size.width;
    final typeColor = widget.questionType.color;

    // Cho phép split-view khi màn đủ rộng (tablet lớn / desktop).
    final canSplit = screenW >= DesignBreakpoints.tabletLarge;
    // Mặc định bật split khi screen rộng; người dùng có thể tắt qua nút.
    final useSplit = canSplit && (_splitView ?? true);

    // Trên màn rộng, dialog cho phép rộng hơn để có chỗ đặt cả 2 panel.
    final EdgeInsets insetPadding = canSplit
        ? EdgeInsets.symmetric(
            horizontal: (screenW * 0.06).clamp(24.0, 80.0),
            vertical: 28,
          )
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 28);

    return DefaultTabController(
      length: 2,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: insetPadding,
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
              // ── Header ─────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: isDark ? 0.15 : 0.07),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(DesignRadius.lg * 2),
                  ),
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
                      child: Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: typeColor,
                      ),
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
                              color: isDark
                                  ? Colors.white
                                  : DesignColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                DesignRadius.full,
                              ),
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
                    if (canSplit)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            // Toggle giữa split và single (tabbed). Lưu giá trị
                            // tường minh để không bị override bởi default.
                            _splitView = !useSplit;
                          });
                        },
                        icon: Icon(
                          useSplit
                              ? Icons.view_stream_rounded
                              : Icons.view_column_rounded,
                          color: DesignColors.primary,
                        ),
                        tooltip: useSplit
                            ? 'Chuyển sang 1 panel (tab)'
                            : 'Hiển thị Sửa + Xem trước song song',
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

              // ── TabBar (chỉ hiện khi KHÔNG split-view) ─────────────────
              if (!useSplit)
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F1923) : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                  ),
                  child: TabBar(
                    labelColor: DesignColors.primary,
                    unselectedLabelColor: isDark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    indicatorColor: DesignColors.primary,
                    tabs: const [
                      Tab(icon: Icon(Icons.edit_rounded, size: 18), text: 'Sửa'),
                      Tab(
                        icon: Icon(Icons.visibility_rounded, size: 18),
                        text: 'Xem trước',
                      ),
                    ],
                  ),
                ),

              // ── Body: split-view (6:4) hoặc TabBarView ────────────────
              Flexible(
                child: useSplit
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 6, child: _buildEditTabContent(isDark)),
                          VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: isDark
                                ? Colors.grey[800]
                                : Colors.grey[200],
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.15)
                                  : Colors.grey[50],
                              child: _buildPreviewTab(isDark),
                            ),
                          ),
                        ],
                      )
                    : TabBarView(
                        children: [
                          _buildEditTabContent(isDark),
                          // Tab 2: Xem trước
                          _buildPreviewTab(isDark),
                        ],
                      ),
              ),


              // ── Footer buttons ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F1923) : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(DesignRadius.lg * 2),
                  ),
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
                          foregroundColor: isDark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          side: BorderSide(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              DesignRadius.lg * 1.5,
                            ),
                          ),
                        ),
                        child: Text(
                          'Hủy',
                          style: DesignTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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
                          shadowColor: DesignColors.primary.withValues(
                            alpha: 0.3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              DesignRadius.lg * 1.5,
                            ),
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
      ),
    );
  }

  // ─── Edit Tab Content ──────────────────────────────────────────────────
  Widget _buildEditTabContent(bool isDark) {
    return SingleChildScrollView(
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
          Text(
            'Chèn công thức:',
            style: DesignTypography.labelSmall.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          RichTextToolbar(controller: _textCtrl),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _textCtrl,
            hintText: 'Nhập nội dung câu hỏi...',
            maxLines: 4,
            isDark: isDark,
          ),

          const SizedBox(height: 20),

          // Section: Đáp án (choices) hoặc Đáp án mẫu
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: DesignColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.full),
                    border: Border.all(
                      color: DesignColors.success.withValues(alpha: 0.3),
                    ),
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
                          ? DesignColors.success.withValues(
                              alpha: isDark ? 0.12 : 0.07,
                            )
                          : (isDark
                              ? const Color(0xFF1A2632)
                              : Colors.grey[50]),
                      borderRadius: BorderRadius.circular(
                        DesignRadius.lg * 1.2,
                      ),
                      border: Border.all(
                        color: isCorrect
                            ? DesignColors.success
                            : (isDark
                                ? Colors.grey[700]!
                                : Colors.grey[200]!),
                        width: isCorrect ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Icon(
                            isCorrect
                                ? Icons.check_circle_rounded
                                : Icons.check_circle_outline_rounded,
                            color: isCorrect
                                ? DesignColors.success
                                : (isDark
                                    ? Colors.grey[600]
                                    : Colors.grey[400]),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? DesignColors.success
                                : (isDark
                                    ? Colors.grey[700]!
                                    : Colors.grey[200]!),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCorrect
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[600]),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _choiceControllers[i],
                            style: DesignTypography.bodyMedium.copyWith(
                              color: isDark
                                  ? Colors.white
                                  : DesignColors.textPrimary,
                              fontWeight: isCorrect
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Đáp án $label...',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.functions, size: 18),
                          color: DesignColors.primary,
                          tooltip: 'Chèn ký tự toán học',
                          onPressed: () =>
                              RichTextToolbar.showMathPickerFor(
                                context,
                                _choiceControllers[i],
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
            RichTextToolbar(controller: _expectedAnswerCtrl),
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

          const SizedBox(height: 20),
          _buildDifficultySection(isDark),
          const SizedBox(height: 20),
          _buildTagsSection(isDark),
          const SizedBox(height: 20),
          _buildObjectivesSection(isDark),
          const SizedBox(height: 20),
          _buildExplanationSection(isDark),
          const SizedBox(height: 20),
          _buildHintsSection(isDark),

          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ─── Section: Độ khó ─────────────────────────────────────────────────────
  Widget _buildDifficultySection(bool isDark) {
    const labels = ['Rất dễ', 'Dễ', 'Trung bình', 'Khó', 'Rất khó'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          icon: Icons.bar_chart_rounded,
          label: 'ĐỘ KHÓ',
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...List.generate(5, (i) {
              final level = i + 1;
              final isActive = _difficulty != null && _difficulty! >= level;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _difficulty = _difficulty == level ? null : level;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.star_rounded,
                    size: 28,
                    color: isActive
                        ? Colors.amber[400]
                        : (isDark ? Colors.grey[600] : Colors.grey[300]),
                  ),
                ),
              );
            }),
            const SizedBox(width: 8),
            Text(
              _difficulty != null ? labels[_difficulty! - 1] : 'Chưa chọn',
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Section: Tags ──────────────────────────────────────────────────────
  Widget _buildTagsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          icon: Icons.local_offer_rounded,
          label: 'THẺ (TAGS)',
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        if (_tags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: DesignColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: DesignTypography.bodySmall.copyWith(
                        color: DesignColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _removeTag(tag),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: DesignColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagInputCtrl,
                onSubmitted: (_) => _addTag(),
                style: DesignTypography.bodyMedium.copyWith(
                  color: isDark ? Colors.white : DesignColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Thêm tag (vd: chương 1, lý thuyết)...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.grey[800]!.withValues(alpha: 0.5)
                      : Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
                    borderSide: BorderSide(
                      color: DesignColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addTag,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.lg * 1.2),
                ),
              ),
              child: const Text('Thêm'),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Section: Learning Objectives ───────────────────────────────────────
  Widget _buildObjectivesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionLabel(
              icon: Icons.school_rounded,
              label: 'MỤC TIÊU HỌC TẬP',
              isDark: isDark,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _openObjectiveSelector,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Chọn'),
              style: TextButton.styleFrom(
                foregroundColor: DesignColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_objectivesLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_selectedObjectives.isEmpty && _learningObjectiveIds.isEmpty)
          Text(
            'Chưa có mục tiêu nào. Bấm "Chọn" để thêm.',
            style: DesignTypography.bodySmall.copyWith(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          )
        else if (_selectedObjectives.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedObjectives.map((o) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: DesignColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.full),
                  border: Border.all(
                    color: DesignColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 14,
                      color: DesignColors.info,
                    ),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        o.description,
                        overflow: TextOverflow.ellipsis,
                        style: DesignTypography.bodySmall.copyWith(
                          color: DesignColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          )
        else
          Text(
            '${_learningObjectiveIds.length} mục tiêu (đang tải tên...)',
            style: DesignTypography.bodySmall.copyWith(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
      ],
    );
  }

  // ─── Section: Explanation ───────────────────────────────────────────────
  Widget _buildExplanationSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          icon: Icons.lightbulb_outline_rounded,
          label: 'GỢI Ý / GIẢI THÍCH',
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        RichTextToolbar(controller: _explanationCtrl),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _explanationCtrl,
          hintText: 'Gợi ý cách làm hoặc giải thích đáp án...',
          maxLines: 3,
          isDark: isDark,
          fillColor: Colors.amber.withValues(alpha: 0.05),
          borderColor: Colors.amber.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  // ─── Section: Hints (nhiều bậc) ────────────────────────────────────────
  Widget _buildHintsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionLabel(
              icon: Icons.tips_and_updates_rounded,
              label: 'GỢI Ý THEO BẬC',
              isDark: isDark,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addHint,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Thêm gợi ý'),
              style: TextButton.styleFrom(
                foregroundColor: DesignColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_hintControllers.isEmpty)
          Text(
            'Chưa có gợi ý nào.',
            style: DesignTypography.bodySmall.copyWith(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          )
        else
          ...List.generate(_hintControllers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: DesignColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: DesignColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      controller: _hintControllers[i],
                      hintText: 'Gợi ý bậc ${i + 1}...',
                      maxLines: 2,
                      isDark: isDark,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeHint(i),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: DesignColors.error,
                      size: 20,
                    ),
                    tooltip: 'Xoá',
                  ),
                ],
              ),
            );
          }),
      ],
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
    final fc =
        fillColor ??
        (isDark ? Colors.grey[800]!.withValues(alpha: 0.5) : Colors.grey[50]!);
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: DesignTypography.bodyMedium.copyWith(
        color: isDark ? Colors.white : DesignColors.textPrimary,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[600] : Colors.grey[400],
        ),
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

/// Tile cho bottom sheet "Tải xuống" — font size explicit để KHÔNG bị
/// theme typography hoặc textScaler ảnh hưởng (đã thấy ListTile inherit
/// font lớn gây overflow trên web).
class _ExportSheetTile extends StatelessWidget {
  const _ExportSheetTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.3,
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
}
