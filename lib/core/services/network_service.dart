import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for checking network connectivity
///
/// Helps prevent app freeze by detecting network issues early
/// before attempting Supabase connection
class NetworkService {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connectivity
  ///
  /// Returns true if device is connected to WiFi, mobile data, or ethernet
  /// Returns false if device has no connection
  static Future<bool> hasInternetConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      // Check if any connectivity result is not none
      return results.isNotEmpty && !results.contains(ConnectivityResult.none);
    } catch (e) {
      // If connectivity check fails, assume we might have connection
      // Don't block app startup
      return true;
    }
  }

  /// Get current connectivity status
  static Future<ConnectivityResult> getConnectivityStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      // Return first result from list, or none if empty
      return results.isNotEmpty ? results.first : ConnectivityResult.none;
    } catch (e) {
      // Default to assuming connection if check fails
      return ConnectivityResult.other;
    }
  }

  /// Get human-readable connectivity status
  static String getStatusDescription(ConnectivityResult status) {
    switch (status) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other Connection';
      case ConnectivityResult.none:
        return 'No Connection';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
    }
  }
}
