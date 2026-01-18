import 'dart:convert';
import 'dart:io' show File, FileMode, Platform;

import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ai_mls/presentation/viewmodels/student_dashboard_viewmodel.dart';
import 'package:ai_mls/presentation/views/assignment/assignment_list_screen.dart';
import 'package:ai_mls/presentation/views/class/student/student_class_list_screen.dart'; // Import trang mới
import 'package:ai_mls/presentation/views/dashboard/home/student_home_content_screen.dart';
import 'package:ai_mls/presentation/views/grading/scores_screen.dart';
import 'package:ai_mls/presentation/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/design_tokens.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../widgets/responsive/responsive_row.dart';
import '../../../widgets/responsive/responsive_text.dart';
import '../../../widgets/smart_marquee_text.dart';

// #region agent log
dynamic _sanitizeData(dynamic data) {
  if (data is Map) {
    return Map<String, dynamic>.fromEntries(
      data.entries.map(
        (e) => MapEntry(e.key.toString(), _sanitizeData(e.value)),
      ),
    );
  } else if (data is List) {
    return data.map((e) => _sanitizeData(e)).toList();
  } else if (data is double) {
    if (data.isInfinite) return 'Infinity';
    if (data.isNaN) return 'NaN';
    return data;
  } else if (data is num && !data.isFinite) {
    return 'Infinity';
  }
  return data;
}

void _log(
  String location,
  String message,
  Map<String, dynamic> data,
  String hypothesisId,
) {
  try {
    final logPath = Platform.isWindows
        ? r'd:\code\Flutter_Android\AI_LMS_PRD\.cursor\debug.log'
        : '/data/data/com.example.ai_mls/files/debug.log';
    final logFile = File(logPath);

    try {
      logFile.parent.createSync(recursive: true);
    } catch (_) {
      debugPrint('Log: $location - $message - ${_sanitizeData(data)}');
      return;
    }

    final sanitizedData = _sanitizeData(data);
    final logEntry = {
      'sessionId': 'debug-session',
      'runId': 'run1',
      'hypothesisId': hypothesisId,
      'location': location,
      'message': message,
      'data': sanitizedData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    final jsonString = jsonEncode(logEntry);
    final existingContent = logFile.existsSync()
        ? logFile.readAsStringSync()
        : '';
    logFile.writeAsStringSync(
      '$existingContent$jsonString\n',
      mode: FileMode.write,
    );
  } catch (e) {
    debugPrint('Log: $location - $message - ${_sanitizeData(data)}');
    debugPrint('Logging error: $e');
  }
}
// #endregion

class StudentDashboardScreen extends StatefulWidget {
  final Profile userProfile;

  const StudentDashboardScreen({super.key, required this.userProfile});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // Cập nhật danh sách trang
      const StudentHomeContentScreen(), // 0
      const StudentClassListScreen(), // 1
      const AssignmentListScreen(), // 2
      const ScoresScreen(), // 3
      const ProfileScreen(), // 4
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // #region agent log
    _log('student_dashboard_screen.dart:50', 'StudentDashboardScreen build', {
      'selectedIndex': _selectedIndex,
    }, 'G');
    // #endregion
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedIndex == 0
          ? AppBar(
              toolbarHeight: DesignComponents.appBarHeight,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Consumer<AuthViewModel>(
                builder: (context, authViewModel, _) {
                  final latestProfile =
                      authViewModel.userProfile ?? widget.userProfile;
                  return _buildHeader(context, latestProfile);
                },
              ),
            )
          : null,
      body: Consumer<StudentDashboardViewModel>(
        builder: (context, viewModel, _) {
          return RefreshIndicator(
            onRefresh: () => viewModel.refresh(showLoading: true),
            child: IndexedStack(index: _selectedIndex, children: _pages),
          );
        },
      ),
      // Xóa hoàn toàn FloatingActionButton và các thuộc tính liên quan
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader(BuildContext context, Profile profile) {
    final config = ResponsiveUtils.getLayoutConfig(context);
    return ResponsiveRow(
      children: [
        _UserProfileAvatar(profile: profile),
        SizedBox(width: config.itemSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ResponsiveText(
                'Chào buổi sáng,',
                style: const TextStyle(color: Colors.grey),
                fontSize: DesignTypography.bodySmallSize,
              ),
              SizedBox(height: DesignSpacing.xs),
              SmartMarqueeText(
                text: profile.fullName ?? 'user',
                style: DesignTypography.titleLarge,
              ),
            ],
          ),
        ),
        SizedBox(width: config.itemSpacing),
        Container(
          width: DesignComponents.avatarMedium,
          height: DesignComponents.avatarMedium,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DesignRadius.md),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
            color: DesignColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
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
                ),
                _buildBottomBarItem(
                  icon: Icons.class_outlined,
                  label: 'Lớp học',
                  index: 1,
                ),
                _buildBottomBarItem(
                  icon: Icons.assignment_outlined,
                  label: 'Bài tập',
                  index: 2,
                ),
                _buildBottomBarItem(
                  icon: Icons.leaderboard_outlined,
                  label: 'Điểm số',
                  index: 3,
                ),
                _buildBottomBarItem(
                  icon: Icons.person_outline,
                  label: 'Cá nhân',
                  index: 4,
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
  }) {
    final bool isActive = _selectedIndex == index;
    final Color color = isActive ? DesignColors.primary : Colors.grey;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      splashColor: DesignColors.primary.withOpacity(0.1),
      highlightColor: DesignColors.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? icon : icon, color: color),
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

class _UserProfileAvatar extends StatelessWidget {
  final Profile profile;
  const _UserProfileAvatar({required this.profile});

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty;
    final initials = (profile.fullName?.isNotEmpty ?? false)
        ? profile.fullName![0].toUpperCase()
        : '?';

    return CircleAvatar(
      radius: DesignComponents.avatarMedium / 2, // 20 = 40dp diameter
      backgroundColor: DesignColors.primary.withOpacity(0.1),
      backgroundImage: hasAvatar ? NetworkImage(profile.avatarUrl!) : null,
      child: !hasAvatar
          ? ResponsiveText(
              initials,
              style: const TextStyle(
                color: DesignColors.primary,
                fontWeight: FontWeight.bold,
              ),
              fontSize: 22,
            )
          : null,
    );
  }
}
