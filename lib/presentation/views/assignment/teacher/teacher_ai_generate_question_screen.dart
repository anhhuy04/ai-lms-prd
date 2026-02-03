import 'dart:convert';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/presentation/providers/ai_providers.dart';
import 'package:ai_mls/presentation/providers/learning_objective_providers.dart';
import 'package:ai_mls/presentation/providers/question_bank_providers.dart';
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
  String? _rawApiResponse; // Lưu raw response từ API để test
  String? _rawApiResponsePretty; // Raw JSON pretty-printed
  List<Map<String, dynamic>>? _generatedQuestions; // Lưu questions đã generate
  bool _isSavingToBank = false;

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
      for (final q in questions) {
        final params = await _mapAiQuestionToCreateQuestionParams(
          q,
          loRepo: loRepo,
          objectivesCache: objectivesCache,
        );
        await questionRepo.createQuestion(params);
        success++;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Đã lưu $success câu hỏi vào Question Bank'),
          backgroundColor: DesignColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
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
  }) async {
    // type
    final QuestionType type = (q['type'] is QuestionType)
        ? (q['type'] as QuestionType)
        : QuestionType.multipleChoice;

    // content (JSONB)
    final content = <String, dynamic>{};
    final contentRaw = q['content'];
    if (contentRaw is Map) {
      content.addAll(Map<String, dynamic>.from(contentRaw));
    }
    content['text'] = (q['text'] as String? ?? content['text'] ?? '')
        .toString();
    content['images'] = content['images'] is List ? content['images'] : [];

    // choices + answer
    Map<String, dynamic>? answer;
    List<Map<String, dynamic>>? choices;
    if (type == QuestionType.multipleChoice) {
      final opts =
          (q['options'] as List?)?.cast<Map<String, dynamic>>() ??
          (q['choices'] as List?)?.cast<Map<String, dynamic>>() ??
          const <Map<String, dynamic>>[];
      choices = opts.asMap().entries.map((entry) {
        final idx = entry.key;
        final opt = entry.value;
        return <String, dynamic>{
          'id': idx,
          'content': {
            'text': (opt['text'] ?? opt['content']?['text'] ?? '').toString(),
            'image': opt['image'],
          },
          'is_correct': opt['isCorrect'] == true || opt['is_correct'] == true,
        };
      }).toList();

      final correctIds = <int>[];
      for (final c in choices) {
        if (c['is_correct'] == true) correctIds.add(c['id'] as int);
      }
      answer = <String, dynamic>{'correct_choice_ids': correctIds};
    } else {
      final a = q['answer'];
      if (a is Map) {
        answer = Map<String, dynamic>.from(a);
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

        final created = await loRepo.createObjective({
          'subject_code': subjectCode,
          'code': code,
          'description': desc,
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final topic = _topicController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 5;
    final difficulty = _difficulty;

    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập chủ đề câu hỏi'),
          backgroundColor: DesignColors.error,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // Gọi AI API để generate questions
      final aiRepository = ref.read(aiRepositoryProvider);
      final generatedQuestions = await aiRepository.generateQuestions(
        topic: topic,
        quantity: quantity,
        difficulty: difficulty,
        onRawResponse: (raw) {
          // Lưu raw JSON từ API để hiển thị/test
          String pretty = raw;
          try {
            final decoded = jsonDecode(raw);
            pretty = const JsonEncoder.withIndent('  ').convert(decoded);
          } catch (_) {}
          if (mounted) {
            setState(() {
              // Append để support batching (vd: quantity 40 => nhiều batch)
              _rawApiResponse = _rawApiResponse == null
                  ? raw
                  : '${_rawApiResponse!}\n\n$raw';
              _rawApiResponsePretty = _rawApiResponsePretty == null
                  ? pretty
                  : '${_rawApiResponsePretty!}\n\n$pretty';
            });
          }
        },
      );

      if (!mounted) return;

      setState(() {
        // Lưu generated questions để có thể trả về khi xác nhận
        _generatedQuestions = generatedQuestions;
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
    // Ưu tiên format chuẩn mà repo map ra
    final direct = q['text'] as String?;
    if (direct != null && direct.trim().isNotEmpty) return direct.trim();

    // Nếu question giữ nguyên format raw (content.text)
    final content = q['content'];
    if (content is Map<String, dynamic>) {
      final t = content['text'] as String?;
      if (t != null && t.trim().isNotEmpty) return t.trim();
    }

    // Fallback: title/content string
    final title = q['title'] as String?;
    if (title != null && title.trim().isNotEmpty) return title.trim();

    return 'Câu hỏi (không có nội dung)';
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
                    // Nút cài đặt (navigate đến Settings)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push(AppRoute.settingsPath),
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
                        onTap: () => context.push(AppRoute.settingsPath),
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

                        // Quantity Input
                        _buildQuantitySection(context, isDark),
                        SizedBox(height: DesignSpacing.xxl),

                        // Difficulty Selector
                        _buildDifficultySection(context, isDark),

                        // AI Response Section (hiển thị sau khi generate)
                        if (_generatedQuestions != null) ...[
                          SizedBox(height: DesignSpacing.xxl),
                          _buildAiResponseSection(context, isDark),
                        ],

                        // Raw API Response Section (để test)
                        if (_rawApiResponse != null ||
                            _rawApiResponsePretty != null) ...[
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
                // Generate/Reset Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _handleGenerate,
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
                color: Colors.black.withValues(alpha: 0.25),
                child: const Center(child: CircularProgressIndicator()),
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
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'SỐ LƯỢNG CÂU HỎI',
              style: TextStyle(
                fontSize: DesignTypography.labelSmallSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ).copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
          TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
        ...questions.asMap().entries.map((entry) {
          final index = entry.key;
          final q = entry.value;
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
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildQuestionPreviewCard(
              context,
              isDark,
              questionNumber: index + 1,
              questionType: type,
              questionText: text,
              options: castedOptions,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuestionPreviewCard(
    BuildContext context,
    bool isDark, {
    required int questionNumber,
    required QuestionType questionType,
    required String questionText,
    List<Map<String, dynamic>>? options,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CÂU $questionNumber • ${questionType.label}',
                        style: TextStyle(
                          fontSize: DesignTypography.labelSmallSize,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
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
}
