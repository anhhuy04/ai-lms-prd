import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/assignment.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_card_config.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_empty_state.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_error_state.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/widgets/assignment_list/assignment_list_view.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình kho bài tập đã tạo (published assignments)
/// Hiển thị danh sách các bài tập đã được publish (is_published = true)
class TeacherPublishedAssignmentsScreen extends ConsumerStatefulWidget {
  const TeacherPublishedAssignmentsScreen({super.key});

  @override
  ConsumerState<TeacherPublishedAssignmentsScreen> createState() =>
      _TeacherPublishedAssignmentsScreenState();
}

class _TeacherPublishedAssignmentsScreenState
    extends ConsumerState<TeacherPublishedAssignmentsScreen> {
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
        appBar: AppBar(title: const Text('Kho bài tập đã tạo')),
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
          'Kho bài tập đã tạo',
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
          // Filter chỉ lấy assignments đã publish
          final publishedAssignments =
              allAssignments.where((a) => a.isPublished).toList()..sort((a, b) {
                // Sort by published_at hoặc updated_at descending (mới nhất trước)
                final aTime = a.updatedAt ?? a.createdAt ?? DateTime(1970);
                final bTime = b.updatedAt ?? b.createdAt ?? DateTime(1970);
                return bTime.compareTo(aTime);
              });

          return AssignmentListView(
            assignments: publishedAssignments,
            badgeConfig: AssignmentBadgeConfig.published,
            actionBuilder: (assignment) => AssignmentActionConfig(
              label: 'Xem chi tiết',
              icon: Icons.visibility_outlined,
              onPressed: () async {
                // TODO: Navigate to view assignment details
                // Tạm thời navigate to edit
                await context.pushNamed(
                  AppRoute.teacherCreateAssignment,
                  extra: {'assignmentId': assignment.id},
                );
                if (!context.mounted) return;
                await _refreshAssignments();
              },
            ),
            metadataConfig: AssignmentMetadataConfig.published,
            emptyState: AssignmentEmptyState.published(),
            onRefresh: _refreshAssignments,
            onTap: (assignment) async {
              // Cho phép tap cả card để chỉnh sửa/xem chi tiết và reload khi quay lại
              await context.pushNamed(
                AppRoute.teacherCreateAssignment,
                extra: {'assignmentId': assignment.id},
              );
              if (!context.mounted) return;
              await _refreshAssignments();
            },
          );
        },
      ),
    );
  }
}
