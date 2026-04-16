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
              if (widget.isLocked) _buildCloseButton() else _buildBottomActions(),
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
    final hasNameError = _s._hasAttemptedSave && _s._errors.containsKey('name_$index');
    final hasLevelsError = _s._hasAttemptedSave && _s._errors.containsKey('levels_$index');

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
                child: isExpanded
                    ? TextFormField(
                        controller: c.nameController,
                        enabled: !widget.isLocked,
                        style: DesignTypography.titleMedium,
                        decoration: InputDecoration(
                          hintText: 'VD: Lập luận',
                          errorText: hasNameError
                              ? _s._errors['name_$index']
                              : null,
                          isDense: true,
                          border: InputBorder.none,
                          hintStyle: DesignTypography.bodyMedium.copyWith(
                            color: DesignColors.textTertiary,
                          ),
                        ),
                        onChanged: (_) {
                          if (hasNameError) {
                            setState(
                                () => _s._errors.remove('name_$index'));
                          }
                        },
                      )
                    : SmartMarqueeText(
                        text: c.nameController.text.isEmpty
                            ? 'Tiêu chí ${index + 1}'
                            : c.nameController.text,
                        style: DesignTypography.titleMedium,
                        height: 22,
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
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: DesignSpacing.md),
                      ..._s._criteria[index].levels.asMap().entries.map(
                          (e) => _buildLevelRow(index, e.key)),
                      if (!widget.isLocked) _buildAddLevelButton(index),
                    ],
                  )
                : const SizedBox.shrink(),
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
    final hasDescError = _s._hasAttemptedSave && _s._errors.containsKey('desc_${ci}_$li');

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 64,
                child: TextFormField(
                  controller: l.pointsController,
                  enabled: !widget.isLocked,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: DesignTypography.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'Điểm mức',
                    hintText: 'VD: 5',
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
                  maxLines: null,
                  style: DesignTypography.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'Mô tả',
                    hintText: 'VD: Lập luận đầy đủ, có dẫn chứng',
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
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    iconSize: DesignIcons.xsSize,
                    color: DesignColors.textTertiary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      maxWidth: 32,
                      maxHeight: 32,
                    ),
                    onPressed: () => _s._deleteLevel(ci, li),
                  ),
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

  Widget _buildCloseButton() {
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
      child: SizedBox(
        height: DesignComponents.buttonHeightLarge,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ),
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
                    alignment: Alignment.center,
                  ),
                  child: const Text(
                    'Chọn từ Mẫu',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(width: DesignSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: _s._saveAsTemplate,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignColors.primary,
                    side: BorderSide(color: DesignColors.primary),
                    alignment: Alignment.center,
                  ),
                  child: const Text(
                    'Lưu thành Mẫu',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.sm),
          _buildPointsSummaryRow(),
          SizedBox(height: DesignSpacing.sm),
          SizedBox(
            height: DesignComponents.buttonHeightLarge,
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

  Widget _buildPointsSummaryRow() {
    final total = _s._totalPoints;
    final ceiling = widget.questionPoints;

    // No ceiling configured — show simple total
    if (ceiling == null) {
      return Row(
        children: [
          Icon(Icons.calculate_outlined,
              size: DesignIcons.smSize, color: DesignColors.textSecondary),
          SizedBox(width: DesignSpacing.xs),
          Text(
            'Tổng: $total điểm',
            style: DesignTypography.bodyMedium
                .copyWith(color: DesignColors.textSecondary),
          ),
        ],
      );
    }

    // Determine status
    final Color statusColor;
    final IconData statusIcon;
    final String statusText;

    if (total < ceiling) {
      statusColor = DesignColors.warning;
      statusIcon = Icons.warning_amber_rounded;
      statusText = 'Tổng: $total đ / Tối đa: $ceiling đ  •  Còn thiếu ${ceiling - total} đ';
    } else if (total == ceiling) {
      statusColor = DesignColors.success;
      statusIcon = Icons.check_circle_outline;
      statusText = 'Tổng: $total đ / Tối đa: $ceiling đ  ✓';
    } else {
      statusColor = DesignColors.error;
      statusIcon = Icons.error_outline;
      statusText = 'Tổng: $total đ / Tối đa: $ceiling đ  •  Vượt ${total - ceiling} đ';
    }

    return Row(
      children: [
        Icon(statusIcon, size: DesignIcons.smSize, color: statusColor),
        SizedBox(width: DesignSpacing.xs),
        Expanded(
          child: Text(
            statusText,
            style: DesignTypography.bodyMedium.copyWith(color: statusColor),
          ),
        ),
      ],
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
