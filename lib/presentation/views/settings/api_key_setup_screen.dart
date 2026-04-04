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
  final _ollamaUrlController = TextEditingController();
  bool _geminiKeyObscured = true;
  bool _groqKeyObscured = true;
  bool _isLoading = false;
  bool _hasGeminiKey = false;
  bool _hasGroqKey = false;
  List<String> _ollamaAvailableModels = [];
  String? _geminiKeyStatus; // 'working', 'error', null
  String? _geminiKeyError; // Chi tiết lỗi nếu có
  String? _groqKeyStatus; // 'working', 'error', null
  String? _groqKeyError; // Chi tiết lỗi nếu có
  String? _ollamaConnectionStatus; // 'working', 'error', null
  String? _ollamaConnectionError;

  // ── Tạo câu hỏi ────────────────────────────────────────────────────────
  String _activeProvider = ApiKeyService.providerGemini;
  String _activeModel = ApiKeyService.defaultGeminiModel;
  String _selectedProvider = ApiKeyService.providerGemini;
  String _selectedGeminiModel = ApiKeyService.defaultGeminiModel;
  String _selectedGroqModel = ApiKeyService.defaultGroqModel;
  String _selectedOllamaModel = ApiKeyService.defaultOllamaModel;

  // ── Phân tích dữ liệu ──────────────────────────────────────────────────
  String _analyticsProvider = ApiKeyService.providerGemini;
  String _analyticsModel = ApiKeyService.defaultGeminiModel;
  String _selectedAnalyticsProvider = ApiKeyService.providerGemini;
  String _selectedAnalyticsGeminiModel = ApiKeyService.defaultGeminiModel;
  String _selectedAnalyticsGroqModel = ApiKeyService.defaultGroqModel;
  String _selectedAnalyticsOllamaModel = ApiKeyService.defaultOllamaModel;
  String? _analyticsKeyStatus; // 'working', 'error', null
  String? _analyticsKeyError;
  bool _analyticsKeyTesting = false;

  // ── Test API cho tạo câu hỏi ───────────────────────────────────────────
  String? _questionKeyStatus; // 'working', 'error', null
  String? _questionKeyError;
  bool _questionKeyTesting = false;
  bool _isUpdatingQuestion = false;
  bool _isUpdatingAnalytics = false;

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  Future<void> _loadApiKeys() async {
    final results = await Future.wait([
      ApiKeyService.getGeminiApiKey(),
      ApiKeyService.getGroqApiKey(),
      ApiKeyService.getOllamaBaseUrl(),
      ApiKeyService.getActiveProvider(),
      ApiKeyService.getActiveModel(),
      ApiKeyService.getAnalyticsProvider(),
      ApiKeyService.getAnalyticsModel(),
    ]);
    final hasGemini = await ApiKeyService.hasGeminiApiKey();
    final hasGroq = await ApiKeyService.hasGroqApiKey();

    final geminiKey = results[0];
    final groqKey = results[1];
    final ollamaUrl = results[2];
    final provider = results[3];
    final model = results[4];
    final analyticsProvider = results[5];
    final analyticsModel = results[6];

    setState(() {
      if (geminiKey.isNotEmpty) {
        _geminiKeyController.text = geminiKey;
        _hasGeminiKey = hasGemini;
      }
      if (groqKey.isNotEmpty) {
        _groqKeyController.text = groqKey;
        _hasGroqKey = hasGroq;
      }
      if (ollamaUrl.isNotEmpty) {
        _ollamaUrlController.text = ollamaUrl;
      }

      _activeProvider = provider;
      _activeModel = model;
      _selectedProvider = provider;
      if (provider == ApiKeyService.providerGroq) {
        _selectedGroqModel = model;
      } else if (provider == ApiKeyService.providerOllama) {
        _selectedOllamaModel = model;
      } else {
        _selectedGeminiModel = model;
      }

      _analyticsProvider = analyticsProvider;
      _analyticsModel = analyticsModel;
      _selectedAnalyticsProvider = analyticsProvider;
      if (analyticsProvider == ApiKeyService.providerGroq) {
        _selectedAnalyticsGroqModel = analyticsModel;
      } else if (analyticsProvider == ApiKeyService.providerOllama) {
        _selectedAnalyticsOllamaModel = analyticsModel;
      } else {
        _selectedAnalyticsGeminiModel = analyticsModel;
      }
    });
  }

  String _resolveModel({
    required String provider,
    required String geminiModel,
    required String groqModel,
    required String ollamaModel,
  }) => switch (provider) {
    ApiKeyService.providerGroq => groqModel,
    ApiKeyService.providerOllama => ollamaModel,
    _ => geminiModel,
  };

  /// Test → Lưu key → Áp dụng model (tất cả trong 1 bước)
  Future<void> _updateAndApplyQuestion() async {
    setState(() => _isUpdatingQuestion = true);
    final provider = _selectedProvider;
    final model = _resolveModel(
      provider: provider,
      geminiModel: _selectedGeminiModel,
      groqModel: _selectedGroqModel,
      ollamaModel: _selectedOllamaModel,
    );

    try {
      // ── Bước 1: Lấy key/URL từ field ──────────────────────────────────
      final geminiKey = _geminiKeyController.text.trim();
      final groqKey = _groqKeyController.text.trim();
      final ollamaUrl = _ollamaUrlController.text.trim();

      if (provider != ApiKeyService.providerOllama) {
        final key = provider == ApiKeyService.providerGemini ? geminiKey : groqKey;
        if (key.isEmpty) {
          if (!mounted) return;
          setState(() => _isUpdatingQuestion = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Vui lòng nhập API key'),
              backgroundColor: DesignColors.warning,
            ),
          );
          return;
        }
      } else if (ollamaUrl.isEmpty) {
        if (!mounted) return;
        setState(() => _isUpdatingQuestion = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Vui lòng nhập Ollama URL'),
            backgroundColor: DesignColors.warning,
          ),
        );
        return;
      }

      // ── Bước 2: Test API ───────────────────────────────────────────────
      Map<String, dynamic> testResult;
      if (provider == ApiKeyService.providerGemini) {
        testResult = await ApiKeyService.testGeminiApiKey(geminiKey, model: model);
      } else if (provider == ApiKeyService.providerGroq) {
        testResult = await ApiKeyService.testGroqApiKey(groqKey, model: model);
      } else {
        testResult = await ApiKeyService.testOllamaConnection(ollamaUrl);
      }

      if (!mounted) return;
      if (testResult['success'] != true) {
        setState(() {
          _isUpdatingQuestion = false;
          _questionKeyStatus = 'error';
          _questionKeyError = testResult['error'] as String?;
        });
        _showErrorDialog('Kiểm tra API thất bại — không lưu', _questionKeyError ?? 'Lỗi không xác định');
        return;
      }
      setState(() => _questionKeyStatus = 'working');

      // ── Bước 3: Lưu key/URL ────────────────────────────────────────────
      Map<String, dynamic> saveResult;
      if (provider == ApiKeyService.providerGemini) {
        saveResult = await ApiKeyService.setGeminiApiKey(geminiKey, setActive: false, model: model);
      } else if (provider == ApiKeyService.providerGroq) {
        saveResult = await ApiKeyService.setGroqApiKey(groqKey, setActive: false, model: model);
      } else {
        saveResult = await ApiKeyService.setOllamaBaseUrl(ollamaUrl, model: model, setActive: false);
      }

      if (!mounted) return;
      if (saveResult['saved'] != true) {
        setState(() => _isUpdatingQuestion = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lưu thất bại: ${saveResult['error'] ?? 'Unknown'}'),
            backgroundColor: DesignColors.error,
          ),
        );
        return;
      }

      // Cập nhật trạng thái has key
      if (provider == ApiKeyService.providerGemini) {
        setState(() => _hasGeminiKey = true);
      } else if (provider == ApiKeyService.providerGroq) {
        setState(() => _hasGroqKey = true);
      }

      // ── Bước 4: Áp dụng model ─────────────────────────────────────────
      final ok = await ApiKeyService.setActiveAiConfig(provider: provider, model: model);
      if (!mounted) return;
      setState(() {
        _isUpdatingQuestion = false;
        if (ok) {
          _activeProvider = provider;
          _activeModel = model;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? '✅ Đã cập nhật và áp dụng: $provider • $model'
              : '⚠️ Đã lưu key nhưng không thể áp dụng cấu hình'),
          backgroundColor: ok ? DesignColors.success : DesignColors.warning,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUpdatingQuestion = false;
        _questionKeyStatus = 'error';
        _questionKeyError = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi: ${e.toString()}'), backgroundColor: DesignColors.error),
      );
    }
  }

  /// Test → Lưu key → Áp dụng model (analytics)
  Future<void> _updateAndApplyAnalytics() async {
    setState(() => _isUpdatingAnalytics = true);
    final provider = _selectedAnalyticsProvider;
    final model = _resolveModel(
      provider: provider,
      geminiModel: _selectedAnalyticsGeminiModel,
      groqModel: _selectedAnalyticsGroqModel,
      ollamaModel: _selectedAnalyticsOllamaModel,
    );

    try {
      // ── Bước 1: Lấy key/URL từ field ──────────────────────────────────
      final geminiKey = _geminiKeyController.text.trim();
      final groqKey = _groqKeyController.text.trim();
      final ollamaUrl = _ollamaUrlController.text.trim();

      if (provider != ApiKeyService.providerOllama) {
        final key = provider == ApiKeyService.providerGemini ? geminiKey : groqKey;
        if (key.isEmpty) {
          if (!mounted) return;
          setState(() => _isUpdatingAnalytics = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Vui lòng nhập API key'),
              backgroundColor: DesignColors.warning,
            ),
          );
          return;
        }
      } else if (ollamaUrl.isEmpty) {
        if (!mounted) return;
        setState(() => _isUpdatingAnalytics = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Vui lòng nhập Ollama URL'),
            backgroundColor: DesignColors.warning,
          ),
        );
        return;
      }

      // ── Bước 2: Test API ───────────────────────────────────────────────
      Map<String, dynamic> testResult;
      if (provider == ApiKeyService.providerGemini) {
        testResult = await ApiKeyService.testGeminiApiKey(geminiKey, model: model);
      } else if (provider == ApiKeyService.providerGroq) {
        testResult = await ApiKeyService.testGroqApiKey(groqKey, model: model);
      } else {
        testResult = await ApiKeyService.testOllamaConnection(ollamaUrl);
      }

      if (!mounted) return;
      if (testResult['success'] != true) {
        setState(() {
          _isUpdatingAnalytics = false;
          _analyticsKeyStatus = 'error';
          _analyticsKeyError = testResult['error'] as String?;
        });
        _showErrorDialog('Kiểm tra API thất bại — không lưu', _analyticsKeyError ?? 'Lỗi không xác định');
        return;
      }
      setState(() => _analyticsKeyStatus = 'working');

      // ── Bước 3: Lưu key/URL ────────────────────────────────────────────
      Map<String, dynamic> saveResult;
      if (provider == ApiKeyService.providerGemini) {
        saveResult = await ApiKeyService.setGeminiApiKey(geminiKey, setActive: false, model: model);
      } else if (provider == ApiKeyService.providerGroq) {
        saveResult = await ApiKeyService.setGroqApiKey(groqKey, setActive: false, model: model);
      } else {
        saveResult = await ApiKeyService.setOllamaBaseUrl(ollamaUrl, model: model, setActive: false);
      }

      if (!mounted) return;
      if (saveResult['saved'] != true) {
        setState(() => _isUpdatingAnalytics = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lưu thất bại: ${saveResult['error'] ?? 'Unknown'}'),
            backgroundColor: DesignColors.error,
          ),
        );
        return;
      }

      if (provider == ApiKeyService.providerGemini) {
        setState(() => _hasGeminiKey = true);
      } else if (provider == ApiKeyService.providerGroq) {
        setState(() => _hasGroqKey = true);
      }

      // ── Bước 4: Áp dụng model ─────────────────────────────────────────
      final ok = await ApiKeyService.setAnalyticsConfig(provider: provider, model: model);
      if (!mounted) return;
      setState(() {
        _isUpdatingAnalytics = false;
        if (ok) {
          _analyticsProvider = provider;
          _analyticsModel = model;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? '✅ Đã cập nhật và áp dụng: $provider • $model'
              : '⚠️ Đã lưu key nhưng không thể áp dụng cấu hình'),
          backgroundColor: ok ? DesignColors.success : DesignColors.warning,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUpdatingAnalytics = false;
        _analyticsKeyStatus = 'error';
        _analyticsKeyError = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi: ${e.toString()}'), backgroundColor: DesignColors.error),
      );
    }
  }

  @override
  void dispose() {
    _geminiKeyController.dispose();
    _groqKeyController.dispose();
    _ollamaUrlController.dispose();
    super.dispose();
  }

  Future<bool> _testAnalyticsApi({bool showSuccessSnackbar = true}) async {
    final provider = _selectedAnalyticsProvider;
    final model = _resolveModel(
      provider: provider,
      geminiModel: _selectedAnalyticsGeminiModel,
      groqModel: _selectedAnalyticsGroqModel,
      ollamaModel: _selectedAnalyticsOllamaModel,
    );

    setState(() {
      _analyticsKeyTesting = true;
      _analyticsKeyStatus = null;
      _analyticsKeyError = null;
    });

    try {
      Map<String, dynamic> result;
      if (provider == ApiKeyService.providerGemini) {
        final fieldKey = _geminiKeyController.text.trim();
        final key = fieldKey.isNotEmpty ? fieldKey : await ApiKeyService.getGeminiApiKey();
        if (key.isEmpty) {
          result = {'success': false, 'error': 'Chưa có Gemini API key. Hãy nhập key vào ô bên dưới.'};
        } else {
          result = await ApiKeyService.testGeminiApiKey(key, model: model);
        }
      } else if (provider == ApiKeyService.providerGroq) {
        final fieldKey = _groqKeyController.text.trim();
        final key = fieldKey.isNotEmpty ? fieldKey : await ApiKeyService.getGroqApiKey();
        if (key.isEmpty) {
          result = {'success': false, 'error': 'Chưa có Groq API key. Hãy nhập key vào ô bên dưới.'};
        } else {
          result = await ApiKeyService.testGroqApiKey(key, model: model);
        }
      } else {
        final url = _ollamaUrlController.text.trim();
        if (url.isEmpty) {
          result = {'success': false, 'error': 'Chưa có Ollama URL. Hãy nhập URL vào ô bên dưới.'};
        } else {
          result = await ApiKeyService.testOllamaConnection(url);
        }
      }

      if (!mounted) return false;
      final success = result['success'] == true;
      setState(() {
        _analyticsKeyTesting = false;
        _analyticsKeyStatus = success ? 'working' : 'error';
        _analyticsKeyError = result['error'] as String?;
      });

      if (success) {
        if (showSuccessSnackbar) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $provider • $model hoạt động bình thường'),
              backgroundColor: DesignColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        _showErrorDialog(
          'API $provider không hoạt động',
          _analyticsKeyError ?? 'Lỗi không xác định',
        );
      }
      return success;
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        _analyticsKeyTesting = false;
        _analyticsKeyStatus = 'error';
        _analyticsKeyError = e.toString();
      });
      _showErrorDialog('Lỗi kiểm tra API', e.toString());
      return false;
    }
  }

  Future<bool> _testQuestionApi({bool showSuccessSnackbar = true}) async {
    final provider = _selectedProvider;
    final model = _resolveModel(
      provider: provider,
      geminiModel: _selectedGeminiModel,
      groqModel: _selectedGroqModel,
      ollamaModel: _selectedOllamaModel,
    );

    setState(() {
      _questionKeyTesting = true;
      _questionKeyStatus = null;
      _questionKeyError = null;
    });

    try {
      Map<String, dynamic> result;
      if (provider == ApiKeyService.providerGemini) {
        final fieldKey = _geminiKeyController.text.trim();
        final key = fieldKey.isNotEmpty ? fieldKey : await ApiKeyService.getGeminiApiKey();
        if (key.isEmpty) {
          result = {'success': false, 'error': 'Chưa có Gemini API key. Hãy nhập key vào ô bên dưới.'};
        } else {
          result = await ApiKeyService.testGeminiApiKey(key, model: model);
        }
      } else if (provider == ApiKeyService.providerGroq) {
        final fieldKey = _groqKeyController.text.trim();
        final key = fieldKey.isNotEmpty ? fieldKey : await ApiKeyService.getGroqApiKey();
        if (key.isEmpty) {
          result = {'success': false, 'error': 'Chưa có Groq API key. Hãy nhập key vào ô bên dưới.'};
        } else {
          result = await ApiKeyService.testGroqApiKey(key, model: model);
        }
      } else {
        final url = _ollamaUrlController.text.trim();
        if (url.isEmpty) {
          result = {'success': false, 'error': 'Chưa có Ollama URL. Hãy nhập URL vào ô bên dưới.'};
        } else {
          result = await ApiKeyService.testOllamaConnection(url);
        }
      }

      if (!mounted) return false;
      final success = result['success'] == true;
      setState(() {
        _questionKeyTesting = false;
        _questionKeyStatus = success ? 'working' : 'error';
        _questionKeyError = result['error'] as String?;
      });

      if (success) {
        if (showSuccessSnackbar) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $provider • $model hoạt động bình thường'),
              backgroundColor: DesignColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        _showErrorDialog(
          'API $provider không hoạt động',
          _questionKeyError ?? 'Lỗi không xác định',
        );
      }
      return success;
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        _questionKeyTesting = false;
        _questionKeyStatus = 'error';
        _questionKeyError = e.toString();
      });
      _showErrorDialog('Lỗi kiểm tra API', e.toString());
      return false;
    }
  }

  /// Hiển thị dialog lỗi chi tiết (dùng chung cho API key và Ollama)
  void _showErrorDialog(
    String title,
    String error, {
    String? contextMessage,
    List<String>? hints,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: DesignColors.warning),
            const SizedBox(width: DesignSpacing.sm),
            Expanded(child: Text(title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contextMessage ??
                    'API Key đã được lưu vào tài khoản của bạn, nhưng không thể kết nối đến API.',
                style: DesignTypography.bodyMedium,
              ),
              const SizedBox(height: DesignSpacing.lg),
              Container(
                padding: EdgeInsets.all(DesignSpacing.md),
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
                    const SizedBox(height: DesignSpacing.sm),
                    Text(error, style: DesignTypography.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: DesignSpacing.lg),
              Text(
                '💡 Gợi ý:',
                style: DesignTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: DesignSpacing.sm),
              Text(
                (hints ?? [
                  'Kiểm tra lại API key có đúng không',
                  'Kiểm tra kết nối internet',
                  'Kiểm tra quota và billing của API key',
                  'Thử lại sau vài phút',
                ]).map((h) => '• $h').join('\n'),
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

  Future<void> _clearOllamaUrl() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa Ollama URL?'),
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
        final cleared = await ApiKeyService.clearOllamaBaseUrl();
        if (cleared && mounted) {
          setState(() {
            _ollamaUrlController.clear();
            _ollamaAvailableModels = [];
            _ollamaConnectionStatus = null;
            _ollamaConnectionError = null;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã xóa Ollama URL'),
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
                  _buildInfoBanner(),
                  SizedBox(height: DesignSpacing.xxl),

                  // ── Phần 1: Tạo câu hỏi ────────────────────────────────
                  _buildSectionLabel(
                    '1. Tạo câu hỏi bằng AI',
                    Icons.quiz_outlined,
                    isDark,
                  ),
                  SizedBox(height: DesignSpacing.md),
                  _buildAiConfigCard(
                    isDark: isDark,
                    title: 'AI cho Tạo câu hỏi',
                    icon: Icons.auto_awesome_rounded,
                    accentColor: DesignColors.primary,
                    runningProvider: _activeProvider,
                    runningModel: _activeModel,
                    keyStatus: _questionKeyStatus,
                    isTesting: _questionKeyTesting,
                    isUpdating: _isUpdatingQuestion,
                    selectedProvider: _selectedProvider,
                    selectedGeminiModel: _selectedGeminiModel,
                    selectedGroqModel: _selectedGroqModel,
                    selectedOllamaModel: _selectedOllamaModel,
                    onProviderChanged: (v) => setState(() {
                      _selectedProvider = v;
                      _questionKeyStatus = null;
                      _questionKeyError = null;
                    }),
                    onGeminiModelChanged: (v) => setState(() {
                      _selectedGeminiModel = v;
                      _questionKeyStatus = null;
                    }),
                    onGroqModelChanged: (v) => setState(() {
                      _selectedGroqModel = v;
                      _questionKeyStatus = null;
                    }),
                    onOllamaModelChanged: (v) => setState(() {
                      _selectedOllamaModel = v;
                      _questionKeyStatus = null;
                    }),
                    onTest: _testQuestionApi,
                    onUpdate: _updateAndApplyQuestion,
                    featureChips: [
                      _buildFeatureChip('Sinh câu hỏi', Icons.create_outlined, DesignColors.primary),
                      _buildFeatureChip('Gợi ý đáp án', Icons.check_circle_outline, DesignColors.primary),
                      _buildFeatureChip('Giải thích tự động', Icons.psychology_outlined, DesignColors.primary),
                    ],
                  ),
                  SizedBox(height: DesignSpacing.xxl),

                  // ── Phần 2: Phân tích dữ liệu ───────────────────────────
                  _buildSectionLabel(
                    '2. Phân tích dữ liệu học tập',
                    Icons.analytics_outlined,
                    isDark,
                  ),
                  SizedBox(height: DesignSpacing.md),
                  _buildAiConfigCard(
                    isDark: isDark,
                    title: 'AI cho Phân tích dữ liệu',
                    icon: Icons.analytics_outlined,
                    accentColor: DesignColors.info,
                    runningProvider: _analyticsProvider,
                    runningModel: _analyticsModel,
                    keyStatus: _analyticsKeyStatus,
                    isTesting: _analyticsKeyTesting,
                    isUpdating: _isUpdatingAnalytics,
                    selectedProvider: _selectedAnalyticsProvider,
                    selectedGeminiModel: _selectedAnalyticsGeminiModel,
                    selectedGroqModel: _selectedAnalyticsGroqModel,
                    selectedOllamaModel: _selectedAnalyticsOllamaModel,
                    onProviderChanged: (v) => setState(() {
                      _selectedAnalyticsProvider = v;
                      _analyticsKeyStatus = null;
                      _analyticsKeyError = null;
                    }),
                    onGeminiModelChanged: (v) => setState(() {
                      _selectedAnalyticsGeminiModel = v;
                      _analyticsKeyStatus = null;
                    }),
                    onGroqModelChanged: (v) => setState(() {
                      _selectedAnalyticsGroqModel = v;
                      _analyticsKeyStatus = null;
                    }),
                    onOllamaModelChanged: (v) => setState(() {
                      _selectedAnalyticsOllamaModel = v;
                      _analyticsKeyStatus = null;
                    }),
                    onTest: _testAnalyticsApi,
                    onUpdate: _updateAndApplyAnalytics,
                    featureChips: [
                      _buildFeatureChip('Báo cáo học tập', Icons.bar_chart_rounded, DesignColors.info),
                      _buildFeatureChip('Phân tích xu hướng', Icons.trending_up_rounded, DesignColors.info),
                      _buildFeatureChip('Đề xuất cải thiện', Icons.lightbulb_outline, DesignColors.info),
                    ],
                  ),
                  SizedBox(height: DesignSpacing.xxl),

                  // Storage Info
                  _buildStorageInfoSection(context, isDark),
                ],
              ),
            ),
    );
  }

  // ── KEY INPUT INLINE ──────────────────────────────────────────────────
  Widget _buildInlineKeyInput(String provider, bool isDark, Color accentColor) {
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final labelColor = isDark ? Colors.grey[400]! : DesignColors.textSecondary;

    if (provider == ApiKeyService.providerOllama) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.computer_rounded, size: 14, color: labelColor),
              const SizedBox(width: 6),
              Text(
                'OLLAMA SERVER URL',
                style: TextStyle(
                  fontSize: DesignTypography.labelSmallSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  color: labelColor,
                ),
              ),
              if (_ollamaUrlController.text.isNotEmpty) ...[
                const Spacer(),
                _buildStatusDot(_ollamaConnectionStatus),
              ],
            ],
          ),
          const SizedBox(height: DesignSpacing.sm),
          TextField(
            controller: _ollamaUrlController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'http://localhost:11434',
              hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignRadius.lg),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignRadius.lg),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignRadius.lg),
                borderSide: BorderSide(color: accentColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              prefixIcon: Icon(Icons.link_rounded, size: 18, color: labelColor),
              suffixIcon: _ollamaUrlController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, size: 16, color: DesignColors.error),
                      tooltip: 'Xóa URL',
                      onPressed: _clearOllamaUrl,
                    )
                  : null,
            ),
          ),
        ],
      );
    }

    final isGemini = provider == ApiKeyService.providerGemini;
    final controller = isGemini ? _geminiKeyController : _groqKeyController;
    final obscured = isGemini ? _geminiKeyObscured : _groqKeyObscured;
    final hasKey = isGemini ? _hasGeminiKey : _hasGroqKey;
    final label = isGemini ? 'GEMINI API KEY' : 'GROQ API KEY';
    final hint = isGemini ? 'AIzaSy...' : 'gsk_...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.key_rounded, size: 14, color: labelColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: DesignTypography.labelSmallSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
                color: labelColor,
              ),
            ),
            if (hasKey) ...[
              const Spacer(),
              _buildStatusDot(isGemini ? _geminiKeyStatus : _groqKeyStatus),
            ],
          ],
        ),
        const SizedBox(height: DesignSpacing.sm),
        TextField(
          controller: controller,
          obscureText: obscured,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.lg),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.lg),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.lg),
              borderSide: BorderSide(color: accentColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            prefixIcon: Icon(Icons.lock_outline_rounded, size: 18, color: labelColor),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                    color: labelColor,
                  ),
                  onPressed: () => setState(() {
                    if (isGemini) {
                      _geminiKeyObscured = !_geminiKeyObscured;
                    } else {
                      _groqKeyObscured = !_groqKeyObscured;
                    }
                  }),
                ),
                if (hasKey)
                  IconButton(
                    icon: Icon(Icons.clear_rounded, size: 16, color: DesignColors.error),
                    tooltip: 'Xóa key',
                    onPressed: isGemini ? _clearGeminiKey : _clearGroqKey,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDot(String? status) {
    final color = status == 'working'
        ? DesignColors.success
        : status == 'error'
            ? DesignColors.error
            : DesignColors.info;
    final label = status == 'working' ? 'OK' : status == 'error' ? 'Lỗi' : 'Chưa test';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: DesignTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ── UNIFIED AI CONFIG CARD ───────────────────────────────────────────────
  Widget _buildAiConfigCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required Color accentColor,
    required String runningProvider,
    required String runningModel,
    required String? keyStatus,
    required bool isTesting,
    required bool isUpdating,
    required String selectedProvider,
    required String selectedGeminiModel,
    required String selectedGroqModel,
    required String selectedOllamaModel,
    required ValueChanged<String> onProviderChanged,
    required ValueChanged<String> onGeminiModelChanged,
    required ValueChanged<String> onGroqModelChanged,
    required ValueChanged<String> onOllamaModelChanged,
    required List<Widget> featureChips,
    required VoidCallback onTest,
    required VoidCallback onUpdate,
  }) {
    final hasKeyForProvider = switch (selectedProvider) {
      ApiKeyService.providerGroq => _hasGroqKey,
      ApiKeyService.providerOllama => _ollamaUrlController.text.isNotEmpty,
      _ => _hasGeminiKey,
    };
    final busy = isTesting || isUpdating;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.all(DesignSpacing.lg),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(DesignRadius.lg * 1.5),
                topRight: Radius.circular(DesignRadius.lg * 1.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(DesignSpacing.sm),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DesignRadius.md),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                const SizedBox(width: DesignSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: DesignTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : DesignColors.textPrimary,
                              ),
                            ),
                          ),
                          if (keyStatus != null) _buildStatusDot(keyStatus),
                        ],
                      ),
                      const SizedBox(height: DesignSpacing.xs),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Đang dùng: $runningProvider • $runningModel',
                              style: DesignTypography.bodySmall.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(DesignSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Feature chips ────────────────────────────────────────
                Wrap(children: featureChips),
                const SizedBox(height: DesignSpacing.lg),

                // ── Warning nếu chưa có key ──────────────────────────────
                if (!hasKeyForProvider) ...[
                  Container(
                    padding: EdgeInsets.all(DesignSpacing.md),
                    decoration: BoxDecoration(
                      color: DesignColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(DesignRadius.md),
                      border: Border.all(color: DesignColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: DesignColors.warning, size: 15),
                        const SizedBox(width: DesignSpacing.xs),
                        Expanded(
                          child: Text(
                            'Chưa có API key cho $selectedProvider. Nhập key bên dưới.',
                            style: DesignTypography.bodySmall.copyWith(color: DesignColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignSpacing.lg),
                ],

                // ── Provider selector ────────────────────────────────────
                SelectField<String>(
                  label: 'Provider',
                  value: selectedProvider,
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
                    SelectFieldOption(
                      value: ApiKeyService.providerOllama,
                      label: 'Ollama (Local)',
                      description: 'Chạy cục bộ, không cần internet',
                      icon: Icons.computer_rounded,
                    ),
                  ],
                  onChanged: (v) { if (v != null) onProviderChanged(v); },
                ),
                const SizedBox(height: DesignSpacing.md),

                // ── Model selector ───────────────────────────────────────
                if (selectedProvider == ApiKeyService.providerGemini)
                  SelectField<String>(
                    label: 'Model Gemini',
                    value: selectedGeminiModel,
                    prefixIcon: Icons.memory_rounded,
                    useCustomPicker: true,
                    options: const [
                      SelectFieldOption(
                        value: 'gemini-1.5-flash',
                        label: 'gemini-1.5-flash (khuyến nghị)',
                        description: 'Nhanh, tối ưu chi phí',
                        icon: Icons.bolt_outlined,
                      ),
                      SelectFieldOption(
                        value: 'gemini-2.0-flash',
                        label: 'gemini-2.0-flash',
                        description: 'Model mới hơn, thông minh hơn',
                        icon: Icons.auto_awesome,
                      ),
                    ],
                    onChanged: (v) { if (v != null) onGeminiModelChanged(v); },
                  )
                else if (selectedProvider == ApiKeyService.providerGroq)
                  SelectField<String>(
                    label: 'Model Groq',
                    value: selectedGroqModel,
                    prefixIcon: Icons.memory_rounded,
                    useCustomPicker: true,
                    options: const [
                      SelectFieldOption(
                        value: 'llama-3.1-8b-instant',
                        label: 'llama-3.1-8b-instant',
                        description: 'Nhanh, nhẹ, generate số lượng lớn',
                        icon: Icons.flash_on_outlined,
                      ),
                      SelectFieldOption(
                        value: 'llama-3.1-70b-versatile',
                        label: 'llama-3.1-70b-versatile',
                        description: 'Độ chính xác cao',
                        icon: Icons.star_rate_rounded,
                      ),
                      SelectFieldOption(
                        value: 'mixtral-8x7b-32768',
                        label: 'mixtral-8x7b-32768',
                        description: 'Context rất dài, nhiều tài liệu',
                        icon: Icons.description_outlined,
                      ),
                    ],
                    onChanged: (v) { if (v != null) onGroqModelChanged(v); },
                  )
                else if (selectedProvider == ApiKeyService.providerOllama)
                  if (_ollamaAvailableModels.isEmpty)
                    Text(
                      'Kết nối Ollama bên dưới để xem danh sách model',
                      style: DesignTypography.bodySmall.copyWith(
                        color: DesignColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    SelectField<String>(
                      label: 'Model Ollama',
                      value: selectedOllamaModel,
                      prefixIcon: Icons.memory_rounded,
                      useCustomPicker: true,
                      options: _ollamaAvailableModels
                          .map((m) => SelectFieldOption(
                                value: m,
                                label: m,
                                description: '',
                                icon: Icons.layers_outlined,
                              ))
                          .toList(),
                      onChanged: (v) { if (v != null) onOllamaModelChanged(v); },
                    ),

                // ── Divider ──────────────────────────────────────────────
                const SizedBox(height: DesignSpacing.lg),
                Row(
                  children: [
                    Expanded(child: Divider(color: isDark ? Colors.grey[700] : Colors.grey[200])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'API KEY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: isDark ? Colors.grey[700] : Colors.grey[200])),
                  ],
                ),
                const SizedBox(height: DesignSpacing.md),

                // ── Key / URL input ──────────────────────────────────────
                _buildInlineKeyInput(selectedProvider, isDark, accentColor),
                const SizedBox(height: DesignSpacing.lg),

                // ── Buttons ──────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : onTest,
                        icon: isTesting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                Icons.wifi_tethering_rounded,
                                size: 16,
                                color: busy ? null : accentColor,
                              ),
                        label: Text(
                          isTesting ? 'Đang kiểm tra...' : 'Kiểm tra',
                          style: TextStyle(color: busy ? null : accentColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: busy ? Colors.grey[300]! : accentColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: DesignSpacing.md),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: busy ? null : onUpdate,
                        icon: isUpdating
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Icon(Icons.save_rounded, size: 16),
                        label: Text(isUpdating ? 'Đang xử lý...' : 'Cập nhật'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          disabledBackgroundColor: accentColor.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignSpacing.xs),
                Text(
                  'Cập nhật = Kiểm tra → Lưu → Áp dụng tự động',
                  style: DesignTypography.bodySmall.copyWith(
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: DesignColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: DesignColors.info, size: 24),
          const SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Text(
              'API keys được lưu an toàn trong tài khoản Supabase của bạn và đồng bộ trên tất cả thiết bị.',
              style: DesignTypography.bodySmall.copyWith(color: DesignColors.info),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? Colors.grey[400] : DesignColors.textSecondary),
        const SizedBox(width: DesignSpacing.xs),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: DesignTypography.labelSmallSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: isDark ? Colors.grey[400] : DesignColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: DesignSpacing.xs, bottom: DesignSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: DesignSpacing.xs),
          Text(
            label,
            style: DesignTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
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
