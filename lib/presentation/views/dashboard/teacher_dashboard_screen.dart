import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/presentation/views/class/teacher/teacher_class_list_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/home/teacher_home_content_screen.dart';
import 'package:ai_mls/presentation/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/design_tokens.dart';
import '../../../presentation/views/assignment/teacher/teacher_assignment_hub_screen.dart';

/// Màn hình này đóng vai trò là "Layout" hoặc "Khung" chính cho Giáo viên.
class TeacherDashboardScreen extends ConsumerStatefulWidget {
  final Profile userProfile;
  final int initialTab;
  final Widget? child; // For ShellRoute support

  const TeacherDashboardScreen({
    super.key,
    required this.userProfile,
    this.initialTab = 0,
    this.child,
  });

  @override
  ConsumerState<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState
    extends ConsumerState<TeacherDashboardScreen> {
  late int _selectedIndex;

  // Cache pages list
  static final List<Widget> _pages = [
    const TeacherHomeContentScreen(), // 0
    const TeacherAssignmentHubScreen(), // 1
    const TeacherClassListScreen(), // 2
    const ProfileScreen(), // 3
  ];

  // Cache routes for ShellRoute navigation
  static final List<String> _routes = [
    AppRoute.teacherDashboardPath, // 0: Home
    AppRoute.teacherAssignmentHubPath, // 1: Assignments
    AppRoute.teacherClassListPath, // 2: Classes
    AppRoute.teacherProfilePath, // 3: Profile
  ];

  // Cache route-to-index map for faster lookup
  static final Map<String, int> _routeIndexMap = {
    AppRoute.teacherDashboardPath: 0,
    AppRoute.teacherAssignmentHubPath: 1,
    AppRoute.teacherClassListPath: 2,
    AppRoute.teacherProfilePath: 3,
  };

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    // Đặt status bar trong suốt hoàn toàn như FB, TikTok
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    // Không cần reset vì sẽ áp dụng cho toàn app
    super.dispose();
  }

  int _getSelectedIndexFromRoute(BuildContext context) {
    if (widget.child == null) {
      return _selectedIndex; // Legacy mode
    }

    // ShellRoute mode: determine index from current route
    try {
      final location = GoRouterState.of(context).matchedLocation;
      return _routeIndexMap[location] ?? 0;
    } catch (_) {
      return _selectedIndex; // Fallback
    }
  }

  void _onItemTapped(int index) {
    if (widget.child != null) {
      // ShellRoute mode: navigate to route
      if (index < _routes.length) {
        context.go(_routes[index]);
      }
    } else {
      // Legacy mode: update state
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSelectedIndex = _getSelectedIndexFromRoute(context);
    final isShellRoute = widget.child != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Hoàn toàn trong suốt
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
      backgroundColor: DesignColors.moonLight,
        extendBody: true, // Cho phép body extend lên status bar
        body: SafeArea(
          top: true,
          bottom: false,
          minimum: EdgeInsets.zero, // Không có minimum padding
          child: isShellRoute
          ? widget.child!
          : IndexedStack(index: _selectedIndex, children: _pages),
        ),
      bottomNavigationBar: _buildBottomBar(currentSelectedIndex),
      ),
    );
  }

  Widget _buildBottomBar(int currentSelectedIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [DesignElevation.level3],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: BottomAppBar(
          padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
          height: DesignComponents.bottomNavHeight,
          elevation: 0,
          color: Colors.transparent,
          child: SizedBox(
            height: DesignComponents.bottomNavHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomBarItem(
                  icon: Icons.home,
                  label: 'Trang chủ',
                  index: 0,
                  currentSelectedIndex: currentSelectedIndex,
                ),
                _buildBottomBarItem(
                  icon: Icons.assignment_turned_in_outlined,
                  label: 'Bài tập',
                  index: 1,
                  currentSelectedIndex: currentSelectedIndex,
                ),
                _buildBottomBarItem(
                  icon: Icons.school_outlined,
                  label: 'Lớp học',
                  index: 2,
                  currentSelectedIndex: currentSelectedIndex,
                ),
                _buildBottomBarItem(
                  icon: Icons.person_outline,
                  label: 'Cá nhân',
                  index: 3,
                  currentSelectedIndex: currentSelectedIndex,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBarItem({
    required IconData icon,
    required String label,
    required int index,
    required int currentSelectedIndex,
  }) {
    final isActive = currentSelectedIndex == index;
    final color = isActive ? DesignColors.primary : Colors.grey;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      splashColor: DesignColors.primary.withAlpha((0.1 * 255).round()),
      highlightColor: DesignColors.primary.withAlpha((0.05 * 255).round()),
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
