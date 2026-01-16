import 'package:ai_mls/data/datasources/supabase_datasource.dart';
import 'package:ai_mls/data/repositories/auth_repository_impl.dart';
import 'package:ai_mls/domain/repositories/auth_repository.dart';
import 'package:ai_mls/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ai_mls/presentation/viewmodels/student_dashboard_viewmodel.dart';
import 'package:ai_mls/routes/app_routes.dart';
import 'package:ai_mls/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_mls/core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

  // 1. Tạo các dependencies từ tầng thấp nhất (Data)
  final supabaseClient = Supabase.instance.client;
  final profileDataSource = BaseTableDataSource(supabaseClient, 'profiles');

  final AuthRepository authRepository = AuthRepositoryImpl(profileDataSource);

  runApp(MyApp(authRepository: authRepository));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;

  const MyApp({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 2. Cung cấp ViewModel và inject Repository vào
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepository)),
        ChangeNotifierProxyProvider<AuthViewModel, StudentDashboardViewModel>(
          create: (context) => StudentDashboardViewModel(
            authViewModel: Provider.of<AuthViewModel>(context, listen: false),
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
