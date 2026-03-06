import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/recipient_tree_node.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/class_hierarchy_provider.dart';
import 'package:ai_mls/presentation/providers/distribute_assignment_notifier.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/recipient_tree_selector_modal.dart';
import 'package:ai_mls/widgets/forms/date_time_picker_field.dart';
import 'package:ai_mls/widgets/forms/select_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TeacherDistributeAssignmentScreen extends ConsumerStatefulWidget {
  final String? assignmentId;
  final String? selectedClassId;

  const TeacherDistributeAssignmentScreen({
    super.key,
    this.assignmentId,
    this.selectedClassId,
  });

  @override
  ConsumerState<TeacherDistributeAssignmentScreen> createState() =>
      _TeacherDistributeAssignmentScreenState();
}

class _TeacherDistributeAssignmentScreenState
    extends ConsumerState<TeacherDistributeAssignmentScreen> {
  final ScrollController _recipientScrollController = ScrollController();

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

    // Lấy teacher ID (đã load từ auth provider)
    final currentUserAsync = ref.watch(currentUserProvider);
    final teacherId = currentUserAsync.valueOrNull?.id;

    // Nếu chưa có teacher ID, hiển thị loading đơn giản
    if (teacherId == null) {
      return Scaffold(
        backgroundColor: isDark ? colorScheme.surface : DesignColors.moonLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(strokeWidth: 2),
              const SizedBox(height: 16),
              Text('Đang tải...', style: TextStyle(color: tSec)),
            ],
          ),
        ),
      );
    }

    // Lấy dữ liệu class hierarchy từ database
    final classHierarchyAsync = ref.watch(classHierarchyForDistributeProvider);

    final primaryColor = DesignColors.primary;
    final primarySoft = DesignColors.primary.withValues(alpha: 0.1);
    final bgColor = isDark ? colorScheme.surface : DesignColors.moonLight;
    final cardColor = isDark
        ? colorScheme.surfaceContainerHighest
        : DesignColors.white;
    final tMain = isDark ? Colors.white : DesignColors.textPrimary;

    // Xử lý classHierarchy - có thể là loading hoặc có dữ liệu
    // KHÔNG trả về empty khi loading - để UI tự xử lý
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
          'Giao Bài Tập',
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
                    onTap: () async {
                      final selectedIds = await context.pushNamed<List<String>>(
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
                        color: isDark
                            ? primaryColor.withValues(alpha: 0.1)
                            : primarySoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            state.selectedAssignments.isEmpty
                                ? Icons.add_circle_outline
                                : Icons.assignment,
                            color: primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              state.isLoading
                                  ? 'Đang tải...'
                                  : (state.selectedAssignments.isEmpty
                                        ? '+ Thêm bài tập'
                                        : (state.selectedAssignments.length > 1
                                              ? '${state.selectedAssignments.length} bài tập'
                                              : state.assignment?.title ??
                                                    'Chưa rõ bài tập')),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            color: primaryColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      text: 'Dự kiến ',
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
                        const TextSpan(text: ' học sinh nhận bài'),
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
            onPressed: state.isLoading ? null : () => notifier.distributeNow(),
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
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send),
                      SizedBox(width: 8),
                      Text(
                        'Giao Bài Ngay',
                        style: TextStyle(
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
  // THÀNH PHẦN GIAO DIỆN
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
    String? classHierarchyError,
  ) {
    final selectionCountText = _getSelectionCountText(state.recipientSelection);
    final hasSelectedRecipients =
        state.recipientSelection != null && !state.recipientSelection!.isEmpty;

    // Xây dựng nội dung trung tâm
    Widget centerContent;

    if (isClassHierarchyLoading) {
      // Đang tải - hiển thị loading + message
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
            'Đang tải danh sách lớp...',
            style: TextStyle(color: tSec, fontSize: 14),
          ),
        ],
      );
    } else if (classHierarchyError != null) {
      // Có lỗi - hiển thị lỗi + nút thử lại
      centerContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red[300], size: 40),
          const SizedBox(height: 12),
          Text(
            'Lỗi khi tải danh sách lớp',
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
            label: const Text('Thử lại'),
          ),
        ],
      );
    } else if (classHierarchy.isEmpty) {
      // Không có lớp - hiển thị message
      centerContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_outlined, color: tSec, size: 40),
          const SizedBox(height: 12),
          Text(
            'Chưa có lớp học nào',
            style: TextStyle(
              color: tMain,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bạn cần tạo lớp học trước khi phân phối bài tập',
            style: TextStyle(color: tSec, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (hasSelectedRecipients) {
      // Có dữ liệu và đã chọn - hiển thị danh sách đã chọn
      centerContent = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
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
              ),
            ),
          ),
        ),
      );
    } else {
      // Có dữ liệu nhưng chưa chọn
      centerContent = const SizedBox.shrink();
    }

    return _buildSectionShell(
      isDark,
      cardColor,
      Icons.group,
      'Đối tượng',
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
          // Nút Add - luôn hiển thị
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
                    'Thêm Lớp / Nhóm / Học sinh',
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
      ),
    );
  }

  List<Widget> _buildSelectedRecipients(
    RecipientSelectionResult selection,
    DistributeAssignmentNotifier notifier,
    Color tMain,
    Color tSec,
    bool isDark,
    List<ClassNode> classHierarchy,
  ) {
    if (selection.isEmpty) return [];

    final result = <Widget>[];

    // Lấy danh sách tất cả các Lớp có chứa Học sinh hoặc Nhóm hoặc fully selected
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
        ),
      );
      result.add(const SizedBox(height: 12));
    }

    // Thêm bottom padding extra
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
      'Lịch trình & Thời gian',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DatePickerField(
                  label: 'NGÀY BẮT ĐẦU',
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
                  label: 'GIỜ BẮT ĐẦU',
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
                  label: 'NGÀY HẾT HẠN',
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
                  label: 'GIỜ HẾT HẠN',
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
            label: 'THỜI GIAN LÀM BÀI',
            value: state.timeLimitMinutes != null
                ? state.timeLimitMinutes.toString()
                : 'unlimited',
            prefixIcon: Icons.timer,
            useCustomPicker: true,
            options: const [
              SelectFieldOption(value: '15', label: '15 phút'),
              SelectFieldOption(value: '30', label: '30 phút'),
              SelectFieldOption(value: '45', label: '45 phút'),
              SelectFieldOption(value: '60', label: '60 phút'),
              SelectFieldOption(value: '90', label: '90 phút'),
              SelectFieldOption(value: 'unlimited', label: 'Không giới hạn'),
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
      'Cài đặt nâng cao',
      child: Column(
        children: [
          _buildToggleRow(
            icon: Icons.history_toggle_off,
            title: 'Cho phép nộp muộn',
            subtitle: 'Học sinh có thể nộp bài sau thời hạn',
            value: state.allowLate,
            onChanged: notifier.setAllowLate,
            tMain: tMain,
            tSec: tSec,
            isDark: isDark,
          ),
          // Late Penalty - Hiển thị khi allowLate = true
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
          _buildToggleRow(
            icon: Icons.visibility,
            title: 'Hiển thị điểm ngay',
            subtitle: 'Học sinh xem điểm ngay sau khi nộp bài',
            value: state.showScoreImmediately,
            onChanged: notifier.setShowScoreImmediately,
            tMain: tMain,
            tSec: tSec,
            isDark: isDark,
          ),
          Divider(color: isDark ? Colors.white10 : Colors.grey[50]),
          _buildToggleRow(
            icon: Icons.shuffle,
            title: 'Đảo câu hỏi',
            subtitle: 'Thứ tự câu hỏi khác nhau cho mỗi học sinh',
            value: state.shuffleQuestions,
            onChanged: notifier.setShuffleQuestions,
            tMain: tMain,
            tSec: tSec,
            isDark: isDark,
          ),
          Divider(color: isDark ? Colors.white10 : Colors.grey[50]),
          _buildToggleRow(
            icon: Icons.swap_horiz,
            title: 'Đảo đáp án',
            subtitle: 'Thứ tự đáp án khác nhau cho mỗi học sinh',
            value: state.shuffleAnswers,
            onChanged: notifier.setShuffleAnswers,
            tMain: tMain,
            tSec: tSec,
            isDark: isDark,
          ),
          Divider(color: isDark ? Colors.white10 : Colors.grey[50]),
          _buildToggleRow(
            icon: Icons.notifications_active,
            title: 'Gửi thông báo',
            subtitle: 'Thông báo cho học sinh khi có bài mới',
            value: state.sendNotification,
            onChanged: notifier.setSendNotification,
            tMain: tMain,
            tSec: tSec,
            isDark: isDark,
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
      margin: const EdgeInsets.only(left: 44), // Indent để phân biệt với toggle
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
                        'Phần trăm trừ điểm',
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
            'Mỗi ngày nộp muộn sẽ bị trừ ${state.latePenaltyPercent}% điểm',
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
          // Toggle custom để giống HTML
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
              ? '$assignmentCount bài tập'
              : state.selectedAssignments.first.title)
        : (state.assignment?.title ?? 'Bài tập');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        // Auto-close sau 2.5 giây
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (ctx.mounted) Navigator.of(ctx).pop();
        });

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
                  'Giao bài thành công!',
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
                    '$estimatedCount học sinh nhận bài',
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
                        'Đề thi sẽ được xáo trộn khi HS bắt đầu làm bài',
                        style: TextStyle(
                          fontSize: 11,
                          color: DesignColors.tealPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: DesignColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSpacing.sm),
        ),
        margin: EdgeInsets.all(DesignSpacing.md),
      ),
    );
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
    if (result.totalClasses > 0) return 'Đã chọn ${result.totalClasses} lớp';
    if (result.totalGroups > 0) return 'Đã chọn ${result.totalGroups} nhóm';
    return 'Đã chọn ${result.totalStudents} HS';
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
        onTap: () async {
          final result = await RecipientTreeSelectorModal.show(
            context,
            data: [classNode],
            initialSelection: selection,
            title: 'Chi tiết ${classNode.name}',
            confirmText: 'Cập nhật danh sách',
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
            if (result.selectedStudentIdsByClass.containsKey(classNode.id)) {
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
              ? 'Đã chọn: $totalSelectedStudentsNum học sinh'
              : (isFullySelected
                    ? 'Lớp đầy đủ ($totalSelectedStudentsNum học sinh)'
                    : 'Đã chọn: $totalSelectedStudentsNum học sinh'),
          style: TextStyle(fontSize: 12, color: tSec),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? Colors.red[300] : Colors.red,
            size: 20,
          ),
          onPressed: () {
            notifier.removeClassSelection(classNode.id);
            // Clear children as normal
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
