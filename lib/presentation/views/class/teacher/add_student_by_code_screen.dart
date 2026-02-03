import 'dart:math';

import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/core/utils/qr_helper.dart';
import 'package:ai_mls/presentation/providers/class_notifier.dart';
import 'package:ai_mls/widgets/dialogs/warning_dialog.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình thêm học sinh bằng mã QR
/// Hiển thị mã QR và các tùy chọn cài đặt cho lớp học
class AddStudentByCodeScreen extends ConsumerStatefulWidget {
  final String classId;
  final String className;

  const AddStudentByCodeScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  ConsumerState<AddStudentByCodeScreen> createState() =>
      _AddStudentByCodeScreenState();
}

class _AddStudentByCodeScreenState
    extends ConsumerState<AddStudentByCodeScreen> {
  // Trạng thái các công tắc
  bool _qrActive = false;
  bool _requireApproval = true;
  bool _expireEnabled = false;
  DateTime? _expireDate;
  bool _isLoading = false;
  bool _isSaving = false;

  // Mã lớp học (sẽ load từ database)
  String? _classCode;

  // Giới hạn số học sinh tham gia thủ công
  bool _manualJoinLimitEnabled = false;
  int? _manualJoinLimit;
  final TextEditingController _manualJoinLimitController =
      TextEditingController();

  // QR Code với Logo
  bool _qrLogoEnabled = true; // Mặc định bật logo

  // Track original values để detect unsaved changes
  bool _originalQrActive = false;
  bool _originalRequireApproval = true;
  bool _originalExpireEnabled = false;
  DateTime? _originalExpireDate;
  String? _originalClassCode;
  bool _originalManualJoinLimitEnabled = false;
  int? _originalManualJoinLimit;
  bool _originalQrLogoEnabled = true;

  @override
  void initState() {
    super.initState();
    // Load class details khi màn hình khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClassSettings();
    });
  }

  @override
  void dispose() {
    _manualJoinLimitController.dispose();
    super.dispose();
  }

  /// Load class settings từ database
  Future<void> _loadClassSettings() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final classNotifier = ref.read(classNotifierProvider.notifier);

      // Load class details nếu chưa có
      if (classNotifier.selectedClass?.id != widget.classId) {
        await classNotifier.loadClassDetails(widget.classId);
      }

      final classItem = classNotifier.selectedClass;
      if (classItem == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy thông tin lớp học'),
              backgroundColor: DesignColors.error,
            ),
          );
        }
        return;
      }

      // Load settings từ classSettings
      final classSettings = classItem.classSettings ?? <String, dynamic>{};
      final enrollment = classSettings['enrollment'] as Map<String, dynamic>?;
      final qrCode = enrollment?['qr_code'] as Map<String, dynamic>?;

      if (qrCode != null) {
        setState(() {
          _qrActive = qrCode['is_active'] as bool? ?? false;
          _requireApproval = qrCode['require_approval'] as bool? ?? true;
          _classCode = qrCode['join_code'] as String?;

          // Load expires_at
          final expiresAtStr = qrCode['expires_at'] as String?;
          if (expiresAtStr != null && expiresAtStr.isNotEmpty) {
            try {
              _expireDate = DateTime.parse(expiresAtStr).toLocal();
              _expireEnabled = true;
            } catch (e) {
              AppLogger.warning('Invalid expires_at format: $expiresAtStr');
            }
          }
        });
      }

      // Load manual_join_limit
      final manualJoinLimit = enrollment?['manual_join_limit'] as int?;
      setState(() {
        _manualJoinLimitEnabled = manualJoinLimit != null;
        _manualJoinLimit = manualJoinLimit;
        _manualJoinLimitController.text = manualJoinLimit != null
            ? manualJoinLimit.toString()
            : '';
      });

      // Load QR logo setting (mặc định true nếu chưa có)
      final qrLogoEnabled = qrCode?['logo_enabled'] as bool?;
      setState(() {
        _qrLogoEnabled = qrLogoEnabled ?? true;
      });

      // Save original values để track unsaved changes
      _originalQrActive = _qrActive;
      _originalRequireApproval = _requireApproval;
      _originalExpireEnabled = _expireEnabled;
      _originalExpireDate = _expireDate;
      _originalClassCode = _classCode;
      _originalManualJoinLimitEnabled = _manualJoinLimitEnabled;
      _originalManualJoinLimit = _manualJoinLimit;
      _originalQrLogoEnabled = _qrLogoEnabled;

      // Generate join code nếu chưa có
      if (_classCode == null || _classCode!.isEmpty) {
        _generateNewCode();
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [ADD STUDENT] Error loading class settings: $e',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải cài đặt: ${e.toString()}'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Kiểm tra xem có thay đổi chưa lưu không
  bool _hasUnsavedChanges() {
    return _qrActive != _originalQrActive ||
        _requireApproval != _originalRequireApproval ||
        _expireEnabled != _originalExpireEnabled ||
        _expireDate != _originalExpireDate ||
        _classCode != _originalClassCode ||
        _manualJoinLimitEnabled != _originalManualJoinLimitEnabled ||
        _manualJoinLimit != _originalManualJoinLimit ||
        _qrLogoEnabled != _originalQrLogoEnabled;
  }

  /// Xử lý khi user bấm back button
  Future<bool> _handleBackButton() async {
    if (!_hasUnsavedChanges()) {
      return true; // Cho phép back
    }

    // Hiển thị dialog xác nhận
    // result == true: User chọn "Lưu thay đổi" → lưu rồi mới back
    // result == false: User chọn "Không lưu" → cho phép back
    // result == null: User bấm ra ngoài dialog (hủy) → không cho back (ở lại trang)
    final result = await WarningDialog.showUnsavedChanges(context: context);

    if (result == true) {
      // User chọn "Lưu thay đổi" → lưu trước khi back
      await _saveSettings();
      // Chỉ cho phép back nếu lưu thành công (không còn thay đổi)
      return !_hasUnsavedChanges();
    } else if (result == false) {
      // User chọn "Không lưu" → cho phép back
      return true;
    } else {
      // User bấm ra ngoài dialog (hủy) → không cho back (ở lại trang)
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handleBackButton();
        if (!context.mounted) return;
        if (shouldPop) context.pop();
      },
      child: Scaffold(
        backgroundColor: DesignColors.moonLight,
        appBar: _buildAppBar(),
        body: _isLoading
            ? const ShimmerDashboardLoading()
            : Column(
                children: [
                  // Phần hiển thị mã QR
                  _buildQRCodeSection(),

                  // Các tùy chọn cài đặt
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Các công tắc và cài đặt
                          _buildSettingsSection(),

                          // Nút hành động
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// AppBar với nút quay lại, tiêu đề và nút lưu
  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: DesignIcons.mdSize,
          color: Theme.of(context).iconTheme.color,
        ),
        onPressed: () async {
          // Xử lý back button tương tự PopScope
          final shouldPop = await _handleBackButton();
          if (!mounted) return;
          if (!shouldPop) return;
          if (context.canPop()) {
            context.pop();
            return;
          }
          // Fallback: navigate về class detail nếu không thể pop
          context.goNamed(
            AppRoute.teacherClassDetail,
            pathParameters: {'classId': widget.classId},
          );
        },
      ),
      title: Text(
        'Thêm Học sinh bằng mã',
        style: DesignTypography.titleLarge.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          IconButton(
            icon: Icon(
              Icons.save,
              size: DesignIcons.mdSize,
              color: DesignColors.primary,
            ),
            onPressed: _handleSaveButton,
          ),
      ],
    );
  }

  /// Phần hiển thị mã QR và mã lớp học
  Widget _buildQRCodeSection() {
    // Generate QR data từ join code
    final qrData = _classCode != null && _classCode!.isNotEmpty
        ? '${widget.classId}:$_classCode'
        : '';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.md,
      ),
      child: Column(
        children: [
          // Mã QR (có thể có logo nếu enabled)
          qrData.isNotEmpty
              ? _qrLogoEnabled
                    ? QrHelper.buildQrWithLogo(
                        qrData,
                        const AssetImage('assets/icon/logo_app.png'),
                        size: 200,
                      )
                    : QrHelper.buildPrettyQr(qrData, size: 200)
              : SizedBox(
                  width: 200,
                  height: 200,
                  child: Center(
                    child: Icon(
                      Icons.qr_code_2,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  ),
                ),

          SizedBox(height: DesignSpacing.lg),

          // Mã lớp học (có thể tap để copy)
          GestureDetector(
            onTap: _classCode != null && _classCode!.isNotEmpty
                ? _copyClassCode
                : null,
            child: Column(
              children: [
                Text(
                  'Mã lớp học',
                  style: DesignTypography.bodySmall.copyWith(
                    color: DesignColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: DesignSpacing.xs),
                Text(
                  _classCode ?? 'Chưa có mã',
                  style: DesignTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                    color: _classCode != null && _classCode!.isNotEmpty
                        ? DesignColors.primary
                        : DesignColors.textSecondary,
                  ),
                ),
                if (_classCode != null && _classCode!.isNotEmpty) ...[
                  SizedBox(height: DesignSpacing.xs),
                  Text(
                    'Nhấn để sao chép',
                    style: DesignTypography.caption.copyWith(
                      color: DesignColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Phần cài đặt các tùy chọn
  Widget _buildSettingsSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mã QR & Hoạt động
          _buildSettingItem(
            title: 'Mã QR & Hoạt động',
            subtitle: 'Cho phép tham gia bằng mã này',
            value: _qrActive,
            onChanged: (value) {
              setState(() {
                _qrActive = value;
              });
            },
          ),

          SizedBox(height: DesignSpacing.md),

          // QR Code với Logo
          _buildSettingItem(
            title: 'Hiển thị logo trên QR code',
            subtitle: 'Thêm logo ứng dụng vào giữa mã QR',
            value: _qrLogoEnabled,
            onChanged: (value) {
              setState(() {
                _qrLogoEnabled = value;
              });
            },
          ),

          SizedBox(height: DesignSpacing.md),

          // Yêu cầu duyệt
          _buildSettingItem(
            title: 'Yêu cầu duyệt',
            subtitle: 'Giáo viên xác nhận khi tham gia',
            value: _requireApproval,
            onChanged: (value) {
              setState(() {
                _requireApproval = value;
              });
            },
          ),

          SizedBox(height: DesignSpacing.md),

          // Thời gian hết hạn mã
          Container(
            padding: EdgeInsets.all(DesignSpacing.md),
            decoration: BoxDecoration(
              color: DesignColors.moonMedium,
              borderRadius: BorderRadius.circular(DesignRadius.md),
              border: Border.all(color: DesignColors.dividerLight, width: 1),
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  title: 'Thời gian hết hạn mã',
                  subtitle: 'Tự động vô hiệu hóa mã',
                  value: _expireEnabled,
                  onChanged: (value) {
                    setState(() {
                      _expireEnabled = value;
                      if (!value) {
                        _expireDate = null;
                      }
                    });
                  },
                ),

                if (_expireEnabled)
                  Padding(
                    padding: EdgeInsets.only(top: DesignSpacing.md),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Chọn thời gian hết hạn',
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: DesignColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.md),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: DesignSpacing.md,
                          vertical: DesignSpacing.sm,
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectExpireDate(context),
                      controller: TextEditingController(
                        text: _expireDate != null
                            ? '${_expireDate!.day}/${_expireDate!.month}/${_expireDate!.year} ${_expireDate!.hour.toString().padLeft(2, '0')}:${_expireDate!.minute.toString().padLeft(2, '0')}'
                            : '',
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: DesignSpacing.md),

          // Giới hạn số học sinh tham gia thủ công
          Container(
            padding: EdgeInsets.all(DesignSpacing.md),
            decoration: BoxDecoration(
              color: DesignColors.moonMedium,
              borderRadius: BorderRadius.circular(DesignRadius.md),
              border: Border.all(color: DesignColors.dividerLight, width: 1),
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  title: 'Giới hạn số học sinh',
                  subtitle:
                      'Số lượng học sinh tối đa có thể tham gia bằng mã QR',
                  value: _manualJoinLimitEnabled,
                  onChanged: (value) {
                    setState(() {
                      _manualJoinLimitEnabled = value;
                      if (!value) {
                        _manualJoinLimit = null;
                        _manualJoinLimitController.clear();
                      }
                    });
                  },
                ),
                if (_manualJoinLimitEnabled)
                  Padding(
                    padding: EdgeInsets.only(top: DesignSpacing.md),
                    child: TextField(
                      controller: _manualJoinLimitController,
                      decoration: InputDecoration(
                        labelText: 'Nhập số lượng',
                        hintText: 'Ví dụ: 50',
                        prefixIcon: Icon(
                          Icons.people_outline,
                          color: DesignColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.md),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: DesignSpacing.md,
                          vertical: DesignSpacing.sm,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _manualJoinLimit = value.isEmpty
                              ? null
                              : int.tryParse(value);
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Một mục cài đặt với công tắc
  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: DesignTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: DesignSpacing.xs),
              Text(
                subtitle,
                style: DesignTypography.bodySmall.copyWith(
                  color: DesignColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Transform.scale(
          scale: 0.7,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: DesignColors.primary,
            inactiveThumbColor: DesignColors.textSecondary,
            inactiveTrackColor: DesignColors.moonMedium,
          ),
        ),
      ],
    );
  }

  /// Nút hành động
  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: ElevatedButton.icon(
        icon: Icon(Icons.refresh, size: DesignIcons.mdSize),
        label: const Text('Tạo mã mới'),
        onPressed: _generateNewCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignColors.white,
          foregroundColor: DesignColors.primary,
          side: BorderSide(color: DesignColors.primary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.md),
          ),
          padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
      // Tạm thời ẩn nút "Chia sẻ mã"
      // TODO: Bật lại khi cần thiết
      // SizedBox(width: DesignSpacing.md),
      // Expanded(
      //   child: ElevatedButton.icon(
      //     icon: Icon(Icons.share, size: DesignIcons.mdSize),
      //     label: const Text('Chia sẻ mã'),
      //     onPressed: _classCode != null && _classCode!.isNotEmpty
      //         ? _shareClassCode
      //         : null,
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: DesignColors.primary,
      //       foregroundColor: Colors.white,
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(DesignRadius.md),
      //       ),
      //       padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
      //       elevation: 3,
      //       shadowColor: DesignColors.primary.withValues(alpha: 0.3),
      //     ),
      //   ),
      // ),
    );
  }

  /// Chọn ngày hết hạn
  Future<void> _selectExpireDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expireDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (!context.mounted) return;
    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: _expireDate != null
            ? TimeOfDay.fromDateTime(_expireDate!)
            : TimeOfDay.now(),
      );

      if (!context.mounted) return;
      if (timePicked != null) {
        setState(() {
          _expireDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
        });
      }
    }
  }

  /// Sao chép mã lớp học
  void _copyClassCode() {
    if (_classCode == null || _classCode!.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _classCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép mã lớp học: $_classCode'),
        backgroundColor: DesignColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Validate join code format (6 ký tự, A-Z0-9)
  bool _validateJoinCodeFormat(String code) {
    if (code.length != 6) return false;
    final regex = RegExp(r'^[A-Z0-9]{6}$');
    return regex.hasMatch(code);
  }

  /// Generate và validate join code (auto-retry nếu trùng)
  Future<String> _generateValidJoinCode({int maxRetries = 5}) async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    for (int i = 0; i < maxRetries; i++) {
      // Generate random 6-character code
      final newCode = String.fromCharCodes(
        Iterable.generate(
          6,
          (_) => chars.codeUnitAt(random.nextInt(chars.length)),
        ),
      );

      // Validate format
      if (!_validateJoinCodeFormat(newCode)) {
        AppLogger.warning('Generated invalid code format: $newCode');
        continue;
      }

      // Check unique
      final classNotifier = ref.read(classNotifierProvider.notifier);
      final exists = await classNotifier.checkJoinCodeExists(
        newCode,
        excludeClassId: widget.classId,
      );

      if (!exists) {
        return newCode; // Code hợp lệ và unique
      }

      AppLogger.debug('Join code $newCode đã tồn tại, thử lại...');
    }

    // Nếu sau maxRetries vẫn không tìm được code unique
    // Trả về code cuối cùng (có thể trùng, nhưng ít nhất format đúng)
    final fallbackCode = String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
    AppLogger.warning(
      'Không thể tạo code unique sau $maxRetries lần thử, sử dụng: $fallbackCode',
    );
    return fallbackCode;
  }

  /// Xử lý khi user bấm nút lưu trên header
  Future<void> _handleSaveButton() async {
    // Kiểm tra xem có thay đổi không
    if (!_hasUnsavedChanges()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không có thay đổi nào để lưu'),
            backgroundColor: DesignColors.info,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Hiển thị dialog xác nhận lưu
    final result = await WarningDialog.showSaveConfirmation(
      context: context,
      title: 'Xác nhận lưu',
      message: 'Bạn có chắc chắn muốn lưu các thay đổi?',
    );

    // result == true: User chọn "Lưu" → thực hiện lưu
    // result == false hoặc null: User chọn "Hủy" hoặc đóng dialog → không làm gì
    if (result == true) {
      await _saveSettings();
    }
  }

  /// Tạo mã mới
  Future<void> _generateNewCode() async {
    try {
      // Generate và validate code
      final newCode = await _generateValidJoinCode();

      setState(() {
        _classCode = newCode;
      });

      // Auto-save khi generate mã mới
      await _saveSettings();
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [ADD STUDENT] Error generating new code: $e',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tạo mã mới: ${e.toString()}'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    }
  }

  /// Chia sẻ mã lớp học
  /// TODO: Bật lại khi cần thiết
  // void _shareClassCode() {
  //   if (_classCode == null || _classCode!.isEmpty) return;

  //   // Copy to clipboard (có thể dùng share_plus package sau)
  //   final shareText = 'Mã tham gia lớp học "${widget.className}": $_classCode';
  //   Clipboard.setData(ClipboardData(text: shareText));

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Đã sao chép thông tin lớp học vào clipboard'),
  //       backgroundColor: DesignColors.primary,
  //       duration: const Duration(seconds: 2),
  //     ),
  //   );
  // }

  /// Lưu cài đặt
  Future<void> _saveSettings() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final classNotifier = ref.read(classNotifierProvider.notifier);

      // Lấy class hiện tại
      final currentClass = classNotifier.selectedClass;
      if (currentClass == null || currentClass.id != widget.classId) {
        await classNotifier.loadClassDetails(widget.classId);
      }

      final classItem = classNotifier.selectedClass;
      if (classItem == null) {
        throw Exception('Không tìm thấy thông tin lớp học');
      }

      // Build new classSettings với tất cả QR code settings
      final classSettings = Map<String, dynamic>.from(
        classItem.classSettings ?? {},
      );

      // Đảm bảo cấu trúc enrollment.qr_code tồn tại
      if (classSettings['enrollment'] == null) {
        classSettings['enrollment'] = <String, dynamic>{};
      }
      if (classSettings['enrollment'] is! Map<String, dynamic>) {
        classSettings['enrollment'] = <String, dynamic>{};
      }

      final enrollment = Map<String, dynamic>.from(
        classSettings['enrollment'] as Map<String, dynamic>,
      );

      if (enrollment['qr_code'] == null) {
        enrollment['qr_code'] = <String, dynamic>{};
      }
      if (enrollment['qr_code'] is! Map<String, dynamic>) {
        enrollment['qr_code'] = <String, dynamic>{};
      }

      final qrCode = Map<String, dynamic>.from(
        enrollment['qr_code'] as Map<String, dynamic>,
      );

      // Update QR code settings
      qrCode['is_active'] = _qrActive;
      qrCode['require_approval'] = _requireApproval;
      if (_classCode != null && _classCode!.isNotEmpty) {
        qrCode['join_code'] = _classCode;
      }
      qrCode['expires_at'] = _expireEnabled && _expireDate != null
          ? _expireDate!.toUtc().toIso8601String()
          : null;
      qrCode['logo_enabled'] = _qrLogoEnabled;

      enrollment['qr_code'] = qrCode;

      // Update manual_join_limit
      // Nếu toggle tắt, lưu null vào database
      enrollment['manual_join_limit'] = _manualJoinLimitEnabled
          ? _manualJoinLimit
          : null;

      classSettings['enrollment'] = enrollment;

      // Update toàn bộ enrollment một lần (optimistic, không bật loading)
      final success = await classNotifier.updateClassSettingOptimistic(
        widget.classId,
        'enrollment',
        enrollment,
      );

      if (!success) {
        throw Exception('Không thể cập nhật cài đặt');
      }

      // Refresh class details
      await classNotifier.loadClassDetails(widget.classId);

      // Update original values sau khi lưu thành công
      _originalQrActive = _qrActive;
      _originalRequireApproval = _requireApproval;
      _originalExpireEnabled = _expireEnabled;
      _originalExpireDate = _expireDate;
      _originalClassCode = _classCode;
      _originalManualJoinLimitEnabled = _manualJoinLimitEnabled;
      _originalManualJoinLimit = _manualJoinLimit;
      _originalQrLogoEnabled = _qrLogoEnabled;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cài đặt đã được lưu thành công'),
            backgroundColor: DesignColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        '🔴 [ADD STUDENT] Error saving settings: $e',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu cài đặt: ${e.toString()}'),
            backgroundColor: DesignColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
