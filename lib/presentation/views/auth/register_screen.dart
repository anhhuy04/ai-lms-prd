import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/validation_utils.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'student';
  String? _selectedGender;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
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
            _errorMessage = _mapRegisterError(err);
          });
        },
      );
    });

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        backgroundColor: DesignColors.moonLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: DesignColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text('Đăng ký', style: DesignTypography.titleLarge),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSpacing.xxl,
            vertical: DesignSpacing.lg,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Center(
                  child: Text(
                    'Tạo tài khoản mới',
                    style: DesignTypography.headlineMedium,
                  ),
                ),
                const SizedBox(height: DesignSpacing.sm),
                Center(
                  child: Text(
                    'Điền thông tin bên dưới để bắt đầu',
                    style: DesignTypography.bodyMedium.copyWith(
                      color: DesignColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: DesignSpacing.xxl),

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
                      // Họ và tên
                      _buildLabel('Họ và tên'),
                      const SizedBox(height: DesignSpacing.xs),
                      _buildInputField(
                        controller: _fullNameController,
                        hint: 'Nhập họ và tên',
                        icon: Icons.person_outline_rounded,
                        capitalization: TextCapitalization.words,
                        validator: (value) {
                          final name = (value ?? '').trim();
                          if (name.isEmpty) return 'Vui lòng nhập họ và tên.';
                          if (name.length < 3) return 'Họ và tên quá ngắn.';
                          return null;
                        },
                      ),
                      const SizedBox(height: DesignSpacing.lg),

                      // Email
                      _buildLabel('Email'),
                      const SizedBox(height: DesignSpacing.xs),
                      _buildInputField(
                        controller: _emailController,
                        hint: 'Nhập email của bạn',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = (value ?? '').trim();
                          if (!ValidationUtils.isValidEmail(email)) {
                            return 'Email không hợp lệ.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: DesignSpacing.lg),

                      // Số điện thoại
                      _buildLabel('Số điện thoại'),
                      const SizedBox(height: DesignSpacing.xs),
                      _buildInputField(
                        controller: _phoneController,
                        hint: 'Nhập số điện thoại (tuỳ chọn)',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          final phone = (value ?? '').trim();
                          if (phone.isEmpty) return null;
                          if (!ValidationUtils.isValidPhoneNumber(phone)) {
                            return 'Số điện thoại phải có 10-11 chữ số.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: DesignSpacing.lg),

                      // Mật khẩu
                      _buildLabel('Mật khẩu'),
                      const SizedBox(height: DesignSpacing.xs),
                      _buildInputField(
                        controller: _passwordController,
                        hint: 'Nhập mật khẩu (tối thiểu 8 ký tự)',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
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
                        validator: (value) {
                          final pwd = (value ?? '').trim();
                          if (!ValidationUtils.isValidPassword(pwd)) {
                            return 'Mật khẩu phải có ít nhất 8 ký tự.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: DesignSpacing.lg),

                      // Xác nhận mật khẩu
                      _buildLabel('Xác nhận mật khẩu'),
                      const SizedBox(height: DesignSpacing.xs),
                      _buildInputField(
                        controller: _confirmPasswordController,
                        hint: 'Nhập lại mật khẩu',
                        icon: Icons.lock_outline_rounded,
                        obscureText: true,
                        validator: (value) {
                          final confirm = (value ?? '').trim();
                          final pwd = _passwordController.text.trim();
                          if (confirm.isEmpty) {
                            return 'Vui lòng nhập lại mật khẩu.';
                          }
                          if (confirm != pwd) {
                            return 'Mật khẩu nhập lại không khớp.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: DesignSpacing.lg),

                      // Giới tính
                      _buildLabel('Giới tính'),
                      const SizedBox(height: DesignSpacing.xs),
                      _buildDropdownField<String>(
                        value: _selectedGender,
                        hint: 'Chọn giới tính',
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Nam')),
                          DropdownMenuItem(value: 'female', child: Text('Nữ')),
                          DropdownMenuItem(value: 'other', child: Text('Khác')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng chọn giới tính.';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedGender = value);
                          }
                        },
                      ),
                      const SizedBox(height: DesignSpacing.lg),

                      // Vai trò
                      _buildLabel('Vai trò'),
                      const SizedBox(height: DesignSpacing.xs),
                      _buildDropdownField<String>(
                        value: _selectedRole,
                        hint: 'Chọn vai trò',
                        items: [
                          const DropdownMenuItem(
                            value: 'student',
                            child: Text('Học sinh'),
                          ),
                          const DropdownMenuItem(
                            value: 'teacher',
                            child: Text('Giáo viên'),
                          ),
                          const DropdownMenuItem(
                            value: 'admin',
                            child: Text('Quản trị'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedRole = value);
                          }
                        },
                      ),

                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: DesignSpacing.lg),
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

                      const SizedBox(height: DesignSpacing.xxl),

                      // Register button
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
                                onPressed: _register,
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
                                  'Đăng ký',
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

                // Login link
                Center(
                  child: TextButton(
                    onPressed: authState.isLoading ? null : () => context.pop(),
                    child: RichText(
                      text: TextSpan(
                        style: DesignTypography.bodyMedium.copyWith(
                          color: DesignColors.textSecondary,
                        ),
                        children: [
                          const TextSpan(text: 'Đã có tài khoản? '),
                          TextSpan(
                            text: 'Đăng nhập',
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
                const SizedBox(height: DesignSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Reusable UI builder methods ─────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: DesignTypography.labelMedium.copyWith(
        color: DesignColors.textSecondary,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: DesignColors.textTertiary,
          fontSize: DesignTypography.bodyMediumSize,
        ),
        prefixIcon: Icon(
          icon,
          color: DesignColors.textSecondary,
          size: DesignIcons.smSize,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: DesignColors.moonLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.inputRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.inputRadius),
          borderSide: const BorderSide(color: DesignColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.inputRadius),
          borderSide: const BorderSide(color: DesignColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.inputRadius),
          borderSide: const BorderSide(color: DesignColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.lg,
          vertical: DesignSpacing.md,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    void Function(T?)? onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      hint: Text(
        hint,
        style: TextStyle(
          color: DesignColors.textTertiary,
          fontSize: DesignTypography.bodyMediumSize,
        ),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: DesignColors.moonLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.inputRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.inputRadius),
          borderSide: const BorderSide(color: DesignColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.inputRadius),
          borderSide: const BorderSide(color: DesignColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.lg,
          vertical: DesignSpacing.md,
        ),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  // ─── Business logic ──────────────────────────────────────────

  Future<void> _register() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() => _errorMessage = null);

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final successMessage = await authNotifier.signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: _selectedRole,
      phone: phone,
      gender: _selectedGender,
    );

    if (!mounted) return;

    if (successMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.goNamed(AppRoute.login);
        }
      });
    }
    // Lỗi đã được xử lý tự động bởi ref.listen trong build()
  }

  String _mapRegisterError(Object err) {
    final raw = err.toString();
    final msg = raw.replaceFirst('Exception: ', '').trim();

    final lower = msg.toLowerCase();
    if (lower.contains('user already exists') ||
        lower.contains('duplicate') ||
        lower.contains('user_already_exists') ||
        lower.contains('email already registered')) {
      return 'Email này đã được đăng ký. Vui lòng sử dụng email khác hoặc đăng nhập.';
    }

    if (lower.contains('invalid email') || lower.contains('email is invalid')) {
      return 'Email không hợp lệ. Vui lòng kiểm tra lại.';
    }

    if (lower.contains('password') && lower.contains('weak')) {
      return 'Mật khẩu quá yếu. Vui lòng sử dụng mật khẩu mạnh hơn.';
    }

    if (lower.contains('network') ||
        lower.contains('socket') ||
        lower.contains('timeout')) {
      return 'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng và thử lại.';
    }

    return 'Đăng ký thất bại: $msg';
  }
}
