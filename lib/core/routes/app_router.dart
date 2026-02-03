import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/views/assignment/assignment_list_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_assignment_hub_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_create_question_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_draft_assignments_screen.dart';
import 'package:ai_mls/presentation/views/assignment/teacher/teacher_published_assignments_screen.dart';
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
import 'package:ai_mls/presentation/views/class/teacher/teacher_class_detail_screen.dart';
import 'package:ai_mls/presentation/views/class/teacher/teacher_class_list_screen.dart';
import 'package:ai_mls/presentation/views/class/teacher/widgets/search/teacher_class_search_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/admin_dashboard_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/home/student_home_content_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/home/teacher_home_content_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/student_dashboard_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/teacher_dashboard_screen.dart';
import 'package:ai_mls/presentation/views/grading/scores_screen.dart';
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
  // Watch auth state to trigger router rebuild on auth changes
  final currentUserAsync = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: AppRoute.splashPath,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final currentPath = state.matchedLocation;

      // Skip redirect logic for splash and no-internet screens
      if (currentPath == AppRoute.splashPath ||
          currentPath == AppRoute.noInternetPath) {
        return null;
      }

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
            builder: (context, state) => const StudentHomeContentScreen(),
          ),
          GoRoute(
            path: AppRoute.studentClassListPath,
            name: AppRoute.studentClassList,
            builder: (context, state) => const StudentClassListScreen(),
          ),
          GoRoute(
            path: AppRoute.studentScoresPath,
            name: AppRoute.studentScores,
            builder: (context, state) => const ScoresScreen(),
          ),
          GoRoute(
            path: AppRoute.studentAssignmentListPath,
            name: AppRoute.studentAssignmentList,
            builder: (context, state) => const AssignmentListScreen(),
          ),
          GoRoute(
            path: AppRoute.studentProfilePath,
            name: AppRoute.studentProfile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
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
            builder: (context, state) => const TeacherHomeContentScreen(),
          ),
          GoRoute(
            path: AppRoute.teacherClassListPath,
            name: AppRoute.teacherClassList,
            builder: (context, state) => const TeacherClassListScreen(),
          ),
          GoRoute(
            path: AppRoute.teacherAssignmentHubPath,
            name: AppRoute.teacherAssignmentHub,
            builder: (context, state) => const TeacherAssignmentHubScreen(),
          ),
          GoRoute(
            path: AppRoute.teacherAssignmentListPath,
            name: AppRoute.teacherAssignmentList,
            builder: (context, state) => const AssignmentListScreen(),
          ),
          GoRoute(
            path: AppRoute.teacherProfilePath,
            name: AppRoute.teacherProfile,
            builder: (context, state) => const ProfileScreen(),
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
            builder: (context, state) =>
                const SizedBox.shrink(), // Shell handles it
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
      // Route AI generate questions (standalone - no bottom nav)
      GoRoute(
        path: AppRoute.teacherAiGenerateQuestionPath,
        name: AppRoute.teacherAiGenerateQuestion,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final questions = extra?['questions'] as List<Map<String, dynamic>>?;
          return TeacherAiGenerateQuestionScreen(
            questions: questions,
          );
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
