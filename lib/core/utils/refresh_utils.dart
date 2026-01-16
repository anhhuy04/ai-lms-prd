
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_mls/presentation/viewmodels/auth_viewmodel.dart';

/// Hàm xử lý làm mới chung cho các trang dashboard.
///
/// Tải lại dữ liệu người dùng và có thể mở rộng để tải lại các dữ liệu khác.
Future<void> handleDashboardRefresh(BuildContext context) async {
  // Gọi ViewModel để tải lại dữ liệu người dùng.
  // Dùng `listen: false` vì chúng ta đang ở trong một callback, không cần build lại widget tại đây.
  await Provider.of<AuthViewModel>(context, listen: false).checkCurrentUser();

  // Ví dụ mở rộng trong tương lai:
  // await Provider.of<AssignmentViewModel>(context, listen: false).fetchAssignments();
  // await Provider.of<ScoresViewModel>(context, listen: false).fetchScores();
}
