import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/domain/entities/create_class_params.dart';
import 'package:ai_mls/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ai_mls/presentation/viewmodels/class_viewmodel.dart';
import 'package:ai_mls/presentation/views/class/teacher/add_student_by_code_screen.dart';
import 'package:ai_mls/presentation/views/class/teacher/edit_class_screen.dart';
import 'package:ai_mls/presentation/views/class/teacher/student_list_screen.dart';
import 'package:ai_mls/routes/app_routes.dart';
import 'package:ai_mls/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:ai_mls/widgets/drawers/drawer_action_tile.dart';
import 'package:ai_mls/widgets/drawers/drawer_section_header.dart';
import 'package:ai_mls/widgets/drawers/drawer_toggle_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Drawer nội dung cài đặt lớp học
/// Hiển thị các tùy chọn quản lý và cài đặt cho lớp học
class ClassSettingsDrawer extends StatelessWidget {
  final ClassViewModel viewModel;
  final Class classItem;

  const ClassSettingsDrawer({
    super.key,
    required this.viewModel,
    required this.classItem,
  });

  /// Đọc settings từ classItem.classSettings
  Map<String, dynamic> get classSettings => classItem.classSettings;

  /// Helper getters để đọc settings
  bool get lockClass => classSettings['defaults']?['lock_class'] ?? false;

  bool get requireApproval =>
      classSettings['enrollment']?['qr_code']?['require_approval'] ?? true;

  int get pendingStudentRequests => viewModel.pendingCount;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Phần quản lý học sinh
          _buildStudentManagementSection(context),

          // Đường phân cách
          const Divider(height: 1, color: DesignColors.dividerLight),

          // Phần cài đặt lớp học
          _buildClassSettingsSection(context),

          // Phần hành động nguy hiểm (xóa lớp)
          _buildDangerZoneSection(context),

          // Padding cuối
          SizedBox(height: DesignSpacing.xxxl),
        ],
      ),
    );
  }

  /// Phần quản lý học sinh
  Widget _buildStudentManagementSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DrawerSectionHeader(
          title: 'QUẢN LÝ HỌC SINH',
          icon: Icons.people_alt_outlined,
        ),

        DrawerActionTile(
          icon: Icons.qr_code_2,
          title: 'Thêm học sinh bằng mã',
          subtitle: 'Chia sẻ mã lớp học',
          onTap: () {
            // Điều hướng đến màn hình thêm học sinh bằng mã
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddStudentByCodeScreen(
                  classId: classItem.id,
                  className: classItem.name,
                ),
              ),
            );
          },
          iconColor: DesignColors.primary,
        ),

        DrawerActionTile(
          icon: Icons.person_add_alt_1,
          title: 'Duyệt học sinh',
          subtitle: pendingStudentRequests > 0
              ? '$pendingStudentRequests yêu cầu đang chờ'
              : 'Không có yêu cầu mới',
          onTap: () {
            // Điều hướng đến màn hình danh sách học sinh
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentListScreen(
                  classId: classItem.id,
                  className: classItem.name,
                ),
              ),
            );
          },
          iconColor: DesignColors.primary,
          showNotificationDot: pendingStudentRequests > 0,
        ),
      ],
    );
  }

  /// Phần cài đặt lớp học
  Widget _buildClassSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DrawerSectionHeader(
          title: 'CÀI ĐẶT LỚP HỌC',
          icon: Icons.settings_outlined,
        ),

        DrawerActionTile(
          icon: Icons.edit_square,
          title: 'Chỉnh sửa thông tin',
          subtitle: 'Tên lớp, môn học, ảnh bìa',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditClassScreen(classItem: classItem),
              ),
            );
          },
          iconColor: DesignColors.textSecondary,
        ),

        DrawerActionTile(
          icon: Icons.share,
          title: 'Chia sẻ lớp học',
          subtitle: 'QR code và link lớp học',
          onTap: () {
            _showShareClassDialog(context);
          },
          iconColor: DesignColors.primary,
        ),

        DrawerActionTile(
          icon: Icons.copy,
          title: 'Sao chép lớp học',
          subtitle: 'Tạo lớp mới với thông tin tương tự',
          onTap: () {
            _handleDuplicateClass(context);
          },
          iconColor: DesignColors.textSecondary,
        ),

        DrawerActionTile(
          icon: Icons.download,
          title: 'Xuất dữ liệu lớp học',
          subtitle: 'Danh sách học sinh và bài tập',
          onTap: () {
            _handleExportClassData(context);
          },
          iconColor: DesignColors.textSecondary,
        ),

        DrawerToggleTile(
          icon: Icons.lock_outline,
          title: 'Khóa lớp học',
          subtitle: 'Ngăn học sinh mới tham gia',
          value: lockClass,
          onChanged: (value) async {
            final success = await viewModel.updateClassSetting(
              classItem.id,
              'defaults.lock_class',
              value,
            );
            if (!success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    viewModel.errorMessage ?? 'Không thể cập nhật cài đặt',
                  ),
                  backgroundColor: DesignColors.error,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  /// Hiển thị dialog chia sẻ lớp học với QR code và link
  void _showShareClassDialog(BuildContext context) {
    Navigator.pop(context);

    // Generate class link (in a real app, this would be a proper deep link)
    final classLink = 'https://app.example.com/join-class/${classItem.id}';
    final joinCode =
        classItem.classSettings['enrollment']?['qr_code']?['join_code'] ??
        classItem.id.substring(0, 8).toUpperCase();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chia sẻ lớp học'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // QR Code placeholder (in production, use qr_flutter package)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(DesignRadius.md),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_2, size: 80, color: Colors.grey[600]),
                    const SizedBox(height: 8),
                    Text(
                      'QR Code',
                      style: DesignTypography.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      joinCode,
                      style: DesignTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Class link
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        classLink,
                        style: DesignTypography.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: classLink));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã sao chép link vào clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Join code
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mã tham gia',
                            style: DesignTypography.caption.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            joinCode,
                            style: DesignTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: joinCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã sao chép mã vào clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              // In production, use share_plus package
              Clipboard.setData(
                ClipboardData(text: '$classLink\nMã: $joinCode'),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã sao chép thông tin lớp học'),
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Sao chép tất cả'),
          ),
        ],
      ),
    );
  }

  /// Xử lý sao chép lớp học
  Future<void> _handleDuplicateClass(BuildContext context) async {
    Navigator.pop(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sao chép lớp học'),
        content: Text(
          'Bạn có muốn tạo một lớp học mới với thông tin tương tự như "${classItem.name}"? '
          'Lớp mới sẽ không bao gồm học sinh và bài tập.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tạo lớp mới'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final authViewModel = context.read<AuthViewModel>();
    final teacherId = authViewModel.userProfile?.id;

    if (teacherId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy thông tin giáo viên'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
      return;
    }

    // Tạo class settings mới (copy từ class hiện tại nhưng reset một số fields)
    final newClassSettings = Map<String, dynamic>.from(classItem.classSettings);
    newClassSettings['enrollment'] = {
      'qr_code': {
        'is_active': false,
        'join_code': null,
        'expires_at': null,
        'require_approval':
            newClassSettings['enrollment']?['qr_code']?['require_approval'] ??
            true,
      },
      'manual_join_limit': newClassSettings['enrollment']?['manual_join_limit'],
    };

    final params = CreateClassParams(
      teacherId: teacherId,
      name: '${classItem.name} (Bản sao)',
      subject: classItem.subject,
      academicYear: classItem.academicYear,
      description: classItem.description,
      classSettings: newClassSettings,
    );

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final newClass = await viewModel.createClass(params);

    if (context.mounted) {
      Navigator.pop(context); // Close loading
    }

    if (newClass != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tạo lớp học "${newClass.name}" thành công!'),
          backgroundColor: Colors.green[600],
        ),
      );
      // Navigate to new class detail or back
      Navigator.pop(context);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Không thể tạo lớp học mới'),
          backgroundColor: DesignColors.error,
        ),
      );
    }
  }

  /// Xử lý xuất dữ liệu lớp học
  Future<void> _handleExportClassData(BuildContext context) async {
    Navigator.pop(context);

    // Show options dialog
    final exportType = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xuất dữ liệu lớp học'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Danh sách học sinh'),
              subtitle: const Text('Xuất danh sách học sinh (CSV)'),
              onTap: () => Navigator.pop(context, 'students'),
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Danh sách bài tập'),
              subtitle: const Text('Xuất danh sách bài tập (CSV)'),
              onTap: () => Navigator.pop(context, 'assignments'),
            ),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('Tất cả dữ liệu'),
              subtitle: const Text('Xuất cả học sinh và bài tập'),
              onTap: () => Navigator.pop(context, 'all'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );

    if (exportType == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Load class members for export
      await viewModel.loadClassMembers(classItem.id);

      // Generate CSV data
      String csvData = '';
      String fileName = '';

      if (exportType == 'students' || exportType == 'all') {
        final students = viewModel.approvedMembers;
        csvData += 'STT,ID học sinh,Trạng thái,Vai trò,Ngày tham gia\n';
        for (int i = 0; i < students.length; i++) {
          final student = students[i];
          csvData +=
              '${i + 1},"${student.studentId}","${student.status}","${student.role ?? "N/A"}","${student.joinedAt?.toIso8601String() ?? "N/A"}"\n';
        }
        fileName =
            '${classItem.name}_hoc_sinh_${DateTime.now().millisecondsSinceEpoch}.csv';
      }

      if (exportType == 'assignments' || exportType == 'all') {
        if (exportType == 'all' && csvData.isNotEmpty) {
          csvData += '\n\n';
        }
        // Note: Assignment data would come from AssignmentRepository
        // For now, we'll create a placeholder
        csvData += 'STT,Tên bài tập,Trạng thái,Hạn nộp\n';
        csvData += '1,"Bài tập mẫu","Đang mở","N/A"\n';
        if (exportType == 'all') {
          fileName =
              '${classItem.name}_tat_ca_${DateTime.now().millisecondsSinceEpoch}.csv';
        } else {
          fileName =
              '${classItem.name}_bai_tap_${DateTime.now().millisecondsSinceEpoch}.csv';
        }
      }

      if (context.mounted) {
        Navigator.pop(context); // Close loading
      }

      // Copy to clipboard (in production, use share_plus to save as file)
      Clipboard.setData(ClipboardData(text: csvData));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã sao chép dữ liệu vào clipboard\nFile: $fileName'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xuất dữ liệu: $e'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    }
  }

  /// Phần hành động nguy hiểm
  Widget _buildDangerZoneSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.lg,
            vertical: DesignSpacing.md,
          ),
          child: Text(
            'NGUY HIỂM',
            style: DesignTypography.labelMedium.copyWith(
              color: DesignColors.error,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),

        DrawerActionTile(
          icon: Icons.delete_outline,
          title: 'Xóa lớp học',
          subtitle: 'Hành động này không thể hoàn tác',
          onTap: () => _handleDeleteClass(context),
          iconColor: DesignColors.error,
          showChevron: false,
        ),
      ],
    );
  }

  /// Xử lý xóa lớp học
  /// Hiển thị confirmation dialog, xóa lớp, và điều hướng về trang chủ
  Future<void> _handleDeleteClass(BuildContext context) async {
    try {
      // Bước 1: Hiển thị dialog xác nhận
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => DeleteConfirmationDialog(
          classItem: classItem,
          studentCount: viewModel.approvedCount,
          pendingCount: viewModel.pendingCount,
        ),
      );

      if (confirmed != true) {
        print('🟡 [UI] deleteClass: User đã hủy thao tác xóa');
        return;
      }

      // Bước 2: Lưu context và đóng drawer
      final drawerContext = context;
      if (drawerContext.mounted) {
        Navigator.pop(drawerContext);
      }

      // Bước 3: Delay để drawer pop hoàn tất
      await Future.delayed(const Duration(milliseconds: 100));

      // Bước 4: Hiển thị loading dialog
      if (!drawerContext.mounted) {
        print('🔴 [UI] deleteClass: Context của drawer không còn valid');
        return;
      }

      showDialog(
        context: drawerContext,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Bước 5: Thực hiện xóa lớp
      print('🟢 [UI] deleteClass: Bắt đầu xóa lớp học ${classItem.id}');
      print('🟢 [UI] deleteClass: Tên lớp: ${classItem.name}');

      final success = await viewModel.deleteClass(classItem.id);

      // Bước 6: Đóng loading dialog
      if (drawerContext.mounted) {
        Navigator.pop(drawerContext);
        print('✅ [UI] deleteClass: Đã đóng loading dialog');
      }

      // Bước 7: Xử lý kết quả
      if (success) {
        print('✅ [UI] deleteClass: Xóa thành công');
        await Future.delayed(const Duration(milliseconds: 300));

        // Schedule navigation after current frame to avoid context issues
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            // Pop drawer (nếu vẫn còn)
            if (drawerContext.mounted) {
              Navigator.pop(drawerContext);
              print('✅ [NAVIGATION] Drawer popped');
            }

            // Refresh data trong background
            print('🔄 [NAVIGATION] Starting background refresh...');
            viewModel
                .refresh()
                .then((_) {
                  print('✅ [NAVIGATION] Background refresh completed');
                })
                .catchError((e) {
                  print('❌ [NAVIGATION] Background refresh failed: $e');
                });

            // Navigate về danh sách lớp học using named route (safer approach)
            await Future.delayed(const Duration(milliseconds: 200));

            print('🧭 [NAVIGATION] Navigating back to teacher classes list...');

            // Use named route navigation to avoid context issues
            if (drawerContext.mounted) {
              try {
                // Navigate to teacher classes screen and remove all previous routes
                Navigator.of(drawerContext).pushNamedAndRemoveUntil(
                  AppRoutes.teacherClasses,
                  (route) => false, // Remove all previous routes
                );
                print(
                  '✅ [NAVIGATION] Successfully navigated to teacher classes list',
                );
              } catch (e) {
                print('❌ [NAVIGATION] Named route navigation failed: $e');
                // Fallback: try to pop back to previous screen
                try {
                  Navigator.of(drawerContext).pop();
                  print('✅ [NAVIGATION] Fallback pop navigation successful');
                } catch (e2) {
                  print('❌ [NAVIGATION] All navigation attempts failed: $e2');
                }
              }
            } else {
              print('⚠️ [NAVIGATION] Context not mounted, skipping navigation');
            }
          } catch (e) {
            print('❌ [NAVIGATION] Navigation failed with exception: $e');
          }
        });

        // Schedule success message after navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            if (drawerContext.mounted) {
              ScaffoldMessenger.of(drawerContext).showSnackBar(
                const SnackBar(
                  content: Text('✅ Đã xóa lớp học thành công'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            print('⚠️ [UI] Could not show success message: $e');
          }
        });

        // Schedule error message if deletion failed
        if (!success) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorSnackBar(drawerContext, viewModel.errorMessage);
          });
        }
      } else {
        // Schedule error message for deletion failure
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showErrorSnackBar(drawerContext, viewModel.errorMessage);
        });
      }
    } catch (e, stackTrace) {
      print('🔴 [UI] deleteClass: Exception: $e');
      print('🔴 [UI] deleteClass: StackTrace: $stackTrace');

      if (context.mounted) {
        Navigator.pop(context); // Close loading if still open
      }

      if (context.mounted) {
        _showErrorSnackBar(context, 'Lỗi không mong đợi: $e');
      }
    }
  }

  /// Hiển thị SnackBar lỗi với nút chi tiết
  void _showErrorSnackBar(BuildContext context, String? errorMessage) {
    if (!context.mounted) return;

    final errorMsg = errorMessage ?? 'Không thể xóa lớp học';
    print('🔴 [UI] deleteClass: Xóa thất bại - $errorMsg');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $errorMsg'),
        backgroundColor: DesignColors.error,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Chi tiết',
          textColor: Colors.white,
          onPressed: () {
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Chi tiết lỗi'),
                  content: SingleChildScrollView(
                    child: Text(errorMsg, style: DesignTypography.bodySmall),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
