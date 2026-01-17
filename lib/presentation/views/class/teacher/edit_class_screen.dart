import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/presentation/viewmodels/class_viewmodel.dart';
import 'package:ai_mls/domain/entities/update_class_params.dart';
import 'package:ai_mls/domain/entities/class.dart';

/// Màn hình chỉnh sửa thông tin lớp học
/// Tái sử dụng form từ CreateClassScreen nhưng pre-fill dữ liệu hiện tại
class EditClassScreen extends StatefulWidget {
  final Class classItem;

  const EditClassScreen({
    super.key,
    required this.classItem,
  });

  @override
  State<EditClassScreen> createState() => _EditClassScreenState();
}

class _EditClassScreenState extends State<EditClassScreen> {
  // Biến trạng thái cho form
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _classNameController;
  late final TextEditingController _subjectController;
  late final TextEditingController _descriptionController;

  // Biến trạng thái cho năm học
  late final TextEditingController _startYearController;
  late final TextEditingController _endYearController;
  final _startYearFocusNode = FocusNode();
  final _endYearFocusNode = FocusNode();

  // Biến trạng thái cho gợi ý môn học
  List<Map<String, String>> _filteredSubjects = [];
  bool _showSubjectSuggestions = false;
  final _subjectFocusNode = FocusNode();

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

  @override
  void initState() {
    super.initState();
    // Pre-fill dữ liệu từ classItem
    _classNameController = TextEditingController(text: widget.classItem.name);
    _subjectController = TextEditingController(text: widget.classItem.subject ?? '');
    _descriptionController = TextEditingController(text: widget.classItem.description ?? '');

    // Parse academic year (format: "2023 - 2024")
    if (widget.classItem.academicYear != null) {
      final parts = widget.classItem.academicYear!.split(' - ');
      if (parts.length == 2) {
        _startYearController = TextEditingController(text: parts[0].trim());
        _endYearController = TextEditingController(text: parts[1].trim());
      } else {
        _startYearController = TextEditingController();
        _endYearController = TextEditingController();
      }
    } else {
      _startYearController = TextEditingController();
      _endYearController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _startYearController.dispose();
    _endYearController.dispose();
    _startYearFocusNode.dispose();
    _endYearFocusNode.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chỉnh sửa lớp học',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: DesignColors.moonLight,
        elevation: 0,
        centerTitle: true,
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
            ],
          ),
        ),
      ),
      // Nút lưu cố định ở đáy màn hình
      bottomNavigationBar: _buildSaveButton(),
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
                        color: Colors.black.withOpacity(0.1),
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
                  // Tự động chuyển focus sang năm kết thúc
                  _endYearFocusNode.requestFocus();
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length != 4) {
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
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length != 4) {
                      return 'Năm phải có 4 chữ số';
                    }
                    if (_startYearController.text.isNotEmpty) {
                      final startYear = int.tryParse(_startYearController.text);
                      final endYear = int.tryParse(value);
                      if (startYear != null &&
                          endYear != null &&
                          endYear <= startYear) {
                        return 'Năm kết thúc phải lớn hơn năm bắt đầu';
                      }
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

  /// Nút lưu ở đáy màn hình
  Widget _buildSaveButton() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        child: Consumer<ClassViewModel>(
          builder: (context, viewModel, _) {
            return ElevatedButton(
              onPressed: viewModel.isUpdating
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        // Xử lý cập nhật lớp học
                        _updateClass();
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
              child: viewModel.isUpdating
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Đang lưu...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lưu thay đổi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.check, size: 20),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  /// Xử lý cập nhật lớp học
  Future<void> _updateClass() async {
    final classViewModel = context.read<ClassViewModel>();

    // Tạo params từ form data
    final academicYear = _startYearController.text.isNotEmpty &&
            _endYearController.text.isNotEmpty
        ? '${_startYearController.text} - ${_endYearController.text}'
        : null;

    final params = UpdateClassParams(
      name: _classNameController.text,
      subject: _subjectController.text.isEmpty ? null : _subjectController.text,
      academicYear: academicYear,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
    );

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Gọi ViewModel để cập nhật lớp học
    final success = await classViewModel.updateClass(
      widget.classItem.id,
      params,
    );

    // Đóng loading dialog
    if (mounted) {
      Navigator.pop(context);
    }

    if (success) {
      // Hiển thị thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật lớp học "${_classNameController.text}" thành công!'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        // Quay lại màn hình trước
        Navigator.pop(context);
      }
    } else {
      // Hiển thị lỗi nếu có
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              classViewModel.errorMessage ?? 'Không thể cập nhật lớp học',
            ),
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
}
