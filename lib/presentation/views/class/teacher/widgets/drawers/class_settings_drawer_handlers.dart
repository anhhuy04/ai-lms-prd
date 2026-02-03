import 'package:ai_mls/domain/entities/class.dart';
import 'package:ai_mls/domain/entities/create_class_params.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/class_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Handlers cho các actions trong ClassSettingsDrawer (Teacher)
/// Tách riêng để giảm số dòng trong file chính
class ClassSettingsDrawerHandlers {
  /// Hiển thị dialog chia sẻ lớp học với QR code và link
  static void showShareClassDialog(
    BuildContext context,
    Class classItem,
    Map<String, dynamic> classSettings,
  ) {
    Navigator.pop(context);

    // Generate class link (in a real app, this would be a proper deep link)
    final classLink = 'https://app.example.com/join-class/${classItem.id}';
    final joinCode =
        classSettings['enrollment']?['qr_code']?['join_code'] ??
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
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_2, size: 80, color: Colors.grey[600]),
                    const SizedBox(height: 8),
                    Text(
                      'QR Code',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      joinCode,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        classLink,
                        style: Theme.of(context).textTheme.bodySmall,
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mã tham gia',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            joinCode,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
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
  static Future<void> handleDuplicateClass(
    BuildContext context,
    WidgetRef ref,
    Class classItem,
    Map<String, dynamic> classSettings,
  ) async {
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

    if (confirmed != true) return;
    if (!context.mounted) return;

    final teacherId = ref.read(currentUserIdProvider);

    if (teacherId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Không tìm thấy thông tin giáo viên'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    // Tạo class settings mới (copy từ class hiện tại nhưng reset một số fields)
    final newClassSettings = Map<String, dynamic>.from(classSettings);
    newClassSettings['enrollment'] = {
      'qr_code': {
        'is_active': false,
        'join_code': null,
        'expires_at': null,
        'require_approval':
            newClassSettings['enrollment']?['qr_code']?['require_approval'] ??
            true,
        'logo_enabled':
            newClassSettings['enrollment']?['qr_code']?['logo_enabled'] ?? true,
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

    final classNotifier = ref.read(classNotifierProvider.notifier);
    final newClass = await classNotifier.createClass(params);

    if (!context.mounted) return;
    Navigator.pop(context); // Close loading

    if (newClass != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tạo lớp học "${newClass.name}" thành công!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      // Navigate to new class detail or back
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không thể tạo lớp học mới'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  /// Xử lý xuất dữ liệu lớp học
  static Future<void> handleExportClassData(
    BuildContext context,
    WidgetRef ref,
    Class classItem,
  ) async {
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
    if (!context.mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Load class members for export
      final classNotifier = ref.read(classNotifierProvider.notifier);
      final approvedMembers = await classNotifier.getClassMembers(
        classItem.id,
        status: 'approved',
      );

      // Generate CSV data
      String csvData = '';
      String fileName = '';

      if (exportType == 'students' || exportType == 'all') {
        csvData += 'STT,ID học sinh,Trạng thái,Vai trò,Ngày tham gia\n';
        for (int i = 0; i < approvedMembers.length; i++) {
          final student = approvedMembers[i];
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

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      // Copy to clipboard (in production, use share_plus to save as file)
      Clipboard.setData(ClipboardData(text: csvData));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã sao chép dữ liệu vào clipboard\nFile: $fileName'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xuất dữ liệu: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
