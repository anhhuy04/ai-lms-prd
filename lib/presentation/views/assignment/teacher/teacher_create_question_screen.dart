import 'dart:io';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/learning_objective.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/presentation/providers/learning_objective_providers.dart';
import 'package:ai_mls/presentation/providers/question_bank_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/create_question/widgets/question_list_drawer.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/create_question/widgets/question_options_list.dart';
import 'package:ai_mls/widgets/dialogs/warning_dialog.dart';
import 'package:ai_mls/widgets/editor/math_input_field.dart';
import 'package:ai_mls/widgets/objective_selector/objective_selector_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Màn hình tạo/chỉnh sửa câu hỏi
class TeacherCreateQuestionScreen extends ConsumerStatefulWidget {
  final QuestionType questionType;
  final Map<String, dynamic>? initialData; // Data để edit (nếu có)
  final List<Map<String, dynamic>>?
  questions; // Danh sách câu hỏi hiện tại (để hiển thị trong drawer)
  final Function(int index)?
  onQuestionSelected; // Callback khi chọn question từ drawer
  final int? currentQuestionIndex; // Index của câu hỏi hiện tại (nếu đang edit)
  final int? Function(Map<String, dynamic>)?
  onSaveAndAddNew; // Callback để save và thêm câu mới, trả về index mới của câu hỏi
  final Function(List<Map<String, dynamic>>)?
  onQuestionsUpdated; // Callback để cập nhật questions list

  const TeacherCreateQuestionScreen({
    super.key,
    required this.questionType,
    this.initialData,
    this.questions,
    this.onQuestionSelected,
    this.currentQuestionIndex,
    this.onSaveAndAddNew,
    this.onQuestionsUpdated,
  });

  @override
  ConsumerState<TeacherCreateQuestionScreen> createState() =>
      _TeacherCreateQuestionScreenState();
}

class _TeacherCreateQuestionScreenState
    extends ConsumerState<TeacherCreateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionTextController = TextEditingController();
  final _explanationController = TextEditingController();
  final _tagInputController = TextEditingController();

  final List<XFile> _images = [];
  List<QuestionOption> _options = [];
  int? _difficulty;
  List<String> _tags = [];
  List<String> _learningObjectiveIds = [];
  // Cache tên objectives để hiển thị chips (id → description)
  List<LearningObjective> _selectedObjectives = [];
  List<TextEditingController> _hintControllers = [];

  bool _hasUnsavedChanges = false;
  bool _isDrawerOpen = false;
  bool _isSavingToCloud = false;
  QuestionType _selectedQuestionType = QuestionType.multipleChoice;
  List<Map<String, dynamic>> _localQuestions = []; // Local copy của questions
  int? _localCurrentIndex; // Local copy của currentQuestionIndex
  String? _editingQuestionId; // Question bank id (null = create mới)

  // Track original values để detect unsaved changes (giống pattern AddStudentByCodeScreen)
  String? _originalQuestionId;
  QuestionType? _originalQuestionType;
  String _originalText = '';
  String _originalExplanation = '';
  String _originalImagesSignature = '';
  String _originalOptionsSignature = '';
  String _originalHintsSignature = '';
  String _originalMetaSignature = ''; // difficulty/tags/objectives

  @override
  void initState() {
    super.initState();
    _selectedQuestionType = widget.questionType;
    _localQuestions = List.from(widget.questions ?? []);
    _localCurrentIndex = widget.currentQuestionIndex;
    _loadInitialData();
    _captureOriginalValues();
    // Nếu có initialData với objectiveIds, load tên objectives để hiển thị chips
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_learningObjectiveIds.isNotEmpty) _loadInitialObjectives();
    });
  }

  @override
  void didUpdateWidget(TeacherCreateQuestionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật local questions khi widget được update
    if (widget.questions != oldWidget.questions) {
      _localQuestions = List.from(widget.questions ?? []);
    }
    if (widget.currentQuestionIndex != oldWidget.currentQuestionIndex) {
      _localCurrentIndex = widget.currentQuestionIndex;
    }
  }

  void _loadInitialData() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _editingQuestionId =
          (data['questionId'] ?? data['id'] ?? data['question_id']) as String?;
      _questionTextController.text = data['text'] as String? ?? '';
      _explanationController.text = data['explanation'] as String? ?? '';
      _difficulty = data['difficulty'] as int?;
      _tags = List<String>.from(data['tags'] as List? ?? []);
      _learningObjectiveIds = List<String>.from(
        data['learningObjectives'] as List? ?? [],
      );

      // Load options for multiple choice
      if (data['options'] != null) {
        final optionsData = data['options'];
        if (optionsData is List<Map<String, dynamic>>) {
          _options = optionsData.map((opt) {
            return QuestionOption(
              text: opt['text'] as String? ?? '',
              isCorrect: opt['isCorrect'] as bool? ?? false,
            );
          }).toList();
        } else if (optionsData is List<String>) {
          // Handle old format (List<String>)
          _options = optionsData.map((text) {
            return QuestionOption(text: text);
          }).toList();
        }
      }

      // Load hints
      if (data['hints'] != null) {
        final hints = data['hints'] as List<String>;
        _hintControllers = hints
            .map((h) => TextEditingController(text: h))
            .toList();
      }
    } else {
      // Initialize với 2 empty options cho multiple choice
      if (_selectedQuestionType == QuestionType.multipleChoice) {
        _options = [QuestionOption(text: ''), QuestionOption(text: '')];
      }
    }
  }

  void _captureOriginalValues() {
    _originalQuestionId = _editingQuestionId;
    _originalQuestionType = _selectedQuestionType;
    _originalText = _questionTextController.text.trim();
    _originalExplanation = _explanationController.text.trim();
    _originalImagesSignature = _buildImagesSignature();
    _originalOptionsSignature = _buildOptionsSignature();
    _originalHintsSignature = _buildHintsSignature();
    _originalMetaSignature = _buildMetaSignature();
  }

  bool _hasUnsavedChangesSinceOriginal() {
    // Nếu "câu hỏi tạm" (không có core content) thì coi như không có thay đổi -> không hỏi lưu
    if (!_isDirty) return false;

    if ((_originalQuestionId ?? '') != (_editingQuestionId ?? '')) return true;
    if (_originalQuestionType != _selectedQuestionType) return true;
    if (_originalText != _questionTextController.text.trim()) return true;
    if (_originalExplanation != _explanationController.text.trim()) return true;
    if (_originalImagesSignature != _buildImagesSignature()) return true;
    if (_originalOptionsSignature != _buildOptionsSignature()) return true;
    if (_originalHintsSignature != _buildHintsSignature()) return true;
    if (_originalMetaSignature != _buildMetaSignature()) return true;
    return false;
  }

  String _buildImagesSignature() {
    if (_images.isEmpty) return '';
    return _images.map((e) => e.path).join('|');
  }

  String _buildHintsSignature() {
    if (_hintControllers.isEmpty) return '';
    return _hintControllers.map((c) => c.text.trim()).join('|');
  }

  String _buildMetaSignature() {
    final d = _difficulty?.toString() ?? '';
    final tags = _tags.join(',');
    final los = _learningObjectiveIds.join(',');
    return '$d|$tags|$los';
  }

  String _buildOptionsSignature() {
    if (_options.isEmpty) return '';
    final buff = <String>[];
    for (final o in _options) {
      final t = o.controller.text.trim();
      final c = o.isCorrect ? '1' : '0';
      buff.add('$t:$c');
    }
    return buff.join('~');
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _explanationController.dispose();
    _tagInputController.dispose();
    for (var controller in _hintControllers) {
      controller.dispose();
    }
    for (var option in _options) {
      option.controller.dispose();
    }
    super.dispose();
  }

  void _checkUnsavedChanges() {
    // Quy ước "câu hỏi tạm": nếu chưa có nội dung chính thì bỏ qua dialog khi thoát.
    // App lớn thường chỉ hỏi lưu khi người dùng đã thực sự nhập nội dung có ý nghĩa.
    final hasCoreContent =
        _questionTextController.text.trim().isNotEmpty ||
        _images.isNotEmpty ||
        _options.any((opt) => opt.controller.text.trim().isNotEmpty) ||
        _explanationController.text.trim().isNotEmpty ||
        _hintControllers.any((c) => c.text.trim().isNotEmpty);

    // Các field phụ chỉ coi là dirty khi đã có core content (tránh hỏi lưu cho câu "rỗng").
    final hasMetaChanges =
        _difficulty != null ||
        _tags.isNotEmpty ||
        _learningObjectiveIds.isNotEmpty;

    final hasChanges = hasCoreContent || (hasCoreContent && hasMetaChanges);

    setState(() {
      _hasUnsavedChanges = hasChanges;
    });
  }

  bool get _isDirty {
    _checkUnsavedChanges();
    return _hasUnsavedChanges;
  }

  /// Map question data sang format mới:
  /// {
  ///   "override_text": "...",
  ///   "choices": [{"id": 0, "text": "A", "isCorrect": true}, ...],
  ///   "tags": [...],
  ///   ...
  /// }
  CreateQuestionParams _mapToCreateQuestionParams(Map<String, dynamic> q) {
    final type = q['type'] as QuestionType;
    final text = (q['text'] as String? ?? '').trim();
    final images = (q['images'] as List?)?.map((e) => e.toString()).toList();
    final explanation = (q['explanation'] as String?)?.trim();
    final hints = (q['hints'] as List?)?.map((e) => e.toString()).toList();
    final difficulty = q['difficulty'] as int?;
    final tags = (q['tags'] as List?)?.map((e) => e.toString()).toList();
    final objectiveIds = (q['learningObjectives'] as List?)
        ?.map((e) => e.toString())
        .toList();

    // Format mới: dùng override_text thay vì text
    final content = <String, dynamic>{
      'override_text': text,
      if (images != null && images.isNotEmpty) 'images': images,
      if (explanation != null && explanation.isNotEmpty) 'explanation': explanation,
      if (hints != null && hints.isNotEmpty) 'hints': hints,
    };

    Map<String, dynamic>? answer;
    List<Map<String, dynamic>>? choices;

    // Format mới: choices với {id: int, text: String, isCorrect: bool}
    if (type == QuestionType.multipleChoice || type == QuestionType.trueFalse) {
      final opts = (q['options'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      choices = opts.asMap().entries.map((entry) {
        final idx = entry.key;
        final opt = entry.value;
        return <String, dynamic>{
          'id': idx, // int: 0, 1, 2...
          'text': (opt['text'] as String? ?? '').trim(),
          'isCorrect': opt['isCorrect'] == true || opt['is_correct'] == true,
        };
      }).toList();

      // Tạo answer với correct_choice_ids
      final correctIds = <int>[];
      for (final c in choices) {
        if (c['isCorrect'] == true) {
          correctIds.add(c['id'] as int);
        }
      }
      answer = <String, dynamic>{'correct_choice_ids': correctIds};
    }

    return CreateQuestionParams(
      type: type,
      content: content,
      answer: answer,
      difficulty: difficulty,
      tags: tags,
      objectiveIds: objectiveIds,
      choices: choices,
      isPublic: false,
      defaultPoints: 1,
    );
  }

  Future<String?> _saveQuestionToSupabase(
    Map<String, dynamic> questionData,
  ) async {
    if (_isSavingToCloud) return null;
    setState(() => _isSavingToCloud = true);
    try {
      final repo = ref.read(questionRepositoryProvider);
      final params = _mapToCreateQuestionParams(questionData);
      if (_editingQuestionId != null && _editingQuestionId!.isNotEmpty) {
        final updated = await repo.updateQuestion(_editingQuestionId!, params);
        return updated.id;
      } else {
        final created = await repo.createQuestion(params);
        return created.id;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: DesignColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _isSavingToCloud = false);
    }
  }

  Map<String, dynamic> _buildQuestionDataFromForm() {
    return {
      'type': _selectedQuestionType,
      'text': _questionTextController.text.trim(),
      'images': _images.map((img) => img.path).toList(),
      'options': _options
          .map(
            (opt) => {
              'text': opt.controller.text.trim(),
              'isCorrect': opt.isCorrect,
            },
          )
          .toList(),
      'difficulty': _difficulty,
      'tags': _tags,
      'learningObjectives': _learningObjectiveIds,
      'explanation': _explanationController.text.trim(),
      'hints': _hintControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
    };
  }

  void _resetForNewQuestion({QuestionType? type}) {
    setState(() {
      _selectedQuestionType = type ?? _selectedQuestionType;
      _questionTextController.clear();
      _explanationController.clear();
      _tagInputController.clear();
      _images.clear();
      _difficulty = null;
      _tags = [];
      _learningObjectiveIds = [];
      _selectedObjectives = [];
      for (final c in _hintControllers) {
        c.dispose();
      }
      _hintControllers = [];
      for (final o in _options) {
        o.controller.dispose();
      }
      _options = _selectedQuestionType == QuestionType.multipleChoice
          ? [QuestionOption(text: ''), QuestionOption(text: '')]
          : [];
      _hasUnsavedChanges = false;
      _localCurrentIndex = null;
      _editingQuestionId = null;
    });
    // Reset xong thì cập nhật original values để back không hỏi
    _captureOriginalValues();
  }

  /// Load full LearningObjective objects cho các IDs đã có (khi edit câu hỏi cũ).
  Future<void> _loadInitialObjectives() async {
    if (_learningObjectiveIds.isEmpty || !mounted) return;
    try {
      final repo = ref.read(learningObjectiveRepositoryProvider);
      final all = await repo.getObjectives();
      final loaded = all
          .where((o) => _learningObjectiveIds.contains(o.id))
          .toList();
      if (mounted) setState(() => _selectedObjectives = loaded);
    } catch (_) {
      // Không hiện lỗi — chips sẽ chỉ hiện ID nếu load lỗi
    }
  }

  /// Mở ObjectiveSelectorSheet và cập nhật state.
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
    _checkUnsavedChanges();
  }

  Future<void> _handleBack() async {
    // Nếu không có thay đổi so với original => back luôn, không hỏi
    if (!_hasUnsavedChangesSinceOriginal()) {
      if (mounted) context.pop();
      return;
    }

    final decision = await WarningDialog.showUnsavedChangesWithCancel(
      context: context,
      title: 'Lưu câu hỏi?',
      message: 'Bạn có muốn lưu câu hỏi hiện tại lên hệ thống trước khi thoát?',
      saveText: 'Lưu',
      discardText: 'Không lưu',
      cancelText: 'Hủy',
      barrierDismissible: false,
    );

    if (!mounted) return;
    if (decision == WarningUnsavedDecision.cancel) return;
    if (decision == WarningUnsavedDecision.discard) {
      context.pop();
      return;
    }

    // save
    final questionData = _buildQuestionDataFromForm();
    final id = await _saveQuestionToSupabase(questionData);
    if (!mounted) return;
    if (id != null) {
      _editingQuestionId = id;
      // Gắn questionId để màn tạo bài có thể link sang Question Bank
      questionData['questionId'] = id;
    }
    // Update original values sau khi save thành công (để back không hỏi lại)
    _captureOriginalValues();
    // Trả dữ liệu về màn tạo bài để cập nhật list + assignment_questions
    context.pop(questionData);
  }

  void _addTag() {
    final tag = _tagInputController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagInputController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _addHint() {
    setState(() {
      _hintControllers.add(TextEditingController());
    });
  }

  void _removeHint(int index) {
    setState(() {
      _hintControllers[index].dispose();
      _hintControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: DesignColors.moonLight,
        body: Stack(
          children: [
            // Main Content
            Column(
              children: [
                // Header
                _buildHeader(context, isDark, statusBarHeight),

                // Form Content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(DesignSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question Type Selector
                          _buildQuestionTypeSelector(context, isDark),
                          SizedBox(height: DesignSpacing.xxl),

                          // Question Content (Text + Images)
                          _buildQuestionContentSection(context, isDark),
                          SizedBox(height: DesignSpacing.xxl),

                          // Options (for Multiple Choice)
                          if (_selectedQuestionType ==
                              QuestionType.multipleChoice) ...[
                            QuestionOptionsList(
                              options: _options,
                              onOptionsChanged: (options) {
                                setState(() {
                                  _options = options;
                                });
                              },
                            ),
                            SizedBox(height: DesignSpacing.xxl),
                          ],

                          // Advanced Settings (includes Explanation)
                          _buildAdvancedSettings(context, isDark),
                          SizedBox(height: DesignSpacing.xxl),

                          // Hints
                          _buildHintsSection(context, isDark),

                          SizedBox(height: 100), // Space for bottom button
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Floating Action Button for Add New
            _buildAddNewButton(context, isDark),

            // Drawer Overlay
            if (_isDrawerOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _isDrawerOpen = false),
                  child: Container(color: Colors.black.withValues(alpha: 0.4)),
                ),
              ),

            // Question List Drawer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              right: _isDrawerOpen ? 0 : -400,
              top: 0,
              bottom: 0,
              child: QuestionListDrawer(
                questions: _localQuestions,
                currentQuestionIndex: _localCurrentIndex,
                onQuestionSelected: (index) {
                  widget.onQuestionSelected?.call(index);
                  setState(() => _isDrawerOpen = false);
                },
                onClose: () => setState(() => _isDrawerOpen = false),
                onAddNew: () {
                  setState(() => _isDrawerOpen = false);
                  // Save current question and add new
                  _handleSaveAndAddNew();
                },
              ),
            ),
            if (_isSavingToCloud)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.25),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getQuestionTitle() {
    // Sử dụng local questions và local current index
    // Nếu có localCurrentIndex, dùng nó trực tiếp (ưu tiên cao nhất)
    if (_localCurrentIndex != null) {
      final index = _localCurrentIndex!;
      if (_localQuestions.isNotEmpty &&
          index >= 0 &&
          index < _localQuestions.length) {
        final question = _localQuestions[index];
        final questionNumber = question['number'] as int? ?? (index + 1);
        return 'Câu $questionNumber';
      }
      // Fallback nếu index không hợp lệ
      return 'Câu ${index + 1}';
    }

    // Nếu có initialData (đang edit), tìm index trong questions list
    if (widget.initialData != null && _localQuestions.isNotEmpty) {
      final initialText = widget.initialData!['text'] as String? ?? '';

      if (initialText.isNotEmpty) {
        // Tìm câu hỏi có text giống với initialData và type giống với questionType hiện tại
        for (int i = 0; i < _localQuestions.length; i++) {
          final question = _localQuestions[i];
          final questionText = question['text'] as String? ?? '';
          final questionType = question['type'] as QuestionType?;

          // So sánh text và type để tìm đúng câu hỏi
          if (questionText == initialText &&
              questionType == widget.questionType) {
            final questionNumber = question['number'] as int? ?? (i + 1);
            return 'Câu $questionNumber';
          }
        }
      }
    }

    // Nếu đang tạo mới, hiển thị số câu tiếp theo
    if (_localQuestions.isNotEmpty) {
      return 'Câu ${_localQuestions.length + 1}';
    }

    return 'Câu 1';
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    double statusBarHeight,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1A2632) : Colors.white).withValues(
          alpha: 0.95,
        ),
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
              onTap: _handleBack,
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
              _getQuestionTitle(),
              style: DesignTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : DesignColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() => _isDrawerOpen = !_isDrawerOpen);
              },
              borderRadius: BorderRadius.circular(DesignRadius.full),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  _isDrawerOpen ? Icons.close_rounded : Icons.menu_rounded,
                  size: 24,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContentSection(BuildContext context, bool isDark) {
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
          // Label
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'NỘI DUNG CÂU HỎI',
              style: TextStyle(
                fontSize: DesignTypography.labelSmallSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ).copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),

          // Toolbar + TextField + preview live (math + plain text)
          MathInputField(
            controller: _questionTextController,
            hintText:
                'Nhập nội dung câu hỏi chi tiết tại đây... '
                '(Ví dụ: Giải phương trình bậc hai \$x^2 - 4x + 4 = 0\$)',
            minLines: 4,
            maxLines: null,
            onChanged: (_) => setState(() {}),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập nội dung câu hỏi';
              }
              return null;
            },
          ),

          // Images (displayed below textarea - only when images exist)
          if (_images.isNotEmpty) ...[
            SizedBox(height: DesignSpacing.md),
            _buildImagePreview(context, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, bool isDark) {
    return Wrap(
      spacing: DesignSpacing.sm,
      runSpacing: DesignSpacing.sm,
      children: _images.asMap().entries.map((entry) {
        final index = entry.key;
        final image = entry.value;
        final file = File(image.path);

        return Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignRadius.lg),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DesignRadius.lg),
                child: FutureBuilder<bool>(
                  future: file.exists(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    if (!snapshot.hasData || !snapshot.data!) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 40),
                      );
                    }

                    return Image.file(
                      file,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 40),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _images.removeAt(index);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildQuestionTypeSelector(BuildContext context, bool isDark) {
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
              'LOẠI CÂU HỎI',
              style: TextStyle(
                fontSize: DesignTypography.labelSmallSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ).copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
          GestureDetector(
            onTap: () => _showQuestionTypeBottomSheet(context, isDark),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[50],
                borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedQuestionType.label,
                    style: DesignTypography.bodyMedium.copyWith(
                      color: isDark ? Colors.white : DesignColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.expand_more,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuestionTypeBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2632) : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DesignRadius.lg * 1.5),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Text(
                  'Chọn Loại Câu Hỏi',
                  style: DesignTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1),
              // Options
              ...QuestionType.values.map((type) {
                final isSelected = _selectedQuestionType == type;
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: type.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(DesignRadius.md),
                    ),
                    child: Icon(
                      _getQuestionTypeIcon(type),
                      color: type.color,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    type.label,
                    style: DesignTypography.bodyMedium.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isDark ? Colors.white : DesignColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: DesignColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedQuestionType = type;
                      // Reset options if switching to/from multiple choice
                      if (type == QuestionType.multipleChoice &&
                          _options.isEmpty) {
                        _options = [
                          QuestionOption(text: ''),
                          QuestionOption(text: ''),
                        ];
                      } else if (type != QuestionType.multipleChoice) {
                        _options.clear();
                      }
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getQuestionTypeIcon(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return Icons.radio_button_checked;
      case QuestionType.trueFalse:
        return Icons.check_circle_outline;
      case QuestionType.shortAnswer:
        return Icons.short_text;
      case QuestionType.essay:
        return Icons.article;
      case QuestionType.fillBlank:
        return Icons.text_fields;
      case QuestionType.matching:
        return Icons.compare_arrows;
      case QuestionType.math:
        return Icons.functions;
      case QuestionType.problemSolving:
        return Icons.calculate;
      case QuestionType.fileUpload:
        return Icons.upload_file;
    }
  }

  Widget _buildAdvancedSettings(BuildContext context, bool isDark) {
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
          Text(
            'Cài Đặt Nâng Cao',
            style: DesignTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : DesignColors.textPrimary,
            ),
          ),
          SizedBox(height: DesignSpacing.xl),

          // Difficulty
          _buildDifficultySelector(context, isDark),
          SizedBox(height: DesignSpacing.xl),

          // Tags
          _buildTagsInput(context, isDark),
          SizedBox(height: DesignSpacing.xl),

          // Learning Objectives
          _buildObjectivesSection(context, isDark),
          SizedBox(height: DesignSpacing.xl),

          // Explanation
          _buildExplanationSection(context, isDark),
        ],
      ),
    );
  }

  Widget _buildObjectivesSection(BuildContext context, bool isDark) {
    final hasObjectives = _selectedObjectives.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                'MỤC TIÊU HỌC TẬP',
                style: TextStyle(
                  fontSize: DesignTypography.labelSmallSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _openObjectiveSelector,
              icon: Icon(
                hasObjectives ? Icons.edit : Icons.add,
                size: DesignIcons.smSize,
                color: DesignColors.primary,
              ),
              label: Text(
                hasObjectives ? 'Sửa' : 'Chọn',
                style: DesignTypography.bodySmall.copyWith(
                  color: DesignColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSpacing.sm,
                  vertical: 2,
                ),
              ),
            ),
          ],
        ),
        if (!hasObjectives)
          GestureDetector(
            onTap: _openObjectiveSelector,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignSpacing.md),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey[800]!.withValues(alpha: 0.3)
                    : Colors.grey[50],
                borderRadius:
                    BorderRadius.circular(DesignRadius.lg),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: DesignIcons.smSize,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  const SizedBox(width: DesignSpacing.sm),
                  Text(
                    'Chưa gắn mục tiêu — Nhấn để chọn',
                    style: DesignTypography.bodySmall.copyWith(
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Wrap(
            spacing: DesignSpacing.xs,
            runSpacing: DesignSpacing.xs,
            children: _selectedObjectives.map((o) {
              return Chip(
                label: Text(
                  o.code,
                  style: DesignTypography.labelSmall.copyWith(
                    color: DesignColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor:
                    DesignColors.primary.withValues(alpha: 0.1),
                side: BorderSide(
                  color: DesignColors.primary.withValues(alpha: 0.3),
                ),
                deleteIcon: Icon(
                  Icons.close,
                  size: 14,
                  color: DesignColors.primary,
                ),
                onDeleted: () {
                  setState(() {
                    _selectedObjectives.removeWhere((x) => x.id == o.id);
                    _learningObjectiveIds.remove(o.id);
                  });
                  _checkUnsavedChanges();
                },
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSpacing.xs,
                  vertical: 0,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildExplanationSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'GIẢI THÍCH ĐÁP ÁN',
                style: TextStyle(
                  fontSize: DesignTypography.labelSmallSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ).copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
            Text(
              'Không bắt buộc',
              style: DesignTypography.bodySmall.copyWith(
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
        TextFormField(
          controller: _explanationController,
          minLines: 3,
          maxLines: null,
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText:
                'Nhập lời giải chi tiết để học sinh tham khảo sau khi làm bài...',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              fontSize: DesignTypography.bodySmallSize,
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
            contentPadding: const EdgeInsets.all(12),
          ),
          style: DesignTypography.bodySmall.copyWith(
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'ĐỘ KHÓ',
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
              final isSelected =
                  _difficulty != null && _difficulty! >= difficulty;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _difficulty = _difficulty == difficulty ? null : difficulty;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      Icons.star_rounded,
                      size: 28,
                      color: isSelected
                          ? Colors.amber[400]
                          : (isDark ? Colors.grey[600] : Colors.grey[300]),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(width: 8),
            Text(
              _difficulty != null
                  ? [
                      'Rất dễ',
                      'Dễ',
                      'Trung bình',
                      'Khó',
                      'Rất khó',
                    ][_difficulty! - 1]
                  : 'Chưa chọn',
              style: DesignTypography.bodySmall.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsInput(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'THẺ (TAGS)',
            style: TextStyle(
              fontSize: DesignTypography.labelSmallSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ).copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
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
          SizedBox(height: DesignSpacing.md),
        ],
        TextFormField(
          controller: _tagInputController,
          decoration: InputDecoration(
            hintText: 'Thêm thẻ mới...',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark
                ? Colors.grey[800]!.withValues(alpha: 0.5)
                : Colors.white,
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
              horizontal: 12,
              vertical: 10,
            ),
          ),
          style: DesignTypography.bodySmall.copyWith(
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
          onFieldSubmitted: (_) => _addTag(),
        ),
      ],
    );
  }

  Widget _buildHintsSection(BuildContext context, bool isDark) {
    if (_hintControllers.isEmpty) {
      return const SizedBox.shrink();
    }

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GỢI Ý',
                style: TextStyle(
                  fontSize: DesignTypography.labelSmallSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ).copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              if (_hintControllers.length < 5)
                TextButton.icon(
                  onPressed: _addHint,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm gợi ý'),
                  style: TextButton.styleFrom(
                    foregroundColor: DesignColors.primary,
                  ),
                ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          ..._hintControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controller = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: DesignSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      minLines: 1,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Gợi ý ${index + 1}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.sm),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeHint(index),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: DesignColors.error,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAddNewButton(BuildContext context, bool isDark) {
    return Positioned(
      bottom: 24 + MediaQuery.of(context).padding.bottom,
      right: 24,
      child: FloatingActionButton(
        onPressed: _handleSaveAndAddNew,
        backgroundColor: DesignColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Future<void> _handleSaveAndAddNew() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng kiểm tra lại các trường bắt buộc'),
          backgroundColor: DesignColors.error,
        ),
      );
      return;
    }

    // Validate options for multiple choice
    if (_selectedQuestionType == QuestionType.multipleChoice) {
      if (_options.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng thêm ít nhất 2 lựa chọn'),
            backgroundColor: DesignColors.error,
          ),
        );
        return;
      }

      final hasCorrectAnswer = _options.any((opt) => opt.isCorrect);
      if (!hasCorrectAnswer) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn ít nhất 1 đáp án đúng'),
            backgroundColor: DesignColors.error,
          ),
        );
        return;
      }
    }

    // Build question data
    final questionData = _buildQuestionDataFromForm();

    // Auto-save to Supabase before adding new question
    final questionId = await _saveQuestionToSupabase(questionData);
    if (!mounted) return;
    if (questionId != null) {
      questionData['questionId'] = questionId;
      _editingQuestionId = questionId;
      // Update original values sau khi save thành công
      _captureOriginalValues();
    }

    // Call callback to save and add new
    if (widget.onSaveAndAddNew != null) {
      widget.onSaveAndAddNew!(questionData);
      // Parent sẽ pop và navigate lại với questions mới và currentQuestionIndex mới
      // Widget sẽ được rebuild với initialData = null (tạo mới)
    } else {
      // Fallback: return data to parent
      if (mounted) {
        context.pop(questionData);
      }
    }

    // Prepare new blank question locally (stay on screen)
    _resetForNewQuestion(type: _selectedQuestionType);
  }
}

/// Model cho option của câu hỏi
class QuestionOption {
  final TextEditingController controller;
  bool isCorrect;

  QuestionOption({String text = '', this.isCorrect = false})
    : controller = TextEditingController(text: text);
}
