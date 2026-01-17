import 'package:ai_mls/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ai_mls/routes/app_routes.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final String? initialEmail;

  const LoginScreen({super.key, this.initialEmail});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    // Sử dụng Consumer để lắng nghe AuthViewModel
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.xxl),
          child: Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              // Kiểm tra null safety cho authViewModel
              if (authViewModel.errorMessage != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authViewModel.errorMessage!)),
                  );
                  authViewModel.clearErrorMessage(); // Xóa lỗi sau khi hiển thị
                });
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.school,
                    size: DesignIcons.lgSize,
                    color: DesignColors.primary,
                  ),
                  SizedBox(height: DesignSpacing.lg),
                  Text(
                    'Chào mừng trở lại',
                    style: DesignTypography.headlineMedium,
                  ),
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
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
                        onChanged: (value) =>
                            setState(() => _rememberMe = value!),
                      ),
                      const Text('Ghi nhớ đăng nhập'),
                    ],
                  ),
                  SizedBox(height: DesignSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: authViewModel.isLoading ?? false
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () => _login(authViewModel),
                            child: const Text('Đăng nhập'),
                          ),
                  ),
                  SizedBox(height: DesignSpacing.md),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.register),
                    child: const Text('Chưa có tài khoản? Đăng ký'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _login(AuthViewModel authViewModel) async {
    final success = await authViewModel.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      // Lưu lựa chọn "Ghi nhớ"
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', _rememberMe);

      final userProfile = authViewModel.userProfile;
      if (userProfile != null) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
          arguments: userProfile,
        );
      }
    }
  }
}
