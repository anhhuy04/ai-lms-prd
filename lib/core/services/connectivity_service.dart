import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _hasInternet = false;

  /// Kiểm tra kết nối internet hiện tại
  Future<bool> checkInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.contains(ConnectivityResult.none) == false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Lắng nghe thay đổi kết nối mạng
  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged
        .asyncMap(
          (results) async => results.contains(ConnectivityResult.none) == false,
        )
        .distinct();
  }

  /// Bắt đầu lắng nghe kết nối mạng
  void startListening() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) async {
      _hasInternet = results.contains(ConnectivityResult.none) == false;
    });
  }

  /// Dừng lắng nghe kết nối mạng
  void stopListening() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Giải phóng tài nguyên
  void dispose() {
    stopListening();
  }

  /// Kiểm tra xem có kết nối internet không (đã cache)
  bool get hasInternet => _hasInternet;
}
