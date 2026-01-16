
import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/presentation/views/assignment/assignment_list_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/student_dashboard_screen.dart';
import 'package:ai_mls/presentation/views/grading/scores_screen.dart';
import 'package:ai_mls/presentation/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';

class MainLayoutScreen extends StatefulWidget {
  final Profile userProfile;
  const MainLayoutScreen({super.key, required this.userProfile});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách các trang
    _pages = [
      // Truyền userProfile vào StudentDashboardScreen
      StudentDashboardScreen(userProfile: widget.userProfile),
      const AssignmentListScreen(),
      const ScoresScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng IndexedStack để giữ trạng thái của các trang
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 20.0,
      shadowColor: Colors.black.withOpacity(0.05),
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomBarItem(icon: Icons.home, label: 'Trang chủ', index: 0),
            _buildBottomBarItem(icon: Icons.assignment_outlined, label: 'Bài tập', index: 1),
            const SizedBox(width: 40), // Khoảng trống cho FAB
            _buildBottomBarItem(icon: Icons.leaderboard_outlined, label: 'Điểm số', index: 2),
            _buildBottomBarItem(icon: Icons.person_outline, label: 'Cá nhân', index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBarItem({required IconData icon, required String label, required int index}) {
    final bool isActive = _selectedIndex == index;
    final Color color = isActive ? Theme.of(context).primaryColor : Colors.grey;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
      highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
