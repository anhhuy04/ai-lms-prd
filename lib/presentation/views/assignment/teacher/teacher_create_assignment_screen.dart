// ignore_for_file: use_build_context_synchronously
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/error_translation_utils.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/domain/entities/assignment_question.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_preview_assignment_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/dialog/delete_question_dialog.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/drawer/create_assignment_drawer.dart';
import 'package:ai_mls/widgets/dialogs/warning_dialog.dart';
import 'package:ai_mls/widgets/forms/date_time_picker_field.dart';
import 'package:ai_mls/widgets/forms/labeled_text_field.dart';
import 'package:ai_mls/widgets/forms/labeled_textarea.dart';
import 'package:ai_mls/widgets/forms/select_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình tạo bài tập mới cho giáo viên
/// Nếu có assignmentId, sẽ load assignment từ database để edit
class TeacherCreateAssignmentScreen extends ConsumerStatefulWidget {
  final String? assignmentId; // Assignment ID để edit (nếu có)

  const TeacherCreateAssignmentScreen({super.key, this.assignmentId});

  @override
  ConsumerState<TeacherCreateAssignmentScreen> createState() =>
      _TeacherCreateAssignmentScreenState();
}

class _TeacherCreateAssignmentScreenState
    extends ConsumerState<TeacherCreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  String? _timeLimit = '45';
  bool _isDrawerOpen = false;

  // State variables for Supabase integration
  String?
  _assignmentId; // Track assignment ID after first save (or from route parameter)
  bool _isSaving = false; // Loading state for save draft
  bool _isPublishing = false; // Loading state for publish
  bool _isLoading = false; // Loading state when loading existing assignment

  // Track original values để detect "unsaved changes" giống pattern ở AddStudentByCodeScreen.
  // Chỉ show back dialog khi có thay đổi so với original values này.
  String? _originalAssignmentId;
  String _originalTitle = '';
  String _originalDescription = '';
  DateTime? _originalDueDate;
  TimeOfDay? _originalDueTime;
  String? _originalTimeLimit;
  String _originalQuestionsSignature = '';
  String _originalScoringSignature = '';

  bool get _isDirty {
    // Heuristic: if any field has content or there is any question/distribution
    if (_titleController.text.trim().isNotEmpty) return true;
    if (_descriptionController.text.trim().isNotEmpty) return true;
    if (_dueDate != null || _dueTime != null) return true;
    if (_timeLimit != null && _timeLimit != '45') return true;
    if (_questions.isNotEmpty) return true;
    // scoring points edited
    if (_scoringPointsMap.isNotEmpty) return true;
    return false;
  }

  /// Rule: nếu chưa có assignmentId và user chưa nhập gì đáng kể => back luôn, không hiện dialog.
  bool get _hasMeaningfulDraftData {
    if (_titleController.text.trim().isNotEmpty) return true;
    if (_descriptionController.text.trim().isNotEmpty) return true;
    if (_dueDate != null || _dueTime != null) return true;
    if (_timeLimit != null && _timeLimit != '45') return true;
    if (_questions.isNotEmpty) return true;
    if (_scoringPointsMap.isNotEmpty) return true;
    return false;
  }

  Future<void> _handleBackWithDialog() async {
    if (_isSaving || _isPublishing) return;
    // Nếu chưa có id và chưa có dữ liệu => thoát luôn
    if ((_assignmentId == null || _assignmentId!.isEmpty) &&
        !_hasMeaningfulDraftData) {
      if (mounted) context.pop();
      return;
    }
    // Nếu không có thay đổi so với original => back luôn (không hiện dialog)
    if (!_hasUnsavedChangesSinceOriginal()) {
      if (mounted) context.pop();
      return;
    }

    final decision = await WarningDialog.showUnsavedChangesWithCancel(
      context: context,
      title: 'Lưu bài tập?',
      message: 'Bạn có muốn lưu bản nháp trước khi rời đi?',
      saveText: 'Lưu bản nháp',
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

    final success = await _handleSaveDraft();
    // Chỉ pop nếu lưu thành công; nếu validation lỗi hoặc exception thì ở lại trang
    if (success && mounted) {
      context.pop();
    }
  }

  void _captureOriginalValues() {
    _originalAssignmentId = _assignmentId;
    _originalTitle = _titleController.text.trim();
    _originalDescription = _descriptionController.text.trim();
    _originalDueDate = _dueDate;
    _originalDueTime = _dueTime;
    _originalTimeLimit = _timeLimit;
    _originalQuestionsSignature = _buildQuestionsSignature(_questions);
    _originalScoringSignature = _buildScoringSignature();
  }

  bool _hasUnsavedChangesSinceOriginal() {
    // Nếu chưa có original values (mở màn hình mới), dùng heuristic cũ
    if (_originalAssignmentId == null &&
        _originalTitle.isEmpty &&
        _originalDescription.isEmpty &&
        _originalDueDate == null &&
        _originalDueTime == null &&
        (_originalTimeLimit == null || _originalTimeLimit == '45') &&
        _originalQuestionsSignature.isEmpty &&
        _originalScoringSignature.isEmpty) {
      return _isDirty;
    }

    if ((_originalAssignmentId ?? '') != (_assignmentId ?? '')) return true;
    if (_originalTitle != _titleController.text.trim()) return true;
    if (_originalDescription != _descriptionController.text.trim()) return true;
    if (_originalDueDate != _dueDate) return true;
    if (_originalDueTime != _dueTime) return true;
    if (_originalTimeLimit != _timeLimit) return true;
    if (_originalQuestionsSignature != _buildQuestionsSignature(_questions)) {
      return true;
    }
    if (_originalScoringSignature != _buildScoringSignature()) return true;
    return false;
  }

  String _buildScoringSignature() {
    if (_scoringPointsMap.isEmpty) return '';
    final keys = _scoringPointsMap.keys.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return keys
        .map(
          (k) =>
              '${k.name}:${(_scoringPointsMap[k] ?? 0.0).toStringAsFixed(4)}',
        )
        .join('|');
  }

  String _buildQuestionsSignature(List<Map<String, dynamic>> qs) {
    if (qs.isEmpty) return '';
    final parts = <String>[];
    for (final q in qs) {
      final type = q['type'] as QuestionType?;
      final typeKey = type?.name ?? '';
      final text = (q['text'] as String? ?? '').trim();
      final qid = (q['questionId'] as String? ?? '').trim();
      final points = (q['points'] as double? ?? 0.0);
      final difficulty = q['difficulty']?.toString() ?? '';
      final tags =
          (q['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [];
      final tagsKey = tags.join(',');
      final los =
          (q['learningObjectives'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [];
      final loKey = los.join(',');
      final explanation = (q['explanation'] as String? ?? '').trim();
      final hints =
          (q['hints'] as List?)?.map((e) => e.toString()).toList() ?? const [];
      final hintsKey = hints.join('|');
      final images =
          (q['images'] as List?)?.map((e) => e.toString()).toList() ?? const [];
      final imagesKey = images.join('|');

      // options signature (MCQ)
      String optionsKey = '';
      final options = q['options'];
      if (options is List) {
        final buff = <String>[];
        for (final o in options) {
          if (o is Map) {
            final t = (o['text'] ?? '').toString().trim();
            final c = (o['isCorrect'] == true || o['is_correct'] == true)
                ? '1'
                : '0';
            buff.add('$t:$c');
          } else {
            buff.add(o.toString());
          }
        }
        optionsKey = buff.join('~');
      }

      parts.add(
        [
          typeKey,
          qid,
          text,
          points.toStringAsFixed(4),
          difficulty,
          tagsKey,
          loKey,
          explanation,
          hintsKey,
          imagesKey,
          optionsKey,
        ].join('^'),
      );
    }
    return parts.join('||');
  }

  // Controllers cho scoring configs
  final Map<QuestionType, TextEditingController> _scoringControllers = {};
  final Map<QuestionType, FocusNode> _scoringFocusNodes = {};

  // Questions data - chỉ rebuild section questions (không rebuild cả page)
  final ValueNotifier<List<Map<String, dynamic>>> _questionsNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  List<Map<String, dynamic>> get _questions => _questionsNotifier.value;

  void _setQuestions(List<Map<String, dynamic>> next) {
    _questionsNotifier.value = List<Map<String, dynamic>>.from(next);
  }

  /// Ensure draft assignment exists (silent create if needed) to avoid losing questions.
  /// Flow chuẩn:
  /// - User muốn thêm/sửa câu hỏi => cần có assignment_id để link và sync list
  /// - Tạo draft assignment tối thiểu (teacher_id, title/description, is_published=false)
  Future<String> _ensureDraftExists() async {
    if (_assignmentId != null && _assignmentId!.isNotEmpty) {
      return _assignmentId!;
    }

    final teacherId = ref.read(currentUserIdProvider);
    if (teacherId == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    final repository = ref.read(assignmentRepositoryProvider);

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      throw Exception('Vui lòng nhập tiêu đề bài tập trước khi tạo câu hỏi');
    }

    final description = _descriptionController.text.trim();

    final created = await repository.createAssignment({
      'teacher_id': teacherId,
      'title': title,
      'description': description.isEmpty ? null : description,
      'is_published': false,
    });

    setState(() => _assignmentId = created.id);
    return created.id;
  }

  /// Persist current questions list into assignment draft (no full-page reload).
  Future<void> _persistQuestionsToDraft() async {
    final repository = ref.read(assignmentRepositoryProvider);
    final assignmentId = await _ensureDraftExists();

    final questions = _mapQuestionsToAssignmentQuestions();
    for (final q in questions) {
      q['assignment_id'] = assignmentId;
    }

    // Patch title/description (draft only)
    final patch = <String, dynamic>{};
    final title = _titleController.text.trim();
    if (title.isNotEmpty) patch['title'] = title;
    final description = _descriptionController.text.trim();
    patch['description'] = description.isEmpty ? null : description;

    await repository.saveDraft(
      assignmentId: assignmentId,
      assignmentPatch: patch,
      questions: questions,
      distributions: const <Map<String, dynamic>>[],
    );
  }

  /// Reload only questions section from DB so user sees synced state.
  Future<void> _reloadQuestionsSection() async {
    if (_assignmentId == null || _assignmentId!.isEmpty) return;
    final repository = ref.read(assignmentRepositoryProvider);
    final questions = await repository.getAssignmentQuestions(_assignmentId!);

    final next = <Map<String, dynamic>>[];
    for (var i = 0; i < questions.length; i++) {
      final q = questions[i];
      final customContent = q.customContent ?? <String, dynamic>{};
      final typeString = customContent['type'] as String? ?? 'multiple_choice';

      QuestionType questionType;
      switch (typeString) {
        case 'multiple_choice':
          questionType = QuestionType.multipleChoice;
          break;
        case 'true_false':
          questionType = QuestionType.trueFalse;
          break;
        case 'short_answer':
          questionType = QuestionType.shortAnswer;
          break;
        case 'essay':
          questionType = QuestionType.essay;
          break;
        case 'fill_blank':
          questionType = QuestionType.fillBlank;
          break;
        case 'matching':
          questionType = QuestionType.matching;
          break;
        case 'math':
          questionType = QuestionType.math;
          break;
        case 'problem_solving':
          questionType = QuestionType.problemSolving;
          break;
        case 'file_upload':
          questionType = QuestionType.fileUpload;
          break;
        default:
          questionType = QuestionType.multipleChoice;
      }

      // Hỗ trợ cả format mới (choices) và cũ (options)
      List<Map<String, dynamic>>? parsedOptions;
      final optionsRaw = customContent['choices'] ?? customContent['options'];
      if (optionsRaw != null && optionsRaw is List && optionsRaw.isNotEmpty) {
        if (optionsRaw.first is String) {
          final correctAnswerIndex =
              customContent['correctAnswer'] as int? ?? 0;
          parsedOptions = optionsRaw.asMap().entries.map((entry) {
            final index = entry.key;
            final text = entry.value.toString();
            return {'text': text, 'isCorrect': index == correctAnswerIndex};
          }).toList();
        } else if (optionsRaw.first is Map) {
          parsedOptions = optionsRaw
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
      }

      final images = (customContent['images'] as List?)
          ?.map((e) => e.toString())
          .toList();
      final tags = (customContent['tags'] as List?)
          ?.map((e) => e.toString())
          .toList();
      final los = (customContent['learningObjectives'] as List?)
          ?.map((e) => e.toString())
          .toList();
      final hints = (customContent['hints'] as List?)
          ?.map((e) => e.toString())
          .toList();

      // Hỗ trợ cả 2 format: mới (override_text + choices) và cũ (text + options)
      final questionText = customContent['override_text'] as String? ??
          customContent['text'] as String? ?? '';
      final questionOptions = customContent['choices'] as List<dynamic>? ??
          customContent['options'] as List<dynamic>?;

      next.add({
        'number': i + 1,
        'type': questionType,
        'text': questionText,
        'images': images,
        'options': questionOptions, // Hỗ trợ cả choices và options
        'difficulty': customContent['difficulty'] as int?,
        'tags': tags,
        'learningObjectives': los,
        'explanation': customContent['explanation'] as String?,
        'hints': hints,
        'points': q.points,
        if (q.questionId != null) 'questionId': q.questionId,
      });
    }

    _setQuestions(next);
    _updateQuestionPoints();
  }

  // Map để lưu trữ điểm cho từng loại câu hỏi (nguồn gốc của điểm)
  final Map<QuestionType, double> _scoringPointsMap = {};

  // Scoring configs - tự động tạo từ các loại câu hỏi có trong danh sách
  List<Map<String, dynamic>> get _scoringConfigs {
    // Lấy danh sách các loại câu hỏi có trong questions
    final questionTypes = _questions
        .map((q) => q['type'] as QuestionType)
        .toSet();

    // Tạo configs cho các loại câu hỏi có trong danh sách
    return questionTypes.map((type) {
      return {
        'type': type,
        'questionType': type.label,
        'totalPoints': _scoringPointsMap[type] ?? 0.0,
        'typeColor': type.color,
      };
    }).toList();
  }

  /// Lấy điểm cho một câu hỏi dựa trên loại và số lượng câu cùng loại
  /// Trả về số thập phân, không làm tròn
  double _getPointsForQuestion(QuestionType type) {
    final totalPoints = _scoringPointsMap[type] ?? 0.0;
    if (totalPoints == 0.0) return 0.0;

    // Đếm số câu hỏi cùng loại
    final count = _questions.where((q) => q['type'] == type).length;
    if (count == 0) return 0.0;

    // Chia đều điểm (không làm tròn)
    return totalPoints / count;
  }

  /// Format số thập phân để hiển thị (tối đa 2 chữ số sau dấu phẩy)
  String _formatPoints(double points) {
    // Làm tròn đến 2 chữ số thập phân để hiển thị
    final rounded = (points * 100).round() / 100;
    // Nếu là số nguyên thì hiển thị không có dấu phẩy
    if (rounded == rounded.roundToDouble()) {
      return rounded.round().toString();
    }
    // Nếu có phần thập phân thì hiển thị tối đa 2 chữ số
    // Loại bỏ các số 0 thừa ở cuối và dấu chấm thừa
    final formatted = rounded.toStringAsFixed(2);
    return formatted
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Cập nhật điểm cho tất cả câu hỏi khi scoring config thay đổi
  void _updateQuestionPoints() {
    for (var q in _questions) {
      final type = q['type'] as QuestionType;
      q['points'] = _getPointsForQuestion(type);
    }
    // Đồng bộ controllers với map (chỉ khi không đang focus)
    for (final entry in _scoringPointsMap.entries) {
      final type = entry.key;
      final totalPoints = entry.value;
      final controller = _scoringControllers[type];
      final focusNode = _scoringFocusNodes[type];
      // Chỉ cập nhật controller nếu field không đang được focus
      if (controller != null &&
          focusNode != null &&
          !focusNode.hasFocus &&
          controller.text != _formatPointsForInput(totalPoints)) {
        controller.text = _formatPointsForInput(totalPoints);
      }
    }
  }

  /// Parse giá trị điểm từ string (hỗ trợ cả dấu phẩy và dấu chấm)
  double _parsePoints(String value) {
    if (value.isEmpty) return 0.0;
    // Thay dấu phẩy bằng dấu chấm để parse
    final normalized = value.replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }

  /// Format điểm để hiển thị trong input (sử dụng dấu phẩy)
  String _formatPointsForInput(double points) {
    if (points == points.roundToDouble()) {
      return points.round().toString();
    }
    return points.toString().replaceAll('.', ',');
  }

  /// Cập nhật điểm từ controller khi mất focus
  void _updatePointsFromController(QuestionType type) {
    final controller = _scoringControllers[type];
    if (controller == null) return;

    final value = controller.text.trim();
    if (value.isEmpty) {
      // Nếu rỗng, đặt về 0
      setState(() {
        _scoringPointsMap[type] = 0.0;
        _updateQuestionPoints();
      });
      controller.text = '0';
      return;
    }

    final newPoints = _parsePoints(value);

    if (newPoints >= 0) {
      setState(() {
        // Lưu dưới dạng double trong map để tính toán chính xác
        _scoringPointsMap[type] = newPoints;
        _updateQuestionPoints();
      });
      // Cập nhật lại text với giá trị đã parse (giữ dấu phẩy nếu người dùng nhập)
      final formatted = newPoints == newPoints.roundToDouble()
          ? newPoints.round().toString()
          : newPoints.toString().replaceAll('.', ',');
      if (controller.text != formatted) {
        controller.text = formatted;
      }
    } else {
      // Nếu giá trị không hợp lệ, khôi phục giá trị cũ
      final oldPoints = _scoringPointsMap[type] ?? 0.0;
      final formattedOld = oldPoints == oldPoints.roundToDouble()
          ? oldPoints.round().toString()
          : oldPoints.toString().replaceAll('.', ',');
      controller.text = formattedOld;
    }
  }

  /// Helper method để convert options/choices sang List<Map> để edit
  /// Hỗ trợ cả format mới (choices) và cũ (options)
  List<Map<String, dynamic>>? _getOptionsAsMapList(dynamic options) {
    if (options == null) return null;
    if (options is List<Map<String, dynamic>>) {
      return options;
    }
    if (options is List<dynamic>) {
      // Convert List<dynamic> to List<Map<String, dynamic>>
      return options.map((e) {
        if (e is Map<String, dynamic>) {
          return e;
        } else if (e is Map) {
          return Map<String, dynamic>.from(e);
        } else if (e is String) {
          return {'text': e, 'isCorrect': false};
        }
        return <String, dynamic>{};
      }).toList();
    }
    if (options is List<String>) {
      // Convert old format to new format
      return options.map((text) => {'text': text, 'isCorrect': false}).toList();
    }
    return null;
  }

  /// Calculate total points from all questions
  double _calculateTotalPoints() {
    return _questions.fold<double>(
      0.0,
      (sum, q) => sum + (q['points'] as double? ?? 0.0),
    );
  }

  /// Map assignment data from UI to database format
  Map<String, dynamic> _mapAssignmentToDb({required bool isPublished}) {
    final teacherId = ref.read(currentUserIdProvider);
    if (teacherId == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    // Calculate total points
    final totalPoints = _calculateTotalPoints();

    final data = {
      'teacher_id': teacherId,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'is_published': isPublished,
      'total_points': totalPoints > 0 ? totalPoints : null,
    };

    return data;
  }

  /// Map questions from UI format to assignment_questions table format
  List<Map<String, dynamic>> _mapQuestionsToAssignmentQuestions() {
    final result = <Map<String, dynamic>>[];

    for (final q in _questions) {
      final text = (q['text'] as String? ?? '').trim();
      // Bỏ qua các câu hỏi tạm chưa có nội dung => không insert vào DB
      if (text.isEmpty) continue;

      // Get question type
      final questionType = q['type'] as QuestionType;
      // Fix: Dùng dbValue thay vì name để match với grading logic (snake_case)
      final typeString = questionType.dbValue; // e.g., 'multiple_choice', 'essay'

      // Build custom_content JSON (theo format mới)
      // Format: {"override_text": "...", "choices": [...], "ai_grading_keywords": [...], "blanks": [...], ...}
      final customContent = <String, dynamic>{
        'type': typeString,
        'override_text': text,
      };

      // Add images if available
      final images = q['images'] as List<String>?;
      if (images != null && images.isNotEmpty) {
        customContent['images'] = images;
      }

      // Add choices for multiple choice / true-false questions
      final options = _getOptionsAsMapList(q['options']);
      if (options != null && options.isNotEmpty) {
        // Generate UUID for each choice (format: "choice-{index}")
        final choicesWithId = options.asMap().entries.map((entry) {
          final idx = entry.key;
          final opt = entry.value as Map<String, dynamic>;
          return {
            'id': idx, // int: 0, 1, 2... (matching question_choices.id)
            'text': opt['text'] ?? opt['content'] ?? '',
            'isCorrect': opt['isCorrect'] ?? opt['is_correct'] ?? false,
          };
        }).toList();
        customContent['choices'] = choicesWithId;
      }

      // Add AI grading keywords for essay/short_answer
      if (questionType == QuestionType.essay || questionType == QuestionType.shortAnswer) {
        final keywords = q['aiGradingKeywords'] as List<dynamic>?;
        if (keywords != null && keywords.isNotEmpty) {
          final keywordsWithId = keywords.asMap().entries.map((entry) {
            final idx = entry.key;
            final kw = entry.value as Map<String, dynamic>;
            return {
              'id': 'kw-$idx',
              'keyword': kw['keyword'] ?? '',
              'weight': kw['weight'] ?? 1.0,
            };
          }).toList();
          customContent['ai_grading_keywords'] = keywordsWithId;
        }
        // Add expected_answer if provided
        if (q['expectedAnswer'] != null) {
          customContent['expected_answer'] = q['expectedAnswer'];
        }
      }

      // Add blanks for fill_in_blank questions
      if (questionType == QuestionType.fillBlank) {
        final blanks = q['blanks'] as List<dynamic>?;
        if (blanks != null && blanks.isNotEmpty) {
          final blanksWithId = blanks.asMap().entries.map((entry) {
            final idx = entry.key;
            final blank = entry.value as Map<String, dynamic>;
            return {
              'id': 'blank_$idx',
              'original_id': blank['id'] ?? 'original_blank_$idx',
              'correct_values': blank['correctValues'] ?? blank['correct_values'] ?? [],
              'case_sensitive': blank['caseSensitive'] ?? blank['case_sensitive'] ?? false,
            };
          }).toList();
          customContent['blanks'] = blanksWithId;
        }
      }

      // Add pairs for matching questions
      if (questionType == QuestionType.matching) {
        final pairs = q['pairs'] as List<dynamic>?;
        if (pairs != null && pairs.isNotEmpty) {
          customContent['pairs'] = pairs;
        }
        final distractors = q['distractors'] as List<dynamic>?;
        if (distractors != null && distractors.isNotEmpty) {
          customContent['distractors'] = distractors;
        }
      }

      // Add file upload constraints for problem_solving / file_upload
      if (questionType == QuestionType.problemSolving || questionType == QuestionType.fileUpload) {
        if (q['allowedExtensions'] != null) {
          customContent['allowed_extensions'] = q['allowedExtensions'];
        }
        if (q['maxFileSizeMb'] != null) {
          customContent['max_file_size_mb'] = q['maxFileSizeMb'];
        }
      }

      // Add other optional fields
      if (q['difficulty'] != null) {
        customContent['difficulty'] = q['difficulty'];
      }
      if (q['tags'] != null) {
        customContent['tags'] = q['tags'];
      }
      if (q['learningObjectives'] != null) {
        customContent['learningObjectives'] = q['learningObjectives'];
      }
      if (q['explanation'] != null) {
        customContent['explanation'] = q['explanation'];
      }
      if (q['hints'] != null) {
        customContent['hints'] = q['hints'];
      }

      // Get points for this question, đảm bảo > 0 để không vi phạm constraint
      double points =
          q['points'] as double? ?? _getPointsForQuestion(questionType);
      if (points <= 0) {
        points = 1.0;
      }

      result.add({
        'assignment_id':
            _assignmentId, // Will be set after assignment is created or by caller
        'question_id': q['questionId'],
        'custom_content': customContent,
        'points': points,
        'order_idx': result.length + 1, // 1-based index trên các câu hỏi hợp lệ
      });
    }

    return result;
  }

  /// Map questions sang payload cho RPC create_assignment_with_questions.
  /// - Nếu có question_id (đã thuộc Question Bank) => dùng trường `id` để server reuse.
  /// - Luôn gửi custom_content + points + order_idx.
  List<Map<String, dynamic>> _mapQuestionsToRpcQuestions() {
    final aq = _mapQuestionsToAssignmentQuestions();
    return aq.map((row) {
      return <String, dynamic>{
        if (row['question_id'] != null) 'id': row['question_id'],
        'custom_content': row['custom_content'],
        'points': row['points'],
        'order_idx': row['order_idx'],
        if (row.containsKey('rubric')) 'rubric': row['rubric'],
        // Giữ default_points giống points để server có thể fallback nếu cần
        'default_points': row['points'],
      };
    }).toList();
  }

  /// Thêm câu hỏi mới từ CreateQuestionScreen
  Future<void> _addQuestionFromScreen(
    QuestionType questionType, {
    int? editIndex,
  }) async {
    // Trước khi cho tạo/sửa câu hỏi: bắt buộc validate các thông tin tối thiểu
    if (!_formKey.currentState!.validate()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Vui lòng nhập các thông tin bắt buộc trước khi tạo câu hỏi',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Auto-save hiện trạng assignment + danh sách câu hỏi hiện tại.
    // Mỗi lần bấm + coi như đã lưu xong "phiên" hiện tại (baseline mới).
    try {
      await _persistQuestionsToDraft();
      // Sau khi auto-save thành công, cập nhật baseline
      _captureOriginalValues();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: DesignColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Kiểm tra nếu editIndex trỏ đến câu hỏi tạm (text rỗng), thì không truyền initialData
    Map<String, dynamic>? initialData;
    if (editIndex != null && editIndex >= 0 && editIndex < _questions.length) {
      final question = _questions[editIndex];
      final questionText = question['text'] as String? ?? '';
      // Chỉ truyền initialData nếu câu hỏi đã có nội dung
      if (questionText.isNotEmpty) {
        initialData = {
          if (question['questionId'] != null)
            'questionId': question['questionId'],
          'text': questionText,
          'images': question['images'] as List<String>?,
          'options': _getOptionsAsMapList(question['options']),
          'difficulty': question['difficulty'] as int?,
          'tags': question['tags'] as List<String>?,
          'learningObjectives': question['learningObjectives'] as List<String>?,
          'explanation': question['explanation'] as String?,
          'hints': question['hints'] as List<String>?,
        };
      }
    }

    final questionData = await context.push<Map<String, dynamic>>(
      AppRoute.teacherCreateQuestionPath,
      extra: {
        'questionType': questionType,
        'questions': _questions,
        'currentQuestionIndex': editIndex,
        'initialData': initialData, // null nếu là câu hỏi tạm
        'onQuestionSelected': (int index) {
          // Navigate to edit question
          _editQuestion(index);
        },
        'onSaveAndAddNew': (Map<String, dynamic> savedQuestionData) {
          int? newIndex;

          // Save current question
          if (editIndex != null &&
              editIndex >= 0 &&
              editIndex < _questions.length) {
            // Update existing question
            final next = List<Map<String, dynamic>>.from(_questions);
            next[editIndex] = {
              'number': next[editIndex]['number'] as int,
              'type': savedQuestionData['type'] as QuestionType,
              'text': savedQuestionData['text'] as String,
              'images': savedQuestionData['images'] as List<String>?,
              'options':
                  savedQuestionData['options'] as List<Map<String, dynamic>>?,
              'difficulty': savedQuestionData['difficulty'] as int?,
              'tags': savedQuestionData['tags'] as List<String>?,
              'learningObjectives':
                  savedQuestionData['learningObjectives'] as List<String>?,
              'explanation': savedQuestionData['explanation'] as String?,
              'hints': savedQuestionData['hints'] as List<String>?,
              'points': _getPointsForQuestion(
                savedQuestionData['type'] as QuestionType,
              ),
              if (savedQuestionData['questionId'] != null)
                'questionId': savedQuestionData['questionId'],
            };
            _setQuestions(next);
            _updateQuestionPoints();

            // Add new temporary question
            final next2 = List<Map<String, dynamic>>.from(_questions);
            final newNumber = next2.length + 1;
            next2.add({
              'number': newNumber,
              'type': savedQuestionData['type'] as QuestionType,
              'text': '', // Tạm thời để trống
              'images': null,
              'options': null,
              'difficulty': null,
              'tags': null,
              'learningObjectives': null,
              'explanation': null,
              'hints': null,
              'points': 0.0,
            });
            _setQuestions(next2);
            newIndex = next2.length - 1;
          } else {
            // Add new question
            final next = List<Map<String, dynamic>>.from(_questions);
            final newNumber = next.length + 1;
            next.add({
              'number': newNumber,
              'type': savedQuestionData['type'] as QuestionType,
              'text': savedQuestionData['text'] as String,
              'images': savedQuestionData['images'] as List<String>?,
              'options':
                  savedQuestionData['options'] as List<Map<String, dynamic>>?,
              'difficulty': savedQuestionData['difficulty'] as int?,
              'tags': savedQuestionData['tags'] as List<String>?,
              'learningObjectives':
                  savedQuestionData['learningObjectives'] as List<String>?,
              'explanation': savedQuestionData['explanation'] as String?,
              'hints': savedQuestionData['hints'] as List<String>?,
              'points': _getPointsForQuestion(
                savedQuestionData['type'] as QuestionType,
              ),
              if (savedQuestionData['questionId'] != null)
                'questionId': savedQuestionData['questionId'],
            });
            _setQuestions(next);
            _updateQuestionPoints();

            // Add new temporary question
            final next2 = List<Map<String, dynamic>>.from(_questions);
            final tempNumber = next2.length + 1;
            next2.add({
              'number': tempNumber,
              'type': savedQuestionData['type'] as QuestionType,
              'text': '', // Tạm thời để trống
              'images': null,
              'options': null,
              'difficulty': null,
              'tags': null,
              'learningObjectives': null,
              'explanation': null,
              'hints': null,
              'points': 0.0,
            });
            _setQuestions(next2);
            newIndex = next2.length - 1;
          }

          // Navigate lại với questions mới và currentQuestionIndex mới
          if (newIndex >= 0) {
            // Pop current screen
            context.pop();
            // Navigate lại với questions mới và index mới
            _addQuestionFromScreen(
              savedQuestionData['type'] as QuestionType,
              editIndex: newIndex,
            );
          }

          // Return new index
          return newIndex;
        },
      },
    );

    if (questionData != null && mounted && editIndex == null) {
      final next = List<Map<String, dynamic>>.from(_questions);
      final newNumber = next.length + 1;
      next.add({
        'number': newNumber,
        'type': questionData['type'] as QuestionType,
        'text': questionData['text'] as String,
        'images': questionData['images'] as List<String>?,
        'options': questionData['options'] as List<Map<String, dynamic>>?,
        'difficulty': questionData['difficulty'] as int?,
        'tags': questionData['tags'] as List<String>?,
        'learningObjectives':
            questionData['learningObjectives'] as List<String>?,
        'explanation': questionData['explanation'] as String?,
        'hints': questionData['hints'] as List<String>?,
        'points': _getPointsForQuestion(questionData['type'] as QuestionType),
        if (questionData['questionId'] != null)
          'questionId': questionData['questionId'],
      });
      _setQuestions(next);
      _updateQuestionPoints();

      // Persist to draft + reload questions section (no full-page reload)
      try {
        await _persistQuestionsToDraft();
        await _reloadQuestionsSection();
        // Sau khi sync thành công, cập nhật baseline mới
        _captureOriginalValues();
      } catch (_) {
        // silent auto-save failures (user can still Save Draft manually)
      }
    }
  }

  /// Chỉnh sửa câu hỏi
  Future<void> _editQuestion(int index) async {
    if (index < 0 || index >= _questions.length) return;

    final question = _questions[index];
    final questionData = await context.push<Map<String, dynamic>>(
      AppRoute.teacherCreateQuestionPath,
      extra: {
        'questionType': question['type'] as QuestionType,
        'initialData': {
          if (question['questionId'] != null)
            'questionId': question['questionId'],
          'text': question['text'] as String? ?? '',
          'images': question['images'] as List<String>?,
          'options': _getOptionsAsMapList(question['options']),
          'difficulty': question['difficulty'] as int?,
          'tags': question['tags'] as List<String>?,
          'learningObjectives': question['learningObjectives'] as List<String>?,
          'explanation': question['explanation'] as String?,
          'hints': question['hints'] as List<String>?,
        },
        'questions': _questions,
        'currentQuestionIndex': index,
        'onQuestionSelected': (int idx) {
          // Navigate to edit another question
          _editQuestion(idx);
        },
        'onSaveAndAddNew': (Map<String, dynamic> savedQuestionData) {
          int? newIndex;

          // Save current question
          final next = List<Map<String, dynamic>>.from(_questions);
          next[index] = {
            'number': question['number'] as int,
            'type': savedQuestionData['type'] as QuestionType,
            'text': savedQuestionData['text'] as String,
            'images': savedQuestionData['images'] as List<String>?,
            'options':
                savedQuestionData['options'] as List<Map<String, dynamic>>?,
            'difficulty': savedQuestionData['difficulty'] as int?,
            'tags': savedQuestionData['tags'] as List<String>?,
            'learningObjectives':
                savedQuestionData['learningObjectives'] as List<String>?,
            'explanation': savedQuestionData['explanation'] as String?,
            'hints': savedQuestionData['hints'] as List<String>?,
            'points': _getPointsForQuestion(
              savedQuestionData['type'] as QuestionType,
            ),
            if (savedQuestionData['questionId'] != null)
              'questionId': savedQuestionData['questionId'],
          };
          _setQuestions(next);
          _updateQuestionPoints();

          // Add new temporary question
          final next2 = List<Map<String, dynamic>>.from(_questions);
          final newNumber = next2.length + 1;
          next2.add({
            'number': newNumber,
            'type': savedQuestionData['type'] as QuestionType,
            'text': '', // Tạm thời để trống
            'images': null,
            'options': null,
            'difficulty': null,
            'tags': null,
            'learningObjectives': null,
            'explanation': null,
            'hints': null,
            'points': 0.0,
          });
          _setQuestions(next2);
          newIndex = next2.length - 1;

          // Navigate lại với questions mới và currentQuestionIndex mới
          if (newIndex >= 0) {
            // Pop current screen
            context.pop();
            // Navigate lại với questions mới và index mới (không có initialData để tạo mới)
            Future.microtask(() {
              if (mounted) {
                _addQuestionFromScreen(
                  savedQuestionData['type'] as QuestionType,
                  editIndex: newIndex,
                );
              }
            });
          }

          // Return new index
          return newIndex;
        },
      },
    );

    if (questionData != null && mounted) {
      final next = List<Map<String, dynamic>>.from(_questions);
      next[index] = {
        'number': question['number'] as int,
        'type': questionData['type'] as QuestionType,
        'text': questionData['text'] as String,
        'images': questionData['images'] as List<String>?,
        'options': questionData['options'] as List<Map<String, dynamic>>?,
        'difficulty': questionData['difficulty'] as int?,
        'tags': questionData['tags'] as List<String>?,
        'learningObjectives':
            questionData['learningObjectives'] as List<String>?,
        'explanation': questionData['explanation'] as String?,
        'hints': questionData['hints'] as List<String>?,
        'points': _getPointsForQuestion(questionData['type'] as QuestionType),
        if (questionData['questionId'] != null)
          'questionId': questionData['questionId'],
      };
      _setQuestions(next);
      _updateQuestionPoints();

      // Persist to draft + reload questions section
      try {
        await _persistQuestionsToDraft();
        await _reloadQuestionsSection();
        // Sau khi sync thành công, cập nhật baseline mới
        _captureOriginalValues();
      } catch (_) {
        // ignore silent auto-save failures
      }
    }
  }

  double get _totalPoints {
    return _scoringConfigs.fold<double>(
      0.0,
      (sum, config) => sum + (config['totalPoints'] as double? ?? 0.0),
    );
  }

  /// Show preview assignment screen
  void _showPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherPreviewAssignmentScreen(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          questions: _questions,
          dueDate: _dueDate,
          dueTime: _dueTime,
          timeLimit: _timeLimit,
          totalPoints: _totalPoints,
        ),
      ),
    );
  }

  /// Handle AI generate questions
  Future<void> _handleAiGenerateQuestion() async {
    // Auto-save hiện trạng assignment + danh sách câu hỏi hiện tại trước khi generate
    try {
      await _persistQuestionsToDraft();
      _captureOriginalValues();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: DesignColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    final generatedQuestions = await context.push<List<Map<String, dynamic>>>(
      AppRoute.teacherAiGenerateQuestionPath,
      extra: {'questions': _questions},
    );

    if (generatedQuestions != null &&
        generatedQuestions.isNotEmpty &&
        mounted) {
      // Thêm các câu hỏi đã generate vào danh sách
      final next = List<Map<String, dynamic>>.from(_questions);
      for (var i = 0; i < generatedQuestions.length; i++) {
        final q = generatedQuestions[i];
        next.add({
          'number': next.length + 1,
          'type': q['type'] as QuestionType? ?? QuestionType.multipleChoice,
          'text': q['text'] as String? ?? '',
          'images': q['images'] as List<String>?,
          'options': q['options'] as List<Map<String, dynamic>>?,
          'difficulty': q['difficulty'] as int?,
          'tags': q['tags'] as List<String>?,
          'learningObjectives': q['learningObjectives'] as List<String>?,
          'explanation': q['explanation'] as String?,
          'hints': q['hints'] as List<String>?,
          'points': _getPointsForQuestion(
            q['type'] as QuestionType? ?? QuestionType.multipleChoice,
          ),
          if (q['questionId'] != null) 'questionId': q['questionId'],
        });
      }
      _setQuestions(next);
      _updateQuestionPoints();

      // Persist to draft + reload questions section
      try {
        await _persistQuestionsToDraft();
        await _reloadQuestionsSection();
        _captureOriginalValues();
      } catch (_) {
        // silent auto-save failures
      }
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    try {
      final translated = ErrorTranslationUtils.translateError(error, '');
      return translated.toString().replaceAll('Exception: ', '');
    } catch (_) {
      final errorStr = error.toString().toLowerCase();
      if (errorStr.contains('network') || errorStr.contains('connection')) {
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra lại kết nối internet.';
      }
      if (errorStr.contains('permission') ||
          errorStr.contains('unauthorized')) {
        return 'Bạn không có quyền thực hiện thao tác này.';
      }
      if (errorStr.contains('validation') || errorStr.contains('invalid')) {
        return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin đã nhập.';
      }
      if (errorStr.contains('timeout')) {
        return 'Thao tác quá thời gian chờ. Vui lòng thử lại.';
      }
      return error.toString();
    }
  }

  /// Handle save draft action
  /// Trả về true nếu lưu thành công, false nếu validation lỗi hoặc exception.
  Future<bool> _handleSaveDraft() async {
    // Validation
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (_questions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng thêm ít nhất một câu hỏi'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return false;
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(assignmentRepositoryProvider);

      // Map data chung cho assignment/questions
      final assignmentData = _mapAssignmentToDb(isPublished: false);
      final questionsForAssignment = _mapQuestionsToAssignmentQuestions();
      final distributions = <Map<String, dynamic>>[];

      if (_assignmentId == null) {
        // Case tạo mới: dùng RPC create_assignment_with_questions để tạo assignment + assignment_questions.
        final teacherId = ref.read(currentUserIdProvider);
        if (teacherId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Người dùng chưa đăng nhập'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return false;
        }

        final rpcQuestions = _mapQuestionsToRpcQuestions();

        final newId = await repository.createAssignmentWithQuestions(
          teacherId: teacherId,
          assignment: assignmentData,
          questions: rpcQuestions,
        );

        setState(() => _assignmentId = newId);
      } else {
        // Case đã có assignment: giữ flow saveDraft cũ (update + replace assignment_questions)
        // Remove id from assignmentData if present (not needed for patch)
        final patchData = Map<String, dynamic>.from(assignmentData);
        patchData.remove('id');

        await repository.saveDraft(
          assignmentId: _assignmentId!,
          assignmentPatch: patchData,
          questions: questionsForAssignment,
          distributions: distributions,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu bản nháp thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      AppLogger.info('✅ Đã lưu bản nháp bài tập thành công');
      // Update original values sau khi save thành công để back không hỏi lại
      _captureOriginalValues();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 Lỗi khi lưu bản nháp bài tập: $e',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        final errorMessage = _getErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: DesignColors.error,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Đóng',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Handle save and publish action
  Future<void> _handleSaveAndPublish() async {
    // Validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_questions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng thêm ít nhất một câu hỏi'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Validate due date is in the future
    if (_dueDate != null && _dueTime != null) {
      final dueAt = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        _dueTime!.hour,
        _dueTime!.minute,
      );
      if (dueAt.isBefore(DateTime.now())) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ngày hết hạn phải là thời điểm trong tương lai'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    }

    setState(() => _isPublishing = true);

    try {
      final repository = ref.read(assignmentRepositoryProvider);

      // Map data
      final assignmentData = _mapAssignmentToDb(isPublished: true);
      final questions = _mapQuestionsToAssignmentQuestions();
      final distributions = <Map<String, dynamic>>[];

      // If assignment doesn't exist yet, create it first as draft
      if (_assignmentId == null) {
        // Create as draft first
        final draftData = Map<String, dynamic>.from(assignmentData);
        draftData['is_published'] = false;
        final assignment = await repository.createAssignment(draftData);
        setState(() => _assignmentId = assignment.id);
      }

      // Update questions with assignment ID
      for (var q in questions) {
        q['assignment_id'] = _assignmentId;
      }

      // Prepare assignment data for RPC (include ID if exists)
      final assignmentForRpc = Map<String, dynamic>.from(assignmentData);
      assignmentForRpc['id'] = _assignmentId;
      assignmentForRpc['is_published'] = true;

      // Publish assignment using RPC
      await repository.publishAssignment(
        assignment: assignmentForRpc,
        questions: questions,
        distributions: distributions,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xuất bản bài tập thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back after successful publish
        context.pop();
      }

      AppLogger.info('✅ Đã xuất bản bài tập thành công');
      // Update original values để tránh hỏi lưu sau publish (phòng trường hợp không pop được)
      _captureOriginalValues();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 Lỗi khi xuất bản bài tập: $e',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        final errorMessage = _getErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: DesignColors.error,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Đóng',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Khởi tạo controllers và focus nodes cho tất cả các loại câu hỏi
    _initializeControllers();
    // Load assignment nếu có assignmentId từ route parameter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadAssignment();
    });
  }

  /// Check và load assignment nếu có assignmentId từ widget parameter
  Future<void> _checkAndLoadAssignment() async {
    // Check widget parameter for assignmentId (when navigating from draft list)
    final assignmentIdFromWidget = widget.assignmentId;

    if (assignmentIdFromWidget != null && assignmentIdFromWidget.isNotEmpty) {
      await _loadAssignment(assignmentIdFromWidget);
    } else {
      // Khởi tạo điểm cho các câu hỏi ban đầu (nếu có)
      _updateQuestionPoints();
      // Capture original values ban đầu (trang mới, chưa thay đổi gì)
      _captureOriginalValues();
    }
  }

  /// Load assignment từ database và populate UI
  Future<void> _loadAssignment(String assignmentId) async {
    if (_isLoading) return; // Prevent multiple loads

    setState(() {
      _isLoading = true;
      _assignmentId = assignmentId;
    });

    try {
      final repository = ref.read(assignmentRepositoryProvider);

      // Load assignment và questions song song
      final results = await Future.wait([
        repository.getAssignmentById(assignmentId),
        repository.getAssignmentQuestions(assignmentId),
      ]);

      final assignment = results[0] as Assignment;
      final questions = results[1] as List<AssignmentQuestion>;

      // Populate UI với assignment data
      _titleController.text = assignment.title;
      _descriptionController.text = assignment.description ?? '';

      // Parse due_at
      if (assignment.dueAt != null) {
        _dueDate = assignment.dueAt;
        _dueTime = TimeOfDay.fromDateTime(assignment.dueAt!);
      }

      // Parse time_limit_minutes
      if (assignment.timeLimitMinutes != null) {
        _timeLimit = assignment.timeLimitMinutes.toString();
      }

      // Populate questions
      final nextQuestions = <Map<String, dynamic>>[];
      for (var i = 0; i < questions.length; i++) {
        final q = questions[i];
        final customContent = q.customContent ?? <String, dynamic>{};
        final typeString =
            customContent['type'] as String? ?? 'multiple_choice';

        // Map type string to QuestionType enum
        QuestionType questionType;
        switch (typeString) {
          case 'multiple_choice':
            questionType = QuestionType.multipleChoice;
            break;
          case 'true_false':
            questionType = QuestionType.trueFalse;
            break;
          case 'short_answer':
            questionType = QuestionType.shortAnswer;
            break;
          case 'essay':
            questionType = QuestionType.essay;
            break;
          case 'fill_blank':
            questionType = QuestionType.fillBlank;
            break;
          case 'matching':
            questionType = QuestionType.matching;
            break;
          case 'math':
            questionType = QuestionType.math;
            break;
          case 'problem_solving':
            questionType = QuestionType.problemSolving;
            break;
          case 'file_upload':
            questionType = QuestionType.fileUpload;
            break;
          default:
            questionType = QuestionType.multipleChoice;
        }

        // Parse options từ custom_content - hỗ trợ cả format mới (choices) và cũ (options)
        List<Map<String, dynamic>>? parsedOptions;
        final optionsRaw = customContent['choices'] ?? customContent['options'];
        if (optionsRaw != null && optionsRaw is List && optionsRaw.isNotEmpty) {
          if (optionsRaw.first is String) {
            final correctAnswerIndex =
                customContent['correctAnswer'] as int? ?? 0;
            parsedOptions = optionsRaw.asMap().entries.map((entry) {
              final index = entry.key;
              final text = entry.value.toString();
              return {'text': text, 'isCorrect': index == correctAnswerIndex};
            }).toList();
          } else if (optionsRaw.first is Map) {
            parsedOptions = optionsRaw
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          }
        }

        // Hỗ trợ cả 2 format: mới (override_text) và cũ (text)
        final questionText = customContent['override_text'] as String? ??
            customContent['text'] as String? ?? '';

        final images = (customContent['images'] as List?)
            ?.map((e) => e.toString())
            .toList();
        final tags = (customContent['tags'] as List?)
            ?.map((e) => e.toString())
            .toList();
        final los = (customContent['learningObjectives'] as List?)
            ?.map((e) => e.toString())
            .toList();
        final hints = (customContent['hints'] as List?)
            ?.map((e) => e.toString())
            .toList();

        nextQuestions.add({
          'number': i + 1,
          'type': questionType,
          'text': questionText,
          'images': images,
          'options': parsedOptions,
          'difficulty': customContent['difficulty'] as int?,
          'tags': tags,
          'learningObjectives': los,
          'explanation': customContent['explanation'] as String?,
          'hints': hints,
          'points': q.points,
          if (q.questionId != null) 'questionId': q.questionId,
        });
      }
      _setQuestions(nextQuestions);

      // Update scoring points map từ questions
      for (var q in _questions) {
        final type = q['type'] as QuestionType;
        final points = q['points'] as double? ?? 0.0;
        _scoringPointsMap[type] = (_scoringPointsMap[type] ?? 0.0) + points;
      }

      // Re-initialize controllers với data mới
      _initializeControllers();

      // Update question points
      _updateQuestionPoints();

      // Capture original values sau khi load xong (baseline)
      _captureOriginalValues();

      AppLogger.info('✅ Đã load assignment thành công: $assignmentId');
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 Lỗi khi load assignment: $e',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải bài tập: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Khởi tạo controllers và focus nodes cho các loại câu hỏi
  void _initializeControllers() {
    // Lấy danh sách các loại câu hỏi có trong questions
    final questionTypes = _questions
        .map((q) => q['type'] as QuestionType)
        .toSet();

    for (final type in questionTypes) {
      // Tạo controller nếu chưa có
      if (!_scoringControllers.containsKey(type)) {
        _scoringControllers[type] = TextEditingController(
          text: _formatPointsForInput(_scoringPointsMap[type] ?? 0.0),
        );
      }
      // Tạo focus node nếu chưa có và thêm listener
      if (!_scoringFocusNodes.containsKey(type)) {
        final focusNode = FocusNode();
        _scoringFocusNodes[type] = focusNode;
        // Thêm listener để cập nhật khi mất focus
        focusNode.addListener(() {
          if (!focusNode.hasFocus) {
            _updatePointsFromController(type);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    // Dispose scoring controllers
    for (final controller in _scoringControllers.values) {
      controller.dispose();
    }
    // Dispose focus nodes
    for (final focusNode in _scoringFocusNodes.values) {
      focusNode.dispose();
    }
    _questionsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Show loading overlay khi đang load assignment
    if (_isLoading) {
      return Scaffold(
        backgroundColor: DesignColors.moonLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: DesignSpacing.lg),
              Text(
                'Đang tải bài tập...',
                style: DesignTypography.bodyMedium.copyWith(
                  color: isDark ? Colors.white : DesignColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackWithDialog();
      },
      child: Scaffold(
        backgroundColor: DesignColors.moonLight,
        body: Stack(
          children: [
            // Main Content
            Column(
              children: [
                // Header
                Container(
                  color: isDark ? const Color(0xFF1A2632) : Colors.white,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: statusBarHeight + 8,
                    bottom: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () async => _handleBackWithDialog(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Trình tạo Bài tập',
                              style: DesignTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : DesignColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_isSaving || _isPublishing) ...[
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark
                                        ? Colors.white
                                        : DesignColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => _isDrawerOpen = !_isDrawerOpen);
                        },
                        icon: Icon(
                          _isDrawerOpen ? Icons.close : Icons.more_vert,
                          size: 20,
                        ),
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
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
                          // Title Field
                          LabeledTextField(
                            label: 'TIÊU ĐỀ BÀI TẬP',
                            controller: _titleController,
                            hintText: 'Nhập tiêu đề...',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tiêu đề';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: DesignSpacing.xxl),

                          // Description Field
                          LabeledTextarea(
                            label: 'MÔ TẢ / HƯỚNG DẪN',
                            controller: _descriptionController,
                            hintText: 'Nhập hướng dẫn làm bài chi tiết...',
                            minLines: 3,
                            showToolbar: true,
                          ),
                          SizedBox(height: DesignSpacing.xxl),

                          // Settings Card
                          _buildSettingsCard(context, isDark),
                          SizedBox(height: DesignSpacing.xxl),

                          // Questions Section
                          ValueListenableBuilder<List<Map<String, dynamic>>>(
                            valueListenable: _questionsNotifier,
                            builder: (context, questions, _) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Nội dung bài tập',
                                    style: DesignTypography.titleMedium
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : DesignColors.textPrimary,
                                        ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: DesignColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        DesignRadius.full,
                                      ),
                                      border: Border.all(
                                        color: DesignColors.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      '${questions.length} câu',
                                      style: TextStyle(
                                        fontSize:
                                            DesignTypography.labelSmallSize,
                                        fontWeight: FontWeight.bold,
                                        color: DesignColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: DesignSpacing.lg),

                          // Questions Section (chỉ rebuild phần này)
                          ValueListenableBuilder<List<Map<String, dynamic>>>(
                            valueListenable: _questionsNotifier,
                            builder: (context, questions, _) {
                              return Column(
                                children: [
                                  ...questions.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final q = entry.value;
                                    final questionType =
                                        q['type'] as QuestionType;
                                    return _buildQuestionCard(
                                      context,
                                      isDark,
                                      questionNumber: q['number'] as int,
                                      questionType: questionType,
                                      questionText: q['text'] as String,
                                      points: _getPointsForQuestion(
                                        questionType,
                                      ),
                                      options: _getOptionsAsMapList(
                                        q['options'],
                                      ),
                                      tags: (q['tags'] as List<String>?) ?? [],
                                      onEdit: () => _editQuestion(index),
                                      onDelete: () async {
                                        final confirmed =
                                            await DeleteQuestionDialog.show(
                                              context: context,
                                              questionNumber:
                                                  q['number'] as int,
                                              questionText: q['text'] as String,
                                            );

                                        if (confirmed == true && mounted) {
                                          final next =
                                              List<Map<String, dynamic>>.from(
                                                _questions,
                                              );
                                          next.removeAt(index);
                                          for (
                                            int i = 0;
                                            i < next.length;
                                            i++
                                          ) {
                                            next[i]['number'] = i + 1;
                                          }
                                          _setQuestions(next);
                                          _updateQuestionPoints();
                                        }
                                      },
                                    );
                                  }),
                                  if (questions.isEmpty)
                                    Container(
                                      padding: EdgeInsets.all(
                                        DesignSpacing.xxxxxl,
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.post_add,
                                            size: 48,
                                            color: isDark
                                                ? Colors.grey[600]
                                                : Colors.grey[300],
                                          ),
                                          SizedBox(height: DesignSpacing.md),
                                          Text(
                                            'Thêm câu hỏi để hoàn thiện cấu trúc bài tập',
                                            style: DesignTypography.bodySmall
                                                .copyWith(
                                                  color: isDark
                                                      ? Colors.grey[400]
                                                      : Colors.grey[600],
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),

                          SizedBox(height: 100), // Space for FAB
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Floating Action Button
            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              right: 24,
              child: FloatingActionButton.extended(
                onPressed: (_isSaving || _isPublishing)
                    ? null
                    : () {
                        setState(() => _isDrawerOpen = !_isDrawerOpen);
                      },
                backgroundColor: DesignColors.primary,
                foregroundColor: Colors.white,
                elevation: 8,
                icon: Icon(_isDrawerOpen ? Icons.close : Icons.add, size: 24),
                label: Text(
                  'Thêm câu hỏi',
                  style: DesignTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Drawer Overlay
            if (_isDrawerOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _isDrawerOpen = false),
                  child: Container(color: Colors.black.withValues(alpha: 0.4)),
                ),
              ),

            // Tools Drawer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              right: _isDrawerOpen ? 0 : -400,
              top: 0,
              bottom: 0,
              child: ToolsDrawer(
                onClose: () => setState(() => _isDrawerOpen = false),
                onAddMultipleChoice: () async {
                  setState(() => _isDrawerOpen = false);
                  await _addQuestionFromScreen(QuestionType.multipleChoice);
                },
                onAddShortAnswer: () async {
                  setState(() => _isDrawerOpen = false);
                  await _addQuestionFromScreen(QuestionType.shortAnswer);
                },
                onAddEssay: () async {
                  setState(() => _isDrawerOpen = false);
                  await _addQuestionFromScreen(QuestionType.essay);
                },
                onAddMath: () async {
                  setState(() => _isDrawerOpen = false);
                  await _addQuestionFromScreen(QuestionType.math);
                },
                onAiGenerateQuestion: () async {
                  setState(() => _isDrawerOpen = false);
                  await _handleAiGenerateQuestion();
                },
                onOpenQuestionBank: () {
                  // TODO: Open question bank
                  setState(() => _isDrawerOpen = false);
                },
                onUploadFile: () {
                  // TODO: Upload file
                  setState(() => _isDrawerOpen = false);
                },
                onPreview: () {
                  setState(() => _isDrawerOpen = false);
                  _showPreview();
                },
                onSaveDraft: _isSaving || _isPublishing
                    ? null
                    : () async {
                        await _handleSaveDraft();
                      },
                onSaveAndPublish: _isSaving || _isPublishing
                    ? null
                    : () async {
                        await _handleSaveAndPublish();
                      },
                isLoading: _isSaving || _isPublishing,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card thiết lập thời hạn & thang điểm
  Widget _buildSettingsCard(BuildContext context, bool isDark) {
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
      padding: EdgeInsets.all(DesignSpacing.lg + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: DesignColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.lg),
                ),
                child: Icon(Icons.tune, size: 20, color: DesignColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'THIẾT LẬP THỜI HẠN & THANG ĐIỂM',
                  style:
                      TextStyle(
                        fontSize: DesignTypography.labelSmallSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ).copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
            ],
          ),
          Divider(
            height: DesignSpacing.xxl,
            color: isDark ? Colors.grey[700] : Colors.grey[100],
          ),

          // Date & Time
          Row(
            children: [
              Expanded(
                child: DatePickerField(
                  label: 'NGÀY HẾT HẠN',
                  initialDate: _dueDate,
                  onDateSelected: (date) {
                    setState(() => _dueDate = date);
                  },
                  onClear: () {
                    setState(() => _dueDate = null);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TimePickerField(
                  label: 'GIỜ HẾT HẠN',
                  initialTime: _dueTime,
                  onTimeSelected: (time) {
                    setState(() => _dueTime = time);
                  },
                  onClear: () {
                    setState(() => _dueTime = null);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.lg),

          // Time Limit
          SelectField<String>(
            label: 'THỜI GIAN LÀM BÀI',
            value: _timeLimit,
            prefixIcon: Icons.timer,
            useCustomPicker: true, // Sử dụng custom picker đẹp hơn
            options: const [
              SelectFieldOption(value: '15', label: '15 phút'),
              SelectFieldOption(value: '30', label: '30 phút'),
              SelectFieldOption(value: '45', label: '45 phút'),
              SelectFieldOption(value: '60', label: '60 phút'),
              SelectFieldOption(value: '90', label: '90 phút'),
              SelectFieldOption(value: 'unlimited', label: 'Không giới hạn'),
            ],
            onChanged: (limit) {
              setState(() => _timeLimit = limit);
            },
          ),
          SizedBox(height: DesignSpacing.lg),

          Divider(
            height: 1,
            color: isDark ? Colors.grey[700] : Colors.grey[100],
          ),
          SizedBox(height: DesignSpacing.lg),

          // Scoring Configuration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'THANG ĐIỂM',
                style: TextStyle(
                  fontSize: DesignTypography.labelSmallSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ).copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: DesignColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.lg),
                  border: Border.all(
                    color: DesignColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TỔNG',
                      style:
                          TextStyle(
                            fontSize: DesignTypography.labelSmallSize,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ).copyWith(
                            color: DesignColors.primary.withValues(alpha: 0.8),
                          ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _totalPoints.toString(),
                      style: DesignTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DesignColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),

          // Scoring Config Items
          ..._scoringConfigs.map((config) {
            return _buildScoringConfigItem(context, isDark, config: config);
          }),

          // Phần thông tin chi tiết ở dưới cùng
          if (_scoringConfigs.isNotEmpty) ...[
            SizedBox(height: DesignSpacing.md),
            Divider(
              height: 1,
              color: isDark ? Colors.grey[700] : Colors.grey[100],
            ),
            SizedBox(height: DesignSpacing.sm),
            ..._scoringConfigs.map((config) {
              final questionTypeEnum = config['type'] as QuestionType;
              final questionType = config['questionType'] as String;
              final totalPoints = _scoringPointsMap[questionTypeEnum] ?? 0.0;

              // Đếm số câu hỏi cùng loại
              final questionCount = _questions
                  .where((q) => q['type'] == questionTypeEnum)
                  .length;
              final pointsPerQuestion = questionCount > 0
                  ? totalPoints / questionCount
                  : 0.0;

              if (questionCount == 0) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: config['typeColor'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$questionType: $questionCount câu (${_formatPoints(pointsPerQuestion)} điểm/câu)',
                        style: DesignTypography.bodySmall.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  /// Item hiển thị cấu hình điểm cho từng loại câu hỏi
  Widget _buildScoringConfigItem(
    BuildContext context,
    bool isDark, {
    required Map<String, dynamic> config,
  }) {
    final questionType = config['questionType'] as String;
    final typeColor = config['typeColor'] as Color;
    final questionTypeEnum = config['type'] as QuestionType;
    final totalPoints = _scoringPointsMap[questionTypeEnum] ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.sm),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]!.withValues(alpha: 0.5)
            : Colors.grey[50]!.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Phần bên trái: Loại câu hỏi
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: typeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                questionType,
                style: DesignTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : DesignColors.textPrimary,
                ),
              ),
            ],
          ),
          // Phần bên phải: TextField nhập điểm
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TextField để nhập điểm
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[700]!.withValues(alpha: 0.5)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                  border: Border.all(
                    color: isDark
                        ? Colors.grey[600]!
                        : typeColor.withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller:
                      _scoringControllers[questionTypeEnum] ??
                      (() {
                        // Tạo controller nếu chưa có (fallback)
                        final controller = TextEditingController(
                          text: _formatPointsForInput(totalPoints),
                        );
                        _scoringControllers[questionTypeEnum] = controller;
                        return controller;
                      })(),
                  focusNode:
                      _scoringFocusNodes[questionTypeEnum] ??
                      (() {
                        // Tạo focus node nếu chưa có (fallback) và thêm listener
                        final focusNode = FocusNode();
                        _scoringFocusNodes[questionTypeEnum] = focusNode;
                        focusNode.addListener(() {
                          if (!focusNode.hasFocus) {
                            _updatePointsFromController(questionTypeEnum);
                          }
                        });
                        return focusNode;
                      })(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    // Chỉ cho phép số, dấu phẩy và dấu chấm
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                    // Chỉ cho phép một dấu phẩy hoặc dấu chấm
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final text = newValue.text;
                      // Đếm số dấu phẩy và dấu chấm
                      final commaCount = ','.allMatches(text).length;
                      final dotCount = '.'.allMatches(text).length;

                      // Nếu có cả dấu phẩy và dấu chấm, chỉ giữ dấu phẩy (ưu tiên dấu phẩy)
                      if (commaCount > 0 && dotCount > 0) {
                        return TextEditingValue(
                          text: text.replaceAll('.', ''),
                          selection: newValue.selection,
                        );
                      }

                      // Nếu có nhiều hơn 1 dấu phẩy hoặc dấu chấm, từ chối
                      if (commaCount > 1 || dotCount > 1) {
                        return oldValue;
                      }

                      return newValue;
                    }),
                  ],
                  style: DesignTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: typeColor,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  // Không cần onChanged, onEditingComplete, onSubmitted
                  // Vì đã có listener trong FocusNode để tự động cập nhật khi mất focus
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'điểm',
                style: DesignTypography.bodySmall.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card hiển thị một câu hỏi trong danh sách
  Widget _buildQuestionCard(
    BuildContext context,
    bool isDark, {
    required int questionNumber,
    required QuestionType questionType,
    required String questionText,
    required double points,
    List<Map<String, dynamic>>? options,
    List<String> tags = const [],
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    final borderRadius = BorderRadius.circular(DesignRadius.lg * 1.5);

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
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
            // Colored left border
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
                  // Header với số câu và điểm
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CÂU $questionNumber • ${questionType.label}',
                            style: TextStyle(
                              fontSize: DesignTypography.labelSmallSize,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      // Points input
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey[800]!.withValues(alpha: 0.5)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(DesignRadius.lg),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[700]!
                                : questionType.color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ĐIỂM',
                              style: TextStyle(
                                fontSize: DesignTypography.labelSmallSize,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 50,
                              child: Text(
                                _formatPoints(points),
                                style: DesignTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: questionType.color,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Question text
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      questionText,
                      style: DesignTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : DesignColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),

                  // Options (cho trắc nghiệm)
                  if (options != null && options.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Column(
                        children: options.map((option) {
                          // Lấy text từ Map
                          final optionText = option['text'] as String? ?? '';

                          // Check xem có phải đáp án đúng không
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
                    ),
                  ],

                  // Tags
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: DesignColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(DesignRadius.sm),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              color: DesignColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Actions
                  const SizedBox(height: 12),
                  Divider(
                    height: 1,
                    color: isDark ? Colors.grey[700] : Colors.grey[50],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: onEdit,
                        icon: Icon(
                          Icons.edit,
                          size: 18,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.transparent
                              : DesignColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete,
                          size: 18,
                          color: isDark ? Colors.grey[400] : Colors.red[600],
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.transparent
                              : Colors.red[50],
                        ),
                      ),
                    ],
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
