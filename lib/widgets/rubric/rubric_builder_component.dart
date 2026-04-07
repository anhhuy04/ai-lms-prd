import 'dart:math';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/datasources/rubric_template_datasource.dart';
import 'package:ai_mls/widgets/rubric/rubric_template_picker_sheet.dart';
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

  /// Fired when user taps "Lưu Rubric". Receives full D-02 JSON or null if
  /// all criteria were removed.
  final ValueChanged<Map<String, dynamic>?> onSave;

  const RubricBuilderComponent({
    super.key,
    this.initialRubric,
    this.isLocked = false,
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
      if (confirmed != true) return;
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
      if (c.levels.length < 2) {
        _errors['levels_$i'] = 'Cần ít nhất 2 mức điểm';
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
    if (!_validate()) {
      setState(() {});
      return;
    }
    widget.onSave(_criteria.isEmpty ? null : _buildRubricJson());
    Navigator.pop(context);
  }

  // ---- Template operations ----

  Future<void> _saveAsTemplate() async {
    final nameCtrl = TextEditingController();
    String? nameError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Lưu thành Template'),
          content: TextFormField(
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: 'Tên template',
              errorText: nameError,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Huỷ'),
            ),
            TextButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) {
                  setDialogState(() => nameError = 'Vui lòng nhập tên template.');
                  return;
                }
                Navigator.pop(ctx);
                try {
                  final ok = await RubricTemplateDatasource.saveRubricTemplate(
                    nameCtrl.text.trim(),
                    _buildRubricJson(),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? 'Đã lưu template' : 'Lưu template thất bại'),
                      ),
                    );
                  }
                } catch (e) {
                  AppLogger.error(
                    '❌ [RubricBuilderComponent] saveAsTemplate: $e',
                    error: e,
                  );
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
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
      builder: (_) => RubricTemplatePickerSheet(
        templates: templates,
        onSelected: (template) {
          Navigator.pop(context);
          _loadTemplate(template);
        },
        onDelete: (index) async {
          try {
            await RubricTemplateDatasource.deleteRubricTemplate(index);
          } catch (e) {
            AppLogger.error(
              '❌ [RubricBuilderComponent] deleteRubricTemplate: $e',
              error: e,
            );
          }
        },
      ),
    );
  }

  void _loadTemplate(Map<String, dynamic> template) {
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

  // ---- Build entry point ----

  @override
  Widget build(BuildContext context) => _buildRoot();
}
