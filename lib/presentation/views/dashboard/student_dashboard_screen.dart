import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/presentation/views/assignment/assignment_list_screen.dart';
import 'package:ai_mls/presentation/views/class/student/student_class_list_screen.dart';
import 'package:ai_mls/presentation/views/dashboard/home/student_home_content_screen.dart';
import 'package:ai_mls/presentation/views/grading/scores_screen.dart';
import 'package:ai_mls/presentation/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/design_tokens.dart';
import '../../../core/routes/route_constants.dart';
import '../../../widgets/responsive/responsive_text.dart';

class StudentDashboardScreen extends ConsumerStatefulWidget {
  final Profile userProfile;
  final Widget? child; // For ShellRoute support

  const StudentDashboardScreen({
    super.key,
    required this.userProfile,
    this.child,
  });

  @override
  ConsumerState<StudentDashboardScreen> createState() =>
      _StudentDashboardScreenState();
}

class _StudentDashboardScreenState
    extends ConsumerState<StudentDashboardScreen> {
  int _selectedIndex = 0;

  // Cache pages list
  static final List<Widget> _pages = [
    const StudentHomeContentScreen(), // 0
    const StudentClassListScreen(), // 1
    const AssignmentListScreen(), // 2
    const ScoresScreen(), // 3
    const ProfileScreen(), // 4
  ];

  // Cache routes map for ShellRoute navigation
  static final List<String> _routes = [
    AppRoute.studentDashboardPath, // 0: Home
    AppRoute.studentClassListPath, // 1: Classes
    AppRoute.studentAssignmentListPath, // 2: Assignments
    AppRoute.studentScoresPath, // 3: Scores
    AppRoute.studentProfilePath, // 4: Profile
  ];

  // Cache route-to-index map for faster lookup
  static final Map<String, int> _routeIndexMap = {
    AppRoute.studentDashboardPath: 0,
    AppRoute.studentClassListPath: 1,
    AppRoute.studentAssignmentListPath: 2,
    AppRoute.studentScoresPath: 3,
    AppRoute.studentProfilePath: 4,
  };

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: isShellRoute
          ? widget.child!
          : IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildBottomBar(currentSelectedIndex),
    );
  }

  Widget _buildBottomBar(int currentSelectedIndex) {
    // Container cung cấp top-only shadow (offset y âm) để bóng chiếu lên trên
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        // (tuỳ chọn) bo góc ở phía trên nếu muốn shadow mềm hơn
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [DesignElevation.level3],
      ),
      child: ClipRRect(
        // đảm bảo borderRadius cắt đúng cho nội dung
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: BottomAppBar(
          padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
          height: DesignComponents.bottomNavHeight,
          shape: const CircularNotchedRectangle(), // giữ notch nếu dùng FAB
          notchMargin: 8.0,
          elevation: 0, // tắt elevation gốc để chỉ dùng shadow của Container
          color: Colors.transparent,
          child: SizedBox(
            height: DesignComponents.bottomNavHeight, // 56dp
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
                  icon: Icons.class_outlined,
                  label: 'Lớp học',
                  index: 1,
                  currentSelectedIndex: currentSelectedIndex,
                ),
                _buildBottomBarItem(
                  icon: Icons.assignment_outlined,
                  label: 'Bài tập',
                  index: 2,
                  currentSelectedIndex: currentSelectedIndex,
                ),
                _buildBottomBarItem(
                  icon: Icons.leaderboard_outlined,
                  label: 'Điểm số',
                  index: 3,
                  currentSelectedIndex: currentSelectedIndex,
                ),
                _buildBottomBarItem(
                  icon: Icons.person_outline,
                  label: 'Cá nhân',
                  index: 4,
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
      splashColor: DesignColors.primary.withValues(alpha: 0.1),
      highlightColor: DesignColors.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            ResponsiveText(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
              fontSize: DesignTypography.labelSmallSize,
            ),
          ],
        ),
      ),
    );
  }
}
