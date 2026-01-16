import 'dart:async';
import 'package:flutter/foundation.dart';

/// Mixin cung cấp chức năng làm mới (refresh) cho các ViewModels.
mixin RefreshableViewModel on ChangeNotifier {
  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  String? _refreshError;
  String? get refreshError => _refreshError;

  Timer? _debounceTimer;

  // Cờ để kiểm tra xem ViewModel đã bị dispose hay chưa.
  bool _isDisposed = false;

  // Cờ để kiểm tra xem đã khởi tạo dữ liệu lần đầu chưa
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> fetchData();

  Future<void> refresh({bool showLoading = true}) async {
    if (_isRefreshing && showLoading) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (showLoading) {
        _isRefreshing = true;
        _refreshError = null;
        if (_isDisposed) return;
        notifyListeners();
      }

      try {
        await fetchData();
        _refreshError = null;
        _isInitialized = true; // Đánh dấu đã khởi tạo xong
      } catch (e) {
        _refreshError = e.toString();
      } finally {
        if (showLoading) {
          _isRefreshing = false;
          if (_isDisposed) return;
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true; // Đặt cờ khi dispose
    _debounceTimer?.cancel();
    super.dispose();
  }
}
