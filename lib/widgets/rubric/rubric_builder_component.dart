import 'dart:math';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/datasources/rubric_template_datasource.dart';
import 'package:ai_mls/widgets/rubric/rubric_template_picker_sheet.dart';
import 'package:ai_mls/widgets/text/smart_marquee_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'rubric_builder_component_builders.dart';

// ---------------------------------------------------------------------------
// Private model classes
// ---------------------------------------------------------------------------

class _LevelState {
  int points;
  String description;
  final TextEditingController pointsController;
  final TextEditingController descriptionController;

  _LevelState({required this.points, required this.description})
      : pointsController =
            TextEditingController(text: points == 0 ? '0' : points.toString()),
        descriptionController = TextEditingController(text: description);

  void dispose() {
    pointsController.dispose();
    descriptionController.dispose();
  }
}

class _CriterionState {
  String id;
  String name;
  List<_LevelState> levels;
  final TextEditingController nameController;

  _CriterionState({
    required this.id,
    required this.name,
    required this.levels,
  }) : nameController = TextEditingController(text: name);

  void dispose() {
    nameController.dispose();
    for (final l in levels) {
      l.dispose();
    }
  }
}

// ---------------------------------------------------------------------------
// Public widget
// ---------------------------------------------------------------------------

/// Full-screen draggable bottom-sheet content for building rubrics.
///
/// Open via [showModalBottomSheet] with [isScrollControlled]: true and
/// [backgroundColor]: Colors.transparent.
///
/// Decision refs: D-01 (bottom sheet), D-02 (JSONB schema), D-05 (template),
/// D-06 (onSave callback), D-07 (essay + short_answer), D-09 (isLocked).
class RubricBuilderComponent extends StatefulWidget {
  /// Existing rubric map following D-02 schema, or null to start blank.
  final Map<String, dynamic>? initialRubric;

  /// When true, all inputs are disabled and a warning banner is shown (D-09).
  final bool isLocked;

  /// Ceiling for rubric total — equals the question's points field (D-06).
  /// Null means no ceiling enforced (legacy / unknown).
  final int? questionPoints;

  /// Fired when user taps "Lưu Rubric". Receives full D-02 JSON or null if
  /// all criteria were removed.
  final ValueChanged<Map<String, dynamic>?> onSave;

  const RubricBuilderComponent({
    super.key,
    this.initialRubric,
    this.isLocked = false,
    this.questionPoints,
    required this.onSave,
  });

  @override
  State<RubricBuilderComponent> createState() =>
      _RubricBuilderComponentState();
}

// ---------------------------------------------------------------------------
// State — logic only (builders are in rubric_builder_component_builders.dart)
// ---------------------------------------------------------------------------

class _RubricBuilderComponentState extends State<RubricBuilderComponent>
    with _RubricBuilderComponentBuilders {
  late List<_CriterionState> _criteria;
  final Set<int> _expandedIndices = {};
  final Map<String, String?> _errors = {};
  bool _hasAttemptedSave = false;

  @override
  void initState() {
    super.initState();
    _parseCriteria(widget.initialRubric);
    if (_criteria.isNotEmpty) _expandedIndices.add(0);
  }

  @override
  void dispose() {
    for (final c in _criteria) {
      c.dispose();
    }
    super.dispose();
  }

  // ---- Data helpers ----

  void _parseCriteria(Map<String, dynamic>? rubric) {
    final raw = rubric?['criteria'];
    if (raw == null || raw is! List || raw.isEmpty) {
      _criteria = [];
      return;
    }
    _criteria = raw.map<_CriterionState>((dynamic item) {
      final c = item as Map<String, dynamic>;
      final rawLevels = (c['levels'] as List?) ?? [];
      final levels = rawLevels.map<_LevelState>((dynamic l) {
        final lm = l as Map<String, dynamic>;
        return _LevelState(
          points: (lm['points'] as num?)?.toInt() ?? 0,
          description: lm['description']?.toString() ?? '',
        );
      }).toList();
      return _CriterionState(
        id: c['id']?.toString() ??
            'crit-${DateTime.now().millisecondsSinceEpoch}',
        name: c['name']?.toString() ?? '',
        levels: levels,
      );
    }).toList();
  }

  Map<String, dynamic> _buildRubricJson() {
    return {
      'criteria': _criteria.map((c) {
        final maxPts =
            c.levels.isEmpty ? 0 : c.levels.map((l) => _parsedPoints(l)).reduce(max);
        return {
          'id': c.id,
          'name': c.nameController.text.trim(),
          'max_points': maxPts,
          'levels': c.levels.map((l) {
            return {
              'points': _parsedPoints(l),
              'description': l.descriptionController.text.trim(),
            };
          }).toList(),
        };
      }).toList(),
    };
  }

  int _parsedPoints(_LevelState l) =>
      int.tryParse(l.pointsController.text.trim()) ?? l.points;

  int get _totalPoints {
    if (_criteria.isEmpty) return 0;
    return _criteria.fold<int>(0, (sum, c) {
      if (c.levels.isEmpty) return sum;
      return sum + c.levels.map(_parsedPoints).reduce(max);
    });
  }

  int _criterionMaxPoints(int index) {
    final c = _criteria[index];
    if (c.levels.isEmpty) return 0;
    return c.levels.map(_parsedPoints).reduce(max);
  }

  // ---- Mutations ----

  void _addCriterion() {
    final newIndex = _criteria.length;
    setState(() {
      _criteria.add(_CriterionState(
        id: 'crit-${DateTime.now().millisecondsSinceEpoch}',
        name: '',
        levels: [
          _LevelState(points: 5, description: ''),
          _LevelState(points: 0, description: ''),
        ],
      ));
      _expandedIndices.add(newIndex);
    });
  }

  void _deleteCriterion(int index) {
    final name = _criteria[index].nameController.text.trim();
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá tiêu chí'),
        content: Text(
          name.isEmpty
              ? 'Xoá tiêu chí này? Toàn bộ mức điểm sẽ bị xoá.'
              : 'Xoá tiêu chí "$name"? Toàn bộ mức điểm trong tiêu chí sẽ bị xoá.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Xoá tiêu chí',
              style: TextStyle(color: DesignColors.error),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed != true || !mounted) return;
      setState(() {
        _criteria[index].dispose();
        _criteria.removeAt(index);
        _expandedIndices.remove(index);
        final above =
            _expandedIndices.where((i) => i > index).toList();
        for (final i in above) {
          _expandedIndices
            ..remove(i)
            ..add(i - 1);
        }
        // Clear stale error keys for deleted criterion
        _errors.removeWhere((k, _) =>
            k == 'name_$index' ||
            k == 'levels_$index' ||
            k.startsWith('desc_${index}_'));
      });
    });
  }

  void _addLevel(int criterionIndex) {
    setState(() {
      _criteria[criterionIndex].levels.add(_LevelState(points: 0, description: ''));
    });
  }

  void _deleteLevel(int ci, int li) {
    setState(() {
      _criteria[ci].levels[li].dispose();
      _criteria[ci].levels.removeAt(li);
      // Clear stale error keys for this level and re-index below
      _errors.remove('desc_${ci}_$li');
      final staleKeys = _errors.keys
          .where((k) => k.startsWith('desc_${ci}_') &&
              int.tryParse(k.split('_').last)! > li)
          .toList();
      for (final k in staleKeys) {
        final oldIdx = int.parse(k.split('_').last);
        final val = _errors.remove(k);
        _errors['desc_${ci}_${oldIdx - 1}'] = val;
      }
    });
  }

  // ---- Validation & Save ----

  bool _validate() {
    _errors.clear();
    bool valid = true;
    for (int i = 0; i < _criteria.length; i++) {
      final c = _criteria[i];
      if (c.nameController.text.trim().isEmpty) {
        _errors['name_$i'] = 'Tên tiêu chí không được để trống';
        valid = false;
      }
      if (c.levels.isEmpty) {
        _errors['levels_$i'] = 'Cần ít nhất 1 mức điểm';
        valid = false;
      }
      for (int j = 0; j < c.levels.length; j++) {
        if (c.levels[j].descriptionController.text.trim().isEmpty) {
          _errors['desc_${i}_$j'] = 'Mô tả không được để trống';
          valid = false;
        }
      }
    }
    return valid;
  }

  void _saveRubric() {
    setState(() => _hasAttemptedSave = true);
    if (!_validate()) {
      setState(() {});
      return;
    }
    widget.onSave(_criteria.isEmpty ? null : _buildRubricJson());
    if (mounted) Navigator.pop(context);
  }

  // ---- Template operations ----

  Future<void> _saveAsTemplate() async {
    final nameCtrl = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String? nameError;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignRadius.lg),
            ),
            titlePadding: EdgeInsets.fromLTRB(
              DesignSpacing.xl,
              DesignSpacing.xl,
              DesignSpacing.xl,
              DesignSpacing.sm,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: DesignSpacing.xl,
              vertical: DesignSpacing.md,
            ),
            actionsPadding: EdgeInsets.fromLTRB(
              DesignSpacing.xl,
              DesignSpacing.xs,
              DesignSpacing.xl,
              DesignSpacing.lg,
            ),
            title: Row(
              children: [
                Icon(
                  Icons.bookmark_add_outlined,
                  color: DesignColors.primary,
                  size: DesignIcons.mdSize,
                ),
                SizedBox(width: DesignSpacing.sm),
                Text(
                  'Lưu thành Mẫu',
                  style: DesignTypography.titleLarge,
                ),
              ],
            ),
            content: TextField(
              controller: nameCtrl,
              autofocus: true,
              style: DesignTypography.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Tên mẫu',
                hintText: 'VD: Mẫu lập luận cơ bản',
                errorText: nameError,
                prefixIcon: const Icon(Icons.label_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
              ),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) Navigator.pop(ctx, val.trim());
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Huỷ'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: DesignColors.primary,
                  foregroundColor: DesignColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                ),
                onPressed: () {
                  final text = nameCtrl.text.trim();
                  if (text.isEmpty) {
                    setDialogState(() => nameError = 'Vui lòng nhập tên mẫu.');
                    return;
                  }
                  Navigator.pop(ctx, text);
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
        );
      },
    );
    // Defer dispose — dialog exit animation may still reference this controller.
    WidgetsBinding.instance.addPostFrameCallback((_) => nameCtrl.dispose());

    if (name == null || !mounted) return;

    try {
      await RubricTemplateDatasource.saveRubricTemplate(
        name,
        _buildRubricJson(),
      );
      if (mounted) {
        /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — /* TODO: AppToast — AppToast.info(context, ok ? 'Đã lưu mẫu "$name"' : 'Lưu mẫu thất bại'); */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */; */;
      }
    } catch (e) {
      AppLogger.error(
        '❌ [RubricBuilderComponent] saveAsTemplate: $e',
        error: e,
      );
    }
  }

  Future<void> _openTemplatePicker() async {
    List<Map<String, dynamic>> templates;
    try {
      templates = await RubricTemplateDatasource.getSavedRubrics();
    } catch (e) {
      AppLogger.error(
        '❌ [RubricBuilderComponent] getSavedRubrics: $e',
        error: e,
      );
      templates = [];
    }
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => RubricTemplatePickerSheet(
        templates: templates,
        onSelected: (template) {
          Navigator.pop(sheetCtx);
          _confirmLoadTemplate(template);
        },
        onDelete: (index) async {
          await RubricTemplateDatasource.deleteRubricTemplate(index);
        },
      ),
    );
  }

  Future<void> _confirmLoadTemplate(Map<String, dynamic> template) async {
    if (_criteria.isEmpty) {
      _replaceWithTemplate(template);
      return;
    }
    final templateName = template['name'] as String? ?? 'mẫu này';
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
        ),
        titlePadding: EdgeInsets.fromLTRB(
          DesignSpacing.xl,
          DesignSpacing.xl,
          DesignSpacing.xl,
          DesignSpacing.sm,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.xl,
          vertical: DesignSpacing.md,
        ),
        actionsPadding: EdgeInsets.fromLTRB(
          DesignSpacing.lg,
          DesignSpacing.xs,
          DesignSpacing.lg,
          DesignSpacing.lg,
        ),
        title: Row(
          children: [
            Icon(
              Icons.file_download_outlined,
              color: DesignColors.primary,
              size: DesignIcons.mdSize,
            ),
            SizedBox(width: DesignSpacing.sm),
            Text('Áp dụng mẫu', style: DesignTypography.titleLarge),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: DesignTypography.bodyMedium.copyWith(
              color: DesignColors.textPrimary,
            ),
            children: [
              const TextSpan(text: 'Bạn đang tải mẫu '),
              TextSpan(
                text: '"$templateName"',
                style: DesignTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DesignColors.primary,
                ),
              ),
              const TextSpan(
                text: '.\n\nBạn muốn làm gì với các tiêu chí hiện tại?',
              ),
            ],
          ),
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: DesignColors.primary,
                  foregroundColor: DesignColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx, 'append'),
                child: const Text('Thêm vào tiêu chí hiện tại'),
              ),
              SizedBox(height: DesignSpacing.xs),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: DesignColors.error,
                  side: BorderSide(color: DesignColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx, 'replace'),
                child: const Text('Thay thế toàn bộ'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'cancel'),
                child: Text(
                  'Huỷ',
                  style: DesignTypography.bodyMedium.copyWith(
                    color: DesignColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (choice == 'replace') _replaceWithTemplate(template);
    if (choice == 'append') _appendTemplate(template);
  }

  void _replaceWithTemplate(Map<String, dynamic> template) {
    for (final c in _criteria) {
      c.dispose();
    }
    setState(() {
      _expandedIndices.clear();
      _errors.clear();
      _parseCriteria(template['rubric'] as Map<String, dynamic>?);
      if (_criteria.isNotEmpty) _expandedIndices.add(0);
    });
  }

  void _appendTemplate(Map<String, dynamic> template) {
    final rubric = template['rubric'] as Map<String, dynamic>?;
    final raw = rubric?['criteria'];
    if (raw == null || raw is! List || raw.isEmpty) return;
    setState(() {
      for (final dynamic item in raw) {
        final c = item as Map<String, dynamic>;
        final rawLevels = (c['levels'] as List?) ?? [];
        final levels = rawLevels.map<_LevelState>((dynamic l) {
          final lm = l as Map<String, dynamic>;
          return _LevelState(
            points: (lm['points'] as num?)?.toInt() ?? 0,
            description: lm['description']?.toString() ?? '',
          );
        }).toList();
        _criteria.add(_CriterionState(
          id: 'crit-${DateTime.now().millisecondsSinceEpoch}-${_criteria.length}',
          name: c['name']?.toString() ?? '',
          levels: levels,
        ));
      }
    });
  }

  // ---- Build entry point ----

  @override
  Widget build(BuildContext context) => _buildRoot();
}
