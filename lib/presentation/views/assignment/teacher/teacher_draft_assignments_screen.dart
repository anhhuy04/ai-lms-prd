import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_card_config.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_empty_state.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_error_state.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_list_view.dart';
import 'package:ai_mls/widgets/dialogs/delete_dialog.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình kho bài tập nháp (draft assignments)
/// Hiển thị danh sách các bài tập chưa được publish (is_published = false)
class TeacherDraftAssignmentsScreen extends ConsumerStatefulWidget {
  const TeacherDraftAssignmentsScreen({super.key});

  @override
  ConsumerState<TeacherDraftAssignmentsScreen> createState() =>
      _TeacherDraftAssignmentsScreenState();
}

class _TeacherDraftAssignmentsScreenState
    extends ConsumerState<TeacherDraftAssignmentsScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-refresh khi screen được mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAssignments();
    });
  }

  Future<void> _refreshAssignments() async {
    // Trigger rebuild để load data mới từ database
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teacherId = ref.watch(currentUserIdProvider);

    if (teacherId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kho bài tập nháp')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: DesignIcons.xxlSize,
                color: DesignColors.error,
              ),
              SizedBox(height: DesignSpacing.lg),
              Text(
                'Người dùng chưa đăng nhập',
                style: DesignTypography.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
          color: isDark ? Colors.grey[300] : Colors.grey[700],
        ),
        title: const Text(
          'Kho bài tập nháp',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Assignment>>(
        future: ref
            .read(assignmentRepositoryProvider)
            .getAssignmentsByTeacher(teacherId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerLoading();
          }

          if (snapshot.hasError) {
            return AssignmentErrorState(
              error: snapshot.error.toString(),
              onRetry: _refreshAssignments,
            );
          }

          final allAssignments = snapshot.data ?? [];
          // Filter chỉ lấy assignments chưa publish
          final draftAssignments =
              allAssignments.where((a) => !a.isPublished).toList()
                ..sort((a, b) {
                  // Sort by updated_at descending (mới nhất trước)
                  final aTime = a.updatedAt ?? a.createdAt ?? DateTime(1970);
                  final bTime = b.updatedAt ?? b.createdAt ?? DateTime(1970);
                  return bTime.compareTo(aTime);
                });

          return AssignmentListView(
            assignments: draftAssignments,
            badgeConfig: AssignmentBadgeConfig.draft,
            actionBuilder: (assignment) => AssignmentActionConfig(
              label: 'Chỉnh sửa',
              icon: Icons.edit_outlined,
              onPressed: () async {
                await context.pushNamed(
                  AppRoute.teacherCreateAssignment,
                  extra: {'assignmentId': assignment.id},
                );
                if (!context.mounted) return;
                await _refreshAssignments();
              },
            ),
            metadataConfig: AssignmentMetadataConfig.draft,
            emptyState: AssignmentEmptyState.draft(),
            onRefresh: _refreshAssignments,
            onTap: (assignment) async {
              await context.pushNamed(
                AppRoute.teacherCreateAssignment,
                extra: {'assignmentId': assignment.id},
              );
              if (!context.mounted) return;
              await _refreshAssignments();
            },
            onDelete: (assignment) async {
              // Confirm delete
              final confirmed = await DeleteDialog.showSimple(
                context: context,
                title: 'Xóa bài tập nháp',
                message:
                    'Bạn có chắc chắn muốn xóa bài tập "${assignment.title}"?',
                confirmText: 'Xóa',
                cancelText: 'Hủy',
                barrierDismissible: true,
              );

              if (confirmed != true) {
                return false;
              }

              try {
                await ref
                    .read(assignmentRepositoryProvider)
                    .deleteAssignment(assignment.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã xóa bài tập "${assignment.title}"'),
                      backgroundColor: DesignColors.success,
                    ),
                  );
                }
                await _refreshAssignments();
                return true;
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: DesignColors.error,
                    ),
                  );
                }
                return false;
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.pushNamed(AppRoute.teacherCreateAssignment);
          if (!context.mounted) return;
          await _refreshAssignments();
        },
        backgroundColor: DesignColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 24),
        label: Text(
          'Tạo bài mới',
          style: DesignTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
