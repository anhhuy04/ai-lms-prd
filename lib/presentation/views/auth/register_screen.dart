import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/validation_utils.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  // Renamed class
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState(); // Renamed class
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Renamed class
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'student';
  String? _selectedGender;
  bool _obscurePassword = true; // Ẩn mật khẩu mặc định

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Validate inputs
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();

    // Email validation
    if (!ValidationUtils.isValidEmail(email)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email không hợp lệ. Vui lòng nhập email đúng định dạng.')),
        );
      }
      return;
    }

    // Password validation
    if (!ValidationUtils.isValidPassword(password)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mật khẩu phải có ít nhất 6 ký tự.')),
        );
      }
      return;
    }

    // Name validation
    if (fullName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập họ và tên.')),
        );
      }
      return;
    }

    // Phone validation
    if (phone.isNotEmpty && !ValidationUtils.isValidPhoneNumber(phone)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Số điện thoại phải có 10-11 chữ số và không chứa chữ cái.')),
        );
      }
      return;
    }

    // Gender validation
    if (_selectedGender == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn giới tính.')),
        );
      }
      return;
    }

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final successMessage = await authNotifier.signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: _selectedRole,
      phone: phone,
      gender: _selectedGender,
    );

    if (mounted && successMessage != null) {
      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));

      // Chuyển sang LoginScreen (GoRouter sẽ tự động điều hướng)
      // Note: initialEmail sẽ được xử lý qua query params nếu cần
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.goNamed(AppRoute.login);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.xxl),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Họ và tên'),
                ),
                SizedBox(height: DesignSpacing.lg),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: DesignSpacing.lg),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: DesignSpacing.lg),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
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
                SizedBox(height: DesignSpacing.lg),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  decoration: const InputDecoration(labelText: 'Giới tính'),
                  items: [
                    const DropdownMenuItem(value: 'male', child: Text('Nam')),
                    const DropdownMenuItem(value: 'female', child: Text('Nữ')),
                    const DropdownMenuItem(value: 'other', child: Text('Khác')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedGender = value;
                      });
                    }
                  },
                ),
                SizedBox(height: DesignSpacing.lg),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Vai trò'),
                  items: ['student', 'teacher', 'admin']
                      .map(
                        (role) => DropdownMenuItem(
                          value: role,
                          child: Text(
                            role == 'student'
                                ? 'Học sinh'
                                : role == 'teacher'
                                ? 'Giáo viên'
                                : 'Quản trị',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRole = value;
                      });
                    }
                  },
                ),
                SizedBox(height: DesignSpacing.xxxl),
                authState.isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _register,
                              child: const Text('Đăng ký'),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
