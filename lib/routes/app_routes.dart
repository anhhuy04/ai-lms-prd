import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/presentation/views/auth/login_screen.dart';
import 'package:ai_mls/presentation/views/auth/register_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/admin_dashboard_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/student_dashboard_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/teacher_dashboard_screen.dart';
import 'package:ai_mls/presentation/views/splash/splash_screen.dart'; // Added splash
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/splash'; // Route for splash screen
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        final initialEmail = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => LoginScreen(initialEmail: initialEmail),
        );

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case home:
        if (settings.arguments is Profile) {
          final userProfile = settings.arguments as Profile;
          switch (userProfile.role) {
            case 'student':
              return MaterialPageRoute(
                builder: (_) =>
                    StudentDashboardScreen(userProfile: userProfile),
              );
            case 'teacher':
              return MaterialPageRoute(
                builder: (_) =>
                    TeacherDashboardScreen(userProfile: userProfile),
              );
            case 'admin':
              return MaterialPageRoute(
                builder: (_) => AdminDashboardScreen(userProfile: userProfile),
              );
            default:
              return _errorRoute(
                'Vai trò người dùng không xác định: ${userProfile.role}',
              );
          }
        }
        return _errorRoute('Không có thông tin người dùng cho trang chủ.');

      default:
        return _errorRoute('Không có định tuyến cho ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(body: Center(child: Text('Lỗi: $message'))),
    );
  }
}
