/// Route Constants - Centralized management of all route names and paths
///
/// This file provides a single source of truth for all route definitions,
/// making it easier to maintain and update routing throughout the application.
/// All route strings should be referenced from here rather than hardcoded.
///
/// Navigation Pattern:
/// - Use named routes: context.goNamed('route-name', pathParameters: {...})
/// - Use path helpers for parameters: AppRoute.studentClassDetailPath(classId)
/// - DO NOT use hardcoded paths or Navigator.push()
class AppRoute {
  AppRoute._(); // Prevent instantiation

  // ==================== PUBLIC ROUTES ====================
  // Routes that don't require authentication

  /// Splash screen - Initial route when app launches
  static const String splash = 'splash';
  static const String splashPath = '/splash';

  /// Login screen - User authentication
  static const String login = 'login';
  static const String loginPath = '/login';

  /// Registration screen - New user signup
  static const String register = 'register';
  static const String registerPath = '/register';

  // ==================== DEEP LINK ROUTES ====================
  // Routes for deep linking (accessible without auth)

  /// Reset password screen with token parameter
  static const String resetPassword = 'reset-password';
  static const String resetPasswordPath = '/reset-password';

  /// Email verification screen with token parameter
  static const String emailVerification = 'verify-email';
  static const String emailVerificationPath = '/verify-email';

  // ==================== PROTECTED ROUTES ====================
  // Routes that require authentication

  /// Home route - Redirects to role-specific dashboard
  static const String home = 'home';
  static const String homePath = '/home';

  // ==================== DASHBOARD ROUTES ====================
  // Role-specific dashboard routes (use ShellRoute structure)

  /// Student dashboard - Main shell for student (contains bottom nav)
  static const String studentDashboard = 'student-dashboard';
  static const String studentDashboardPath = '/student-dashboard';

  /// Teacher dashboard - Main shell for teacher (contains bottom nav)
  static const String teacherDashboard = 'teacher-dashboard';
  static const String teacherDashboardPath = '/teacher-dashboard';

  /// Admin dashboard - Main shell for admin (contains bottom nav)
  static const String adminDashboard = 'admin-dashboard';
  static const String adminDashboardPath = '/admin-dashboard';

  // ==================== STUDENT ROUTES ====================
  // Routes specific to student role

  /// Student - Class list (inside student dashboard shell)
  static const String studentClassList = 'student-class-list';
  static const String studentClassListPath = '/student/classes';

  /// Student - Class search
  static const String studentClassSearch = 'student-class-search';
  static const String studentClassSearchPath = '/student/class/search';

  /// Student - Class detail (with parameter)
  static const String studentClassDetail = 'student-class-detail';
  static String studentClassDetailPath(String classId) =>
      '/student/class/$classId';

  /// Student - Join class by code
  static const String studentJoinClass = 'student-join-class';
  static const String studentJoinClassPath = '/student/join-class';

  /// Student - QR scan for class
  static const String studentQrScan = 'student-qr-scan';
  static const String studentQrScanPath = '/student/qr-scan';

  /// Student - Assignment list
  static const String studentAssignmentList = 'student-assignment-list';
  static const String studentAssignmentListPath = '/student/assignments';

  /// Student - Assignment detail (with parameter)
  static const String studentAssignmentDetail = 'student-assignment-detail';
  static String studentAssignmentDetailPath(String assignmentId) =>
      '/student/assignment/$assignmentId';

  /// Student - Profile screen (within shell)
  static const String studentProfile = 'student-profile';
  static const String studentProfilePath = '/student/profile';

  /// Student - Scores/Grades view
  static const String studentScores = 'student-scores';
  static const String studentScoresPath = '/student/scores';

  // ==================== TEACHER ROUTES ====================
  // Routes specific to teacher role

  /// Teacher - Class list (inside teacher dashboard shell)
  static const String teacherClassList = 'teacher-class-list';
  static const String teacherClassListPath = '/teacher/classes';

  /// Teacher - Class search
  static const String teacherClassSearch = 'teacher-class-search';
  static const String teacherClassSearchPath = '/teacher/class/search';

  /// Teacher - Class detail (with parameter)
  static const String teacherClassDetail = 'teacher-class-detail';
  static String teacherClassDetailPath(String classId) =>
      '/teacher/class/$classId';

  /// Teacher - Create class
  static const String teacherCreateClass = 'teacher-create-class';
  static const String teacherCreateClassPath = '/teacher/class/create';

  /// Teacher - Edit class (with parameter)
  static const String teacherEditClass = 'teacher-edit-class';
  static String teacherEditClassPath(String classId) =>
      '/teacher/class/$classId/edit';

  /// Teacher - Student list for class (with parameter)
  static const String teacherStudentList = 'teacher-student-list';
  static String teacherStudentListPath(String classId) =>
      '/teacher/class/$classId/students';

  /// Teacher - Add student by code (with parameter)
  static const String teacherAddStudentByCode = 'teacher-add-student-code';
  static String teacherAddStudentByCodePath(String classId) =>
      '/teacher/class/$classId/add-student';

  /// Teacher - Assignment Hub (overview screen)
  static const String teacherAssignmentHub = 'teacher-assignment-hub';
  static const String teacherAssignmentHubPath = '/teacher/assignments/hub';

  /// Teacher - Assignment list
  static const String teacherAssignmentList = 'teacher-assignment-list';
  static const String teacherAssignmentListPath = '/teacher/assignments';

  /// Teacher - Profile screen (within shell)
  static const String teacherProfile = 'teacher-profile';
  static const String teacherProfilePath = '/teacher/profile';

  /// Teacher - Create assignment
  static const String teacherCreateAssignment = 'teacher-create-assignment';
  static const String teacherCreateAssignmentPath =
      '/teacher/assignment/create';

  /// Teacher - Draft assignments (kho bài tập nháp)
  static const String teacherDraftAssignments = 'teacher-draft-assignments';
  static const String teacherDraftAssignmentsPath =
      '/teacher/assignments/drafts';

  /// Teacher - Published assignments (kho bài tập đã tạo)
  static const String teacherPublishedAssignments =
      'teacher-published-assignments';
  static const String teacherPublishedAssignmentsPath =
      '/teacher/assignments/published';

  /// Teacher - Create question
  static const String teacherCreateQuestion = 'teacher-create-question';
  static const String teacherCreateQuestionPath =
      '/teacher/assignment/question/create';

  /// Teacher - AI Generate questions
  static const String teacherAiGenerateQuestion =
      'teacher-ai-generate-question';
  static const String teacherAiGenerateQuestionPath =
      '/teacher/assignment/question/ai-generate';

  /// Teacher - Edit assignment (with parameter)
  static const String teacherEditAssignment = 'teacher-edit-assignment';
  static String teacherEditAssignmentPath(String assignmentId) =>
      '/teacher/assignment/$assignmentId/edit';

  /// Teacher - Grading view (assignments to grade)
  static const String teacherGrading = 'teacher-grading';
  static const String teacherGradingPath = '/teacher/grading';

  /// Teacher - Grade assignment submissions (with parameter)
  static const String teacherGradeSubmission = 'teacher-grade-submission';
  static String teacherGradeSubmissionPath(String submissionId) =>
      '/teacher/submission/$submissionId/grade';

  // ==================== ADMIN ROUTES ====================
  // Routes specific to admin role (if needed)

  /// Admin - User management
  static const String adminUsers = 'admin-users';
  static const String adminUsersPath = '/admin/users';

  /// Admin - System settings
  static const String adminSettings = 'admin-settings';
  static const String adminSettingsPath = '/admin/settings';

  // ==================== SHARED ROUTES ====================
  // Routes accessible to all authenticated users

  /// User profile screen
  static const String profile = 'profile';
  static const String profilePath = '/profile';

  /// Edit profile screen
  static const String editProfile = 'edit-profile';
  static const String editProfilePath = '/profile/edit';

  /// Settings screen
  static const String settings = 'settings';
  static const String settingsPath = '/settings';

  /// API Key Setup screen
  static const String apiKeySetup = 'api-key-setup';
  static const String apiKeySetupPath = '/settings/api-keys';

  /// Error page (403 - Access Denied)
  static const String forbidden = 'forbidden';
  static const String forbiddenPath = '/403';

  /// No internet connection screen
  static const String noInternet = 'no-internet';
  static const String noInternetPath = '/no-internet';

  // ==================== HELPER METHODS ====================

  /// Checks if a given path is a public route (doesn't require authentication)
  ///
  /// [path] - The path to check
  /// Returns true if the path is a public route, false otherwise
  static bool isPublicRoute(String path) {
    return path == splashPath ||
        path == loginPath ||
        path == registerPath ||
        path.startsWith(resetPasswordPath) ||
        path.startsWith(emailVerificationPath);
  }

  /// Checks if a route requires authentication
  static bool isAuthenticatedRoute(String path) {
    return !isPublicRoute(path);
  }

  /// Gets the appropriate dashboard path based on user role
  ///
  /// [role] - The user role ('student', 'teacher', 'admin')
  /// Returns the dashboard path for the given role, or login path if role is unknown
  static String getDashboardPathForRole(String role) {
    switch (role) {
      case 'student':
        return studentDashboardPath;
      case 'teacher':
        return teacherDashboardPath;
      case 'admin':
        return adminDashboardPath;
      default:
        return loginPath;
    }
  }

  /// Checks if a path is a dashboard route
  ///
  /// [path] - The path to check
  /// Returns true if the path is a dashboard route, false otherwise
  static bool isDashboardRoute(String path) {
    return path == studentDashboardPath ||
        path == teacherDashboardPath ||
        path == adminDashboardPath;
  }

  /// Checks if user can access a specific named route based on their role
  ///
  /// [role] - The user role ('student', 'teacher', 'admin')
  /// [routeName] - The route name to check
  /// Returns true if user can access this route
  static bool canAccessRoute(String role, String routeName) {
    // Public routes accessible to everyone
    if (routeName == splash ||
        routeName == login ||
        routeName == register ||
        routeName == resetPassword ||
        routeName == emailVerification) {
      return true;
    }

    // Routes only for students
    final studentRoutes = {
      studentClassList,
      studentClassSearch,
      studentClassDetail,
      studentJoinClass,
      studentQrScan,
      studentAssignmentList,
      studentAssignmentDetail,
      studentScores,
      studentDashboard,
      profile,
      editProfile,
      settings,
      apiKeySetup,
    };
    if (role == 'student' && studentRoutes.contains(routeName)) {
      return true;
    }

    // Routes only for teachers
    final teacherRoutes = {
      teacherClassList,
      teacherClassSearch,
      teacherClassDetail,
      teacherCreateClass,
      teacherEditClass,
      teacherStudentList,
      teacherAddStudentByCode,
      teacherAssignmentHub,
      teacherAssignmentList,
      teacherCreateAssignment,
      teacherDraftAssignments,
      teacherPublishedAssignments,
      teacherCreateQuestion,
      teacherEditAssignment,
      teacherGrading,
      teacherGradeSubmission,
      teacherDashboard,
      profile,
      editProfile,
      settings,
      apiKeySetup,
    };
    if (role == 'teacher' && teacherRoutes.contains(routeName)) {
      return true;
    }

    // Routes only for admins
    final adminRoutes = {
      adminUsers,
      adminSettings,
      adminDashboard,
      profile,
      editProfile,
      settings,
      apiKeySetup,
    };
    if (role == 'admin' && adminRoutes.contains(routeName)) {
      return true;
    }

    return false;
  }
}
