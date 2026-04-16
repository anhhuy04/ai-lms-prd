import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/learning_objective.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/learning_objective_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom sheet để giáo viên chọn Learning Objectives cho câu hỏi.
///
/// - [allowCreate]: Cho phép giáo viên tạo objective mới (private, source='teacher').
///
/// Trả về `List<LearningObjective>` khi xác nhận, hoặc null nếu hủy.
class ObjectiveSelectorSheet extends ConsumerStatefulWidget {
  final List<String> selectedIds;
  final bool allowCreate;

  const ObjectiveSelectorSheet({
    super.key,
    required this.selectedIds,
    this.allowCreate = false,
  });

  static Future<List<LearningObjective>?> show(
    BuildContext context, {
    required List<String> selectedIds,
    bool allowCreate = false,
  }) {
    return showModalBottomSheet<List<LearningObjective>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ObjectiveSelectorSheet(
        selectedIds: selectedIds,
        allowCreate: allowCreate,
      ),
    );
  }

  @override
  ConsumerState<ObjectiveSelectorSheet> createState() =>
      _ObjectiveSelectorSheetState();
}

class _ObjectiveSelectorSheetState
    extends ConsumerState<ObjectiveSelectorSheet> {
  late Set<String> _selected;
  bool _isLoading = true;
  String? _error;
  bool _isCreating = false;

  // objectives chia theo 3 section
  List<LearningObjective> _curriculum = []; // is_global=true, source=system/admin
  List<LearningObjective> _aiSuggested = []; // source=ai_generated
  List<LearningObjective> _mine = [];        // is_global=false, source=teacher

  // Track which subjectCode groups are expanded (key = "section_subjectCode")
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedIds);
    _loadObjectives();
  }

  Future<void> _loadObjectives() async {
    try {
      final repo = ref.read(learningObjectiveRepositoryProvider);
      final all = await repo.getObjectives();
      final currentUserId = ref.read(currentUserIdProvider);

      if (mounted) {
        setState(() {
          _curriculum = all
              .where((o) => o.isGlobal && (o.source == 'system' || o.source == 'admin'))
              .toList();
          _aiSuggested = all
              .where((o) => !o.isGlobal && o.source == 'ai_generated')
              .toList();
          _mine = all
              .where((o) =>
                  !o.isGlobal &&
                  o.source == 'teacher' &&
                  o.createdBy == currentUserId)
              .toList();
          _isLoading = false;
          // Auto-expand groups có objectives đã được chọn
          for (final o in all) {
            if (_selected.contains(o.id)) {
              final section = _sectionKeyFor(o, currentUserId);
              _expanded.add('${section}_${o.subjectCode}');
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  String _sectionKeyFor(LearningObjective o, String? currentUserId) {
    if (o.isGlobal && (o.source == 'system' || o.source == 'admin')) {
      return 'curriculum';
    }
    if (o.source == 'ai_generated') return 'ai';
    return 'mine';
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _confirm() {
    final allObjectives = [..._curriculum, ..._aiSuggested, ..._mine];
    final result = allObjectives.where((o) => _selected.contains(o.id)).toList();
    Navigator.of(context).pop(result);
  }

  // ── Create new objective ──────────────────────────────────────────────────

  Future<void> _openCreateDialog() async {
    setState(() => _isCreating = true);
    try {
      final result = await showDialog<LearningObjective>(
        context: context,
        builder: (ctx) => _CreateObjectiveDialog(ref: ref),
      );
      if (result == null || !mounted) return;
      setState(() {
        _mine.add(result);
        _selected.add(result.id);
      });
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      height: maxHeight,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DesignRadius.lg * 1.5),
        ),
      ),
      child: Column(
        children: [
          _buildHandle(isDark),
          _buildHeader(isDark),
          const Divider(height: 1),
          Expanded(child: _buildBody(isDark)),
          _buildFooter(isDark),
        ],
      ),
    );
  }

  Widget _buildHandle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: DesignSpacing.sm),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[600] : Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignSpacing.lg,
        DesignSpacing.md,
        DesignSpacing.sm,
        DesignSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chọn Mục Tiêu Học Tập',
                  style: DesignTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                ),
                if (_selected.isNotEmpty)
                  Text(
                    'Đã chọn ${_selected.length} mục tiêu',
                    style: DesignTypography.bodySmall.copyWith(
                      color: DesignColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignSpacing.xl),
          child: Text(
            'Lỗi tải dữ liệu: $_error',
            style: DesignTypography.bodyMedium.copyWith(color: DesignColors.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final hasAny = _curriculum.isNotEmpty || _aiSuggested.isNotEmpty || _mine.isNotEmpty;
    if (!hasAny) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignSpacing.xl),
          child: Text(
            'Chưa có mục tiêu học tập nào.\nNhấn "+ Tạo mới" để thêm.',
            style: DesignTypography.bodyMedium.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: DesignSpacing.xs),
      children: [
        if (_curriculum.isNotEmpty)
          _buildSection(
            isDark,
            key: 'curriculum',
            icon: Icons.menu_book_outlined,
            label: 'Chuẩn chương trình',
            color: DesignColors.primary,
            objectives: _curriculum,
          ),
        if (_aiSuggested.isNotEmpty)
          _buildSection(
            isDark,
            key: 'ai',
            icon: Icons.auto_awesome_outlined,
            label: 'AI gợi ý',
            color: const Color(0xFF7C3AED),
            objectives: _aiSuggested,
          ),
        if (_mine.isNotEmpty)
          _buildSection(
            isDark,
            key: 'mine',
            icon: Icons.edit_note_outlined,
            label: 'Của tôi',
            color: DesignColors.success,
            objectives: _mine,
          ),
      ],
    );
  }

  /// Section lớn (Chuẩn CT / AI / Của tôi) → bên trong sub-group theo subjectCode.
  Widget _buildSection(
    bool isDark, {
    required String key,
    required IconData icon,
    required String label,
    required Color color,
    required List<LearningObjective> objectives,
  }) {
    final grouped = <String, List<LearningObjective>>{};
    for (final o in objectives) {
      grouped.putIfAbsent(o.subjectCode, () => []).add(o);
    }

    final selectedCount = objectives.where((o) => _selected.contains(o.id)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DesignSpacing.lg, DesignSpacing.md, DesignSpacing.lg, DesignSpacing.xs,
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: DesignSpacing.xs),
              Text(
                label,
                style: DesignTypography.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (selectedCount > 0) ...[
                const SizedBox(width: DesignSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSpacing.sm, vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                  child: Text(
                    '$selectedCount đã chọn',
                    style: DesignTypography.labelSmall.copyWith(
                      color: color, fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Sub-groups theo subjectCode
        ...grouped.entries.map(
          (entry) => _buildSubjectGroup(isDark, key, entry.key, entry.value),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildSubjectGroup(
    bool isDark,
    String sectionKey,
    String subjectCode,
    List<LearningObjective> objectives,
  ) {
    final groupKey = '${sectionKey}_$subjectCode';
    final isExpanded = _expanded.contains(groupKey);
    final selectedCount = objectives.where((o) => _selected.contains(o.id)).length;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() {
            if (isExpanded) {
              _expanded.remove(groupKey);
            } else {
              _expanded.add(groupKey);
            }
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.lg,
              vertical: DesignSpacing.sm,
            ),
            color: isDark
                ? Colors.grey[900]!.withValues(alpha: 0.5)
                : Colors.grey[50],
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSpacing.sm, vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: DesignColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                  child: Text(
                    subjectCode,
                    style: DesignTypography.labelSmall.copyWith(
                      color: DesignColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: Text(
                    '${objectives.length} mục tiêu',
                    style: DesignTypography.bodySmall.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                if (selectedCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignSpacing.sm, vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: DesignColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(DesignRadius.sm),
                    ),
                    child: Text(
                      '$selectedCount đã chọn',
                      style: DesignTypography.labelSmall.copyWith(
                        color: DesignColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: DesignSpacing.xs),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...objectives.map((o) => _buildObjectiveItem(isDark, o)),
      ],
    );
  }

  Widget _buildObjectiveItem(bool isDark, LearningObjective objective) {
    final isSelected = _selected.contains(objective.id);

    return InkWell(
      onTap: () => _toggle(objective.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.lg,
          vertical: DesignSpacing.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => _toggle(objective.id),
              activeColor: DesignColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: DesignSpacing.xs),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      objective.code,
                      style: DesignTypography.labelSmall.copyWith(
                        color: DesignColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      objective.description,
                      style: DesignTypography.bodySmall.copyWith(
                        color: isDark ? Colors.grey[300] : DesignColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DesignSpacing.lg),
        child: Row(
          children: [
            if (widget.allowCreate)
              TextButton.icon(
                onPressed: _isCreating ? null : _openCreateDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tạo mới'),
                style: TextButton.styleFrom(
                  foregroundColor: DesignColors.success,
                ),
              ),
            // Khi có selection: "Bỏ tất cả" thay thế "Hủy" để tránh overflow
            if (_selected.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _selected.clear()),
                child: Text(
                  'Bỏ tất cả',
                  style: DesignTypography.bodyMedium.copyWith(
                    color: DesignColors.error,
                  ),
                ),
              )
            else
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Hủy',
                  style: DesignTypography.bodyMedium.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            const SizedBox(width: DesignSpacing.sm),
            ElevatedButton(
              onPressed: _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSpacing.xl,
                  vertical: DesignSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.lg),
                ),
              ),
              child: Text(
                _selected.isEmpty ? 'Xác nhận (không chọn)' : 'Xác nhận',
                style: DesignTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Create Objective Dialog ───────────────────────────────────────────────────

class _CreateObjectiveDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _CreateObjectiveDialog({required this.ref});

  @override
  ConsumerState<_CreateObjectiveDialog> createState() =>
      _CreateObjectiveDialogState();
}

class _CreateObjectiveDialogState extends ConsumerState<_CreateObjectiveDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _codeController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _codeController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final userId = ref.read(currentUserIdProvider);
      final repo = ref.read(learningObjectiveRepositoryProvider);
      final created = await repo.createObjective({
        'subject_code': _subjectController.text.trim().toUpperCase(),
        'code': _codeController.text.trim(),
        'description': _descController.text.trim(),
        'is_global': false,
        'source': 'teacher',
        'created_by': userId,
      });
      if (mounted) Navigator.of(context).pop(created);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo mục tiêu học tập'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Mã môn học *',
                hintText: 'VD: MATH, FL, IELTS',
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Bắt buộc'
                  : null,
            ),
            const SizedBox(height: DesignSpacing.sm),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Mã chuẩn *',
                hintText: 'VD: FL.01, IELTS-R1',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Bắt buộc'
                  : null,
            ),
            const SizedBox(height: DesignSpacing.sm),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Mô tả *',
                hintText: 'VD: Học sinh hiểu cấu trúc câu...',
              ),
              maxLines: 2,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Bắt buộc'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Tạo'),
        ),
      ],
    );
  }
}
