import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/core/services/api_key_service.dart';
import 'package:ai_mls/widgets/forms/select_field.dart';
import 'package:flutter/material.dart';

class ApiKeySetupScreen extends StatefulWidget {
  const ApiKeySetupScreen({super.key});

  @override
  State<ApiKeySetupScreen> createState() => _ApiKeySetupScreenState();
}

class _ApiKeySetupScreenState extends State<ApiKeySetupScreen> {
  final _geminiKeyController = TextEditingController();
  final _groqKeyController = TextEditingController();
  final _aiKeyController = TextEditingController();
  bool _geminiKeyObscured = true;
  bool _groqKeyObscured = true;
  bool _aiKeyObscured = true;
  bool _isLoading = false;
  bool _hasGeminiKey = false;
  bool _hasGroqKey = false;
  bool _hasAiKey = false;
  String? _geminiKeyStatus; // 'working', 'error', null
  String? _geminiKeyError; // Chi tiết lỗi nếu có
  String? _groqKeyStatus; // 'working', 'error', null
  String? _groqKeyError; // Chi tiết lỗi nếu có

  String _activeProvider = ApiKeyService.providerGemini;
  String _activeModel = ApiKeyService.defaultGeminiModel;
  String _selectedProvider = ApiKeyService.providerGemini;
  String _selectedGeminiModel = ApiKeyService.defaultGeminiModel;
  String _selectedGroqModel = ApiKeyService.defaultGroqModel;

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  Future<void> _loadApiKeys() async {
    final geminiKey = await ApiKeyService.getGeminiApiKey();
    final groqKey = await ApiKeyService.getGroqApiKey();
    final aiKey = await ApiKeyService.getAiApiKey();
    final hasGemini = await ApiKeyService.hasGeminiApiKey();
    final hasGroq = await ApiKeyService.hasGroqApiKey();
    final provider = await ApiKeyService.getActiveProvider();
    final model = await ApiKeyService.getActiveModel();

    setState(() {
      if (geminiKey.isNotEmpty) {
        _geminiKeyController.text = geminiKey;
        _hasGeminiKey = hasGemini;
      }
      if (groqKey.isNotEmpty) {
        _groqKeyController.text = groqKey;
        _hasGroqKey = hasGroq;
      }
      if (aiKey.isNotEmpty) {
        _aiKeyController.text = aiKey;
        _hasAiKey = true;
      }

      _activeProvider = provider;
      _activeModel = model;
      _selectedProvider = provider;
      if (provider == ApiKeyService.providerGroq) {
        _selectedGroqModel = model;
      } else {
        _selectedGeminiModel = model;
      }
    });
  }

  Future<void> _applyActiveAi() async {
    setState(() => _isLoading = true);
    try {
      final model = _selectedProvider == ApiKeyService.providerGroq
          ? _selectedGroqModel
          : _selectedGeminiModel;

      final ok = await ApiKeyService.setActiveAiConfig(
        provider: _selectedProvider,
        model: model,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã áp dụng AI: $_selectedProvider • $model'),
            backgroundColor: DesignColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        await _loadApiKeys();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Không thể áp dụng cấu hình AI'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi: ${e.toString()}'),
          backgroundColor: DesignColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _geminiKeyController.dispose();
    _groqKeyController.dispose();
    _aiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveGeminiKey() async {
    final key = _geminiKeyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập Gemini API Key'),
          backgroundColor: DesignColors.error,
        ),
      );
      return;
    }

    // Kiểm tra xem có phải đang cập nhật key cũ không
    final oldKey = await ApiKeyService.getGeminiApiKey();
    final isUpdating = oldKey.isNotEmpty && oldKey != key;

    setState(() {
      _isLoading = true;
      _geminiKeyStatus = null;
      _geminiKeyError = null;
    });

    try {
      // Test và lưu API key (tự động ghi đè nếu đã có key cũ)
      final result = await ApiKeyService.setGeminiApiKey(
        key,
        // Không tự đổi provider/model khi lưu key; user sẽ chọn ở mục "AI đang dùng".
        setActive: false,
        model: _selectedGeminiModel,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result['saved'] == true) {
            _hasGeminiKey = true;

            // Xử lý kết quả test
            if (result['tested'] == true) {
              final testSuccess = result['testSuccess'] as bool?;
              if (testSuccess == true) {
                _geminiKeyStatus = 'working';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isUpdating
                          ? '✅ Đã cập nhật và test thành công! API hoạt động bình thường.'
                          : '✅ Đã lưu và test thành công! API hoạt động bình thường.',
                    ),
                    backgroundColor: DesignColors.success,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else {
                // Test thất bại nhưng đã lưu - hiển thị dialog lỗi chi tiết
                _geminiKeyStatus = 'error';
                _geminiKeyError = result['error'] as String?;
                _showApiKeyErrorDialog(
                  isUpdating
                      ? 'API Key đã được cập nhật nhưng test thất bại'
                      : 'API Key đã được lưu nhưng test thất bại',
                  _geminiKeyError ?? 'Lỗi không xác định',
                );
              }
            } else {
              // Không test được (có thể do network)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isUpdating
                        ? '✅ Đã cập nhật API Key (không thể test do lỗi kết nối)'
                        : '✅ Đã lưu API Key (không thể test do lỗi kết nối)',
                  ),
                  backgroundColor: DesignColors.warning,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } else {
            // Lưu thất bại
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '❌ Lỗi khi ${isUpdating ? 'cập nhật' : 'lưu'}: ${result['error'] ?? 'Unknown error'}',
                ),
                backgroundColor: DesignColors.error,
              ),
            );
          }
        });
      }
      await _loadApiKeys();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _geminiKeyStatus = 'error';
          _geminiKeyError = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: ${e.toString()}'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveGroqKey() async {
    final key = _groqKeyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập Groq API Key'),
          backgroundColor: DesignColors.error,
        ),
      );
      return;
    }

    final oldKey = await ApiKeyService.getGroqApiKey();
    final isUpdating = oldKey.isNotEmpty && oldKey != key;

    setState(() {
      _isLoading = true;
      _groqKeyStatus = null;
      _groqKeyError = null;
    });

    try {
      final result = await ApiKeyService.setGroqApiKey(
        key,
        model: _selectedGroqModel,
        // Không tự đổi provider/model khi lưu key; user sẽ chọn ở mục "AI đang dùng".
        setActive: false,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result['saved'] == true) {
            _hasGroqKey = true;

            if (result['tested'] == true) {
              final testSuccess = result['testSuccess'] as bool?;
              if (testSuccess == true) {
                _groqKeyStatus = 'working';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isUpdating
                          ? '✅ Đã cập nhật Groq API Key và test thành công!'
                          : '✅ Đã lưu Groq API Key và test thành công!',
                    ),
                    backgroundColor: DesignColors.success,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else {
                _groqKeyStatus = 'error';
                _groqKeyError = result['error'] as String?;
                _showApiKeyErrorDialog(
                  isUpdating
                      ? 'Groq API Key đã được cập nhật nhưng test thất bại'
                      : 'Groq API Key đã được lưu nhưng test thất bại',
                  _groqKeyError ?? 'Lỗi không xác định',
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isUpdating
                        ? '✅ Đã cập nhật Groq API Key (không thể test do lỗi kết nối)'
                        : '✅ Đã lưu Groq API Key (không thể test do lỗi kết nối)',
                  ),
                  backgroundColor: DesignColors.warning,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '❌ Lỗi khi ${isUpdating ? 'cập nhật' : 'lưu'}: ${result['error'] ?? 'Unknown error'}',
                ),
                backgroundColor: DesignColors.error,
              ),
            );
          }
        });
      }
      await _loadApiKeys();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _groqKeyStatus = 'error';
          _groqKeyError = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: ${e.toString()}'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    }
  }

  /// Hiển thị dialog lỗi chi tiết cho API key
  void _showApiKeyErrorDialog(String title, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: DesignColors.warning,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'API Key đã được lưu vào tài khoản của bạn, nhưng không thể kết nối đến API.',
                style: DesignTypography.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DesignColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.md),
                  border: Border.all(
                    color: DesignColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chi tiết lỗi:',
                      style: DesignTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DesignColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(error, style: DesignTypography.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '💡 Gợi ý:',
                style: DesignTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Kiểm tra lại API key có đúng không\n'
                '• Kiểm tra kết nối internet\n'
                '• Kiểm tra quota và billing của API key\n'
                '• Thử lại sau vài phút',
                style: DesignTypography.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearGeminiKey() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa Gemini API Key?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: DesignColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final cleared = await ApiKeyService.clearGeminiApiKey();
        if (cleared && mounted) {
          setState(() {
            _geminiKeyController.clear();
            _hasGeminiKey = false;
            _geminiKeyStatus = null;
            _geminiKeyError = null;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã xóa Gemini API Key'),
              backgroundColor: DesignColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Lỗi: ${e.toString()}'),
              backgroundColor: DesignColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _clearGroqKey() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa Groq API Key?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: DesignColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final cleared = await ApiKeyService.clearGroqApiKey();
        if (cleared && mounted) {
          setState(() {
            _groqKeyController.clear();
            _hasGroqKey = false;
            _groqKeyStatus = null;
            _groqKeyError = null;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã xóa Groq API Key'),
              backgroundColor: DesignColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Lỗi: ${e.toString()}'),
              backgroundColor: DesignColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _saveAiKey() async {
    final key = _aiKeyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập AI API Key'),
          backgroundColor: DesignColors.error,
        ),
      );
      return;
    }

    // Kiểm tra xem có phải đang cập nhật key cũ không
    final oldKey = await ApiKeyService.getAiApiKey();
    final isUpdating = oldKey.isNotEmpty && oldKey != key;

    setState(() => _isLoading = true);
    try {
      final saved = await ApiKeyService.setAiApiKey(key);
      if (saved && mounted) {
        setState(() {
          _hasAiKey = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isUpdating
                  ? '✅ Đã cập nhật AI API Key thành công!'
                  : '✅ Đã lưu AI API Key thành công!',
            ),
            backgroundColor: DesignColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: ${e.toString()}'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    }
  }

  Future<void> _clearAiKey() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa AI API Key?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: DesignColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final cleared = await ApiKeyService.clearAllApiKeys();
        if (cleared && mounted) {
          setState(() {
            _aiKeyController.clear();
            _hasAiKey = false;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã xóa AI API Key'),
              backgroundColor: DesignColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Lỗi: ${e.toString()}'),
              backgroundColor: DesignColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
        elevation: 0,
        title: Text(
          'Cài đặt API Key',
          style: DesignTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
                    padding: EdgeInsets.all(DesignSpacing.lg),
                    decoration: BoxDecoration(
                      color: DesignColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(DesignRadius.lg),
                      border: Border.all(
                        color: DesignColors.info.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: DesignColors.info,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'API keys được lưu an toàn trong tài khoản của bạn trên Supabase. '
                            'Mỗi người dùng có thể sử dụng API key riêng của mình và đồng bộ trên tất cả thiết bị.',
                            style: DesignTypography.bodySmall.copyWith(
                              color: DesignColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: DesignSpacing.xxl),

                  _buildActiveAiSelectorCard(context, isDark),

                  SizedBox(height: DesignSpacing.xxl),

                  // API Key Section - chỉ hiển thị card theo provider đang chọn
                  _buildProviderKeySection(
                    context,
                    isDark: isDark,
                    provider: _selectedProvider,
                  ),

                  SizedBox(height: DesignSpacing.xxl),

                  // AI API Key Section
                  _buildApiKeySection(
                    context,
                    title: 'AI API Key (Generic)',
                    description: 'API key cho các dịch vụ AI khác (nếu có)',
                    controller: _aiKeyController,
                    obscured: _aiKeyObscured,
                    hasKey: _hasAiKey,
                    isDark: isDark,
                    onObscuredToggle: () =>
                        setState(() => _aiKeyObscured = !_aiKeyObscured),
                    onSave: _saveAiKey,
                    onClear: _clearAiKey,
                    hintText: 'Nhập AI API Key...',
                    helpUrl: null,
                  ),

                  SizedBox(height: DesignSpacing.xxl),

                  // Storage Info
                  _buildStorageInfoSection(context, isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildApiKeySection(
    BuildContext context, {
    required String title,
    required String description,
    required TextEditingController controller,
    required bool obscured,
    required bool hasKey,
    String? status, // 'working', 'error', null
    required bool isDark,
    required VoidCallback onObscuredToggle,
    required VoidCallback onSave,
    required VoidCallback onClear,
    required String hintText,
    String? helpUrl,
  }) {
    // Xác định text cho nút lưu/cập nhật
    final saveButtonText = hasKey ? 'Cập nhật' : 'Lưu';
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.key_rounded, size: 20, color: DesignColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: DesignTypography.labelSmallSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasKey)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (status == 'working'
                                ? DesignColors.success
                                : status == 'error'
                                ? DesignColors.error
                                : DesignColors.info)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: status == 'working'
                              ? DesignColors.success
                              : status == 'error'
                              ? DesignColors.error
                              : DesignColors.info,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status == 'working'
                            ? 'API hoạt động bình thường'
                            : status == 'error'
                            ? 'API có lỗi'
                            : 'Đã lưu',
                        style: DesignTypography.bodySmall.copyWith(
                          color: status == 'working'
                              ? DesignColors.success
                              : status == 'error'
                              ? DesignColors.error
                              : DesignColors.info,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: DesignTypography.bodySmall.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            obscureText: obscured,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignRadius.lg),
              ),
              suffixIcon: IconButton(
                icon: Icon(obscured ? Icons.visibility : Icons.visibility_off),
                onPressed: onObscuredToggle,
              ),
            ),
          ),
          if (helpUrl != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                // TODO: Open help URL
              },
              icon: const Icon(Icons.help_outline, size: 16),
              label: const Text('Lấy API key tại đây'),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: hasKey ? onClear : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignColors.error,
                    side: BorderSide(color: DesignColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Xóa'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(saveButtonText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAiSelectorCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: DesignColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI đang dùng trong dự án',
                      style: DesignTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : DesignColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đang chạy: $_activeProvider • $_activeModel',
                      style: DesignTypography.bodySmall.copyWith(
                        color: DesignColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Chọn provider/model sẽ được dùng khi tạo câu hỏi bằng AI.',
            style: DesignTypography.bodySmall.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          SelectField<String>(
            label: 'Provider',
            value: _selectedProvider,
            prefixIcon: Icons.precision_manufacturing_outlined,
            useCustomPicker: true,
            options: const [
              SelectFieldOption(
                value: ApiKeyService.providerGemini,
                label: 'Gemini (Google)',
                description: 'Model Gemini chuyên câu hỏi trắc nghiệm',
                icon: Icons.bubble_chart_outlined,
              ),
              SelectFieldOption(
                value: ApiKeyService.providerGroq,
                label: 'Groq (OpenAI-compatible)',
                description: 'Model Groq tốc độ cao, OpenAI-compatible',
                icon: Icons.memory_rounded,
              ),
            ],
            onChanged: (v) {
              if (v == null) return;
              setState(() => _selectedProvider = v);
            },
          ),
          const SizedBox(height: 12),
          if (_selectedProvider == ApiKeyService.providerGemini)
            SelectField<String>(
              label: 'Model Gemini',
              value: _selectedGeminiModel,
              prefixIcon: Icons.memory_rounded,
              useCustomPicker: true,
              options: const [
                SelectFieldOption(
                  value: 'gemini-1.5-flash',
                  label: 'gemini-1.5-flash (khuyến nghị)',
                  description: 'Nhanh, tối ưu chi phí, phù hợp tạo câu hỏi',
                  icon: Icons.bolt_outlined,
                ),
                SelectFieldOption(
                  value: 'gemini-2.0-flash',
                  label: 'gemini-2.0-flash',
                  description: 'Model mới hơn, thông minh hơn, tốn token hơn',
                  icon: Icons.auto_awesome,
                ),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _selectedGeminiModel = v);
              },
            )
          else
            SelectField<String>(
              label: 'Model Groq',
              value: _selectedGroqModel,
              prefixIcon: Icons.memory_rounded,
              useCustomPicker: true,
              options: const [
                SelectFieldOption(
                  value: 'llama-3.1-8b-instant',
                  label: 'llama-3.1-8b-instant',
                  description: 'Nhanh, nhẹ, phù hợp generate số lượng lớn',
                  icon: Icons.flash_on_outlined,
                ),
                SelectFieldOption(
                  value: 'llama-3.1-70b-versatile',
                  label: 'llama-3.1-70b-versatile',
                  description: 'Độ chính xác cao, nặng hơn',
                  icon: Icons.star_rate_rounded,
                ),
                SelectFieldOption(
                  value: 'mixtral-8x7b-32768',
                  label: 'mixtral-8x7b-32768',
                  description: 'Context rất dài, phù hợp đề nhiều tài liệu',
                  icon: Icons.description_outlined,
                ),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _selectedGroqModel = v);
              },
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyActiveAi,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Áp dụng'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderKeySection(
    BuildContext context, {
    required bool isDark,
    required String provider,
  }) {
    final isGemini = provider == ApiKeyService.providerGemini;
    final title = isGemini ? 'Gemini API Key' : 'Groq API Key';
    final controller = isGemini ? _geminiKeyController : _groqKeyController;
    final obscured = isGemini ? _geminiKeyObscured : _groqKeyObscured;
    final hasKey = isGemini ? _hasGeminiKey : _hasGroqKey;
    final status = isGemini ? _geminiKeyStatus : _groqKeyStatus;
    final onSave = isGemini ? _saveGeminiKey : _saveGroqKey;
    final onClear = isGemini ? _clearGeminiKey : _clearGroqKey;
    void onToggle() => setState(() {
      if (isGemini) {
        _geminiKeyObscured = !_geminiKeyObscured;
      } else {
        _groqKeyObscured = !_groqKeyObscured;
      }
    });
    final hintText = isGemini ? 'AIzaSy...' : 'gsk_...';

    final description = isGemini
        ? 'API key cho Google Gemini. Lưu key không đổi AI đang dùng; bạn chọn ở mục phía trên.'
        : 'API key cho Groq. Lưu key không đổi AI đang dùng; bạn chọn ở mục phía trên.';

    return _buildApiKeySection(
      context,
      title: title,
      description: description,
      controller: controller,
      obscured: obscured,
      hasKey: hasKey,
      status: status,
      isDark: isDark,
      onObscuredToggle: onToggle,
      onSave: onSave,
      onClear: onClear,
      hintText: hintText,
      helpUrl: null,
    );
  }

  Widget _buildStorageInfoSection(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.storage_outlined,
                size: 20,
                color: DesignColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'THÔNG TIN LƯU TRỮ',
                style: TextStyle(
                  fontSize: DesignTypography.labelSmallSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<Map<String, String>>(
            future: ApiKeyService.getStorageInfo(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              final info = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Loại lưu trữ', info['storage_type'] ?? 'N/A'),
                  _buildInfoRow('Nền tảng', info['platform'] ?? 'N/A'),
                  _buildInfoRow('Vị trí', info['location'] ?? 'N/A'),
                  _buildInfoRow('Mã hóa', info['encryption'] ?? 'N/A'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: DesignTypography.bodySmall.copyWith(
                color: DesignColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(value, style: DesignTypography.bodySmall)),
        ],
      ),
    );
  }
}
