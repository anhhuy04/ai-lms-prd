import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// InteractiveRubricGrader — Dumb StatefulWidget for teacher grading via rubric.
///
/// D-04 happy path: Teacher taps a level card → onLevelSelected fires.
/// D-04 exception path: Teacher taps pencil icon → override input expands
///   with mandatory "Lý do ghi đè" TextField → onManualOverride fires.
///
/// This widget is DUMB — it fires callbacks only and never touches providers.
/// Callers (QuestionAnswerCard, Wave 3 screens) wire callbacks to
/// submissionGradingNotifierProvider.
///
/// Used in:
/// - QuestionAnswerCard (teacher submission detail, essay/shortAnswer with rubric)
/// - TeacherSubmissionDetailScreen (Wave 3)
class InteractiveRubricGrader extends StatefulWidget {
  /// Rubric JSONB map (D-02 schema). Must have 'criteria' list.
  final Map<String, dynamic> rubric;

  /// Currently saved score (used to pre-populate override field).
  final double? currentScore;

  /// The submission answer ID this grader applies to.
  final String submissionAnswerId;

  /// Fired when teacher selects a level card.
  /// [points] is the level's point value, [criterionId] is the criterion ID.
  final void Function(double points, String criterionId) onLevelSelected;

  /// Fired when teacher confirms a manual override.
  /// [score] is the new custom score, [reason] is mandatory override reason.
  final void Function(double score, String reason) onManualOverride;

  const InteractiveRubricGrader({
    super.key,
    required this.rubric,
    this.currentScore,
    required this.submissionAnswerId,
    required this.onLevelSelected,
    required this.onManualOverride,
  });

  @override
  State<InteractiveRubricGrader> createState() =>
      _InteractiveRubricGraderState();
}

class _InteractiveRubricGraderState extends State<InteractiveRubricGrader> {
  /// Criterion ID → selected level index within that criterion's levels array.
  final Map<String, int> _selectedLevelIndices = {};

  bool _showOverride = false;
  bool _overrideSubmitted = false;

  final _overrideScoreController = TextEditingController();
  final _overrideReasonController = TextEditingController();
  final _overrideFormKey = GlobalKey<FormState>();

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  List<dynamic> get _criteria =>
      widget.rubric['criteria'] as List<dynamic>? ?? [];

  double get _totalMax => _criteria.fold<double>(
        0,
        (sum, c) =>
            sum + ((c as Map<String, dynamic>)['max_points'] as num? ?? 0)
                .toDouble(),
      );

  double get _totalSelected {
    double total = 0;
    for (final c in _criteria) {
      final criterion = c as Map<String, dynamic>;
      final criterionId = criterion['id'] as String?;
      if (criterionId == null) continue;
      final selectedIdx = _selectedLevelIndices[criterionId];
      if (selectedIdx == null) continue;
      final levels = criterion['levels'] as List<dynamic>? ?? [];
      if (selectedIdx >= 0 && selectedIdx < levels.length) {
        total += ((levels[selectedIdx] as Map<String, dynamic>)['points']
                    as num? ??
                0)
            .toDouble();
      }
    }
    return total;
  }

  bool get _allSelected =>
      _criteria.every((c) => _selectedLevelIndices
          .containsKey((c as Map<String, dynamic>)['id'] as String? ?? ''));

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _selectLevel(String criterionId, int levelIndex, double points) {
    setState(() => _selectedLevelIndices[criterionId] = levelIndex);
    widget.onLevelSelected(points, criterionId);
  }

  void _submitOverride() {
    if (!_overrideFormKey.currentState!.validate()) return;
    final newScore =
        double.tryParse(_overrideScoreController.text.trim()) ?? 0;
    final reason = _overrideReasonController.text.trim();
    widget.onManualOverride(newScore, reason);
    setState(() {
      _overrideSubmitted = true;
      _showOverride = false;
    });
  }

  @override
  void dispose() {
    _overrideScoreController.dispose();
    _overrideReasonController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final criteria = _criteria;
    if (criteria.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: DesignSpacing.md),
          ...criteria.asMap().entries.map((entry) {
            final idx = entry.key;
            final criterion = entry.value as Map<String, dynamic>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCriterionGradingRow(criterion),
                if (idx < criteria.length - 1)
                  const SizedBox(height: DesignSpacing.lg),
              ],
            );
          }),
          const Divider(color: DesignColors.dividerLight, height: DesignSpacing.lg),
          _buildTotalScoreRow(),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _showOverride ? _buildOverrideInput() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.grading, size: DesignIcons.smSize, color: DesignColors.primary),
        const SizedBox(width: DesignSpacing.sm),
        Text('Chấm điểm theo Rubric', style: DesignTypography.titleMedium),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Criterion row
  // ---------------------------------------------------------------------------

  Widget _buildCriterionGradingRow(Map<String, dynamic> criterion) {
    final criterionId = criterion['id'] as String? ?? '';
    final selectedIdx = _selectedLevelIndices[criterionId];
    final levels = criterion['levels'] as List<dynamic>? ?? [];
    final maxPoints = criterion['max_points'];

    final selectedPoints = (selectedIdx != null &&
            selectedIdx >= 0 &&
            selectedIdx < levels.length)
        ? (levels[selectedIdx] as Map<String, dynamic>)['points']
        : null;

    final hasSelection = selectedPoints != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                criterion['name']?.toString() ?? '',
                style: DesignTypography.titleMedium.copyWith(fontSize: 14),
              ),
            ),
            Text(
              hasSelection
                  ? '$selectedPoints/$maxPoints điểm'
                  : '--/$maxPoints điểm',
              style: DesignTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: hasSelection
                    ? DesignColors.primary
                    : DesignColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignSpacing.sm),
        Wrap(
          spacing: DesignSpacing.sm,
          runSpacing: DesignSpacing.sm,
          children: levels.asMap().entries.map((entry) {
            final levelIdx = entry.key;
            final level = entry.value as Map<String, dynamic>;
            final isSelected = selectedIdx == levelIdx;
            return _buildLevelCard(criterion, level, levelIdx, isSelected);
          }).toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Level card
  // ---------------------------------------------------------------------------

  Widget _buildLevelCard(
    Map<String, dynamic> criterion,
    Map<String, dynamic> level,
    int levelIndex,
    bool isSelected,
  ) {
    final criterionId = criterion['id'] as String? ?? '';
    final points = (level['points'] as num?)?.toDouble() ?? 0;
    final description = level['description']?.toString() ?? '';

    return Semantics(
      label: '${level['points']} điểm - $description',
      child: GestureDetector(
        onTap: () => _selectLevel(criterionId, levelIndex, points),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSpacing.md,
            vertical: DesignSpacing.sm,
          ),
          constraints: const BoxConstraints(minWidth: 80, maxWidth: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? DesignColors.primary.withValues(alpha: 0.1)
                : DesignColors.white,
            border: Border.all(
              color: isSelected
                  ? DesignColors.primary
                  : DesignColors.dividerLight,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(DesignRadius.sm),
            boxShadow: isSelected ? [DesignElevation.level1] : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLevelCardHeader(level, isSelected),
              const SizedBox(height: DesignSpacing.xs),
              Text(
                description,
                style: DesignTypography.caption.copyWith(
                  color: isSelected
                      ? DesignColors.textPrimary
                      : DesignColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCardHeader(Map<String, dynamic> level, bool isSelected) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${level['points']}đ',
          style: DesignTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? DesignColors.primary : DesignColors.textPrimary,
          ),
        ),
        if (isSelected)
          Padding(
            padding: const EdgeInsets.only(left: DesignSpacing.xs),
            child: const Icon(
              Icons.check_circle,
              size: DesignIcons.xsSize,
              color: DesignColors.primary,
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Total score row
  // ---------------------------------------------------------------------------

  Widget _buildTotalScoreRow() {
    final totalDisplay =
        _allSelected ? _totalSelected.toStringAsFixed(0) : '--';
    final maxDisplay = _totalMax.toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Tổng điểm:',
                style: DesignTypography.titleMedium,
              ),
            ),
            Text(
              '$totalDisplay/$maxDisplay điểm',
              style: DesignTypography.headlineMedium.copyWith(
                color: DesignColors.primary,
              ),
            ),
            const SizedBox(width: DesignSpacing.sm),
            IconButton(
              icon: Icon(
                Icons.edit,
                size: DesignIcons.smSize,
                color: DesignColors.warning,
              ),
              tooltip: 'Ghi đè điểm',
              onPressed: () =>
                  setState(() => _showOverride = !_showOverride),
            ),
          ],
        ),
        if (_overrideSubmitted)
          Padding(
            padding: const EdgeInsets.only(top: DesignSpacing.xs),
            child: Text(
              'Đã ghi đè',
              style: DesignTypography.caption.copyWith(
                color: DesignColors.warning,
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Override input
  // ---------------------------------------------------------------------------

  Widget _buildOverrideInput() {
    return Form(
      key: _overrideFormKey,
      child: Container(
        margin: const EdgeInsets.only(top: DesignSpacing.md),
        padding: const EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: DesignColors.warning.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreField(),
            const SizedBox(height: DesignSpacing.sm),
            _buildReasonField(),
            const SizedBox(height: DesignSpacing.sm),
            _buildOverrideActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreField() {
    return TextFormField(
      controller: _overrideScoreController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Điểm mới',
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: DesignColors.warning),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: DesignColors.warning, width: 2),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: DesignColors.error),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: DesignColors.error, width: 2),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Vui lòng nhập điểm mới.';
        final parsed = double.tryParse(v.trim());
        if (parsed == null) return 'Điểm phải là số hợp lệ.';
        if (parsed < 0) return 'Điểm không được âm.';
        return null;
      },
    );
  }

  Widget _buildReasonField() {
    return TextFormField(
      controller: _overrideReasonController,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'Lý do ghi đè *',
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: DesignColors.warning),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: DesignColors.warning, width: 2),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: DesignColors.error),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: DesignColors.error, width: 2),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Vui lòng nhập lý do ghi đè điểm.';
        }
        return null;
      },
    );
  }

  Widget _buildOverrideActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => setState(() => _showOverride = false),
          style: TextButton.styleFrom(foregroundColor: DesignColors.textSecondary),
          child: const Text('Huỷ'),
        ),
        const SizedBox(width: DesignSpacing.sm),
        ElevatedButton(
          onPressed: _submitOverride,
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignColors.warning,
            foregroundColor: DesignColors.white,
            minimumSize: const Size(0, 34),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
          ),
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}
