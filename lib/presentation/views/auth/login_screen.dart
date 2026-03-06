import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/validation_utils.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = true;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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

    ref.listen<AsyncValue>(authNotifierProvider, (previous, next) {
      if (!mounted) return;
      next.when(
        data: (_) {
          if (_errorMessage != null) {
            setState(() => _errorMessage = null);
          }
        },
        loading: () {
          if (_errorMessage != null) {
            setState(() => _errorMessage = null);
          }
        },
        error: (err, _) {
          setState(() {
            _errorMessage = _mapLoginError(err);
          });
        },
      );
    });

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.xxl,
              vertical: DesignSpacing.xxxl,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            DesignColors.primary,
                            DesignColors.primaryLight,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: DesignColors.primary.withValues(alpha: 0.25),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: DesignColors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignSpacing.xxl),

                  // Title
                  Center(
                    child: Text(
                      'Chào mừng trở lại',
                      style: DesignTypography.headlineLarge,
                    ),
                  ),
                  const SizedBox(height: DesignSpacing.sm),
                  Center(
                    child: Text(
                      'Đăng nhập để tiếp tục học tập',
                      style: DesignTypography.bodyMedium.copyWith(
                        color: DesignColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignSpacing.xxxl),

                  // Form card
                  Container(
                    padding: const EdgeInsets.all(DesignSpacing.xxl),
                    decoration: BoxDecoration(
                      color: DesignColors.white,
                      borderRadius: BorderRadius.circular(DesignRadius.lg),
                      boxShadow: [DesignElevation.level2],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email field
                        Text(
                          'Email',
                          style: DesignTypography.labelMedium.copyWith(
                            color: DesignColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: DesignSpacing.xs),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Nhập email của bạn',
                            hintStyle: TextStyle(
                              color: DesignColors.textTertiary,
                              fontSize: DesignTypography.bodyMediumSize,
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: DesignColors.textSecondary,
                              size: DesignIcons.smSize,
                            ),
                            filled: true,
                            fillColor: DesignColors.moonLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DesignRadius.inputRadius,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DesignRadius.inputRadius,
                              ),
                              borderSide: const BorderSide(
                                color: DesignColors.primary,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DesignRadius.inputRadius,
                              ),
                              borderSide: const BorderSide(
                                color: DesignColors.error,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DesignRadius.inputRadius,
                              ),
                              borderSide: const BorderSide(
                                color: DesignColors.error,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: DesignSpacing.lg,
                              vertical: DesignSpacing.md,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final email = (value ?? '').trim();
                            if (email.isEmpty) {
                              return 'Vui lòng nhập email.';
                            }
                            if (!ValidationUtils.isValidEmail(email)) {
                              return 'Email không hợp lệ.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: DesignSpacing.lg),

                        // Password field
                        Text(
                          'Mật khẩu',
                          style: DesignTypography.labelMedium.copyWith(
                            color: DesignColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: DesignSpacing.xs),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: 'Nhập mật khẩu',
                            hintStyle: TextStyle(
                              color: DesignColors.textTertiary,
                              fontSize: DesignTypography.bodyMediumSize,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: DesignColors.textSecondary,
                              size: DesignIcons.smSize,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: DesignColors.textSecondary,
                                size: DesignIcons.smSize,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: DesignColors.moonLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DesignRadius.inputRadius,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DesignRadius.inputRadius,
                              ),
                              borderSide: const BorderSide(
                                color: DesignColors.primary,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DesignRadius.inputRadius,
                              ),
                              borderSide: const BorderSide(
                                color: DesignColors.error,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DesignRadius.inputRadius,
                              ),
                              borderSide: const BorderSide(
                                color: DesignColors.error,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: DesignSpacing.lg,
                              vertical: DesignSpacing.md,
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            final pwd = (value ?? '').trim();
                            if (pwd.isEmpty) {
                              return 'Vui lòng nhập mật khẩu.';
                            }
                            if (!ValidationUtils.isValidPassword(pwd)) {
                              return 'Mật khẩu phải có ít nhất 8 ký tự.';
                            }
                            return null;
                          },
                        ),

                        // Error message
                        if (_errorMessage != null) ...[
                          const SizedBox(height: DesignSpacing.md),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignSpacing.md,
                              vertical: DesignSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: DesignColors.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                DesignRadius.sm,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: DesignColors.error,
                                  size: DesignIcons.smSize,
                                ),
                                const SizedBox(width: DesignSpacing.sm),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: DesignTypography.bodySmall.copyWith(
                                      color: DesignColors.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: DesignSpacing.md),

                        // Remember me
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: DesignColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: authState.isLoading
                                    ? null
                                    : (value) => setState(
                                        () =>
                                            _rememberMe = value ?? _rememberMe,
                                      ),
                              ),
                            ),
                            const SizedBox(width: DesignSpacing.sm),
                            Text(
                              'Ghi nhớ đăng nhập',
                              style: DesignTypography.bodySmall.copyWith(
                                color: DesignColors.textSecondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: DesignSpacing.xxl),

                        // Login button
                        SizedBox(
                          height: DesignComponents.buttonHeightLarge,
                          child: authState.isLoading
                              ? Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: DesignColors.primary,
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: DesignColors.primary,
                                    foregroundColor: DesignColors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        DesignRadius.buttonRadius,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      fontSize: DesignTypography.bodyLargeSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: DesignSpacing.xxl),

                  // Register link
                  Center(
                    child: TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => context.pushNamed(AppRoute.register),
                      child: RichText(
                        text: TextSpan(
                          style: DesignTypography.bodyMedium.copyWith(
                            color: DesignColors.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: 'Chưa có tài khoản? '),
                            TextSpan(
                              text: 'Đăng ký',
                              style: TextStyle(
                                color: DesignColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() => _errorMessage = null);

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    final success = await ref
        .read(authNotifierProvider.notifier)
        .signIn(email, password);

    if (!mounted) return;

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', _rememberMe);
      if (!mounted) return;

      final redirect = GoRouterState.of(
        context,
      ).uri.queryParameters['redirect'];

      if (redirect != null && redirect.isNotEmpty) {
        context.go(Uri.decodeComponent(redirect));
      } else {
        // Lấy role từ profile đã đăng nhập thành công
        final profile = ref.read(authNotifierProvider).value;
        final role = profile?.role ?? 'student';
        context.go(AppRoute.getDashboardPathForRole(role));
      }
    }
    // Lỗi đã được xử lý tự động bởi ref.listen trong build()
  }

  String _mapLoginError(Object err) {
    final raw = err.toString();
    final msg = raw.replaceFirst('Exception: ', '').trim();

    final lower = msg.toLowerCase();
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid login') ||
        lower.contains('invalid email or password') ||
        lower.contains('email or password is incorrect')) {
      return 'Email hoặc mật khẩu không chính xác.';
    }

    if (lower.contains('network') ||
        lower.contains('socket') ||
        lower.contains('timeout')) {
      return 'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng và thử lại.';
    }

    if (lower.contains('email not confirmed') ||
        lower.contains('email confirmation')) {
      return 'Email chưa được xác nhận. Vui lòng kiểm tra hộp thư để xác nhận tài khoản.';
    }

    return 'Đăng nhập thất bại: $msg';
  }
}
