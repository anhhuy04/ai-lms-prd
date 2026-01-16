
import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/presentation/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';

/// Màn hình này đóng vai trò là "Layout" hoặc "Khung" chính cho Admin.
/// Nó chứa BottomNavigationBar và quản lý việc chuyển đổi giữa các trang con.
class AdminDashboardScreen extends StatefulWidget {
  final Profile userProfile;

  const AdminDashboardScreen({super.key, required this.userProfile});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  // Danh sách các trang con dành cho Admin
  final List<Widget> _pages = const [
    // Trang 0: Placeholder cho trang Tổng quan Admin
    Scaffold(body: Center(child: Text('Trang Tổng quan Admin'))),
    // Trang 1: Placeholder cho trang Quản lý người dùng
    Scaffold(body: Center(child: Text('Trang Quản lý Người dùng'))),
    // Trang 2: Placeholder cho trang Quản lý nội dung
    Scaffold(body: Center(child: Text('Trang Quản lý Nội dung'))),
    // Trang 3: Trang Hồ sơ cá nhân (tái sử dụng)
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_selectedIndex)),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Để hiển thị tất cả các nhãn
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Người dùng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Nội dung',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }

  // Hàm helper để lấy tiêu đề cho AppBar dựa trên tab được chọn
  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Tổng quan Admin';
      case 1:
        return 'Quản lý Người dùng';
      case 2:
        return 'Quản lý Nội dung';
      case 3:
        return 'Hồ sơ Cá nhân';
      default:
        return 'Admin Dashboard';
    }
  }
}
