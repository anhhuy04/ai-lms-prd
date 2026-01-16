
import 'package:ai_mls/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ai_mls/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin người dùng từ AuthViewModel
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ Cá nhân'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (user != null)
            ListTile(
              title: const Text('Họ và tên'),
              subtitle: Text(user.fullName ?? 'Chưa cập nhật'),
            ),
          if (user != null)
            ListTile(
              title: const Text('Vai trò'),
              subtitle: Text(user.role),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await authViewModel.signOut();
              // Điều hướng về trang đăng nhập và xóa hết các màn hình cũ
              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
