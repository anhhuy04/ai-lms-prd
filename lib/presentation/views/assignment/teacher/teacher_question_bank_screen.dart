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
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';

/// Question Bank list screen (teacher).
///
/// Hiển thị danh sách câu hỏi của teacher (+ global nếu chọn), với:
/// - Source chip bar (Tất cả / Của tôi / AI tạo / Toàn cầu)
/// - Search box
/// - Card list với menu Sửa/Sao chép/Xóa (theo quyền VM)
/// - Pull-to-refresh, optimistic delete + Undo SnackBar
///
/// Edit / duplicate / create FAB wire vào create_question_screen ở Phase 6.
class TeacherQuestionBankScreen extends ConsumerStatefulWidget {
  const TeacherQuestionBankScreen({super.key});

  @override
  ConsumerState<TeacherQuestionBankScreen> createState() =>
      _TeacherQuestionBankScreenState();
}

class _TeacherQuestionBankScreenState
    extends ConsumerState<TeacherQuestionBankScreen> {
  SourceChipFilter _source = SourceChipFilter.all;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

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
      case SourceChipFilter.global:
        // Show global + own — filter UI nâng cao sẽ refine sau.
        includeGlobal = true;
        break;
    }
    return QuestionFilter(
      authorId: userId,
      includeGlobal: includeGlobal,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      sourceFilter: sourceFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập')),
      );
    }

    // Admin detection — derive từ profile role (currentUserIsAdminProvider
    // không tồn tại trong codebase hiện tại).
    final profileAsync = ref.watch(currentUserProvider);
    final isAdmin = profileAsync.value?.role == 'admin';

    final filter = _buildFilter(userId);
    final stateAsync =
        ref.watch(questionBankNotifierProvider(filter: filter));

    return Scaffold(
      appBar: AppBar(title: const Text('Ngân hàng câu hỏi')),
      body: Column(
        children: [
          QuestionSourceChipBar(
            selected: _source,
            onChanged: (f) => setState(() => _source = f),
          ),
          Padding(
            padding: EdgeInsets.all(DesignSpacing.md),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Tìm câu hỏi...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (v) => setState(() => _searchQuery = v),
            ),
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
            _searchQuery.isEmpty
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
    _searchCtrl.dispose();
    super.dispose();
  }
}
