import 'dart:convert';
import 'dart:io' show File, FileMode, Platform;

import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/core/theme/app_theme.dart';
import 'package:ai_mls/data/datasources/school_class_datasource.dart';
import 'package:ai_mls/data/datasources/supabase_datasource.dart';
import 'package:ai_mls/data/repositories/auth_repository_impl.dart';
import 'package:ai_mls/data/repositories/school_class_repository_impl.dart';
import 'package:ai_mls/domain/repositories/auth_repository.dart';
import 'package:ai_mls/domain/repositories/school_class_repository.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';
import 'package:ai_mls/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ai_mls/presentation/viewmodels/class_viewmodel.dart';
import 'package:ai_mls/presentation/viewmodels/student_dashboard_viewmodel.dart';
import 'package:ai_mls/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:supabase_flutter/supabase_flutter.dart';

// #region agent log
dynamic _sanitizeData(dynamic data) {
  if (data is Map) {
    return Map<String, dynamic>.fromEntries(
      data.entries.map(
        (e) => MapEntry(e.key.toString(), _sanitizeData(e.value)),
      ),
    );
  } else if (data is List) {
    return data.map((e) => _sanitizeData(e)).toList();
  } else if (data is double) {
    if (data.isInfinite) return 'Infinity';
    if (data.isNaN) return 'NaN';
    return data;
  } else if (data is num && !data.isFinite) {
    return 'Infinity';
  }
  return data;
}

void _log(
  String location,
  String message,
  Map<String, dynamic> data,
  String hypothesisId,
) {
  try {
    // Use relative path that works on all platforms
    final logPath = Platform.isWindows
        ? r'd:\code\Flutter_Android\AI_LMS_PRD\.cursor\debug.log'
        : '/data/data/com.example.ai_mls/files/debug.log';
    final logFile = File(logPath);

    // Ensure directory exists
    try {
      logFile.parent.createSync(recursive: true);
    } catch (_) {
      // Directory might not be writable, skip file logging
      debugPrint('Log: $location - $message - ${_sanitizeData(data)}');
      return;
    }

    final sanitizedData = _sanitizeData(data);
    final logEntry = {
      'sessionId': 'debug-session',
      'runId': 'run1',
      'hypothesisId': hypothesisId,
      'location': location,
      'message': message,
      'data': sanitizedData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    final jsonString = jsonEncode(logEntry);
    final existingContent = logFile.existsSync()
        ? logFile.readAsStringSync()
        : '';
    logFile.writeAsStringSync(
      '$existingContent$jsonString\n',
      mode: FileMode.write,
    );
  } catch (e) {
    // Fallback to console logging
    debugPrint('Log: $location - $message - ${_sanitizeData(data)}');
    debugPrint('Logging error: $e');
  }
}
// #endregion

void main() async {
  // #region agent log
  _log('main.dart:17', 'App startup', {}, 'G');
  // #endregion
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // #region agent log
    _log('main.dart:22', 'Initializing Supabase', {}, 'G');
    // #endregion
    await SupabaseService.initialize();
    // #region agent log
    _log('main.dart:24', 'Supabase initialized', {}, 'G');
    // #endregion
  } catch (e) {
    // #region agent log
    _log('main.dart:27', 'Supabase init error', {'error': e.toString()}, 'G');
    // #endregion
    rethrow;
  }

  // 1. Tạo các dependencies từ tầng thấp nhất (Data)
  final supabaseClient = Supabase.instance.client;
  final profileDataSource = BaseTableDataSource(supabaseClient, 'profiles');
  final schoolClassDataSource = SchoolClassDataSource();

  final AuthRepository authRepository = AuthRepositoryImpl(profileDataSource);
  final SchoolClassRepository schoolClassRepository = SchoolClassRepositoryImpl(
    schoolClassDataSource,
  );

  // #region agent log
  try {
    final logFile = File(
      'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
    );
    logFile.writeAsStringSync(
      '${jsonEncode({
        "id": "log_${DateTime.now().millisecondsSinceEpoch}",
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "location": "main.dart:119",
        "message": "Setting up ProviderScope with overrides",
        "data": {"hasAuthRepository": authRepository != null, "hasSchoolClassRepository": schoolClassRepository != null},
        "sessionId": "debug-session",
        "runId": "run1",
        "hypothesisId": "E",
      })}\n',
      mode: FileMode.append,
    );
  } catch (_) {}
  // #endregion
  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        schoolClassRepositoryProvider.overrideWithValue(schoolClassRepository),
      ],
      child: MyApp(
        authRepository: authRepository,
        schoolClassRepository: schoolClassRepository,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final SchoolClassRepository schoolClassRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.schoolClassRepository,
  });

  @override
  Widget build(BuildContext context) {
    // #region agent log
    _log('main.dart:51', 'MyApp build called', {}, 'G');
    // #endregion
    return provider.MultiProvider(
      providers: [
        // 2. Cung cấp ViewModel và inject Repository vào
        provider.ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository),
        ),
        provider.ChangeNotifierProvider(
          create: (_) => ClassViewModel(schoolClassRepository),
        ),
        provider.ChangeNotifierProxyProvider<
          AuthViewModel,
          StudentDashboardViewModel
        >(
          create: (context) => StudentDashboardViewModel(
            authViewModel: provider.Provider.of<AuthViewModel>(
              context,
              listen: false,
            ),
          ),
          update: (context, authViewModel, _) =>
              StudentDashboardViewModel(authViewModel: authViewModel),
        ),
      ],
      child: MaterialApp(
        title: 'AI Learning App',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
