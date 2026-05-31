import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/toast/app_toast.dart';
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
  final _openRouterKeyController = TextEditingController();
  bool _geminiKeyObscured = true;
  bool _groqKeyObscured = true;
  bool _openRouterKeyObscured = true;
  bool _isLoading = false;
  bool _hasGeminiKey = false;
  bool _hasGroqKey = false;
  bool _hasOpenRouterKey = false;
  List<String> _ollamaAvailableModels = [];
  String? _geminiKeyStatus; // 'working', 'error', null
  String? _groqKeyStatus; // 'working', 'error', null
  String? _ollamaConnectionStatus; // 'working', 'error', null
  String? _openRouterKeyStatus; // 'working', 'error', null

  // ── Dynamic model lists (shared, keys are shared) ──────────────────────
  List<String>? _geminiAvailableModels; // null = chưa fetch
  bool _isFetchingGeminiModels = false;
  List<String>? _groqAvailableModels;
  bool _isFetchingGroqModels = false;
  List<String> _openRouterAvailableModels = [];
  Map<String, ({String name, bool isFree})> _openRouterModelMeta = {};
  bool _isFetchingOpenRouterModels = false;

  // ── Tạo câu hỏi ────────────────────────────────────────────────────────
  String _activeProvider = ApiKeyService.providerGemini;
  String _activeModel = ApiKeyService.defaultGeminiModel;
  String _selectedProvider = ApiKeyService.providerGemini;
  String _selectedGeminiModel = ApiKeyService.defaultGeminiModel;
  String _selectedGroqModel = ApiKeyService.defaultGroqModel;
  String _selectedOllamaModel = ApiKeyService.defaultOllamaModel;
  String _selectedOpenRouterModel = ApiKeyService.defaultOpenRouterModel;

  // ── Phân tích dữ liệu ──────────────────────────────────────────────────
  String _analyticsProvider = ApiKeyService.providerGemini;
  String _analyticsModel = ApiKeyService.defaultGeminiModel;
  String _selectedAnalyticsProvider = ApiKeyService.providerGemini;
  String _selectedAnalyticsGeminiModel = ApiKeyService.defaultGeminiModel;
  String _selectedAnalyticsGroqModel = ApiKeyService.defaultGroqModel;
  String _selectedAnalyticsOllamaModel = ApiKeyService.defaultOllamaModel;
  String _selectedAnalyticsOpenRouterModel = ApiKeyService.defaultOpenRouterModel;
  String? _analyticsKeyStatus; // 'working', 'error', null
  String? _analyticsKeyError;
  bool _analyticsKeyTesting = false;

  // ── Test API cho tạo câu hỏi ───────────────────────────────────────────
  String? _questionKeyStatus; // 'working', 'error', null
  String? _questionKeyError;
  bool _questionKeyTesting = false;
  bool _isUpdatingQuestion = false;
  bool _isUpdatingAnalytics = false;

  // ── Ollama model controllers (nhập thủ công) ───────────────────────────
  final _ollamaModelQuestionController = TextEditingController(
    text: ApiKeyService.defaultOllamaModel,
  );
  final _ollamaModelAnalyticsController = TextEditingController(
    text: ApiKeyService.defaultOllamaModel,
  );
  bool _isFetchingOllamaModels = false;

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
      ApiKeyService.getOpenRouterApiKey(),
    ]);
    final hasGemini = await ApiKeyService.hasGeminiApiKey();
    final hasGroq = await ApiKeyService.hasGroqApiKey();
    final hasOpenRouter = await ApiKeyService.hasOpenRouterApiKey();

    final geminiKey = results[0];
    final groqKey = results[1];
    final ollamaUrl = results[2];
    final provider = results[3];
    final model = results[4];
    final analyticsProvider = results[5];
    final analyticsModel = results[6];
    final openRouterKey = results[7];

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
      if (openRouterKey.isNotEmpty) {
        _openRouterKeyController.text = openRouterKey;
        _hasOpenRouterKey = hasOpenRouter;
      }

      _activeProvider = provider;
      _activeModel = model;
      _selectedProvider = provider;
      if (provider == ApiKeyService.providerGroq) {
        _selectedGroqModel = model;
      } else if (provider == ApiKeyService.providerOllama) {
        _selectedOllamaModel = model;
        _ollamaModelQuestionController.text = model;
      } else if (provider == ApiKeyService.providerOpenRouter) {
        _selectedOpenRouterModel = model;
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
        _ollamaModelAnalyticsController.text = analyticsModel;
      } else if (analyticsProvider == ApiKeyService.providerOpenRouter) {
        _selectedAnalyticsOpenRouterModel = analyticsModel;
      } else {
        _selectedAnalyticsGeminiModel = analyticsModel;
      }
    });

    // Auto-fetch Ollama models nếu URL đã lưu
    if (ollamaUrl.isNotEmpty) {
      _fetchOllamaModels(ollamaUrl.toString());
    }
  }

  /// Fetch danh sách models từ Ollama server (background, không block UI)
  Future<void> _fetchOllamaModels(String url) async {
    if (url.isEmpty || _isFetchingOllamaModels) return;
    setState(() => _isFetchingOllamaModels = true);
    try {
      final result = await ApiKeyService.testOllamaConnection(url);
      if (!mounted) return;
      final models = (result['models'] as List<dynamic>?)
              ?.map((m) => m.toString())
              .toList() ??
          [];
      setState(() {
        _ollamaAvailableModels = models;
        _isFetchingOllamaModels = false;
        if (result['success'] == true) {
          _ollamaConnectionStatus = 'working';
        }
      });
    } catch (_) {
      if (mounted) setState(() => _isFetchingOllamaModels = false);
    }
  }

  Future<void> _fetchGeminiModels() async {
    final key = _geminiKeyController.text.trim();
    if (key.isEmpty || _isFetchingGeminiModels) return;
    setState(() => _isFetchingGeminiModels = true);
    try {
      final models = await ApiKeyService.fetchGeminiModels(key);
      if (!mounted) return;
      setState(() {
        _geminiAvailableModels = models;
        _isFetchingGeminiModels = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isFetchingGeminiModels = false);
    }
  }

  Future<void> _fetchGroqModels() async {
    final key = _groqKeyController.text.trim();
    if (key.isEmpty || _isFetchingGroqModels) return;
    setState(() => _isFetchingGroqModels = true);
    try {
      final models = await ApiKeyService.fetchGroqModels(key);
      if (!mounted) return;
      setState(() {
        _groqAvailableModels = models;
        _isFetchingGroqModels = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isFetchingGroqModels = false);
    }
  }

  Future<void> _fetchOpenRouterModels() async {
    if (_isFetchingOpenRouterModels) return;
    setState(() => _isFetchingOpenRouterModels = true);
    try {
      final raw = await ApiKeyService.fetchOpenRouterModels();
      if (!mounted) return;
      final ids = <String>[];
      final meta = <String, ({String name, bool isFree})>{};
      for (final m in raw) {
        final id = m['id'] as String? ?? '';
        if (id.isEmpty) continue;
        ids.add(id);
        meta[id] = (
          name: m['name'] as String? ?? id,
          isFree: m['isFree'] as bool? ?? false,
        );
      }
      setState(() {
        _openRouterAvailableModels = ids;
        _openRouterModelMeta = meta;
        _isFetchingOpenRouterModels = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isFetchingOpenRouterModels = false);
    }
  }

  /// Nhận diện model có khả năng thinking/reasoning dựa trên model ID.
  /// Áp dụng cho DeepSeek-R1, QwQ, Gemini Thinking, OpenAI o1/o3, v.v.
  static bool _isThinkingModel(String modelId) {
    final id = modelId.toLowerCase();
    if (id.contains('thinking')) return true;
    if (id.contains('deepseek-r1') || id.contains('deepseek-r2')) return true;
    if (id.contains('qwq')) return true;
    if (id.contains('reasoning')) return true;
    // o1/o3 family: /o1, /o3, o1-, o3-mini, v.v. — tránh match gpt-4o
    if (RegExp(r'(?:^|[/\-:])o[13](?:$|[/\-:\d])').hasMatch(id)) return true;
    return false;
  }

  /// Chọn model theo provider. Tất cả params required để callers
  /// KHÔNG bị silent fallback về hardcoded default — đã từng bị bug
  /// "nút Test luôn dùng gemma-3-4b" do quên truyền openRouterModel.
  String _resolveModel({
    required String provider,
    required String geminiModel,
    required String groqModel,
    required String ollamaModel,
    required String openRouterModel,
  }) => switch (provider) {
    ApiKeyService.providerGroq => groqModel,
    ApiKeyService.providerOllama => ollamaModel,
    ApiKeyService.providerOpenRouter => openRouterModel,
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
      openRouterModel: _selectedOpenRouterModel,
    );

    try {
      // ── Bước 1: Lấy key/URL từ field ──────────────────────────────────
      final geminiKey = _geminiKeyController.text.trim();
      final groqKey = _groqKeyController.text.trim();
      final ollamaUrl = _ollamaUrlController.text.trim();
      final openRouterKey = _openRouterKeyController.text.trim();

      if (provider == ApiKeyService.providerOllama) {
        if (ollamaUrl.isEmpty) {
          if (!mounted) return;
          setState(() => _isUpdatingQuestion = false);
          AppToast.warning(context, '⚠️ Vui lòng nhập Ollama URL');
          return;
        }
      } else {
        final key = switch (provider) {
          ApiKeyService.providerGroq => groqKey,
          ApiKeyService.providerOpenRouter => openRouterKey,
          _ => geminiKey,
        };
        if (key.isEmpty) {
          if (!mounted) return;
          setState(() => _isUpdatingQuestion = false);
          AppToast.warning(context, '⚠️ Vui lòng nhập API key');
          return;
        }
      }

      // ── Bước 2: Test API ───────────────────────────────────────────────
      Map<String, dynamic> testResult;
      if (provider == ApiKeyService.providerGemini) {
        testResult = await ApiKeyService.testGeminiApiKey(geminiKey, model: model);
      } else if (provider == ApiKeyService.providerGroq) {
        testResult = await ApiKeyService.testGroqApiKey(groqKey, model: model);
      } else if (provider == ApiKeyService.providerOpenRouter) {
        testResult = await ApiKeyService.testOpenRouterApiKey(openRouterKey, model: model);
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

      // Cập nhật models list nếu là Ollama
      if (provider == ApiKeyService.providerOllama) {
        final models = (testResult['models'] as List<dynamic>?)
                ?.map((m) => m.toString())
                .toList() ??
            [];
        if (models.isNotEmpty) {
          setState(() {
            _ollamaAvailableModels = models;
            _ollamaConnectionStatus = 'working';
          });
        }
      }

      setState(() => _questionKeyStatus = 'working');

      // ── Bước 3: Lưu key/URL ────────────────────────────────────────────
      Map<String, dynamic> saveResult;
      if (provider == ApiKeyService.providerGemini) {
        saveResult = await ApiKeyService.setGeminiApiKey(geminiKey, setActive: false, model: model);
      } else if (provider == ApiKeyService.providerGroq) {
        saveResult = await ApiKeyService.setGroqApiKey(groqKey, setActive: false, model: model);
      } else if (provider == ApiKeyService.providerOpenRouter) {
        saveResult = await ApiKeyService.setOpenRouterApiKey(openRouterKey, setActive: false, model: model, skipTest: true);
      } else {
        saveResult = await ApiKeyService.setOllamaBaseUrl(ollamaUrl, model: model, setActive: false);
      }

      if (!mounted) return;
      if (saveResult['saved'] != true) {
        setState(() => _isUpdatingQuestion = false);
        AppToast.error(context, '❌ Lưu thất bại: ${saveResult['error'] ?? 'Unknown'}');
        return;
      }

      // Cập nhật trạng thái has key
      if (provider == ApiKeyService.providerGemini) {
        setState(() => _hasGeminiKey = true);
      } else if (provider == ApiKeyService.providerGroq) {
        setState(() => _hasGroqKey = true);
      } else if (provider == ApiKeyService.providerOpenRouter) {
        setState(() => _hasOpenRouterKey = true);
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

      if (ok) {
        AppToast.success(context, '✅ Đã cập nhật và áp dụng: $provider • $model');
      } else {
        AppToast.warning(context, '⚠️ Đã lưu key nhưng không thể áp dụng cấu hình');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUpdatingQuestion = false;
        _questionKeyStatus = 'error';
        _questionKeyError = e.toString();
      });
      AppToast.error(context, '❌ Lỗi: ${e.toString()}');
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
      openRouterModel: _selectedAnalyticsOpenRouterModel,
    );

    try {
      // ── Bước 1: Lấy key/URL từ field ──────────────────────────────────
      final geminiKey = _geminiKeyController.text.trim();
      final groqKey = _groqKeyController.text.trim();
      final ollamaUrl = _ollamaUrlController.text.trim();
      final openRouterKey = _openRouterKeyController.text.trim();

      if (provider == ApiKeyService.providerOllama) {
        if (ollamaUrl.isEmpty) {
          if (!mounted) return;
          setState(() => _isUpdatingAnalytics = false);
          AppToast.warning(context, '⚠️ Vui lòng nhập Ollama URL');
          return;
        }
      } else {
        final key = switch (provider) {
          ApiKeyService.providerGroq => groqKey,
          ApiKeyService.providerOpenRouter => openRouterKey,
          _ => geminiKey,
        };
        if (key.isEmpty) {
          if (!mounted) return;
          setState(() => _isUpdatingAnalytics = false);
          AppToast.warning(context, '⚠️ Vui lòng nhập API key');
          return;
        }
      }

      // ── Bước 2: Test API ───────────────────────────────────────────────
      Map<String, dynamic> testResult;
      if (provider == ApiKeyService.providerGemini) {
        testResult = await ApiKeyService.testGeminiApiKey(geminiKey, model: model);
      } else if (provider == ApiKeyService.providerGroq) {
        testResult = await ApiKeyService.testGroqApiKey(groqKey, model: model);
      } else if (provider == ApiKeyService.providerOpenRouter) {
        testResult = await ApiKeyService.testOpenRouterApiKey(openRouterKey, model: model);
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

      // Cập nhật models list nếu là Ollama
      if (provider == ApiKeyService.providerOllama) {
        final models = (testResult['models'] as List<dynamic>?)
                ?.map((m) => m.toString())
                .toList() ??
            [];
        if (models.isNotEmpty) {
          setState(() {
            _ollamaAvailableModels = models;
            _ollamaConnectionStatus = 'working';
          });
        }
      }

      setState(() => _analyticsKeyStatus = 'working');

      // ── Bước 3: Lưu key/URL ────────────────────────────────────────────
      Map<String, dynamic> saveResult;
      if (provider == ApiKeyService.providerGemini) {
        saveResult = await ApiKeyService.setGeminiApiKey(geminiKey, setActive: false, model: model);
      } else if (provider == ApiKeyService.providerGroq) {
        saveResult = await ApiKeyService.setGroqApiKey(groqKey, setActive: false, model: model);
      } else if (provider == ApiKeyService.providerOpenRouter) {
        saveResult = await ApiKeyService.setOpenRouterApiKey(openRouterKey, setActive: false, model: model, skipTest: true);
      } else {
        saveResult = await ApiKeyService.setOllamaBaseUrl(ollamaUrl, model: model, setActive: false);
      }

      if (!mounted) return;
      if (saveResult['saved'] != true) {
        setState(() => _isUpdatingAnalytics = false);
        AppToast.error(context, '❌ Lưu thất bại: ${saveResult['error'] ?? 'Unknown'}');
        return;
      }

      if (provider == ApiKeyService.providerGemini) {
        setState(() => _hasGeminiKey = true);
      } else if (provider == ApiKeyService.providerGroq) {
        setState(() => _hasGroqKey = true);
      } else if (provider == ApiKeyService.providerOpenRouter) {
        setState(() => _hasOpenRouterKey = true);
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

      if (ok) {
        AppToast.success(context, '✅ Đã cập nhật và áp dụng: $provider • $model');
      } else {
        AppToast.warning(context, '⚠️ Đã lưu key nhưng không thể áp dụng cấu hình');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUpdatingAnalytics = false;
        _analyticsKeyStatus = 'error';
        _analyticsKeyError = e.toString();
      });
      AppToast.error(context, '❌ Lỗi: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _geminiKeyController.dispose();
    _groqKeyController.dispose();
    _ollamaUrlController.dispose();
    _openRouterKeyController.dispose();
    _ollamaModelQuestionController.dispose();
    _ollamaModelAnalyticsController.dispose();
    super.dispose();
  }

  Future<bool> _testAnalyticsApi({bool showSuccessSnackbar = true}) async {
    final provider = _selectedAnalyticsProvider;
    final model = _resolveModel(
      provider: provider,
      geminiModel: _selectedAnalyticsGeminiModel,
      groqModel: _selectedAnalyticsGroqModel,
      ollamaModel: _selectedAnalyticsOllamaModel,
      openRouterModel: _selectedAnalyticsOpenRouterModel,
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
      } else if (provider == ApiKeyService.providerOpenRouter) {
        final fieldKey = _openRouterKeyController.text.trim();
        final key = fieldKey.isNotEmpty ? fieldKey : await ApiKeyService.getOpenRouterApiKey();
        if (key.isEmpty) {
          result = {'success': false, 'error': 'Chưa có OpenRouter API key. Hãy nhập key vào ô bên dưới.'};
        } else {
          result = await ApiKeyService.testOpenRouterApiKey(key, model: model);
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

      // Cập nhật models list nếu là Ollama
      if (provider == ApiKeyService.providerOllama && success) {
        final models = (result['models'] as List<dynamic>?)
                ?.map((m) => m.toString())
                .toList() ??
            [];
        if (models.isNotEmpty) {
          setState(() {
            _ollamaAvailableModels = models;
            _ollamaConnectionStatus = 'working';
          });
        }
      }

      setState(() {
        _analyticsKeyTesting = false;
        _analyticsKeyStatus = success ? 'working' : 'error';
        _analyticsKeyError = result['error'] as String?;
      });

      if (success) {
        if (showSuccessSnackbar) {
          AppToast.success(context, '✅ $provider • $model hoạt động bình thường');
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
      openRouterModel: _selectedOpenRouterModel,
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
      } else if (provider == ApiKeyService.providerOpenRouter) {
        final fieldKey = _openRouterKeyController.text.trim();
        final key = fieldKey.isNotEmpty ? fieldKey : await ApiKeyService.getOpenRouterApiKey();
        if (key.isEmpty) {
          result = {'success': false, 'error': 'Chưa có OpenRouter API key. Hãy nhập key vào ô bên dưới.'};
        } else {
          result = await ApiKeyService.testOpenRouterApiKey(key, model: model);
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

      // Cập nhật models list nếu là Ollama
      if (provider == ApiKeyService.providerOllama && success) {
        final models = (result['models'] as List<dynamic>?)
                ?.map((m) => m.toString())
                .toList() ??
            [];
        if (models.isNotEmpty) {
          setState(() {
            _ollamaAvailableModels = models;
            _ollamaConnectionStatus = 'working';
          });
        }
      }

      setState(() {
        _questionKeyTesting = false;
        _questionKeyStatus = success ? 'working' : 'error';
        _questionKeyError = result['error'] as String?;
      });

      if (success) {
        if (showSuccessSnackbar) {
          AppToast.success(context, '✅ $provider • $model hoạt động bình thường');
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
            _isLoading = false;
          });
          AppToast.success(context, '✅ Đã xóa Gemini API Key');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          AppToast.error(context, '❌ Lỗi: ${e.toString()}');
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
            _isLoading = false;
          });
          AppToast.success(context, '✅ Đã xóa Groq API Key');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          AppToast.error(context, '❌ Lỗi: ${e.toString()}');
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
            _isLoading = false;
          });
          AppToast.success(context, '✅ Đã xóa Ollama URL');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          AppToast.error(context, '❌ Lỗi: ${e.toString()}');
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
                    selectedOpenRouterModel: _selectedOpenRouterModel,
                    ollamaModelController: _ollamaModelQuestionController,
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
                    onOpenRouterModelChanged: (v) => setState(() {
                      _selectedOpenRouterModel = v;
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
                    selectedOpenRouterModel: _selectedAnalyticsOpenRouterModel,
                    ollamaModelController: _ollamaModelAnalyticsController,
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
                    onOpenRouterModelChanged: (v) => setState(() {
                      _selectedAnalyticsOpenRouterModel = v;
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

  // ── OLLAMA MODEL INPUT ───────────────────────────────────────────────────
  Widget _buildOllamaModelInput({
    required bool isDark,
    required Color accentColor,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final labelColor = isDark ? Colors.grey[400]! : DesignColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text field nhập model thủ công
        TextField(
          controller: controller,
          onChanged: (v) => onChanged(v.trim()),
          decoration: InputDecoration(
            labelText: 'Model Ollama',
            hintText: 'mistral, llama3:8b, codellama:7b...',
            hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
            prefixIcon: Icon(Icons.memory_rounded, size: 18, color: labelColor),
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
          ),
        ),
        // Chips danh sách models đã cài (nếu có)
        if (_ollamaAvailableModels.isNotEmpty) ...[
          const SizedBox(height: DesignSpacing.sm),
          Row(
            children: [
              Icon(Icons.check_circle_outline, size: 12, color: DesignColors.success),
              const SizedBox(width: 4),
              Text(
                'Đã cài (${_ollamaAvailableModels.length}):',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _ollamaAvailableModels.map((m) {
              final isSelected = controller.text.trim() == m;
              return GestureDetector(
                onTap: () {
                  controller.text = m;
                  onChanged(m);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor.withValues(alpha: 0.12)
                        : isDark
                            ? Colors.grey[800]
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(DesignRadius.full),
                    border: Border.all(
                      color: isSelected
                          ? accentColor.withValues(alpha: 0.5)
                          : isDark
                              ? Colors.grey[700]!
                              : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    m,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? accentColor
                          : isDark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ] else if (_isFetchingOllamaModels) ...[
          const SizedBox(height: DesignSpacing.xs),
          Row(
            children: [
              const SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
              const SizedBox(width: 6),
              Text(
                'Đang lấy danh sách model...',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: DesignSpacing.xs),
          Text(
            'Kết nối Ollama bên dưới để xem danh sách model đã cài',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],

        // ── Nút xem & chọn model ──────────────────────────────────────
        const SizedBox(height: DesignSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isFetchingOllamaModels
                ? null
                : () => _showOllamaModelBottomSheet(
                      isDark: isDark,
                      accentColor: accentColor,
                      controller: controller,
                      onChanged: onChanged,
                    ),
            icon: _isFetchingOllamaModels
                ? const SizedBox(
                    width: 13,
                    height: 13,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  )
                : Icon(Icons.list_alt_rounded, size: 15, color: accentColor),
            label: Text(
              _isFetchingOllamaModels
                  ? 'Đang tải...'
                  : _ollamaAvailableModels.isEmpty
                      ? 'Kiểm tra & chọn model'
                      : 'Chọn model (${_ollamaAvailableModels.length} đã cài)',
              style: TextStyle(fontSize: 13, color: accentColor),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _isFetchingOllamaModels
                    ? Colors.grey[400]!
                    : accentColor,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  // ── UNIFIED MODEL PICKER (Gemini / Groq / OpenRouter) ─────────────────────
  Widget _buildUnifiedModelPicker({
    required String provider,
    required String currentModel,
    required List<String>? availableModels,
    required bool isFetching,
    required VoidCallback onFetch,
    required ValueChanged<String> onChanged,
    required bool isDark,
    required Color accentColor,
    bool fetchDisabled = false,
  }) {
    final labelColor = isDark ? Colors.grey[400]! : DesignColors.textSecondary;
    final models = availableModels ?? [];
    final isOpenRouter = provider == ApiKeyService.providerOpenRouter;
    final isFree = isOpenRouter && (_openRouterModelMeta[currentModel]?.isFree ?? currentModel.endsWith(':free'));
    final displayName = isOpenRouter
        ? (_openRouterModelMeta[currentModel]?.name ?? currentModel)
        : currentModel;
    final providerLabel = switch (provider) {
      ApiKeyService.providerGemini => 'Gemini',
      ApiKeyService.providerGroq => 'Groq',
      ApiKeyService.providerOpenRouter => 'OpenRouter',
      _ => provider,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ─────────────────────────────────────────────────────────
        Row(
          children: [
            Icon(Icons.memory_rounded, size: 13, color: labelColor),
            const SizedBox(width: 4),
            Text(
              'MODEL ${providerLabel.toUpperCase()}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
                color: labelColor,
              ),
            ),
            if (models.isNotEmpty) ...[
              const Spacer(),
              Text(
                '${models.length} model',
                style: TextStyle(fontSize: 10, color: labelColor),
              ),
            ],
          ],
        ),
        const SizedBox(height: DesignSpacing.sm),
        // ── Tap tile → mở sheet ──────────────────────────────────────────
        GestureDetector(
          onTap: models.isEmpty && fetchDisabled
              ? null
              : () => _showUnifiedModelSheet(
                    provider: provider,
                    isDark: isDark,
                    accentColor: accentColor,
                    currentModel: currentModel,
                    models: models,
                    onChanged: onChanged,
                    onFetch: onFetch,
                    isFetching: isFetching,
                    fetchDisabled: fetchDisabled,
                  ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(DesignRadius.lg),
              color: isDark ? Colors.grey[850] : Colors.grey[50],
            ),
            child: Row(
              children: [
                Icon(Icons.memory_rounded, size: 18, color: labelColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentModel.isEmpty
                            ? 'Tải danh sách model để chọn'
                            : displayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: currentModel.isEmpty
                              ? Colors.grey
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isOpenRouter && currentModel.isNotEmpty && displayName != currentModel)
                        Text(
                          currentModel,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (isFree)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: DesignColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(DesignRadius.full),
                    ),
                    child: Text(
                      'FREE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: DesignColors.success,
                      ),
                    ),
                  ),
                if (currentModel.isNotEmpty && _isThinkingModel(currentModel))
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.psychology_rounded,
                      size: 16,
                      color: Colors.purple[400],
                    ),
                  ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down_rounded, color: labelColor),
              ],
            ),
          ),
        ),
        const SizedBox(height: DesignSpacing.xs),
        // ── Nút Fetch ────────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: (isFetching || fetchDisabled) ? null : onFetch,
            icon: isFetching
                ? const SizedBox(
                    width: 13,
                    height: 13,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  )
                : Icon(
                    Icons.refresh_rounded,
                    size: 15,
                    color: fetchDisabled ? null : accentColor,
                  ),
            label: Text(
              isFetching
                  ? 'Đang tải...'
                  : fetchDisabled
                      ? 'Nhập API key để tải danh sách model'
                      : models.isEmpty
                          ? 'Tải danh sách model từ API'
                          : 'Tải lại (${models.length} model)',
              style: TextStyle(
                fontSize: 12,
                color: fetchDisabled ? Colors.grey : accentColor,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: fetchDisabled ? Colors.grey[300]! : accentColor,
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  // ── UNIFIED MODEL BOTTOM SHEET ───────────────────────────────────────────
  void _showUnifiedModelSheet({
    required String provider,
    required bool isDark,
    required Color accentColor,
    required String currentModel,
    required List<String> models,
    required ValueChanged<String> onChanged,
    required VoidCallback onFetch,
    required bool isFetching,
    required bool fetchDisabled,
  }) {
    // Auto-fetch nếu chưa có data
    if (models.isEmpty && !isFetching && !fetchDisabled) {
      onFetch();
    }

    String searchQuery = '';
    bool filterFree = false;
    bool filterThinking = false;
    int displayCount = 40; // Lazy load: hiển thị 40 items đầu
    final isOpenRouter = provider == ApiKeyService.providerOpenRouter;
    final providerLabel = switch (provider) {
      ApiKeyService.providerGemini => 'Gemini',
      ApiKeyService.providerGroq => 'Groq',
      ApiKeyService.providerOpenRouter => 'OpenRouter',
      _ => provider,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          // Lấy lại models mới nhất từ state (vì có thể fetch xong sau khi mở sheet)
          final latestModels = switch (provider) {
            ApiKeyService.providerGemini => _geminiAvailableModels ?? [],
            ApiKeyService.providerGroq => _groqAvailableModels ?? [],
            ApiKeyService.providerOpenRouter => _openRouterAvailableModels,
            _ => models,
          };
          final latestFetching = switch (provider) {
            ApiKeyService.providerGemini => _isFetchingGeminiModels,
            ApiKeyService.providerGroq => _isFetchingGroqModels,
            ApiKeyService.providerOpenRouter => _isFetchingOpenRouterModels,
            _ => isFetching,
          };

          // Filter
          final filtered = latestModels.where((id) {
            if (isOpenRouter && filterFree) {
              final meta = _openRouterModelMeta[id];
              final isFreeModel = meta?.isFree ?? id.endsWith(':free');
              if (!isFreeModel) return false;
            }
            if (filterThinking && !_isThinkingModel(id)) return false;
            if (searchQuery.isEmpty) return true;
            final q = searchQuery.toLowerCase();
            if (id.toLowerCase().contains(q)) return true;
            if (isOpenRouter) {
              final meta = _openRouterModelMeta[id];
              if (meta != null && meta.name.toLowerCase().contains(q)) return true;
            }
            return false;
          }).toList();

          // Lazy load: chỉ hiện displayCount items
          final visibleItems = filtered.take(displayCount).toList();
          final hasMore = filtered.length > displayCount;

          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (_, scrollCtrl) {
              // Lazy load: khi scroll gần cuối → tăng displayCount
              scrollCtrl.addListener(() {
                if (scrollCtrl.hasClients &&
                    scrollCtrl.position.pixels >=
                        scrollCtrl.position.maxScrollExtent - 200 &&
                    hasMore) {
                  setSheetState(() => displayCount += 40);
                }
              });

              return Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[600] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // ── Header ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.memory_rounded, color: accentColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Chọn model $providerLabel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        if (latestFetching)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Text(
                            '${latestModels.length} model',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ── Search ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm model...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                      onChanged: (v) => setSheetState(() {
                        searchQuery = v;
                        displayCount = 40;
                      }),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ── Filter pills ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        if (isOpenRouter)
                          _FilterPill(
                            active: filterFree,
                            icon: Icons.money_off_csred_rounded,
                            label: 'Miễn phí',
                            color: DesignColors.success,
                            isDark: isDark,
                            onTap: () => setSheetState(() {
                              filterFree = !filterFree;
                              displayCount = 40;
                            }),
                          ),
                        if (isOpenRouter) const SizedBox(width: 8),
                        _FilterPill(
                          active: filterThinking,
                          icon: Icons.psychology_rounded,
                          label: 'Thinking',
                          color: Colors.purple[400]!,
                          isDark: isDark,
                          onTap: () => setSheetState(() {
                            filterThinking = !filterThinking;
                            displayCount = 40;
                          }),
                        ),
                      ],
                    ),
                  ),
                  // ── Fetch button inside sheet ────────────────────────────
                  if (!fetchDisabled)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: latestFetching
                              ? null
                              : () {
                                  onFetch();
                                  // Cần re-read state sau khi fetch xong
                                  Future.delayed(
                                    const Duration(milliseconds: 500),
                                    () {
                                      if (ctx.mounted) setSheetState(() {});
                                    },
                                  );
                                },
                          icon: latestFetching
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 1.5),
                                )
                              : Icon(Icons.refresh_rounded, size: 14, color: accentColor),
                          label: Text(
                            latestFetching
                                ? 'Đang tải...'
                                : latestModels.isEmpty
                                    ? 'Tải danh sách model'
                                    : 'Tải lại danh sách',
                            style: TextStyle(fontSize: 12, color: accentColor),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: accentColor),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  // ── Filter info bar ──────────────────────────────────────
                  if (searchQuery.isNotEmpty || filterFree || filterThinking)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Icons.filter_list_rounded, size: 14, color: accentColor),
                          const SizedBox(width: 4),
                          Text(
                            '${filtered.length} kết quả',
                            style: TextStyle(fontSize: 12, color: accentColor, fontWeight: FontWeight.w500),
                          ),
                          if (hasMore) ...[
                            const SizedBox(width: 8),
                            Text(
                              '(hiển thị ${visibleItems.length})',
                              style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[500] : Colors.grey[500]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  // ── Model list ──────────────────────────────────────────
                  if (latestFetching && latestModels.isEmpty)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (latestModels.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_off_rounded,
                              size: 40,
                              color: isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Chưa có danh sách model',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bấm "Tải danh sách model" để lấy dữ liệu',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[600] : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (filtered.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'Không tìm thấy model phù hợp',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: scrollCtrl,
                        itemCount: visibleItems.length + (hasMore ? 1 : 0),
                        itemBuilder: (_, i) {
                          // Loading indicator cuối list
                          if (i >= visibleItems.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          }
                          final id = visibleItems[i];
                          final isSelected = id == currentModel;
                          // OpenRouter: hiển thị name + free badge
                          String displayTitle = id;
                          bool modelIsFree = false;
                          if (isOpenRouter) {
                            final meta = _openRouterModelMeta[id];
                            if (meta != null) {
                              displayTitle = meta.name;
                              modelIsFree = meta.isFree;
                            }
                          }
                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: accentColor.withValues(alpha: 0.08),
                            leading: Icon(
                              isOpenRouter
                                  ? (modelIsFree
                                      ? Icons.money_off_csred_rounded
                                      : Icons.attach_money_rounded)
                                  : Icons.layers_outlined,
                              size: 18,
                              color: isSelected
                                  ? accentColor
                                  : modelIsFree
                                      ? DesignColors.success
                                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            ),
                            title: Text(
                              isOpenRouter ? displayTitle : id,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? accentColor : null,
                              ),
                            ),
                            subtitle: isOpenRouter && displayTitle != id
                                ? Text(
                                    id,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                                    ),
                                  )
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (modelIsFree)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: DesignColors.success.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'FREE',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: DesignColors.success,
                                      ),
                                    ),
                                  ),
                                if (_isThinkingModel(id)) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.psychology_rounded,
                                    size: 16,
                                    color: Colors.purple[400],
                                  ),
                                ],
                                if (isSelected) ...[
                                  const SizedBox(width: 4),
                                  Icon(Icons.check_rounded, size: 18, color: accentColor),
                                ],
                              ],
                            ),
                            onTap: () {
                              onChanged(id);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }


  Widget _buildOpenRouterKeyInput({required bool isDark, required Color accentColor}) {
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final labelColor = isDark ? Colors.grey[400]! : DesignColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.key_rounded, size: 14, color: labelColor),
            const SizedBox(width: 6),
            Text(
              'OPENROUTER API KEY',
              style: TextStyle(fontSize: DesignTypography.labelSmallSize, fontWeight: FontWeight.bold, letterSpacing: 0.6, color: labelColor),
            ),
            if (_hasOpenRouterKey) ...[
              const Spacer(),
              _buildStatusDot(_openRouterKeyStatus),
            ],
          ],
        ),
        const SizedBox(height: DesignSpacing.sm),
        TextField(
          controller: _openRouterKeyController,
          obscureText: _openRouterKeyObscured,
          decoration: InputDecoration(
            hintText: 'sk-or-...',
            hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.lg), borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.lg), borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.lg), borderSide: BorderSide(color: accentColor, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            prefixIcon: Icon(Icons.lock_outline_rounded, size: 18, color: labelColor),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _openRouterKeyObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                    color: labelColor,
                  ),
                  onPressed: () => setState(() => _openRouterKeyObscured = !_openRouterKeyObscured),
                ),
                if (_hasOpenRouterKey)
                  IconButton(
                    icon: Icon(Icons.clear_rounded, size: 16, color: DesignColors.error),
                    tooltip: 'Xóa key',
                    onPressed: _clearOpenRouterKey,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DesignSpacing.xs),
        Text(
          'Lấy API key tại openrouter.ai/keys — Hỗ trợ 200+ model, nhiều model free.',
          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: isDark ? Colors.grey[500] : Colors.grey[500]),
        ),
      ],
    );
  }

  Future<void> _clearOpenRouterKey() async {
    await ApiKeyService.clearOpenRouterApiKey();
    if (!mounted) return;
    setState(() {
      _openRouterKeyController.clear();
      _hasOpenRouterKey = false;
      _openRouterKeyStatus = null;
    });
    AppToast.success(context, '✅ Đã xóa OpenRouter API key');
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
                _isFetchingOllamaModels
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      )
                    : _buildStatusDot(_ollamaConnectionStatus),
              ],
            ],
          ),
          const SizedBox(height: DesignSpacing.sm),
          TextField(
            controller: _ollamaUrlController,
            onChanged: (_) => setState(() {
              _ollamaConnectionStatus = null;
            }),
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
          const SizedBox(height: DesignSpacing.sm),
          // ── Quick URL presets ────────────────────────────────────────────
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flash_on_rounded, size: 12, color: labelColor),
                  const SizedBox(width: 4),
                  Text(
                    'QUICK:',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: labelColor,
                    ),
                  ),
                ],
              ),
              _buildUrlPresetChip(
                'Kiểm tra trên PC',
                Icons.monitor_rounded,
                'http://127.0.0.1:11434',
                accentColor,
                isDark,
              ),
              _buildUrlPresetChip(
                'Kiểm tra từ Emulator',
                Icons.phone_android_rounded,
                null, // mở dialog nhập IP LAN
                accentColor,
                isDark,
              ),
              _buildUrlPresetChip(
                'Dùng trên PC (Mạng)',
                Icons.lan_rounded,
                'http://localhost:11434',
                accentColor,
                isDark,
              ),
            ],
          ),
        ],
      );
    }

    if (provider == ApiKeyService.providerOpenRouter) {
      return _buildOpenRouterKeyInput(isDark: isDark, accentColor: accentColor);
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
    required String selectedOpenRouterModel,
    required TextEditingController ollamaModelController,
    required ValueChanged<String> onProviderChanged,
    required ValueChanged<String> onGeminiModelChanged,
    required ValueChanged<String> onGroqModelChanged,
    required ValueChanged<String> onOllamaModelChanged,
    required ValueChanged<String> onOpenRouterModelChanged,
    required List<Widget> featureChips,
    required VoidCallback onTest,
    required VoidCallback onUpdate,
  }) {
    final hasKeyForProvider = switch (selectedProvider) {
      ApiKeyService.providerGroq => _hasGroqKey,
      ApiKeyService.providerOllama => _ollamaUrlController.text.isNotEmpty,
      ApiKeyService.providerOpenRouter => _hasOpenRouterKey,
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
                    SelectFieldOption(
                      value: ApiKeyService.providerOpenRouter,
                      label: 'OpenRouter (200+ models)',
                      description: 'Tổng hợp nhiều provider, nhiều model free',
                      icon: Icons.route_rounded,
                    ),
                  ],
                  onChanged: (v) { if (v != null) onProviderChanged(v); },
                ),
                const SizedBox(height: DesignSpacing.md),

                // ── Model selector ───────────────────────────────────────
                if (selectedProvider == ApiKeyService.providerGemini)
                  _buildUnifiedModelPicker(
                    provider: ApiKeyService.providerGemini,
                    currentModel: selectedGeminiModel,
                    availableModels: _geminiAvailableModels,
                    isFetching: _isFetchingGeminiModels,
                    onFetch: _fetchGeminiModels,
                    onChanged: onGeminiModelChanged,
                    isDark: isDark,
                    accentColor: accentColor,
                    fetchDisabled: _geminiKeyController.text.trim().isEmpty,
                  )
                else if (selectedProvider == ApiKeyService.providerGroq)
                  _buildUnifiedModelPicker(
                    provider: ApiKeyService.providerGroq,
                    currentModel: selectedGroqModel,
                    availableModels: _groqAvailableModels,
                    isFetching: _isFetchingGroqModels,
                    onFetch: _fetchGroqModels,
                    onChanged: onGroqModelChanged,
                    isDark: isDark,
                    accentColor: accentColor,
                    fetchDisabled: _groqKeyController.text.trim().isEmpty,
                  )
                else if (selectedProvider == ApiKeyService.providerOllama)
                  _buildOllamaModelInput(
                    isDark: isDark,
                    accentColor: accentColor,
                    controller: ollamaModelController,
                    onChanged: onOllamaModelChanged,
                  )
                else if (selectedProvider == ApiKeyService.providerOpenRouter)
                  _buildUnifiedModelPicker(
                    provider: ApiKeyService.providerOpenRouter,
                    currentModel: selectedOpenRouterModel,
                    availableModels: _openRouterAvailableModels,
                    isFetching: _isFetchingOpenRouterModels,
                    onFetch: _fetchOpenRouterModels,
                    onChanged: onOpenRouterModelChanged,
                    isDark: isDark,
                    accentColor: accentColor,
                    fetchDisabled: _openRouterKeyController.text.trim().isEmpty,
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

  // ── OLLAMA MODEL BOTTOM SHEET ────────────────────────────────────────────
  Future<void> _showOllamaModelBottomSheet({
    required bool isDark,
    required Color accentColor,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) async {
    // Nếu chưa có models và có URL → fetch trước
    if (_ollamaAvailableModels.isEmpty && _ollamaUrlController.text.trim().isNotEmpty) {
      await _fetchOllamaModels(_ollamaUrlController.text.trim());
    }
    if (!mounted) return;

    final manualCtrl = TextEditingController(text: controller.text);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.35,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, scrollCtrl) => Column(
              children: [
                // ── Handle ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[600] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // ── Header ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.memory_rounded, size: 18, color: accentColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Chọn model Ollama',
                          style: DesignTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(ctx).pop(),
                        iconSize: 20,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // ── Scrollable content ───────────────────────────────────
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      // ── Nhập thủ công ─────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NHẬP TÊN MODEL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: manualCtrl,
                                    autofocus: _ollamaAvailableModels.isEmpty,
                                    decoration: InputDecoration(
                                      hintText: 'mistral, llama3:8b, codellama:7b...',
                                      prefixIcon: const Icon(Icons.edit_rounded, size: 16),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(DesignRadius.lg),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(DesignRadius.lg),
                                        borderSide: BorderSide(color: accentColor, width: 1.5),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    final val = manualCtrl.text.trim();
                                    if (val.isEmpty) return;
                                    controller.text = val;
                                    onChanged(val);
                                    Navigator.of(ctx).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text('Dùng'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (_ollamaAvailableModels.isNotEmpty) ...[
                        const Divider(height: 24),
                        // ── Danh sách models đã cài ───────────────────
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 13,
                              color: DesignColors.success,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'MODELS ĐÃ CÀI (${_ollamaAvailableModels.length})',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._ollamaAvailableModels.map((m) {
                          final isSelected = controller.text.trim() == m;
                          return InkWell(
                            onTap: () {
                              controller.text = m;
                              onChanged(m);
                              Navigator.of(ctx).pop();
                            },
                            borderRadius: BorderRadius.circular(DesignRadius.md),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? accentColor.withValues(alpha: 0.08)
                                    : null,
                                borderRadius: BorderRadius.circular(DesignRadius.md),
                                border: isSelected
                                    ? Border.all(
                                        color: accentColor.withValues(alpha: 0.4),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.layers_outlined,
                                    size: 16,
                                    color: isSelected
                                        ? accentColor
                                        : isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      m,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? accentColor
                                            : isDark
                                                ? Colors.white
                                                : DesignColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: accentColor,
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ] else ...[
                        const Divider(height: 24),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.cloud_off_rounded,
                                  size: 36,
                                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Không tìm thấy model nào',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Nhập URL Ollama và bấm "Kiểm tra" để load',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[600] : Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── URL PRESET CHIP ──────────────────────────────────────────────────────
  Widget _buildUrlPresetChip(
    String label,
    IconData icon,
    String? url,
    Color accentColor,
    bool isDark,
  ) {
    final isActive = url != null && _ollamaUrlController.text == url;
    return GestureDetector(
      onTap: () async {
        if (url != null) {
          setState(() {
            _ollamaUrlController.text = url;
            _ollamaConnectionStatus = null;
            _ollamaAvailableModels = [];
          });
        } else {
          await _showCustomIpDialog();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? accentColor.withValues(alpha: 0.12)
              : isDark
                  ? Colors.grey[800]
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(DesignRadius.full),
          border: Border.all(
            color: isActive
                ? accentColor.withValues(alpha: 0.5)
                : isDark
                    ? Colors.grey[700]!
                    : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 11,
              color: isActive ? accentColor : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? accentColor : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomIpDialog() async {
    final currentUrl = _ollamaUrlController.text;
    String initialValue = '192.168.1.x:11434';
    try {
      if (currentUrl.isNotEmpty) {
        final uri = Uri.parse(currentUrl);
        if (uri.host.isNotEmpty) {
          initialValue = '${uri.host}:${uri.port}';
        }
      }
    } catch (_) {}

    final inputCtrl = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.phone_android_rounded, size: 18, color: DesignColors.primary),
            const SizedBox(width: 8),
            const Text('Kiểm tra từ Emulator'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: inputCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'IP:Port',
                  hintText: '192.168.1.5:11434',
                  prefixText: 'http://',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              // ── Hướng dẫn theo loại emulator ──────────────────────────
              _buildIpHintBox(
                icon: Icons.computer_rounded,
                title: 'LDPlayer / BlueStacks / Genymotion',
                steps: [
                  'Chạy ipconfig trên Windows → lấy IPv4 (vd: 192.168.1.5)',
                  'Bật OLLAMA_HOST=0.0.0.0:11434 rồi restart Ollama',
                  'Mở firewall port 11434 (netsh hoặc Windows Defender)',
                  'Nhập: 192.168.1.5:11434',
                ],
              ),
              const SizedBox(height: 8),
              _buildIpHintBox(
                icon: Icons.android_rounded,
                title: 'Android Studio AVD',
                steps: ['Dùng nút "Máy ảo" → tự điền 10.0.2.2:11434'],
              ),
              const SizedBox(height: 8),
              _buildIpHintBox(
                icon: Icons.phone_android_rounded,
                title: 'Máy thật (cùng WiFi)',
                steps: [
                  'Lấy IP máy tính trên cùng mạng WiFi',
                  'Bật OLLAMA_HOST=0.0.0.0:11434',
                  'Nhập IP đó vào đây',
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = inputCtrl.text.trim();
              if (val.isNotEmpty) {
                Navigator.of(ctx).pop('http://$val');
              }
            },
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _ollamaUrlController.text = result;
        _ollamaConnectionStatus = null;
        _ollamaAvailableModels = [];
      });
    }
  }

  Widget _buildIpHintBox({
    required IconData icon,
    required String title,
    required List<String> steps,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: DesignColors.info.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: DesignColors.info.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: DesignColors.info),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: DesignTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DesignColors.info,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...steps.map(
            (s) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '• $s',
                style: DesignTypography.bodySmall.copyWith(fontSize: 11),
              ),
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

/// Pill filter chip với animation — dùng trong model picker sheet.
class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.active,
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactiveIconColor = isDark ? Colors.grey[400]! : Colors.grey[500]!;
    final inactiveBorder = isDark ? Colors.grey[600]! : Colors.grey[300]!;
    final inactiveBg = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.12) : inactiveBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? color : inactiveBorder,
            width: active ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? color : inactiveIconColor,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color: active ? color : inactiveIconColor,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              child: active
                  ? Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 9, color: Colors.white),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
