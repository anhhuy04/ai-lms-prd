import 'dart:convert';
import 'dart:io';

import 'package:ai_mls/core/routes/app_router.dart';
import 'package:ai_mls/core/services/deep_link_service.dart';
import 'package:ai_mls/core/services/error_reporting_service.dart';
import 'package:ai_mls/core/services/network_service.dart';
import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/core/theme/app_theme.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/data/datasources/assignment_datasource.dart';
import 'package:ai_mls/data/datasources/learning_objective_datasource.dart';
import 'package:ai_mls/data/datasources/question_bank_datasource.dart';
import 'package:ai_mls/data/datasources/school_class_datasource.dart';
import 'package:ai_mls/data/datasources/supabase_datasource.dart';
import 'package:ai_mls/data/repositories/assignment_repository_impl.dart';
import 'package:ai_mls/data/repositories/auth_repository_impl.dart';
import 'package:ai_mls/data/repositories/learning_objective_repository_impl.dart';
import 'package:ai_mls/data/repositories/question_repository_impl.dart';
import 'package:ai_mls/data/repositories/school_class_repository_impl.dart';
import 'package:ai_mls/domain/repositories/assignment_repository.dart';
import 'package:ai_mls/domain/repositories/auth_repository.dart';
import 'package:ai_mls/domain/repositories/learning_objective_repository.dart';
import 'package:ai_mls/domain/repositories/question_repository.dart';
import 'package:ai_mls/domain/repositories/school_class_repository.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';
import 'package:ai_mls/presentation/providers/learning_objective_providers.dart';
import 'package:ai_mls/presentation/providers/question_bank_providers.dart';
import 'package:ai_mls/widgets/navigation/back_button_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  if (!kDebugMode) return;
  try {
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

    // Write to host file khi chạy trên Windows desktop (không áp dụng cho web)
    if (!kIsWeb && Platform.isWindows) {
      try {
        final logPath = r'd:\code\Flutter_Android\AI_LMS_PRD\.cursor\debug.log';
        final logFile = File(logPath);
        // Tránh I/O sync trong UI loop: tạo thư mục + append đều chạy async.
        // ignore: discarded_futures
        logFile.parent
            .create(recursive: true)
            .then((_) {
              return logFile.writeAsString(
                '${jsonEncode(logEntry)}\n',
                mode: FileMode.append,
                flush: false,
              );
            })
            .catchError((e) {
              // Silently ignore file write errors (e.g., read-only file system)
              // Return logFile chỉ để đáp ứng kiểu Future<File>, KHÔNG ghi file
              return Future<File>.value(logFile);
            }, test: (_) => true);
      } catch (_) {
        // Swallow write failures on non-host environments or read-only file systems
      }
    }

    // Tắt gửi ingest HTTP trong app runtime để tránh network jitter.
  } catch (e) {
    // Fallback to console logging
    AppLogger.debug('Log: $location - $message - ${_sanitizeData(data)}');
    AppLogger.error('Logging error', error: e);
  }
}
// #endregion

void main() async {
  // #region agent log
  _log('main.dart:17', 'App startup', {}, 'G');
  // #endregion

  // Debug: Check ENV_FILE environment variable (compile-time constant)
  const envFile = String.fromEnvironment('ENV_FILE', defaultValue: '.env.dev');
  AppLogger.info(
    '📋 [MAIN] ENV_FILE from environment: "$envFile" '
    '(default: .env.dev)',
  );
  AppLogger.info(
    '📋 [MAIN] To use custom env file, run: '
    'flutter run --dart-define=ENV_FILE=.env.dev',
  );

  // Khởi tạo Sentry báo cáo lỗi ĐẦU TIÊN, trước bất kỳ khởi tạo nào khác
  await ErrorReportingService.initialize(
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();

      try {
        // #region agent log
        _log('main.dart:22', 'Initializing Supabase', {}, 'G');
        // #endregion

        // Check network connectivity before attempting Supabase initialization
        final hasNetwork = await NetworkService.hasInternetConnection();
        if (!hasNetwork) {
          throw Exception(
            'No internet connection detected. '
            'Please ensure your device is connected to WiFi or mobile data.',
          );
        }

        // Initialize Supabase with 15 second timeout
        await SupabaseService.initialize(timeout: const Duration(seconds: 15));

        // Khởi tạo DeepLinkService sau khi Supabase đã sẵn sàng
        await DeepLinkService.instance.initialize();
        // #region agent log
        _log('main.dart:24', 'Supabase initialized', {}, 'G');
        // #endregion
      } catch (e) {
        // #region agent log
        _log('main.dart:27', 'Supabase init error', {
          'error': e.toString(),
        }, 'G');
        // #endregion
        AppLogger.error('Failed to initialize Supabase', error: e);
        rethrow;
      }

      // Tạo các dependencies từ tầng thấp nhất (Data)
      final supabaseClient = Supabase.instance.client;
      final profileDataSource = BaseTableDataSource(supabaseClient, 'profiles');
      final schoolClassDataSource = SchoolClassDataSource();
      final questionBankDataSource = QuestionBankDataSource(supabaseClient);
      final assignmentDataSource = AssignmentDataSource(supabaseClient);
      final learningObjectiveDataSource = LearningObjectiveDataSource(
        supabaseClient,
      );

      final AuthRepository authRepository = AuthRepositoryImpl(
        profileDataSource,
      );
      final SchoolClassRepository schoolClassRepository =
          SchoolClassRepositoryImpl(schoolClassDataSource);
      final QuestionRepository questionRepository = QuestionRepositoryImpl(
        questionBankDataSource,
      );
      final AssignmentRepository assignmentRepository =
          AssignmentRepositoryImpl(assignmentDataSource);
      final LearningObjectiveRepository learningObjectiveRepository =
          LearningObjectiveRepositoryImpl(learningObjectiveDataSource);

      // #region agent log
      // Chỉ ghi file debug trên Windows desktop, không chạy trên web.
      if (!kIsWeb && Platform.isWindows) {
        try {
          final logFile = File(
            'd:\\code\\Flutter_Android\\AI_LMS_PRD\\.cursor\\debug.log',
          );
          // ignore: discarded_futures
          logFile
              .writeAsString(
                '${jsonEncode({
                  "id": "log_${DateTime.now().millisecondsSinceEpoch}",
                  "timestamp": DateTime.now().millisecondsSinceEpoch,
                  "location": "main.dart:119",
                  "message": "Setting up ProviderScope with overrides",
                  "data": {"hasAuthRepository": true, "hasSchoolClassRepository": true},
                  "sessionId": "debug-session",
                  "runId": "run1",
                  "hypothesisId": "E",
                })}\n',
                mode: FileMode.append,
                flush: false,
              )
              .catchError((e) {
                // Silently ignore file write errors (e.g., read-only file system)
                // Return logFile chỉ để đáp ứng kiểu Future<File>, KHÔNG ghi file
                return Future<File>.value(logFile);
              }, test: (_) => true);
        } catch (_) {
          // Swallow write failures on non-host environments or read-only file systems
        }
      }
      // #endregion

      runApp(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepository),
            schoolClassRepositoryProvider.overrideWithValue(
              schoolClassRepository,
            ),
            questionRepositoryProvider.overrideWithValue(questionRepository),
            assignmentRepositoryProvider.overrideWithValue(
              assignmentRepository,
            ),
            learningObjectiveRepositoryProvider.overrideWithValue(
              learningObjectiveRepository,
            ),
          ],
          child: const MyApp(),
        ),
      );
    },
  );
}

/// MyApp widget - chỉ dùng Riverpod providers, không còn ChangeNotifierProvider.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // #region agent log
    _log('main.dart:51', 'MyApp build called', {}, 'G');
    // #endregion
    final router = ref.watch(appRouterProvider);

    // Setup ScreenUtil với design size (mặc định: 375x812 cho iPhone X)
    // Có thể điều chỉnh theo design mockup thực tế
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Design size mặc định
      minTextAdapt: true, // Cho phép text scale nhỏ hơn
      splitScreenMode: true, // Hỗ trợ split screen
      builder: (context, child) {
        // Apply deep link navigation after router is available.
        // Safe to call multiple times (DeepLinkService clears pending path after applying).
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          // Sử dụng context bên trong GoRouter thay vì context của ScreenUtilInit,
          // tránh lỗi "No GoRouter found in context" trên web.
          final navContext = router.routerDelegate.navigatorKey.currentContext;
          if (navContext == null) return;
          DeepLinkService.instance.applyPendingDeepLink(navContext);
        });

        return BackButtonHandler(
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor:
                  Colors.transparent, // Hoàn toàn trong suốt như FB, TikTok
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: GestureDetector(
              onTap: () {
                // Tự động ẩn keyboard và unfocus khi tap ra ngoài
                FocusScope.of(context).unfocus();
              },
              behavior: HitTestBehavior.opaque,
              child: MaterialApp.router(
                title: 'AI Learning App',
                theme: AppTheme.lightTheme,
                routerConfig: router,
                builder: (context, child) {
                  return GestureDetector(
                    onTap: () {
                      // Đảm bảo keyboard ẩn khi tap bất kỳ đâu
                      FocusScope.of(context).unfocus();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: child,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
