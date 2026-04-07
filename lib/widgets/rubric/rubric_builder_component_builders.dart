part of 'rubric_builder_component.dart';

/// UI builder mixin for [_RubricBuilderComponentState].
/// Separated to keep each file within the 300-line guideline.
mixin _RubricBuilderComponentBuilders on State<RubricBuilderComponent> {
  // Concrete state fields are accessed via `this` (same object).
  // Cast to access private fields — only valid inside the same library part.
  _RubricBuilderComponentState get _s => this as _RubricBuilderComponentState;

  Widget _buildRoot() {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: DesignColors.moonLight,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(DesignRadius.lg),
              topRight: Radius.circular(DesignRadius.lg),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              const Divider(color: DesignColors.dividerLight, height: 1),
              Expanded(
                child: _s._criteria.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        controller: scrollController,
                        padding: EdgeInsets.only(
                          top: DesignSpacing.md,
                          bottom: DesignSpacing.xxxxl,
                        ),
                        itemCount: _s._criteria.length + 1,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: DesignSpacing.xs),
                        itemBuilder: (_, i) {
                          if (i == _s._criteria.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: DesignSpacing.lg,
                                vertical: DesignSpacing.sm,
                              ),
                              child: _buildAddCriterionButton(),
                            );
                          }
                          return _buildCriterionCard(i);
                        },
                      ),
              ),
              if (!widget.isLocked) _buildBottomActions(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        DesignSpacing.lg,
        DesignSpacing.xxxl,
        DesignSpacing.lg,
        DesignSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Thiết lập Rubric', style: DesignTypography.headlineMedium),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                iconSize: DesignIcons.mdSize,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          if (widget.isLocked) ...[
            SizedBox(height: DesignSpacing.sm),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignSpacing.md,
                vertical: DesignSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: DesignColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(DesignRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: DesignColors.warning,
                    size: DesignIcons.smSize,
                  ),
                  SizedBox(width: DesignSpacing.sm),
                  Expanded(
                    child: Text(
                      'Rubric đã khoá vì có học sinh đang làm bài',
                      style: DesignTypography.caption
                          .copyWith(color: DesignColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCriterionCard(int index) {
    final c = _s._criteria[index];
    final isExpanded = _s._expandedIndices.contains(index);
    final hasNameError = _s._errors.containsKey('name_$index');
    final hasLevelsError = _s._errors.containsKey('levels_$index');

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.xs,
      ),
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: DesignColors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        boxShadow: [DesignElevation.level1],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: c.nameController,
                  enabled: !widget.isLocked,
                  style: DesignTypography.titleMedium,
                  decoration: InputDecoration(
                    hintText: 'VD: Lập luận',
                    errorText:
                        hasNameError ? _s._errors['name_$index'] : null,
                    isDense: true,
                    border: InputBorder.none,
                    hintStyle: DesignTypography.bodyMedium
                        .copyWith(color: DesignColors.textTertiary),
                  ),
                  onChanged: (_) {
                    if (hasNameError) {
                      setState(() => _s._errors.remove('name_$index'));
                    }
                  },
                ),
              ),
              SizedBox(width: DesignSpacing.sm),
              _buildPointsBadge(_s._criterionMaxPoints(index)),
              IconButton(
                icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more),
                iconSize: DesignIcons.smSize,
                onPressed: () => setState(() {
                  if (isExpanded) {
                    _s._expandedIndices.remove(index);
                  } else {
                    _s._expandedIndices.add(index);
                  }
                }),
              ),
              if (!widget.isLocked)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  iconSize: DesignIcons.smSize,
                  color: DesignColors.error,
                  onPressed: () => _s._deleteCriterion(index),
                ),
            ],
          ),
          if (hasLevelsError) ...[
            SizedBox(height: DesignSpacing.xs),
            Text(
              _s._errors['levels_$index']!,
              style: DesignTypography.caption
                  .copyWith(color: DesignColors.error),
            ),
          ],
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 150),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: DesignSpacing.md),
                ..._s._criteria[index].levels.asMap().entries.map(
                    (e) => _buildLevelRow(index, e.key)),
                if (!widget.isLocked) _buildAddLevelButton(index),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsBadge(int points) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: DesignColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DesignRadius.full),
      ),
      child: Text(
        '$points điểm',
        style: DesignTypography.caption
            .copyWith(color: DesignColors.primary),
      ),
    );
  }

  Widget _buildLevelRow(int ci, int li) {
    final l = _s._criteria[ci].levels[li];
    final hasDescError = _s._errors.containsKey('desc_${ci}_$li');

    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.sm),
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.moonLight,
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        border: hasDescError ? Border.all(color: DesignColors.error) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 60,
                child: TextFormField(
                  controller: l.pointsController,
                  enabled: !widget.isLocked,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: DesignTypography.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'Điểm',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: DesignSpacing.xs,
                      vertical: DesignSpacing.sm,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(width: DesignSpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: l.descriptionController,
                  enabled: !widget.isLocked,
                  maxLines: 2,
                  style: DesignTypography.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'Mô tả mức điểm',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: DesignSpacing.sm,
                      vertical: DesignSpacing.sm,
                    ),
                  ),
                  onChanged: (_) {
                    if (hasDescError) {
                      setState(() => _s._errors.remove('desc_${ci}_$li'));
                    }
                  },
                ),
              ),
              if (!widget.isLocked)
                IconButton(
                  icon: const Icon(Icons.close),
                  iconSize: DesignIcons.xsSize,
                  color: DesignColors.textTertiary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _s._deleteLevel(ci, li),
                ),
            ],
          ),
          if (hasDescError) ...[
            SizedBox(height: DesignSpacing.xs),
            Text(
              _s._errors['desc_${ci}_$li']!,
              style: DesignTypography.caption
                  .copyWith(color: DesignColors.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddCriterionButton() {
    return OutlinedButton.icon(
      onPressed: widget.isLocked ? null : _s._addCriterion,
      icon: const Icon(Icons.add),
      label: const Text('Thêm tiêu chí'),
      style: OutlinedButton.styleFrom(
        foregroundColor: DesignColors.primary,
        side: BorderSide(color: DesignColors.primary),
        minimumSize: const Size(double.infinity, 40),
      ),
    );
  }

  Widget _buildAddLevelButton(int criterionIndex) {
    return TextButton.icon(
      onPressed: () => _s._addLevel(criterionIndex),
      icon: const Icon(Icons.add, size: DesignIcons.xsSize),
      label: const Text('Thêm mức điểm'),
      style: TextButton.styleFrom(foregroundColor: DesignColors.primary),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      decoration: BoxDecoration(
        color: DesignColors.white,
        border: Border(top: BorderSide(color: DesignColors.dividerLight)),
      ),
      padding: EdgeInsets.fromLTRB(
        DesignSpacing.lg,
        DesignSpacing.md,
        DesignSpacing.lg,
        DesignSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _s._openTemplatePicker,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignColors.primary,
                    side: BorderSide(color: DesignColors.primary),
                  ),
                  child: const Text('Chọn từ Template'),
                ),
              ),
              SizedBox(width: DesignSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: _s._saveAsTemplate,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignColors.primary,
                    side: BorderSide(color: DesignColors.primary),
                  ),
                  child: const Text('Lưu thành Template'),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.calculate_outlined,
                size: DesignIcons.smSize,
                color: DesignColors.textSecondary,
              ),
              SizedBox(width: DesignSpacing.xs),
              Text(
                'Tổng điểm: ${_s._totalPoints} điểm',
                style: DesignTypography.bodyMedium
                    .copyWith(color: DesignColors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.sm),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _s._saveRubric,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.primary,
                foregroundColor: DesignColors.white,
              ),
              child: const Text('Lưu Rubric'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xxxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.article_outlined,
              size: DesignIcons.xlSize,
              color: DesignColors.textTertiary,
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              'Chưa có tiêu chí nào',
              style: DesignTypography.titleMedium
                  .copyWith(color: DesignColors.textSecondary),
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              "Nhấn '+ Thêm tiêu chí' để bắt đầu xây dựng rubric.",
              style: DesignTypography.bodyMedium
                  .copyWith(color: DesignColors.textTertiary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.lg),
            _buildAddCriterionButton(),
          ],
        ),
      ),
    );
  }
}
