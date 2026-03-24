import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/views/assignment/student/assignment_list_screen.dart';
import 'package:ai_mls/presentation/views/assignment/student/student_assignment_detail_screen.dart';
import 'package:ai_mls/presentation/views/assignment/student/student_assignment_workspace_screen.dart';
import 'package:ai_mls/presentation/views/assignment/student/student_submission_history_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_assignment_hub_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_assignment_management_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_assignment_selection_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_create_question_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_distribute_assignment_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_draft_assignments_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_published_assignments_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_class_submission_list_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_grading_hub_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_submission_list_screen.dart';
import 'package:ai_mls/presentation/views/auth/login_screen.dart';
import 'package:ai_mls/presentation/views/auth/register_screen.dart';
import 'package:ai_mls/presentation/views/class/student/join_class_screen.dart';
import 'package:ai_mls/presentation/views/class/student/qr_scan_screen.dart';
import 'package:ai_mls/presentation/views/class/student/student_class_detail_screen.dart';
import 'package:ai_mls/presentation/views/class/student/student_class_list_screen.dart';
import 'package:ai_mls/presentation/views/class/student/widgets/search/student_class_search_screen.dart';
import 'package:ai_mls/presentation/views/class/teacher/add_student_by_code_screen.dart';
import 'package:ai_mls/presentation/views/class/teacher/create_class_screen.dart';
import 'package:ai_mls/presentation/views/class/teacher/edit_class_screen.dart';
import 'package:ai_mls/presentation/views/class/teacher/student_list_screen.dart';
import 'package:ai_mls/presentation/views/class/teacher/teacher_assignment_detail_screen.dart';
import 'package:ai_mls/presentation/views/class/teacher/teacher_class_detail_screen.dart';
import 'package:ai_mls/presentation/views/class/teacher/teacher_class_list_screen.dart';
import 'package:ai_mls/presentation/views/class/teacher/widgets/search/teacher_class_search_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/admin_dashboard_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/home/student_home_content_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/home/teacher_home_content_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/student_dashboard_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/teacher_dashboard_screen.dart';
import 'package:ai_mls/presentation/views/grading/scores_screen.dart';
import 'package:ai_mls/presentation/views/grading/student_analytics_screen.dart';
import 'package:ai_mls/presentation/views/grading/teacher_analytics_screen.dart';
import 'package:ai_mls/presentation/views/network/no_internet_screen.dart';
import 'package:ai_mls/presentation/views/profile/profile_screen.dart';
import 'package:ai_mls/presentation/views/settings/api_key_setup_screen.dart';
import 'package:ai_mls/presentation/views/settings/settings_screen.dart';
import 'package:ai_mls/presentation/views/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// GoRouter configuration for AI LMS application
///
/// Architecture:
/// - ShellRoutes for dashboard (preserves bottom nav during navigation)
/// - Named routes for type-safety and refactoring
/// - RBAC guards integrated in redirect logic
/// - Deep linking support for authentication
///
/// Navigation patterns:
/// - UI: context.goNamed('route-name', pathParameters: {...})
/// - Logic: ref.read(routerProvider).goNamed(...)
final appRouterProvider = Provider<GoRouter>((ref) {
  // Tạo Listenable để GoRouter biết khi nào cần re-evaluate redirect.
  // KHÔNG dùng ref.watch vì nó sẽ tái tạo TOÀN BỘ GoRouter (reset về splash).
  final authChangeNotifier = ValueNotifier<int>(0);
  ref.listen(currentUserProvider, (_, __) {
    authChangeNotifier.value++;
  });

  return GoRouter(
    initialLocation: AppRoute.splashPath,
    debugLogDiagnostics: false,
    refreshListenable: authChangeNotifier,
    redirect: (context, state) {
      final currentPath = state.matchedLocation;

      // Skip redirect logic for splash and no-internet screens
      if (currentPath == AppRoute.splashPath ||
          currentPath == AppRoute.noInternetPath) {
        return null;
      }

      // Đọc auth state MỖI LẦN redirect chạy (không capture từ closure)
      final currentUserAsync = ref.read(currentUserProvider);

      final profile = currentUserAsync.value;
      final isAuth = profile != null;
      final userRole = profile?.role ?? '';

      if (AppRoute.isPublicRoute(currentPath)) {
        return null;
      }

      // Wait for auth state to resolve before redirecting
      if (currentUserAsync.isLoading) {
        return null;
      }

      if (!isAuth) {
        if (currentPath != AppRoute.loginPath &&
            currentPath != AppRoute.registerPath) {
          return '${AppRoute.loginPath}?redirect=${Uri.encodeComponent(currentPath)}';
        }
        return null;
      }

      if (currentPath == AppRoute.loginPath ||
          currentPath == AppRoute.registerPath) {
        return AppRoute.getDashboardPathForRole(userRole);
      }

      final routeName = state.name;
      if (routeName != null && !AppRoute.canAccessRoute(userRole, routeName)) {
        return AppRoute.getDashboardPathForRole(userRole);
      }

      return null;
    },
    routes: [
      // ==================== REDIRECTS ====================
      // Catch-all redirect to splash
      GoRoute(path: '/', redirect: (_, __) => AppRoute.splashPath),

      // ==================== PUBLIC ROUTES ====================
      // No authentication required
      GoRoute(
        path: AppRoute.splashPath,
        name: AppRoute.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: AppRoute.loginPath,
        name: AppRoute.login,
        builder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return LoginScreen(initialEmail: redirect != null ? null : null);
        },
      ),

      GoRoute(
        path: AppRoute.registerPath,
        name: AppRoute.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: AppRoute.resetPasswordPath,
        name: AppRoute.resetPassword,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return Scaffold(
            appBar: AppBar(title: const Text('Reset Password')),
            body: Center(
              child: Text(
                token != null ? 'Reset token: $token' : 'Invalid reset link',
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoute.emailVerificationPath,
        name: AppRoute.emailVerification,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return Scaffold(
            appBar: AppBar(title: const Text('Verify Email')),
            body: Center(
              child: Text(
                token != null
                    ? 'Verification token: $token'
                    : 'Invalid verification link',
              ),
            ),
          );
        },
      ),

      // ==================== STUDENT DASHBOARD SHELL ====================
      // ShellRoute maintains bottom nav while child routes swap content
      ShellRoute(
        builder: (context, state, child) {
          final profile = ref.watch(currentUserProvider).value;
          if (profile == null) return const SizedBox.shrink();

          return StudentDashboardScreen(userProfile: profile, child: child);
        },
        routes: [
          GoRoute(
            path: AppRoute.studentDashboardPath,
            name: AppRoute.studentDashboard,
            pageBuilder: (context, state) => FadeTransitionPage(
              key: state.pageKey,
              child: StudentHomeContentScreen(),
            ),
          ),
          GoRoute(
            path: AppRoute.studentClassListPath,
            name: AppRoute.studentClassList,
            pageBuilder: (context, state) => FadeTransitionPage(
              key: state.pageKey,
              child: StudentClassListScreen(),
            ),
          ),
          GoRoute(
            path: AppRoute.studentScoresPath,
            name: AppRoute.studentScores,
            pageBuilder: (context, state) =>
                FadeTransitionPage(key: state.pageKey, child: ScoresScreen()),
          ),
          GoRoute(
            path: AppRoute.studentAnalyticsPath,
            name: AppRoute.studentAnalytics,
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final classId = extra?['classId'] as String?;
              return FadeTransitionPage(
                key: state.pageKey,
                child: StudentAnalyticsScreen(classId: classId),
              );
            },
          ),
          GoRoute(
            path: AppRoute.studentAssignmentListPath,
            name: AppRoute.studentAssignmentList,
            pageBuilder: (context, state) => FadeTransitionPage(
              key: state.pageKey,
              child: AssignmentListScreen(),
            ),
          ),
          GoRoute(
            path: AppRoute.studentProfilePath,
            name: AppRoute.studentProfile,
            pageBuilder: (context, state) =>
                FadeTransitionPage(key: state.pageKey, child: ProfileScreen()),
          ),
        ],
      ),

      // ==================== TEACHER PUBLIC ROUTES (No Bottom Nav) ====================
      GoRoute(
        path: AppRoute.teacherGradingPath,
        name: AppRoute.teacherGrading,
        pageBuilder: (context, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const TeacherGradingHubScreen(),
        ),
      ),

      // Teacher Analytics Overview (show class list)
      GoRoute(
        path: AppRoute.teacherAnalyticsOverviewPath,
        name: AppRoute.teacherAnalyticsOverview,
        pageBuilder: (context, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const TeacherAnalyticsScreen(),
        ),
      ),

      // Teacher Analytics for specific class (show analytics dashboard)
      GoRoute(
        path: AppRoute.teacherAnalyticsPath(':classId'),
        name: AppRoute.teacherAnalytics,
        pageBuilder: (context, state) {
          final classId = state.pathParameters['classId']!;
          return FadeTransitionPage(
            key: state.pageKey,
            child: TeacherAnalyticsScreen(classId: classId),
          );
        },
      ),

      // ==================== TEACHER DASHBOARD SHELL ====================
      ShellRoute(
        builder: (context, state, child) {
          final profile = ref.watch(currentUserProvider).value;
          if (profile == null) return const SizedBox.shrink();

          return TeacherDashboardScreen(userProfile: profile, child: child);
        },
        routes: [
          GoRoute(
            path: AppRoute.teacherDashboardPath,
            name: AppRoute.teacherDashboard,
            pageBuilder: (context, state) => FadeTransitionPage(
              key: state.pageKey,
              child: TeacherHomeContentScreen(),
            ),
          ),
          GoRoute(
            path: AppRoute.teacherClassListPath,
            name: AppRoute.teacherClassList,
            pageBuilder: (context, state) => FadeTransitionPage(
              key: state.pageKey,
              child: TeacherClassListScreen(),
            ),
          ),
          GoRoute(
            path: AppRoute.teacherAssignmentHubPath,
            name: AppRoute.teacherAssignmentHub,
            pageBuilder: (context, state) => FadeTransitionPage(
              key: state.pageKey,
              child: TeacherAssignmentHubScreen(),
            ),
          ),
          GoRoute(
            path: AppRoute.teacherAssignmentListPath,
            name: AppRoute.teacherAssignmentList,
            pageBuilder: (context, state) => FadeTransitionPage(
              key: state.pageKey,
              child: AssignmentListScreen(),
            ),
          ),
          GoRoute(
            path: AppRoute.teacherProfilePath,
            name: AppRoute.teacherProfile,
            pageBuilder: (context, state) =>
                FadeTransitionPage(key: state.pageKey, child: ProfileScreen()),
          ),
        ],
      ),

      // ==================== ADMIN DASHBOARD SHELL ====================
      ShellRoute(
        builder: (context, state, child) {
          final profile = ref.watch(currentUserProvider).value;
          if (profile == null) return const SizedBox.shrink();

          return AdminDashboardScreen(userProfile: profile);
        },
        routes: [
          GoRoute(
            path: AppRoute.adminDashboardPath,
            name: AppRoute.adminDashboard,
            pageBuilder: (context, state) => FadeTransitionPage(
              key: state.pageKey,
              child: SizedBox.shrink(), // Shell handles it
            ),
          ),
        ],
      ),

      // ==================== STUDENT STANDALONE ROUTES ====================
      // Routes outside of student shell (no bottom nav)
      GoRoute(
        path: AppRoute.studentJoinClassPath,
        name: AppRoute.studentJoinClass,
        builder: (context, state) => const JoinClassScreen(),
      ),

      GoRoute(
        path: AppRoute.studentQrScanPath,
        name: AppRoute.studentQrScan,
        builder: (context, state) => const QRScanScreen(),
      ),

      // Route search class (standalone - no bottom nav)
      // Phải đặt TRƯỚC route có parameter để tránh conflict
      GoRoute(
        path: AppRoute.studentClassSearchPath,
        name: AppRoute.studentClassSearch,
        builder: (context, state) => const StudentClassSearchScreen(),
      ),

      // Route class detail (standalone - no bottom nav)
      GoRoute(
        path: AppRoute.studentClassDetailPath(':classId'),
        name: AppRoute.studentClassDetail,
        builder: (context, state) {
          final classId = state.pathParameters['classId']!;
          // Validate classId là UUID hợp lệ
          if (classId.isEmpty) {
            return const StudentClassListScreen();
          }
          final extra = state.extra;
          String? className;
          String? semesterInfo;
          String? studentName;
          if (extra is Map<String, dynamic>) {
            className = extra['className'] as String?;
            semesterInfo = extra['semesterInfo'] as String?;
            studentName = extra['studentName'] as String?;
          }
          return StudentClassDetailScreen(
            classId: classId,
            className: className ?? '',
            semesterInfo: semesterInfo ?? '',
            studentName: studentName ?? '',
          );
        },
      ),

      // Route assignment detail (standalone - no bottom nav)
      GoRoute(
        path: AppRoute.studentAssignmentDetailPath(':assignmentId'),
        name: AppRoute.studentAssignmentDetail,
        builder: (context, state) {
          final assignmentId = state.pathParameters['assignmentId']!;
          if (assignmentId.isEmpty) {
            return const AssignmentListScreen();
          }
          return StudentAssignmentDetailScreen(assignmentId: assignmentId);
        },
      ),

      // Route assignment workspace (làm bài tập)
      GoRoute(
        path: AppRoute.studentAssignmentWorkspacePath(':distributionId'),
        name: AppRoute.studentAssignmentWorkspace,
        builder: (context, state) {
          final distributionId = state.pathParameters['distributionId']!;
          return StudentAssignmentWorkspaceScreen(
            distributionId: distributionId,
          );
        },
      ),

      // Route submission history
      GoRoute(
        path: AppRoute.studentSubmissionHistoryPath,
        name: AppRoute.studentSubmissionHistory,
        builder: (context, state) {
          return const StudentSubmissionHistoryScreen();
        },
      ),

      // ==================== TEACHER STANDALONE ROUTES ====================
      // Routes outside of teacher shell (no bottom nav)
      // Route create assignment (standalone - no bottom nav)
      GoRoute(
        path: AppRoute.teacherCreateAssignmentPath,
        name: AppRoute.teacherCreateAssignment,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final assignmentId = extra?['assignmentId'] as String?;
          return TeacherCreateAssignmentScreen(assignmentId: assignmentId);
        },
      ),
      // Route edit assignment (standalone - no bottom nav)
      GoRoute(
        path: AppRoute.teacherEditAssignmentPath(':assignmentId'),
        name: AppRoute.teacherEditAssignment,
        builder: (context, state) {
          final assignmentId = state.pathParameters['assignmentId'];
          return TeacherCreateAssignmentScreen(assignmentId: assignmentId);
        },
      ),
      // Route draft assignments (kho bài tập nháp)
      GoRoute(
        path: AppRoute.teacherDraftAssignmentsPath,
        name: AppRoute.teacherDraftAssignments,
        builder: (context, state) => const TeacherDraftAssignmentsScreen(),
      ),
      // Route published assignments (kho bài tập đã tạo)
      GoRoute(
        path: AppRoute.teacherPublishedAssignmentsPath,
        name: AppRoute.teacherPublishedAssignments,
        builder: (context, state) => const TeacherPublishedAssignmentsScreen(),
      ),
      // Route assignment selection (chọn nhiều bài tập để giao)
      GoRoute(
        path: AppRoute.teacherAssignmentSelectionPath,
        name: AppRoute.teacherAssignmentSelection,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isSelectionOnly = extra?['isSelectionOnly'] as bool? ?? false;
          final initialSelectedIds =
              extra?['initialSelectedIds'] as List<String>? ?? const [];
          final selectedClassId = extra?['selectedClassId'] as String?;
          return TeacherAssignmentSelectionScreen(
            isSelectionOnly: isSelectionOnly,
            initialSelectedIds: initialSelectedIds,
            selectedClassId: selectedClassId,
          );
        },
      ),
      // Route assignment management (quản lý bài tập)
      GoRoute(
        path: AppRoute.teacherAssignmentManagementPath,
        name: AppRoute.teacherAssignmentManagement,
        builder: (context, state) => const TeacherAssignmentManagementScreen(),
      ),
      // Route distribute assignment (phân phối bài tập)
      GoRoute(
        path: AppRoute.teacherDistributeAssignmentPath,
        name: AppRoute.teacherDistributeAssignment,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final assignmentId = extra?['assignmentId'] as String?;
          final selectedClassId = extra?['selectedClassId'] as String?;
          return TeacherDistributeAssignmentScreen(
            assignmentId: assignmentId,
            selectedClassId: selectedClassId,
          );
        },
      ),
      // Route AI generate questions (standalone - no bottom nav)
      GoRoute(
        path: AppRoute.teacherAiGenerateQuestionPath,
        name: AppRoute.teacherAiGenerateQuestion,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final questions = extra?['questions'] as List<Map<String, dynamic>>?;
          return TeacherAiGenerateQuestionScreen(questions: questions);
        },
      ),
      // Route create question (standalone - no bottom nav)
      GoRoute(
        path: AppRoute.teacherCreateQuestionPath,
        name: AppRoute.teacherCreateQuestion,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final questionType =
              extra?['questionType'] as QuestionType? ??
              QuestionType.multipleChoice;
          final initialData = extra?['initialData'] as Map<String, dynamic>?;
          final questions = extra?['questions'] as List<Map<String, dynamic>>?;
          final currentQuestionIndex = extra?['currentQuestionIndex'] as int?;
          final onQuestionSelected =
              extra?['onQuestionSelected'] as Function(int)?;
          final onSaveAndAddNew =
              extra?['onSaveAndAddNew'] as int? Function(Map<String, dynamic>)?;
          final onQuestionsUpdated =
              extra?['onQuestionsUpdated']
                  as Function(List<Map<String, dynamic>>)?;

          return TeacherCreateQuestionScreen(
            questionType: questionType,
            initialData: initialData,
            questions: questions,
            currentQuestionIndex: currentQuestionIndex,
            onQuestionSelected: onQuestionSelected,
            onSaveAndAddNew: onSaveAndAddNew,
            onQuestionsUpdated: onQuestionsUpdated,
          );
        },
      ),
      // Route create class (standalone - no bottom nav)
      GoRoute(
        path: AppRoute.teacherCreateClassPath,
        name: AppRoute.teacherCreateClass,
        builder: (context, state) => const CreateClassScreen(),
      ),
      // Route search class (standalone - no bottom nav)
      GoRoute(
        path: AppRoute.teacherClassSearchPath,
        name: AppRoute.teacherClassSearch,
        builder: (context, state) => const TeacherClassSearchScreen(),
      ),
      // Route class detail (standalone - no bottom nav)
      GoRoute(
        path: AppRoute.teacherClassDetailPath(':classId'),
        name: AppRoute.teacherClassDetail,
        builder: (context, state) {
          final classId = state.pathParameters['classId'];

          if (classId == null || classId.isEmpty) {
            // Redirect về class list nếu không có classId
            return const TeacherClassListScreen();
          }

          // Validate: nếu classId là "create" hoặc "search" thì redirect về đúng screen
          if (classId == 'create') {
            return const CreateClassScreen();
          }
          if (classId == 'search') {
            return const TeacherClassSearchScreen();
          }

          final extra = state.extra;
          String? className;
          String? semesterInfo;
          if (extra is Map<String, dynamic>) {
            className = extra['className'] as String?;
            semesterInfo = extra['semesterInfo'] as String?;
          }

          return TeacherClassDetailScreen(
            classId: classId,
            className: className ?? '',
            semesterInfo: semesterInfo ?? '',
          );
        },
      ),

      // Route assignment detail (standalone - no bottom nav)
      GoRoute(
        path: AppRoute.teacherAssignmentDetailPath(
          ':classId',
          ':distributionId',
        ),
        name: AppRoute.teacherAssignmentDetail,
        builder: (context, state) {
          final classId = state.pathParameters['classId']!;
          final distributionId = state.pathParameters['distributionId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return TeacherAssignmentDetailScreen(
            classId: classId,
            distributionId: distributionId,
            assignmentTitle: extra?['assignmentTitle'] as String? ?? '',
            className: extra?['className'] as String? ?? '',
          );
        },
      ),

      // Route class submission list (chọn lớp để xem bài nộp)
      GoRoute(
        path: AppRoute.teacherClassSubmissionListPath(':assignmentId'),
        name: AppRoute.teacherClassSubmissionList,
        builder: (context, state) {
          final assignmentId = state.pathParameters['assignmentId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return TeacherClassSubmissionListScreen(
            assignmentId: assignmentId,
            assignmentTitle: extra?['assignmentTitle'] as String? ?? '',
          );
        },
      ),

      // Route submission list (teacher grading - ATC Dashboard)
      GoRoute(
        path: AppRoute.teacherSubmissionListPath(':distributionId'),
        name: AppRoute.teacherSubmissionList,
        builder: (context, state) {
          final distributionId = state.pathParameters['distributionId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return TeacherSubmissionListScreen(
            distributionId: distributionId,
            assignmentTitle: extra?['assignmentTitle'] as String? ?? '',
            className: extra?['className'] as String?,
          );
        },
      ),

      // Route submission detail (teacher grading - Focus Lens)
      GoRoute(
        path: AppRoute.teacherGradeSubmissionPath(':submissionId'),
        name: AppRoute.teacherGradeSubmission,
        builder: (context, state) {
          final submissionId = state.pathParameters['submissionId']!;
          final extra = state.extra as Map<String, dynamic>?;
          final allSubmissionIds =
              extra?['allSubmissionIds'] as List<String>? ?? [];
          return TeacherSubmissionDetailScreen(
            submissionId: submissionId,
            allSubmissionIds: allSubmissionIds,
          );
        },
      ),

      // Note: teacherClassSearch is now inside ShellRoute, so this standalone route is removed
      // GoRoute(
      //   path: AppRoute.teacherClassSearchPath,
      //   name: AppRoute.teacherClassSearch,
      //   builder: (context, state) => const TeacherClassSearchScreen(),
      // ),

      // Note: teacherAssignmentList is now inside ShellRoute, so this standalone route is removed
      // GoRoute(
      //   path: AppRoute.teacherAssignmentListPath,
      //   name: AppRoute.teacherAssignmentList,
      //   builder: (context, state) => const AssignmentListScreen(),
      // ),
      GoRoute(
        path: AppRoute.teacherEditClassPath(':classId'),
        name: AppRoute.teacherEditClass,
        builder: (context, state) {
          final classItem = state.extra as Class?;
          if (classItem == null) {
            return const Scaffold(
              body: Center(child: Text('Thiếu dữ liệu lớp học')),
            );
          }
          return EditClassScreen(classItem: classItem);
        },
      ),

      GoRoute(
        path: AppRoute.teacherAddStudentByCodePath(':classId'),
        name: AppRoute.teacherAddStudentByCode,
        builder: (context, state) {
          final classId = state.pathParameters['classId']!;
          final className = state.extra as String?;
          return AddStudentByCodeScreen(
            classId: classId,
            className: className ?? '',
          );
        },
      ),

      GoRoute(
        path: AppRoute.teacherStudentListPath(':classId'),
        name: AppRoute.teacherStudentList,
        builder: (context, state) {
          final classId = state.pathParameters['classId']!;
          final className = state.extra as String?;
          return StudentListScreen(
            classId: classId,
            className: className ?? '',
          );
        },
      ),

      // ==================== SHARED ROUTES ====================
      // Available to all authenticated users
      GoRoute(
        path: AppRoute.profilePath,
        name: AppRoute.profile,
        builder: (context, state) => const ProfileScreen(),
      ),

      GoRoute(
        path: AppRoute.settingsPath,
        name: AppRoute.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
        path: AppRoute.apiKeySetupPath,
        name: AppRoute.apiKeySetup,
        builder: (context, state) => const ApiKeySetupScreen(),
      ),

      GoRoute(
        path: AppRoute.forbiddenPath,
        name: AppRoute.forbidden,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('403 - Access Denied'))),
      ),

      // No internet screen
      GoRoute(
        path: AppRoute.noInternetPath,
        name: AppRoute.noInternet,
        builder: (context, state) => NoInternetScreen(
          onRetry: () {
            // Try to navigate back to the previous route
            if (state.uri.queryParameters['redirect'] != null) {
              context.go(state.uri.queryParameters['redirect']!);
            } else {
              context.go(AppRoute.splashPath);
            }
          },
        ),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
});

/// Custom Page cho tab switches trong ShellRoute.
/// Fade crossfade mượt 200ms — giống Instagram, Shopee, YouTube.
/// Trang mới mờ dần hiện lên, trang cũ mờ dần biến mất.
class FadeTransitionPage extends CustomTransitionPage<void> {
  const FadeTransitionPage({super.key, required super.child})
    : super(
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: _fadeTransition,
      );

  static Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: child,
    );
  }
}
