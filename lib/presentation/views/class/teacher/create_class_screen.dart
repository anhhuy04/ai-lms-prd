import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/routes/route_constants.dart';
import 'package:ai_mls/domain/entities/create_class_params.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:ai_mls/presentation/providers/class_notifier.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';
import 'package:ai_mls/presentation/views/class/teacher/widgets/drawers/class_create_class_setting_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Màn hình tạo lớp học mới
/// Thiết kế dựa trên HTML cung cấp với giao diện hiện đại
class CreateClassScreen extends ConsumerStatefulWidget {
  const CreateClassScreen({super.key});

  @override
  ConsumerState<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends ConsumerState<CreateClassScreen> {
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

  // Advanced settings từ drawer
  bool _lockClass = false;
  bool _showGroupToStudents = true;
  bool _lockGroupChanges = false;
  bool _allowStudentSwitch = false;
  bool _allowStudentProfileEdit = true;
  bool _autoLockAfterSubmit = false;

  // Class settings để truyền vào drawer
  Map<String, dynamic> get _classSettings => {
    'defaults': {'lock_class': _lockClass},
    'enrollment': {
      'qr_code': {
        'is_active': _qrCodeEnabled,
        'join_code': null,
        'expires_at': null,
        'require_approval': _approvalRequired,
        'logo_enabled': true,
      },
      'manual_join_limit': _maxStudentsController.text.isEmpty
          ? null
          : int.tryParse(_maxStudentsController.text),
    },
    'group_management': {
      'lock_groups': _lockGroupChanges,
      'allow_student_switch': _allowStudentSwitch,
      'is_visible_to_students': _showGroupToStudents,
    },
    'student_permissions': {
      'auto_lock_on_submission': _autoLockAfterSubmit,
      'can_edit_profile_in_class': _allowStudentProfileEdit,
    },
  };

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

  // Biến trạng thái cho ô năm học và kỳ học
  final _startYearController = TextEditingController();
  final _endYearController = TextEditingController();
  final _semesterController = TextEditingController();
  final _startYearFocusNode = FocusNode();
  final _endYearFocusNode = FocusNode();
  final _semesterFocusNode = FocusNode();

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
    _startYearController.dispose();
    _endYearController.dispose();
    _semesterController.dispose();
    _startYearFocusNode.dispose();
    _endYearFocusNode.dispose();
    _semesterFocusNode.dispose();
    _subjectFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (context.canPop()) {
              // Quay lại màn trước với hiệu ứng back mượt (pop)
              context.pop();
            } else {
              // Fallback: nếu vì lý do nào đó không pop được, quay về danh sách lớp
              context.go(AppRoute.teacherClassListPath);
            }
          },
        ),
        title: const Text(
          'Thêm Lớp học mới',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      endDrawer: ClassCreateClassSettingDrawer(
        classSettings: _classSettings,
        onSettingChanged: (path, value) {
          _updateClassSetting(path, value);
        },
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
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              child: Icon(icon, size: 16, color: Colors.blue[800]),
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
                style: TextStyle(color: Colors.red, fontSize: 14),
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
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            fillColor: Colors.grey[50],
            filled: true,
          ),
          style: const TextStyle(fontSize: 14, color: Colors.black),
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
              child: Icon(icon, size: 16, color: Colors.blue[800]),
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
                style: TextStyle(color: Colors.red, fontSize: 14),
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
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            fillColor: Colors.grey[50],
            filled: true,
          ),
          style: const TextStyle(fontSize: 14, color: Colors.black),
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
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                child: Icon(icon, size: 20, color: Colors.blue[800]),
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
                    activeThumbColor: Colors.blue[800],
                    activeTrackColor: Colors.blue[200],
                    inactiveThumbColor: Colors.grey[400],
                    inactiveTrackColor: Colors.grey[300],
                    thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
                      Set<WidgetState> states,
                    ) {
                      return states.contains(WidgetState.selected)
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            );
                    }),
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
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
            child: const Icon(Icons.groups, size: 20, color: Colors.blue),
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
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Row(
              children: [
                const Text(
                  'Tối đa',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
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
            shadowColor: Colors.blue.withValues(alpha: 0.3),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tạo Lớp học',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Cập nhật class setting theo path (ví dụ: 'group_management.is_visible_to_students')
  void _updateClassSetting(String path, dynamic value) {
    setState(() {
      final parts = path.split('.');
      if (parts.length == 2) {
        final section = parts[0];
        final key = parts[1];
        if (section == 'group_management') {
          if (key == 'is_visible_to_students') {
            _showGroupToStudents = value as bool;
          } else if (key == 'lock_groups') {
            _lockGroupChanges = value as bool;
          } else if (key == 'allow_student_switch') {
            _allowStudentSwitch = value as bool;
          }
        } else if (section == 'student_permissions') {
          if (key == 'can_edit_profile_in_class') {
            _allowStudentProfileEdit = value as bool;
          } else if (key == 'auto_lock_on_submission') {
            _autoLockAfterSubmit = value as bool;
          }
        } else if (section == 'defaults') {
          if (key == 'lock_class') {
            _lockClass = value as bool;
          }
        }
      }
    });
  }

  /// Xử lý tạo lớp học
  Future<void> _createClass() async {
    final authState = ref.read(authNotifierProvider);
    final classNotifier = ref.read(classNotifierProvider.notifier);

    final currentTeacherId = authState.value?.id;
    if (currentTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không tìm thấy thông tin giáo viên'),
          backgroundColor: Colors.red[600],
        ),
      );
      return;
    }

    // Sử dụng classSettings từ getter (đã được cập nhật từ drawer)
    final classSettings = _classSettings;

    // Tạo params
    final params = CreateClassParams(
      teacherId: currentTeacherId,
      name: _classNameController.text,
      subject: _subjectController.text.isEmpty ? null : _subjectController.text,
      academicYear: _buildAcademicYearString(),
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      classSettings: classSettings,
    );

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Gọi ViewModel để tạo lớp học
    final newClass = await classNotifier.createClass(params);

    // Đóng loading dialog
    if (mounted) {
      context.pop();
    }

    if (newClass != null) {
      // Hiển thị thông báo thành công
      if (mounted) {
        // Refresh danh sách lớp trong TeacherClassListScreen
        try {
          ref.read(pagingControllerProvider(currentTeacherId)).refresh();
        } catch (_) {
          // Ignore if paging controller chưa khởi tạo hoặc teacherId chưa có
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lớp học "${newClass.name}" đã được tạo thành công!'),
            backgroundColor: DesignColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            margin: EdgeInsets.all(DesignSpacing.lg),
          ),
        );

        // Quay lại màn hình danh sách lớp học
        // Sử dụng context.go() thay vì Navigator.pop() vì route này nằm trong ShellRoute
        context.go(AppRoute.teacherClassListPath);
      }
    } else {
      // Hiển thị lỗi nếu có
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Không thể tạo lớp học'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
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
              child: Icon(Icons.menu_book, size: 16, color: Colors.blue[800]),
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
            const Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
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
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                fillColor: Colors.grey[50],
                filled: true,
                suffixIcon: Icon(Icons.search, color: Colors.grey[500]),
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black),
              onChanged: (value) {
                // Lọc danh sách môn học dựa trên text nhập
                setState(() {
                  if (value.isEmpty) {
                    _showSubjectSuggestions = false;
                  } else {
                    _filteredSubjects = _subjects.where((subject) {
                      return subject['label']!.toLowerCase().contains(
                        value.toLowerCase(),
                      );
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
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey[200]!, width: 1),
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

  /// Trường năm học với 3 ô nhập: năm đầu, năm sau, kỳ học
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
              'Kỳ học',
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
                  hintText: 'Năm đầu',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  fillColor: Colors.grey[50],
                  filled: true,
                ),
                style: const TextStyle(fontSize: 14, color: Colors.black),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  // Tự động chuyển focus sang năm sau
                  _endYearFocusNode.requestFocus();
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bắt buộc';
                  }
                  if (value.length != 4) {
                    return '4 chữ số';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '_',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            // Năm sau
            Expanded(
              child: TextFormField(
                controller: _endYearController,
                focusNode: _endYearFocusNode,
                decoration: InputDecoration(
                  hintText: 'Năm sau',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  fillColor: Colors.grey[50],
                  filled: true,
                ),
                style: const TextStyle(fontSize: 14, color: Colors.black),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  // Tự động chuyển focus sang kỳ học
                  _semesterFocusNode.requestFocus();
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bắt buộc';
                  }
                  if (value.length != 4) {
                    return '4 chữ số';
                  }
                  final startText = _startYearController.text;
                  if (startText.isNotEmpty) {
                    final startYear = int.tryParse(startText);
                    final endYear = int.tryParse(value);
                    if (startYear != null &&
                        endYear != null &&
                        endYear <= startYear) {
                      return 'Phải > năm đầu';
                    }
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '_',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            // Kỳ học (không bắt buộc)
            Expanded(
              child: TextFormField(
                controller: _semesterController,
                focusNode: _semesterFocusNode,
                decoration: InputDecoration(
                  hintText: 'Kỳ (tùy chọn)',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  fillColor: Colors.grey[50],
                  filled: true,
                ),
                style: const TextStyle(fontSize: 14, color: Colors.black),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                // Không có validator vì không bắt buộc
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Xây dựng chuỗi academicYear theo định dạng xxxx_xxxx_x
  String? _buildAcademicYearString() {
    final startYear = _startYearController.text.trim();
    final endYear = _endYearController.text.trim();
    final semester = _semesterController.text.trim();

    // Nếu không có đủ 2 năm thì trả về null
    if (startYear.isEmpty || endYear.isEmpty) {
      return null;
    }

    // Định dạng: xxxx_xxxx_x
    // Nếu có kỳ học thì thêm vào, không có thì bỏ qua phần kỳ
    if (semester.isNotEmpty) {
      return '${startYear}_${endYear}_$semester';
    } else {
      return '${startYear}_$endYear';
    }
  }
}
