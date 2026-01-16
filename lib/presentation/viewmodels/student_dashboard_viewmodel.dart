import 'package:ai_mls/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ai_mls/presentation/viewmodels/mixins/refreshable_view_model.dart';
import 'package:flutter/material.dart';

/// ViewModel điều phối việc tải dữ liệu cho Student Dashboard.
/// Sử dụng `RefreshableViewModel` để có chức năng làm mới.
class StudentDashboardViewModel extends ChangeNotifier
    with RefreshableViewModel {
  final AuthViewModel _authViewModel;

  StudentDashboardViewModel({required AuthViewModel authViewModel})
    : _authViewModel = authViewModel;

  /// override: Định nghĩa logic lấy dữ liệu cụ thể cho Dashboard.
  @override
  Future<void> fetchData() async {
    // Gọi các ViewModel tương ứng để tải lại dữ liệu của chúng.
    await _authViewModel.checkCurrentUser();
    // Trong tương lai, bạn có thể thêm các lệnh gọi khác ở đây, ví dụ:
    // await _assignmentViewModel.fetchAssignments();
  }
}
