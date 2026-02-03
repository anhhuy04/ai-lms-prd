import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? initialEmail;

  const LoginScreen({super.key, this.initialEmail});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  bool _rememberMe = true; // Giá trị mặc định cho checkbox
  bool _obscurePassword = true; // Ẩn mật khẩu mặc định

  @override
  void initState() {
    super.initState();
    // Khởi tạo email controller với initialEmail (nếu có)
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Hiển thị lỗi nếu có
    ref.listen<AsyncValue>(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (err, _) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err.toString())));
        },
      );
    });

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.school,
                size: DesignIcons.lgSize,
                color: DesignColors.primary,
              ),
              SizedBox(height: DesignSpacing.lg),
              Text('Chào mừng trở lại', style: DesignTypography.headlineMedium),
              SizedBox(height: DesignSpacing.xxl),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: DesignSpacing.lg),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: DesignColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
              ),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) => setState(() => _rememberMe = value!),
                  ),
                  const Text('Ghi nhớ đăng nhập'),
                ],
              ),
              SizedBox(height: DesignSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: authState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text('Đăng nhập'),
                      ),
              ),
              SizedBox(height: DesignSpacing.md),
              TextButton(
                onPressed: () => context.pushNamed(AppRoute.register),
                child: const Text('Chưa có tài khoản? Đăng ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final success = await ref
        .read(authNotifierProvider.notifier)
        .signIn(_emailController.text.trim(), _passwordController.text.trim());

    if (success && mounted) {
      // Lưu lựa chọn "Ghi nhớ"
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', _rememberMe);
      if (!mounted) return;

      // Handle redirect after login
      final redirect = GoRouterState.of(
        context,
      ).uri.queryParameters['redirect'];

      if (redirect != null && redirect.isNotEmpty) {
        // Redirect to the saved URL after login
        context.go(Uri.decodeComponent(redirect));
      } else {
        // Default: go to home (will be redirected to appropriate dashboard)
        context.go(AppRoute.homePath);
      }
    }
  }
}
