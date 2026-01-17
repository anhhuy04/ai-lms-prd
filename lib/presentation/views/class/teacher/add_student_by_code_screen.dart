import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';

/// Màn hình thêm học sinh bằng mã QR
/// Hiển thị mã QR và các tùy chọn cài đặt cho lớp học
class AddStudentByCodeScreen extends StatefulWidget {
  final String classId;
  final String className;

  const AddStudentByCodeScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<AddStudentByCodeScreen> createState() => _AddStudentByCodeScreenState();
}

class _AddStudentByCodeScreenState extends State<AddStudentByCodeScreen> {
  // Trạng thái các công tắc
  bool _qrActive = true;
  bool _requireApproval = false;
  bool _expireEnabled = true;
  DateTime? _expireDate;
  int? _studentLimit;

  // Mã lớp học
  final String _classCode = 'XY78ZQ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: _buildAppBar(),
      body: Column(
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
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Thêm Học sinh bằng mã',
        style: DesignTypography.titleLarge.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.save,
            size: DesignIcons.mdSize,
            color: DesignColors.primary,
          ),
          onPressed: () {
            _saveSettings();
          },
        ),
      ],
    );
  }

  /// Phần hiển thị mã QR và mã lớp học
  Widget _buildQRCodeSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: DesignColors.white,
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          border: Border.all(color: DesignColors.dividerLight, width: 1),
          boxShadow: [DesignElevation.level1],
        ),
        child: Column(
          children: [
            // Thanh gradient trên cùng
            Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(DesignRadius.lg),
                ),
                gradient: LinearGradient(
                  colors: [
                    DesignColors.primary.withOpacity(0.6),
                    DesignColors.primary,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),

            // Mã QR
            Padding(
              padding: EdgeInsets.all(DesignSpacing.md),
              child: Column(
                children: [
                  // Hình ảnh mã QR
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(DesignRadius.md),
                      border: Border.all(
                        color: DesignColors.dividerLight,
                        width: 1,
                      ),
                      boxShadow: [DesignElevation.level1],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DesignRadius.md),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAb4jIpWfp_-tkF-XotkKci-MDX6oV9X-L8ijsJEQDd9vAx8Vn3MmrKiJDvjSG9GSLGC8sRyJk7L60ujIwN-v3ui5FjOEWr4qkiN3JjOFfjKKChp7VGb9BrMLCCeI9uZnbRM9J7wDUU3G2q9yHsUAKrPzYDSejjBzKhTNsSGeyZo7vn3ek3TfSDap2TPFa-K2tzqmcMUwW_gEZGOfBZMwDledkYMwGQWE4wA-Z0GAhg-t3bBO-7AyyfEdqABAPdTh-n_RB9eYM7KQ',
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(height: DesignSpacing.md),

                  // Mã lớp học
                  Column(
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
                        _classCode,
                        style: DesignTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: DesignSpacing.sm),

                  // Nút sao chép
                  ElevatedButton.icon(
                    icon: Icon(Icons.content_copy, size: DesignIcons.smSize),
                    label: Text('Sao chép'),
                    onPressed: () {
                      _copyClassCode();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignColors.primary.withOpacity(0.1),
                      foregroundColor: DesignColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignRadius.full),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignSpacing.md,
                        vertical: DesignSpacing.sm,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                            ? '${_expireDate!.day}/${_expireDate!.month}/${_expireDate!.year} ${_expireDate!.hour}:${_expireDate!.minute}'
                            : '',
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: DesignSpacing.md),

          // Giới hạn số học sinh
          Text(
            'Giới hạn số học sinh tham gia thủ công',
            style: DesignTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: DesignSpacing.sm),
          TextField(
            decoration: InputDecoration(
              hintText: 'Nhập số lượng (Ví dụ: 50)',
              hintStyle: DesignTypography.bodySmall,
              suffixText: 'Học sinh',
              suffixStyle: DesignTypography.caption.copyWith(
                color: DesignColors.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignRadius.md),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: DesignSpacing.sm,
                vertical: DesignSpacing.sm,
              ),
              isDense: true,
            ),
            style: DesignTypography.bodySmall,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _studentLimit = int.tryParse(value);
              });
            },
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
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.refresh, size: DesignIcons.mdSize),
              label: Text('Tạo mã mới'),
              onPressed: () {
                _generateNewCode();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.primary.withOpacity(0.1),
                foregroundColor: DesignColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.md),
                ),
                padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
              ),
            ),
          ),
          SizedBox(width: DesignSpacing.md),
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.share, size: DesignIcons.mdSize),
              label: Text('Chia sẻ mã'),
              onPressed: () {
                _shareClassCode();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.md),
                ),
                padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                elevation: 3,
                shadowColor: DesignColors.primary.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
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

    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

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
    // TODO: Implement copy to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép mã lớp học: $_classCode'),
        backgroundColor: DesignColors.success,
      ),
    );
  }

  /// Tạo mã mới
  void _generateNewCode() {
    // TODO: Implement generate new code
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã tạo mã mới'),
        backgroundColor: DesignColors.primary,
      ),
    );
  }

  /// Chia sẻ mã lớp học
  void _shareClassCode() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chia sẻ mã lớp học'),
        backgroundColor: DesignColors.primary,
      ),
    );
  }

  /// Lưu cài đặt
  void _saveSettings() {
    // TODO: Implement save settings to backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cài đặt đã được lưu'),
        backgroundColor: DesignColors.success,
      ),
    );
  }
}
