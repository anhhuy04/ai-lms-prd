import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/drawers/action_end_drawer.dart';
import 'package:ai_mls/widgets/drawers/class_advanced_settings_drawer.dart';

/// Màn hình tạo lớp học mới
/// Thiết kế dựa trên HTML cung cấp với giao diện hiện đại
class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  // Biến trạng thái cho form
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _schoolYearController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxStudentsController = TextEditingController();

  // Biến trạng thái cho các toggle
  bool _qrCodeEnabled = true;
  bool _approvalRequired = false;

  // Danh sách môn học
  final List<Map<String, String>> _subjects = [
    {'value': 'math', 'label': 'Toán học'},
    {'value': 'lit', 'label': 'Ngữ văn'},
    {'value': 'eng', 'label': 'Tiếng Anh'},
    {'value': 'phys', 'label': 'Vật lý'},
    {'value': 'chem', 'label': 'Hóa học'},
    {'value': 'bio', 'label': 'Sinh học'},
    {'value': 'hist', 'label': 'Lịch sử'},
    {'value': 'geo', 'label': 'Địa lý'},
  ];

  // Biến trạng thái cho ô năm học
  final _startYearController = TextEditingController();
  final _endYearController = TextEditingController();
  final _startYearFocusNode = FocusNode();
  final _endYearFocusNode = FocusNode();

  // Biến trạng thái cho gợi ý môn học
  List<Map<String, String>> _filteredSubjects = [];
  bool _showSubjectSuggestions = false;
  final _subjectFocusNode = FocusNode();

  @override
  void dispose() {
    _classNameController.dispose();
    _subjectController.dispose();
    _schoolYearController.dispose();
    _descriptionController.dispose();
    _maxStudentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thêm Lớp học mới',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
        backgroundColor: DesignColors.moonLight,
        elevation: 0,
        centerTitle: true,
      ),
      endDrawer: ActionEndDrawer(
        title: 'Cài đặt Lớp học',
        subtitle: _classNameController.text.isEmpty ? 'Lớp học mới' : _classNameController.text,
        child: ClassAdvancedSettingsDrawer(
          className: _classNameController.text.isEmpty ? 'Lớp học mới' : _classNameController.text,
          showGroupToStudents: true,
          lockGroupChanges: false,
          allowStudentProfileEdit: true,
          autoLockAfterSubmit: false,
          lockClass: false,
          onShowGroupToStudentsChanged: (value) {
            // Xử lý thay đổi cài đặt
          },
          onLockGroupChangesChanged: (value) {
            // Xử lý thay đổi cài đặt
          },
          onAllowStudentProfileEditChanged: (value) {
            // Xử lý thay đổi cài đặt
          },
          onAutoLockAfterSubmitChanged: (value) {
            // Xử lý thay đổi cài đặt
          },
          onLockClassChanged: (value) {
            // Xử lý thay đổi cài đặt
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Phần thông tin chung
              _buildGeneralInfoSection(),
              const SizedBox(height: 24),

              // Phần quản lý tham gia
              _buildParticipationManagementSection(),
            ],
          ),
        ),
      ),
      // Nút tạo lớp học cố định ở đáy màn hình
      bottomNavigationBar: _buildCreateButton(),
    );
  }

  /// Phần thông tin chung
  Widget _buildGeneralInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Thông tin chung',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Trường tên lớp học
          _buildTextFieldWithIcon(
            label: 'Tên Lớp học',
            icon: Icons.school,
            controller: _classNameController,
            hintText: 'Ví dụ: 12A1 - Toán nâng cao',
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập tên lớp học';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Trường môn học với gợi ý tự động
          _buildSubjectFieldWithSuggestions(),
          const SizedBox(height: 16),

          // Trường năm học với 2 ô nhập
          _buildSchoolYearField(),
          const SizedBox(height: 16),

          // Trường mô tả
          _buildTextAreaFieldWithIcon(
            label: 'Mô tả',
            icon: Icons.description,
            controller: _descriptionController,
            hintText: 'Nhập thông tin giới thiệu về lớp học...',
            maxLines: 3,
            isOptional: true,
          ),
        ],
      ),
    );
  }

  /// Phần quản lý tham gia
  Widget _buildParticipationManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Quản lý tham gia',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Lưới các tùy chọn
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.8,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            // Tùy chọn mã QR
            _buildToggleCard(
              icon: Icons.qr_code_2,
              title: 'Kích hoạt\nmã QR',
              value: _qrCodeEnabled,
              onChanged: (value) {
                setState(() {
                  _qrCodeEnabled = value;
                });
              },
            ),

            // Tùy chọn yêu cầu xét duyệt
            _buildToggleCard(
              icon: Icons.verified_user,
              title: 'Yêu cầu\nxét duyệt',
              value: _approvalRequired,
              onChanged: (value) {
                setState(() {
                  _approvalRequired = value;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tùy chọn giới hạn học sinh
        _buildStudentLimitCard(),
      ],
    );
  }

  /// Trường văn bản với icon
  Widget _buildTextFieldWithIcon({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    bool isRequired = false,
    bool isOptional = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            if (isOptional)
              const Text(
                ' (Tùy chọn)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.blue[800]!,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            fillColor: Colors.grey[50],
            filled: true,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

  /// Trường văn bản đa dòng với icon
  Widget _buildTextAreaFieldWithIcon({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 3,
    bool isRequired = false,
    bool isOptional = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            if (isOptional)
              const Text(
                ' (Tùy chọn)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.blue[800]!,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            fillColor: Colors.grey[50],
            filled: true,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
          maxLines: maxLines,
          validator: validator,
        ),
      ],
    );
  }

  /// Card toggle với icon
  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Colors.blue[800],
                ),
              ),
              // Toggle switch
              SizedBox(
                width: 40,
                height: 32,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Switch(
                    value: value,
                    onChanged: onChanged,
                    activeColor: Colors.blue[800],
                    activeTrackColor: Colors.blue[200],
                    inactiveThumbColor: Colors.grey[400],
                    inactiveTrackColor: Colors.grey[300],
                    thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                      (Set<WidgetState> states) {
                        return states.contains(WidgetState.selected)
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : const Icon(Icons.close, size: 16, color: Colors.white);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  /// Card giới hạn học sinh
  Widget _buildStudentLimitCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.groups,
              size: 20,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giới hạn học sinh',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Tối đa',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: TextFormField(
                    controller: _maxStudentsController,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText: '∞',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Nút tạo lớp học ở đáy màn hình
  Widget _buildCreateButton() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Xử lý tạo lớp học
              _createClass();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            shadowColor: Colors.blue.withOpacity(0.3),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tạo Lớp học',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Xử lý tạo lớp học
  void _createClass() {
    // Lấy dữ liệu từ form
    final classData = {
      'name': _classNameController.text,
      'subject': _subjectController.text,
      'schoolYear': '${_startYearController.text} - ${_endYearController.text}',
      'description': _descriptionController.text,
      'qrCodeEnabled': _qrCodeEnabled,
      'approvalRequired': _approvalRequired,
      'maxStudents': _maxStudentsController.text.isEmpty
          ? null
          : int.tryParse(_maxStudentsController.text),
    };

    // Hiển thị thông báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lớp học đã được tạo thành công!'),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );

    // Quay lại màn hình danh sách lớp học
    Navigator.pop(context, classData);
  }

  /// Trường môn học với gợi ý tự động hoàn thành
  Widget _buildSubjectFieldWithSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.menu_book,
                size: 16,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Môn học',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Stack để hiển thị gợi ý phía trên TextField
        Stack(
          children: [
            // TextField nhập môn học
            TextFormField(
              controller: _subjectController,
              focusNode: _subjectFocusNode,
              decoration: InputDecoration(
                hintText: 'Nhập tên môn học (ví dụ: Toán học)',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.blue[800]!,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                fillColor: Colors.grey[50],
                filled: true,
                suffixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[500],
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              onChanged: (value) {
                // Lọc danh sách môn học dựa trên text nhập
                setState(() {
                  if (value.isEmpty) {
                    _showSubjectSuggestions = false;
                  } else {
                    _filteredSubjects = _subjects.where((subject) {
                      return subject['label']!.toLowerCase().contains(value.toLowerCase());
                    }).toList();
                    _showSubjectSuggestions = _filteredSubjects.isNotEmpty;
                  }
                });
              },
              onTap: () {
                setState(() {
                  _showSubjectSuggestions = _subjectController.text.isNotEmpty;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập môn học';
                }
                return null;
              },
            ),

            // Danh sách gợi ý môn học
            if (_showSubjectSuggestions)
              Positioned(
                top: 56, // Vị trí ngay dưới TextField
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _filteredSubjects.length,
                    itemBuilder: (context, index) {
                      final subject = _filteredSubjects[index];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _subjectController.text = subject['label']!;
                            _showSubjectSuggestions = false;
                          });
                          _subjectFocusNode.unfocus();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            subject['label']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Trường năm học với 2 ô nhập riêng biệt
  Widget _buildSchoolYearField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.calendar_month,
                size: 16,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Năm học',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Năm bắt đầu
            Expanded(
              child: TextFormField(
                controller: _startYearController,
                focusNode: _startYearFocusNode,
                decoration: InputDecoration(
                  hintText: 'Năm bắt đầu',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue[800]!,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  fillColor: Colors.grey[50],
                  filled: true,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  // Tự động chuyển focus sang năm kết thúc
                  _endYearFocusNode.requestFocus();
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập năm';
                  }
                  if (value.length != 4) {
                    return 'Năm phải có 4 chữ số';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              '-',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            // Năm kết thúc
            Expanded(
              child: TextFormField(
                controller: _endYearController,
                focusNode: _endYearFocusNode,
                decoration: InputDecoration(
                  hintText: 'Năm kết thúc',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue[800]!,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  fillColor: Colors.grey[50],
                  filled: true,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập năm';
                  }
                  if (value.length != 4) {
                    return 'Năm phải có 4 chữ số';
                  }
                  if (_startYearController.text.isNotEmpty) {
                    final startYear = int.tryParse(_startYearController.text);
                    final endYear = int.tryParse(value ?? '');
                    if (startYear != null && endYear != null && endYear <= startYear) {
                      return 'Năm kết thúc phải lớn hơn năm bắt đầu';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
