import 'dart:async';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/recipient_tree_node.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/class_hierarchy_provider.dart';
import 'package:ai_mls/presentation/providers/distribute_assignment_notifier.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/recipient_tree_selector_modal.dart';
import 'package:ai_mls/widgets/forms/date_time_picker_field.dart';
import 'package:ai_mls/widgets/forms/select_field.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TeacherDistributeAssignmentScreen extends ConsumerStatefulWidget {
  final String? assignmentId;
  final String? selectedClassId;
  final bool isEditMode;
  final String? distributionId;
  final Map<String, dynamic>? distributionConfig;

  const TeacherDistributeAssignmentScreen({
    super.key,
    this.assignmentId,
    this.selectedClassId,
    this.isEditMode = false,
    this.distributionId,
    this.distributionConfig,
  });

  @override
  ConsumerState<TeacherDistributeAssignmentScreen> createState() =>
      _TeacherDistributeAssignmentScreenState();
}

class _TeacherDistributeAssignmentScreenState
    extends ConsumerState<TeacherDistributeAssignmentScreen> {
  final ScrollController _recipientScrollController = ScrollController();
  bool _configLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.isEditMode && !_configLoaded && widget.distributionConfig != null) {
      _configLoaded = true;
      final notifierProvider = distributeAssignmentNotifierProvider(
        assignmentId: widget.assignmentId,
      );
      Future.microtask(() {
        if (mounted) {
          ref.read(notifierProvider.notifier).loadDistributionConfig(widget.distributionConfig!);
        }
      });
    }
  }

  @override
  void dispose() {
    _recipientScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifierProvider = distributeAssignmentNotifierProvider(
      assignmentId: widget.assignmentId,
    );
    final state = ref.watch(notifierProvider);
    final notifier = ref.read(notifierProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final tSec = isDark ? Colors.white70 : DesignColors.textSecondary;

    // Láº¥y teacher ID (Ä‘Ă£ load tá»« auth provider)
    final currentUserAsync = ref.watch(currentUserProvider);
    final teacherId = currentUserAsync.valueOrNull?.id;

    // Náº¿u chÆ°a cĂ³ teacher ID, hiá»ƒn thá»‹ loading Ä‘Æ¡n giáº£n
    if (teacherId == null) {
      return Scaffold(
        backgroundColor: isDark ? colorScheme.surface : DesignColors.moonLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(strokeWidth: 2),
              const SizedBox(height: 16),
              Text('Äang táº£i...', style: TextStyle(color: tSec)),
            ],
          ),
        ),
      );
    }

    // Láº¥y dá»¯ liá»‡u class hierarchy tá»« database
    final classHierarchyAsync = ref.watch(classHierarchyForDistributeProvider);

    final primaryColor = DesignColors.primary;
    final primarySoft = DesignColors.primary.withValues(alpha: 0.1);
    final bgColor = isDark ? colorScheme.surface : DesignColors.moonLight;
    final cardColor = isDark
        ? colorScheme.surfaceContainerHighest
        : DesignColors.white;
    final tMain = isDark ? Colors.white : DesignColors.textPrimary;

    // Xá»­ lĂ½ classHierarchy - cĂ³ thá»ƒ lĂ  loading hoáº·c cĂ³ dá»¯ liá»‡u
    // KHĂ”NG tráº£ vá» empty khi loading - Ä‘á»ƒ UI tá»± xá»­ lĂ½
    List<ClassNode> classHierarchy;
    bool isClassHierarchyLoading = false;
    String? classHierarchyError;

    classHierarchy = classHierarchyAsync.when(
      data: (data) {
        if (widget.selectedClassId != null) {
          final filtered = data
              .where((c) => c.id == widget.selectedClassId)
              .toList();

          if (filtered.isNotEmpty && state.recipientSelection == null) {
            Future.microtask(() {
              if (mounted) {
                notifier.setRecipientSelection(
                  RecipientSelectionResult(
                    fullySelectedClassIds: {widget.selectedClassId!},
                    selectedGroupIdsByClass: const {},
                    selectedStudentIdsByClass: const {},
                  ),
                );
              }
            });
          }
          return filtered;
        }
        return data;
      },
      loading: () {
        isClassHierarchyLoading = true;
        return <ClassNode>[];
      },
      error: (error, _) {
        classHierarchyError = error.toString();
        return <ClassNode>[];
      },
    );

    ref.listen(notifierProvider, (prev, next) {
      if (next.isSuccess) {
        notifier.resetSuccess();
        _showSuccessAndPop(context);
      }
      if (next.errorMessage != null) {
        _showError(context, next.errorMessage!);
        notifier.clearError();
      }
    });

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tSec),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.isEditMode ? 'Cáº¥u hĂ¬nh phĂ¢n phá»‘i' : 'Giao BĂ i Táº­p',
          style: TextStyle(
            color: tMain,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: tSec),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? Colors.white10 : Colors.grey[200],
            height: 1,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: cardColor,
              padding: const EdgeInsets.only(bottom: 20, top: 8),
              child: Column(
                children: [
                  InkWell(
                    onTap: widget.isEditMode
                        ? null
                        : () async {
                            final selectedIds =
                                await context.pushNamed<List<String>>(
                              AppRoute.teacherAssignmentSelection,
                              extra: {
                                'isSelectionOnly': true,
                                'initialSelectedIds': state.selectedAssignments
                                    .map((a) => a.id)
                                    .toList(),
                                if (widget.selectedClassId != null)
                                  'selectedClassId': widget.selectedClassId,
                              },
                            );
                            if (selectedIds != null && context.mounted) {
                              notifier.loadAssignmentsByIds(selectedIds);
                            }
                          },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isEditMode
                            ? (isDark ? Colors.grey[800] : Colors.grey[100])
                            : (isDark
                                ? primaryColor.withValues(alpha: 0.1)
                                : primarySoft),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.isEditMode
                              ? (isDark ? Colors.grey[600]! : Colors.grey[300]!)
                              : primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.isEditMode
                                ? Icons.lock_outline
                                : (state.selectedAssignments.isEmpty
                                    ? Icons.add_circle_outline
                                    : Icons.assignment),
                            color: widget.isEditMode
                                ? (isDark ? Colors.grey[400] : Colors.grey[500])
                                : primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              state.isLoading
                                  ? 'Äang táº£i...'
                                  : (state.selectedAssignments.isEmpty
                                        ? '+ ThĂªm bĂ i táº­p'
                                        : (state.selectedAssignments.length > 1
                                              ? '${state.selectedAssignments.length} bĂ i táº­p'
                                              : state.assignment?.title ??
                                                    'ChÆ°a rĂµ bĂ i táº­p')),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: widget.isEditMode
                                    ? (isDark ? Colors.grey[400] : Colors.grey[600])
                                    : primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            widget.isEditMode ? Icons.lock_outline : Icons.chevron_right,
                            color: widget.isEditMode
                                ? (isDark ? Colors.grey[600] : Colors.grey[400])
                                : primaryColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      text: 'Dá»± kiáº¿n ',
                      style: TextStyle(
                        fontSize: 14,
                        color: tSec,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: _calculateEstimatedCount(
                            state.recipientSelection,
                            classHierarchy,
                          ),
                          style: TextStyle(
                            color: tMain,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: ' há»c sinh nháº­n bĂ i'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildRecipientsSection(
                  state,
                  notifier,
                  isDark,
                  cardColor,
                  tMain,
                  tSec,
                  classHierarchy,
                  classHierarchyAsync,
                  isClassHierarchyLoading,
                  classHierarchyError,
                  isEditMode: widget.isEditMode,
                ),
                const SizedBox(height: 24),
                _buildScheduleSection(
                  state,
                  notifier,
                  isDark,
                  cardColor,
                  tMain,
                  tSec,
                ),
                const SizedBox(height: 24),
                _buildAdvancedSettingsSection(
                  state,
                  notifier,
                  isDark,
                  cardColor,
                  tMain,
                  tSec,
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: cardColor,
          border: Border(
            top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: state.isLoading
                ? null
                : () {
                    if (widget.isEditMode && widget.distributionId != null) {
                      notifier.updateDistribution(widget.distributionId!);
                    } else {
                      notifier.distributeNow();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: primaryColor.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: state.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.isEditMode ? Icons.save_outlined : Icons.send),
                      const SizedBox(width: 8),
                      Text(
                        widget.isEditMode ? 'LÆ°u cáº¥u hĂ¬nh' : 'Giao BĂ i Ngay',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // =======================================================
  // THĂ€NH PHáº¦N GIAO DIá»†N
  // =======================================================

  Widget _buildSectionShell(
    bool isDark,
    Color cardColor,
    IconData icon,
    String title, {
    required Widget child,
    Widget? trailingHeader,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000), // 0.04
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.02)
                  : const Color(0xFFF9FAFB),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey[100]!,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: DesignColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (trailingHeader != null) trailingHeader,
              ],
            ),
          ),
          // Body
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  Widget _buildRecipientsSection(
    DistributeAssignmentState state,
    DistributeAssignmentNotifier notifier,
    bool isDark,
    Color cardColor,
    Color tMain,
    Color tSec,
    List<ClassNode> classHierarchy,
    AsyncValue<List<ClassNode>> classHierarchyAsync,
    bool isClassHierarchyLoading,
    String? classHierarchyError, {
    bool isEditMode = false,
  }) {
    final selectionCountText = _getSelectionCountText(state.recipientSelection);
    final hasSelectedRecipients =
        state.recipientSelection != null && !state.recipientSelection!.isEmpty;

    // XĂ¢y dá»±ng ná»™i dung trung tĂ¢m
    Widget centerContent;

    if (isClassHierarchyLoading) {
      // Äang táº£i - hiá»ƒn thá»‹ loading + message
      centerContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 12),
          Text(
            'Äang táº£i danh sĂ¡ch lá»›p...',
            style: TextStyle(color: tSec, fontSize: 14),
          ),
        ],
      );
    } else if (classHierarchyError != null) {
      // CĂ³ lá»—i - hiá»ƒn thá»‹ lá»—i + nĂºt thá»­ láº¡i
      centerContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red[300], size: 40),
          const SizedBox(height: 12),
          Text(
            'Lá»—i khi táº£i danh sĂ¡ch lá»›p',
            style: TextStyle(
              color: tMain,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => ref.refresh(classHierarchyForDistributeProvider),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Thá»­ láº¡i'),
          ),
        ],
      );
    } else if (classHierarchy.isEmpty) {
      // KhĂ´ng cĂ³ lá»›p - hiá»ƒn thá»‹ message
      centerContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_outlined, color: tSec, size: 40),
          const SizedBox(height: 12),
          Text(
            'ChÆ°a cĂ³ lá»›p há»c nĂ o',
            style: TextStyle(
              color: tMain,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Báº¡n cáº§n táº¡o lá»›p há»c trÆ°á»›c khi phĂ¢n phá»‘i bĂ i táº­p',
            style: TextStyle(color: tSec, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (hasSelectedRecipients) {
      // CĂ³ dá»¯ liá»‡u vĂ  Ä‘Ă£ chá»n - hiá»ƒn thá»‹ danh sĂ¡ch Ä‘Ă£ chá»n
      centerContent = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: (MediaQuery.of(context).size.height * 0.5).clamp(0.0, 700.0),
        ),
        child: Scrollbar(
          controller: _recipientScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _recipientScrollController,
            child: Column(
              children: _buildSelectedRecipients(
                state.recipientSelection!,
                notifier,
                tMain,
                tSec,
                isDark,
                classHierarchy,
                isEditMode: isEditMode,
              ),
            ),
          ),
        ),
      );
    } else {
      // CĂ³ dá»¯ liá»‡u nhÆ°ng chÆ°a chá»n
      centerContent = const SizedBox.shrink();
    }

    return _buildSectionShell(
      isDark,
      cardColor,
      Icons.group,
      'Äá»‘i tÆ°á»£ng',
      trailingHeader: selectionCountText.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? DesignColors.primary.withValues(alpha: 0.2)
                    : DesignColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                selectionCountText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DesignColors.primary,
                ),
              ),
            )
          : null,
      child: Column(
        children: [
          centerContent,
          // NĂºt Add - áº©n trong editMode
          if (!isEditMode) ...[
            if (centerContent is! SizedBox) const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final result = await RecipientTreeSelectorModal.show(
                  context,
                  data: classHierarchy,
                  initialSelection: state.recipientSelection,
                );
                if (result != null && mounted) {
                  notifier.setRecipientSelection(result);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: DesignColors.primary.withValues(alpha: 0.4),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isDark
                      ? DesignColors.primary.withValues(alpha: 0.05)
                      : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle, color: DesignColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'ThĂªm Lá»›p / NhĂ³m / Há»c sinh',
                      style: TextStyle(
                        color: DesignColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildSelectedRecipients(
    RecipientSelectionResult selection,
    DistributeAssignmentNotifier notifier,
    Color tMain,
    Color tSec,
    bool isDark,
    List<ClassNode> classHierarchy, {
    bool isEditMode = false,
  }) {
    if (selection.isEmpty) return [];

    final result = <Widget>[];

    // Láº¥y danh sĂ¡ch táº¥t cáº£ cĂ¡c Lá»›p cĂ³ chá»©a Há»c sinh hoáº·c NhĂ³m hoáº·c fully selected
    final allClassIds = <String>{
      ...selection.fullySelectedClassIds,
      ...selection.selectedGroupIdsByClass.keys,
      ...selection.selectedStudentIdsByClass.keys,
    };

    for (final classId in allClassIds) {
      final classNode = classHierarchy.firstWhere((c) => c.id == classId);
      final isFullySelected = selection.fullySelectedClassIds.contains(classId);

      final selectedGroupIds = selection.selectedGroupIdsByClass[classId] ?? {};
      final selectedStudentIds =
          selection.selectedStudentIdsByClass[classId] ?? {};

      result.add(
        _ClassRecipientAccordion(
          classNode: classNode,
          isFullySelected: isFullySelected,
          selectedGroupIds: selectedGroupIds,
          selectedStudentIds: selectedStudentIds,
          selection: selection,
          notifier: notifier,
          primaryColor: DesignColors.primary,
          tMain: tMain,
          tSec: tSec,
          isDark: isDark,
          isEditMode: isEditMode,
        ),
      );
      result.add(const SizedBox(height: 12));
    }

    // ThĂªm bottom padding extra
    if (result.isNotEmpty) {
      result.add(const SizedBox(height: 4));
    }

    return result;
  }

  Widget _buildScheduleSection(
    DistributeAssignmentState state,
    DistributeAssignmentNotifier notifier,
    bool isDark,
    Color cardColor,
    Color tMain,
    Color tSec,
  ) {
    return _buildSectionShell(
      isDark,
      cardColor,
      Icons.calendar_month,
      'Lá»‹ch trĂ¬nh & Thá»i gian',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DatePickerField(
                  label: 'NGĂ€Y Báº®T Äáº¦U',
                  initialDate: state.availableFrom,
                  onDateSelected: (date) {
                    notifier.setAvailableFrom(date);
                  },
                  onClear: () {
                    // Not supported easily without nullable in state, but ignore for now
                    // or implement a clear method in state if needed.
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TimePickerField(
                  label: 'GIá»œ Báº®T Äáº¦U',
                  initialTime: state.availableFrom != null
                      ? TimeOfDay.fromDateTime(state.availableFrom!)
                      : null,
                  onTimeSelected: (time) {
                    final current = state.availableFrom ?? DateTime.now();
                    notifier.setAvailableFrom(
                      DateTime(
                        current.year,
                        current.month,
                        current.day,
                        time.hour,
                        time.minute,
                      ),
                    );
                  },
                  onClear: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DatePickerField(
                  label: 'NGĂ€Y Háº¾T Háº N',
                  initialDate: state.dueDate,
                  onDateSelected: (date) {
                    notifier.setDueDate(date);
                  },
                  onClear: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TimePickerField(
                  label: 'GIá»œ Háº¾T Háº N',
                  initialTime: state.dueDate != null
                      ? TimeOfDay.fromDateTime(state.dueDate!)
                      : null,
                  onTimeSelected: (time) {
                    final current = state.dueDate ?? DateTime.now();
                    notifier.setDueDate(
                      DateTime(
                        current.year,
                        current.month,
                        current.day,
                        time.hour,
                        time.minute,
                      ),
                    );
                  },
                  onClear: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: isDark ? Colors.grey[700] : Colors.grey[200],
          ),
          const SizedBox(height: 16),
          // Time Limit
          SelectField<String>(
            label: 'THá»œI GIAN LĂ€M BĂ€I',
            value: state.timeLimitMinutes != null
                ? state.timeLimitMinutes.toString()
                : 'unlimited',
            prefixIcon: Icons.timer,
            useCustomPicker: true,
            options: const [
              SelectFieldOption(value: '15', label: '15 phĂºt'),
              SelectFieldOption(value: '30', label: '30 phĂºt'),
              SelectFieldOption(value: '45', label: '45 phĂºt'),
              SelectFieldOption(value: '60', label: '60 phĂºt'),
              SelectFieldOption(value: '90', label: '90 phĂºt'),
              SelectFieldOption(value: 'unlimited', label: 'KhĂ´ng giá»›i háº¡n'),
            ],
            onChanged: (limit) {
              if (limit == 'unlimited') {
                notifier.setTimeLimitMinutes(null);
              } else {
                notifier.setTimeLimitMinutes(int.tryParse(limit ?? ''));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettingsSection(
    DistributeAssignmentState state,
    DistributeAssignmentNotifier notifier,
    bool isDark,
    Color cardColor,
    Color tMain,
    Color tSec,
  ) {
    return _buildSectionShell(
      isDark,
      cardColor,
      Icons.tune,
      'CĂ i Ä‘áº·t nĂ¢ng cao',
      child: Column(
        children: [
          _buildToggleRow(
            icon: Icons.history_toggle_off,
            title: 'Cho phĂ©p ná»™p muá»™n',
            subtitle: 'Há»c sinh cĂ³ thá»ƒ ná»™p bĂ i sau thá»i háº¡n',
            value: state.allowLate,
            onChanged: notifier.setAllowLate,
            tMain: tMain,
            tSec: tSec,
            isDark: isDark,
          ),
          // Late Penalty - Hiá»ƒn thá»‹ khi allowLate = true
          if (state.allowLate) ...[
            const SizedBox(height: 8),
            _buildLatePenaltyRow(
              state: state,
              notifier: notifier,
              isDark: isDark,
              tMain: tMain,
              tSec: tSec,
            ),
          ],
          Divider(color: isDark ? Colors.white10 : Colors.grey[50]),
          // Student Review Mode
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark
                            ? DesignColors.primary.withValues(alpha: 0.15)
                            : Colors.blue[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.visibility, color: DesignColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cháº¿ Ä‘á»™ xem káº¿t quáº£',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: tMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Há»c sinh xem Ä‘Æ°á»£c gĂ¬ sau khi ná»™p bĂ i',
                            style: TextStyle(fontSize: 12, color: tSec),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'none',
                        icon: Icon(Icons.visibility_off_outlined, size: 15),
                        label: Text('áº¨n háº¿t', style: TextStyle(fontSize: 11)),
                      ),
                      ButtonSegment(
                        value: 'score_only',
                        icon: Icon(Icons.stars_outlined, size: 15),
                        label: Text('Chá»‰ Ä‘iá»ƒm', style: TextStyle(fontSize: 11)),
                      ),
                      ButtonSegment(
                        value: 'full_review',
                        icon: Icon(Icons.fact_check_outlined, size: 15),
                        label: Text('Xem láº¡i', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                    selected: {state.studentReviewMode},
                    onSelectionChanged: (s) => notifier.setStudentReviewMode(s.first),
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildReviewModeHint(state.studentReviewMode, isDark),
              ],
            ),
          ),
          Divider(color: isDark ? Colors.white10 : Colors.grey[50]),
          // Cho phĂ©p lĂ m láº¡i
          _buildToggleRow(
            icon: Icons.replay_rounded,
            title: 'Cho phĂ©p lĂ m láº¡i',
            subtitle: 'Há»c sinh cĂ³ thá»ƒ lĂ m láº¡i bĂ i sau khi Ä‘Ă£ ná»™p',
            value: state.allowRetake,
            onChanged: (v) {
              notifier.setAllowRetake(v);
              if (v) {
                if ((state.maxAttempts ?? 0) < 2) notifier.setMaxAttempts(2);
              } else {
                notifier.setMaxAttempts(null);
              }
            },
            tMain: tMain,
            tSec: tSec,
            isDark: isDark,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: state.allowRetake
                ? Container(
                    margin: const EdgeInsets.only(left: 44, top: 4, bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? DesignColors.primary.withValues(alpha: 0.08)
                          : DesignColors.primary.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? DesignColors.primary.withValues(alpha: 0.2)
                            : DesignColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.format_list_numbered, size: 18, color: DesignColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sá»‘ láº§n lĂ m tá»‘i Ä‘a',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: tMain,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCounterBtn(
                              icon: Icons.remove,
                              onPressed: (state.maxAttempts ?? 2) > 2
                                  ? () => notifier.setMaxAttempts(
                                        ((state.maxAttempts ?? 2) - 1).clamp(2, 10),
                                      )
                                  : null,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 28,
                              child: Text(
                                '${state.maxAttempts ?? 2}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: DesignColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildCounterBtn(
                              icon: Icons.add,
                              onPressed: (state.maxAttempts ?? 2) < 10
                                  ? () => notifier.setMaxAttempts(
                                        ((state.maxAttempts ?? 2) + 1).clamp(2, 10),
                                      )
                                  : null,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Divider(color: isDark ? Colors.white10 : Colors.grey[50]),
          // Quy táº¯c tĂ­nh Ä‘iá»ƒm cuá»‘i
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark
                            ? DesignColors.primary.withValues(alpha: 0.15)
                            : Colors.blue[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.calculate_outlined, color: DesignColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quy táº¯c tĂ­nh Ä‘iá»ƒm cuá»‘i',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: tMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Äiá»ƒm nĂ o Ä‘Æ°á»£c tĂ­nh khi lĂ m nhiá»u láº§n',
                            style: TextStyle(fontSize: 12, color: tSec),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'latest',
                        icon: Icon(Icons.update, size: 15),
                        label: Text('Má»›i nháº¥t', style: TextStyle(fontSize: 11)),
                      ),
                      ButtonSegment(
                        value: 'first',
                        icon: Icon(Icons.looks_one_outlined, size: 15),
                        label: Text('Äáº§u tiĂªn', style: TextStyle(fontSize: 11)),
                      ),
                      ButtonSegment(
                        value: 'max',
                        icon: Icon(Icons.trending_up, size: 15),
                        label: Text('Cao nháº¥t', style: TextStyle(fontSize: 11)),
                      ),
                      ButtonSegment(
                        value: 'average',
                        icon: Icon(Icons.bar_chart, size: 15),
                        label: Text('Trung bĂ¬nh', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                    selected: {state.scoreAggregationRule},
                    onSelectionChanged: (s) {
                      final newRule = s.first;
                      if (widget.isEditMode &&
                          newRule != state.scoreAggregationRule) {
                        _confirmRuleChange(context, newRule, notifier);
                      } else {
                        notifier.setScoreAggregationRule(newRule);
                      }
                    },
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: isDark ? Colors.white10 : Colors.grey[50]),
          _buildToggleRow(
            icon: Icons.shuffle,
            title: 'Äáº£o cĂ¢u há»i',
            subtitle: 'Thá»© tá»± cĂ¢u há»i khĂ¡c nhau cho má»—i há»c sinh',
            value: state.shuffleQuestions,
            onChanged: notifier.setShuffleQuestions,
            tMain: tMain,
            tSec: tSec,
            isDark: isDark,
          ),
          Divider(color: isDark ? Colors.white10 : Colors.grey[50]),
          _buildToggleRow(
            icon: Icons.swap_horiz,
            title: 'Äáº£o Ä‘Ă¡p Ă¡n',
            subtitle: 'Thá»© tá»± Ä‘Ă¡p Ă¡n khĂ¡c nhau cho má»—i há»c sinh',
            value: state.shuffleAnswers,
            onChanged: notifier.setShuffleAnswers,
            tMain: tMain,
            tSec: tSec,
            isDark: isDark,
          ),
          Divider(color: isDark ? Colors.white10 : Colors.grey[50]),
          _buildToggleRow(
            icon: Icons.notifications_active,
            title: 'Gá»­i thĂ´ng bĂ¡o',
            subtitle: 'ThĂ´ng bĂ¡o cho há»c sinh khi cĂ³ bĂ i má»›i',
            value: state.sendNotification,
            onChanged: notifier.setSendNotification,
            tMain: tMain,
            tSec: tSec,
            isDark: isDark,
          ),
          Divider(color: isDark ? Colors.white10 : Colors.grey[50]),
          // AI Analysis toggle (7-11b)
          _buildToggleRow(
            icon: Icons.auto_awesome,
            title: 'AI PhĂ¢n tĂ­ch bĂ i lĂ m',
            subtitle: 'Sau khi ná»™p, AI giáº£i thĂ­ch Ä‘Ă¡p Ă¡n vĂ  phĂ¢n tĂ­ch há»c lá»±c',
            value: state.aiEnabled,
            onChanged: (_) => notifier.toggleAiEnabled(),
            tMain: tMain,
            tSec: tSec,
            isDark: isDark,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: state.aiEnabled
                ? Container(
                    margin: const EdgeInsets.only(left: 44, top: 4, bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? DesignColors.primary.withValues(alpha: 0.08)
                          : DesignColors.primary.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? DesignColors.primary.withValues(alpha: 0.2)
                            : DesignColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                'Chá» giĂ¡o viĂªn duyá»‡t trÆ°á»›c khi cĂ´ng bá»‘',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: tMain,
                                ),
                              ),
                            ),
                            Transform.scale(
                              scale: 0.65,
                              child: Switch(
                                value: state.requireReview,
                                onChanged: (_) => notifier.toggleRequireReview(),
                                activeThumbColor: Colors.white,
                                activeTrackColor: DesignColors.primary,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.grey[300],
                                trackOutlineColor: WidgetStateProperty.resolveWith(
                                  (s) => s.contains(WidgetState.selected)
                                      ? DesignColors.primary
                                      : Colors.grey[300],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.requireReview
                              ? 'AI phĂ¢n tĂ­ch xong â†’ giĂ¡o viĂªn xem xĂ©t â†’ cĂ´ng bá»‘ Ä‘iá»ƒm'
                              : 'AI phĂ¢n tĂ­ch xong â†’ tá»± Ä‘á»™ng cĂ´ng bá»‘ Ä‘iá»ƒm',
                          style: TextStyle(fontSize: 12, color: tSec),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Build row cho Late Penalty slider
  Widget _buildLatePenaltyRow({
    required DistributeAssignmentState state,
    required DistributeAssignmentNotifier notifier,
    required bool isDark,
    required Color tMain,
    required Color tSec,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(left: 44), // Indent Ä‘á»ƒ phĂ¢n biá»‡t vá»›i toggle
      decoration: BoxDecoration(
        color: isDark
            ? DesignColors.primary.withValues(alpha: 0.08)
            : DesignColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? DesignColors.primary.withValues(alpha: 0.2)
              : DesignColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.percent, size: 18, color: DesignColors.primary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Pháº§n trÄƒm trá»« Ä‘iá»ƒm',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: tMain,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: DesignColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${state.latePenaltyPercent}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('0%', style: TextStyle(fontSize: 11, color: tSec)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: DesignColors.primary,
                    inactiveTrackColor: isDark
                        ? Colors.grey[700]
                        : DesignColors.primary.withValues(alpha: 0.2),
                    thumbColor: DesignColors.primary,
                    overlayColor: DesignColors.primary.withValues(alpha: 0.12),
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                  ),
                  child: Slider(
                    value: state.latePenaltyPercent.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    onChanged: (value) {
                      notifier.setLatePenaltyPercent(value.round());
                    },
                  ),
                ),
              ),
              Text('100%', style: TextStyle(fontSize: 11, color: tSec)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Má»—i ngĂ y ná»™p muá»™n sáº½ bá»‹ trá»« ${state.latePenaltyPercent}% Ä‘iá»ƒm',
            style: TextStyle(
              fontSize: 12,
              color: tSec,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color tMain,
    required Color tSec,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? DesignColors.primary.withValues(alpha: 0.15)
                        : Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: DesignColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: tMain,
                        ),
                      ),
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 12, color: tSec),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Toggle custom Ä‘á»ƒ giá»‘ng HTML
          Transform.scale(
            scale: 0.65,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: DesignColors.primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey[300],
              trackOutlineColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected)
                    ? DesignColors.primary
                    : Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRuleChange(
    BuildContext context,
    String newRule,
    DistributeAssignmentNotifier notifier,
  ) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Äá»•i quy táº¯c tĂ­nh Ä‘iá»ƒm?'),
        content: Text(
          'Chuyá»ƒn sang "${_ruleLabel(newRule)}" sáº½ thay Ä‘á»•i Ä‘iá»ƒm cuá»‘i '
          'hiá»ƒn thá»‹ cho táº¥t cáº£ há»c sinh Ä‘Ă£ ná»™p bĂ i. Tiáº¿p tá»¥c?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Há»§y'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tiáº¿p tá»¥c'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        notifier.setScoreAggregationRule(newRule);
      }
    });
  }

  String _ruleLabel(String rule) => switch (rule) {
        'max' => 'Cao nháº¥t',
        'average' => 'Trung bĂ¬nh',
        'first' => 'Äáº§u tiĂªn',
        _ => 'Má»›i nháº¥t',
      };

  Widget _buildCounterBtn({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onPressed == null
              ? (isDark ? Colors.white10 : Colors.grey[100])
              : (isDark
                    ? DesignColors.primary.withValues(alpha: 0.2)
                    : DesignColors.primary.withValues(alpha: 0.12)),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: onPressed == null
              ? (isDark ? Colors.white24 : Colors.grey[400])
              : DesignColors.primary,
        ),
      ),
    );
  }

  // ===================== Review mode hint =====================

  Widget _buildReviewModeHint(String mode, bool isDark) {
    final (IconData icon, String text, Color color) = switch (mode) {
      'none' => (
          Icons.visibility_off_outlined,
          'Há»c sinh khĂ´ng tháº¥y Ä‘iá»ƒm sá»‘ vĂ  khĂ´ng Ä‘Æ°á»£c xem láº¡i bĂ i lĂ m',
          const Color(0xFFDC2626),
        ),
      'score_only' => (
          Icons.stars_outlined,
          'Há»c sinh chá»‰ tháº¥y Ä‘iá»ƒm sá»‘, khĂ´ng xem chi tiáº¿t tá»«ng cĂ¢u tráº£ lá»i',
          const Color(0xFFD97706),
        ),
      _ => (
          Icons.fact_check_outlined,
          'Há»c sinh tháº¥y Ä‘iá»ƒm, nháº­n xĂ©t AI vĂ  cĂ³ thá»ƒ xem láº¡i tá»«ng cĂ¢u tráº£ lá»i',
          const Color(0xFF16A34A),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== Helpers =====================

  void _showSuccessAndPop(BuildContext context) {
    final state = ref.read(
      distributeAssignmentNotifierProvider(assignmentId: widget.assignmentId),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final estimatedCount = _calculateEstimatedCount(
      state.recipientSelection,
      [],
    );
    final assignmentCount = state.selectedAssignments.isNotEmpty
        ? state.selectedAssignments.length
        : 1;
    final assignmentTitle = state.selectedAssignments.isNotEmpty
        ? (assignmentCount > 1
              ? '$assignmentCount bĂ i táº­p'
              : state.selectedAssignments.first.title)
        : (state.assignment?.title ?? 'BĂ i táº­p');

    final navigator = Navigator.of(context);
    // Auto-Ä‘Ă³ng sau 3s â€” lĂªn lá»‹ch Má»˜T Láº¦N ngoĂ i builder (Ä‘áº·t trong builder sáº½ táº¡o
    // nhiá»u timer má»—i láº§n rebuild â†’ dialog tá»± Ä‘Ă³ng/pop sai). Guard mounted trĂ¡nh
    // gá»i navigator Ä‘Ă£ defunct sau khi mĂ n bá»‹ pop.
    Timer(const Duration(seconds: 3), () {
      if (mounted && navigator.canPop()) navigator.pop();
    });
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: isDark
              ? const Color(0xFF1E293B)
              : DesignColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSpacing.xl),
          ),
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated check icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        DesignColors.success,
                        DesignColors.success.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: DesignColors.success.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                SizedBox(height: DesignSpacing.lg),
                Text(
                  'Giao bĂ i thĂ nh cĂ´ng!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : DesignColors.textPrimary,
                  ),
                ),
                SizedBox(height: DesignSpacing.sm),
                Text(
                  assignmentTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: DesignColors.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: DesignSpacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignSpacing.md,
                    vertical: DesignSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: DesignColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(DesignSpacing.md),
                  ),
                  child: Text(
                    '$estimatedCount há»c sinh nháº­n bĂ i',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white70
                          : DesignColors.textSecondary,
                    ),
                  ),
                ),
                if (state.shuffleQuestions || state.shuffleAnswers) ...[
                  SizedBox(height: DesignSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shuffle_rounded,
                        size: 14,
                        color: DesignColors.tealPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Äá» thi sáº½ Ä‘Æ°á»£c xĂ¡o trá»™n khi HS báº¯t Ä‘áº§u lĂ m bĂ i',
                        style: TextStyle(
                          fontSize: 11,
                          color: DesignColors.tealPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: DesignSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: DesignSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignSpacing.md),
                      ),
                    ),
                    child: const Text('Xong'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      if (context.mounted) context.pop();
    });
  }

  void _showError(BuildContext context, String message) {
    if (context.mounted) AppToast.error(context, message);
  }

  String _calculateEstimatedCount(
    RecipientSelectionResult? result,
    List<ClassNode> classHierarchy,
  ) {
    if (result == null || result.isEmpty) return '0';

    int count = 0;
    final sel = result;

    final allClassIds = <String>{
      ...sel.fullySelectedClassIds,
      ...sel.selectedGroupIdsByClass.keys,
      ...sel.selectedStudentIdsByClass.keys,
    };

    for (final classId in allClassIds) {
      final classNode = classHierarchy.firstWhere(
        (c) => c.id == classId,
        orElse: () => ClassNode(id: '', name: ''),
      );
      if (classNode.id.isEmpty) continue;

      final isFullySelected = sel.fullySelectedClassIds.contains(classId);
      final selectedGroupIds = sel.selectedGroupIdsByClass[classId] ?? {};
      final selectedStudentIds = sel.selectedStudentIdsByClass[classId] ?? {};

      if (isFullySelected) {
        count += classNode.groups.expand((g) => g.students).length;
        count += classNode.independentStudents.length;
      } else {
        count += selectedStudentIds.length;
        for (var groupId in selectedGroupIds) {
          try {
            final groupNode = classNode.groups.firstWhere(
              (g) => g.id == groupId,
            );
            count += groupNode.students.length;
          } catch (_) {}
        }
      }
    }

    return count.toString();
  }

  String _getSelectionCountText(RecipientSelectionResult? result) {
    if (result == null || result.isEmpty) return '';
    if (result.totalClasses > 0) return 'ÄĂ£ chá»n ${result.totalClasses} lá»›p';
    if (result.totalGroups > 0) return 'ÄĂ£ chá»n ${result.totalGroups} nhĂ³m';
    return 'ÄĂ£ chá»n ${result.totalStudents} HS';
  }
}

class _ClassRecipientAccordion extends StatelessWidget {
  final ClassNode classNode;
  final bool isFullySelected;
  final Set<String> selectedGroupIds;
  final Set<String> selectedStudentIds;
  final RecipientSelectionResult selection;
  final DistributeAssignmentNotifier notifier;
  final Color primaryColor;
  final Color tMain;
  final Color tSec;
  final bool isDark;
  final bool isEditMode;

  const _ClassRecipientAccordion({
    required this.classNode,
    required this.isFullySelected,
    required this.selectedGroupIds,
    required this.selectedStudentIds,
    required this.selection,
    required this.notifier,
    required this.primaryColor,
    required this.tMain,
    required this.tSec,
    required this.isDark,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {
    int totalSelectedStudentsNum = 0;

    final effectiveStudentIds = isFullySelected
        ? {
            ...classNode.groups.expand((g) => g.students).map((s) => s.id),
            ...classNode.independentStudents.map((s) => s.id),
          }
        : selectedStudentIds;

    if (isFullySelected) {
      totalSelectedStudentsNum = effectiveStudentIds.length;
    } else {
      totalSelectedStudentsNum = selectedStudentIds.length;
      for (var groupId in selectedGroupIds) {
        try {
          final groupNode = classNode.groups.firstWhere((g) => g.id == groupId);
          totalSelectedStudentsNum += groupNode.students.length;
        } catch (_) {}
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[100]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: isEditMode
            ? null
            : () async {
                final result = await RecipientTreeSelectorModal.show(
                  context,
                  data: [classNode],
                  initialSelection: selection,
                  title: 'Chi tiáº¿t ${classNode.name}',
                  confirmText: 'Cáº­p nháº­t danh sĂ¡ch',
                );
                if (result != null) {
                  final fullySelected = Set.of(selection.fullySelectedClassIds);
                  final groups = Map.of(selection.selectedGroupIdsByClass);
                  final students = Map.of(selection.selectedStudentIdsByClass);

                  fullySelected.remove(classNode.id);
                  groups.remove(classNode.id);
                  students.remove(classNode.id);

                  if (result.fullySelectedClassIds.contains(classNode.id)) {
                    fullySelected.add(classNode.id);
                  }
                  if (result.selectedGroupIdsByClass.containsKey(classNode.id)) {
                    groups[classNode.id] =
                        result.selectedGroupIdsByClass[classNode.id]!;
                  }
                  if (result.selectedStudentIdsByClass
                      .containsKey(classNode.id)) {
                    students[classNode.id] =
                        result.selectedStudentIdsByClass[classNode.id]!;
                  }

                  notifier.setRecipientSelection(
                    selection.copyWith(
                      fullySelectedClassIds: fullySelected,
                      selectedGroupIdsByClass: groups,
                      selectedStudentIdsByClass: students,
                    ),
                  );
                }
              },
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? primaryColor.withValues(alpha: 0.15)
                : Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            classNode.id == 'inter_class_root'
                ? Icons.groups_2_rounded
                : Icons.school,
            color: primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          classNode.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: tMain,
          ),
        ),
        subtitle: Text(
          classNode.id == 'inter_class_root'
              ? 'ÄĂ£ chá»n: $totalSelectedStudentsNum há»c sinh'
              : (isFullySelected
                    ? 'Lá»›p Ä‘áº§y Ä‘á»§ ($totalSelectedStudentsNum há»c sinh)'
                    : 'ÄĂ£ chá»n: $totalSelectedStudentsNum há»c sinh'),
          style: TextStyle(fontSize: 12, color: tSec),
        ),
        trailing: isEditMode
            ? Icon(Icons.lock_outline, size: 18, color: Colors.grey[400])
            : IconButton(
                icon: Icon(
                  Icons.close,
                  color: isDark ? Colors.red[300] : Colors.red,
                  size: 20,
                ),
                onPressed: () {
                  notifier.removeClassSelection(classNode.id);
                  for (var g in selectedGroupIds) {
                    notifier.removeGroupSelection(classNode.id, g);
                  }
                  for (var s in selectedStudentIds) {
                    notifier.removeStudentSelection(classNode.id, s);
                  }
                },
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.red[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
      ),
    );
  }
}
