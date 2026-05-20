import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/question_filter.dart';
import 'package:ai_mls/domain/entities/question_source.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/question_bank_notifier.dart';
import 'package:ai_mls/presentation/view_models/question_vm.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/question_bank/question_bank_card.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/question_bank/question_source_chip_bar.dart';
import 'package:ai_mls/widgets/dialogs/question_filter_bottom_sheet.dart';
import 'package:ai_mls/widgets/dialogs/question_sort_bottom_sheet.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:ai_mls/widgets/search/shared/search_field.dart';

/// Question Bank list screen (teacher).
///
/// Hiển thị danh sách câu hỏi của teacher (+ global nếu chọn), với:
/// - Source chip bar (Tất cả / Của tôi / AI tạo)
/// - SearchField widget (debounced 300ms)
/// - Filter + Sort actions trong AppBar (bottom sheets)
/// - Card list với menu Sửa/Sao chép/Xóa (theo quyền VM)
/// - Pull-to-refresh, optimistic delete + Undo SnackBar
class TeacherQuestionBankScreen extends ConsumerStatefulWidget {
  const TeacherQuestionBankScreen({super.key});

  @override
  ConsumerState<TeacherQuestionBankScreen> createState() =>
      _TeacherQuestionBankScreenState();
}

class _TeacherQuestionBankScreenState
    extends ConsumerState<TeacherQuestionBankScreen> {
  SourceChipFilter _source = SourceChipFilter.all;
  String _searchQuery = '';
  Timer? _debounce;

  // Filter/sort state
  QuestionFilterValue _filterValue = const QuestionFilterValue();
  QuestionSortKey _sortKey = QuestionSortKey.recentlyCreated;

  QuestionFilter _buildFilter(String userId) {
    QuestionSource? sourceFilter;
    bool includeGlobal = true;
    switch (_source) {
      case SourceChipFilter.all:
        includeGlobal = true;
        break;
      case SourceChipFilter.mine:
        includeGlobal = false;
        break;
      case SourceChipFilter.aiGenerated:
        includeGlobal = false;
        sourceFilter = QuestionSource.aiGenerated;
        break;
    }
    return QuestionFilter(
      authorId: userId,
      includeGlobal: includeGlobal,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      sourceFilter: sourceFilter,
      type: _filterValue.type,
      difficulty: _filterValue.difficulty,
      tags: _filterValue.tags.isEmpty ? null : _filterValue.tags,
      sortBy: _sortKey,
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _searchQuery = value);
    });
  }

  Future<void> _openFilterSheet() async {
    final result = await QuestionFilterBottomSheet.show(
      context,
      _filterValue,
    );
    if (result != null) {
      setState(() => _filterValue = result);
    }
  }

  Future<void> _openSortSheet() async {
    final result = await QuestionSortBottomSheet.show(context, _sortKey);
    if (result != null) {
      setState(() => _sortKey = result);
    }
  }

  bool get _hasActiveFilter =>
      _filterValue.type != null ||
      _filterValue.difficulty != null ||
      _filterValue.tags.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập')),
      );
    }

    final profileAsync = ref.watch(currentUserProvider);
    final isAdmin = profileAsync.value?.role == 'admin';

    final filter = _buildFilter(userId);
    final stateAsync =
        ref.watch(questionBankNotifierProvider(filter: filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngân hàng câu hỏi'),
        actions: [
          IconButton(
            tooltip: 'Bộ lọc',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.filter_list),
                if (_hasActiveFilter)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: DesignColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _openFilterSheet,
          ),
          IconButton(
            tooltip: 'Sắp xếp',
            icon: const Icon(Icons.sort),
            onPressed: _openSortSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          QuestionSourceChipBar(
            selected: _source,
            onChanged: (f) => setState(() => _source = f),
          ),
          SearchField(
            hintText: 'Tìm câu hỏi...',
            onChanged: _onSearchChanged,
            onClear: () {
              _debounce?.cancel();
              setState(() => _searchQuery = '');
            },
          ),
          Expanded(
            child: stateAsync.when(
              data: (s) => s.questions.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: () async => ref.invalidate(
                        questionBankNotifierProvider,
                      ),
                      child: ListView.builder(
                        itemCount: s.questions.length,
                        itemBuilder: (_, i) {
                          final q = s.questions[i];
                          final vm = q.toVM(
                            currentUserId: userId,
                            isAdmin: isAdmin,
                          );
                          return QuestionBankCard(
                            vm: vm,
                            onTap: () => context.pushNamed(
                              AppRoute.teacherQuestionBankDetail,
                              pathParameters: {'questionId': q.id},
                            ),
                            onEdit: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Sửa câu hỏi — sẽ wire trong Phase 6',
                                  ),
                                ),
                              );
                            },
                            onDelete: () => _confirmDelete(q.id, filter),
                            onDuplicate: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Sao chép — sẽ implement sau',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
              loading: () => const ShimmerListTileLoading(itemCount: 6),
              error: (e, _) => Center(
                child: Padding(
                  padding: EdgeInsets.all(DesignSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: DesignColors.error,
                        size: 48,
                      ),
                      SizedBox(height: DesignSpacing.md),
                      Text(
                        'Lỗi tải danh sách: $e',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: DesignSpacing.md),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(
                          questionBankNotifierProvider,
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo câu hỏi — sẽ wire trong Phase 6'),
            ),
          );
        },
        label: const Text('Tạo câu hỏi mới'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Padding(
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
          SizedBox(height: DesignSpacing.md),
          Text(
            _searchQuery.isEmpty && !_hasActiveFilter
                ? 'Kho câu hỏi trống'
                : 'Không tìm thấy câu hỏi phù hợp',
            style: DesignTypography.bodyLarge,
          ),
        ],
      ),
    ),
  );

  Future<void> _confirmDelete(String id, QuestionFilter filter) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa câu hỏi?'),
        content: const Text(
          'Câu hỏi sẽ vào "Thùng rác" và có thể khôi phục trong 30 ngày.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref
          .read(questionBankNotifierProvider(filter: filter).notifier)
          .softDelete(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã xóa câu hỏi'),
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () => ref
                .read(questionBankNotifierProvider(filter: filter).notifier)
                .restore(id),
          ),
          duration: const Duration(seconds: 30),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: DesignColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
