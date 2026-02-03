import 'package:ai_mls/core/services/connectivity_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final hasInternetProvider = StreamProvider<bool>((ref) async* {
  final connectivityService = ref.watch(connectivityServiceProvider);
  yield* connectivityService.connectivityStream;
});
