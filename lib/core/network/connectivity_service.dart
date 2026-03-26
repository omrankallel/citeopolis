import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static StreamController<bool> connectionStatusController = StreamController<bool>.broadcast();

  static Stream<bool> get connectionStream => connectionStatusController.stream;

  static Future<void> initialize() async {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      final bool isConnected = !result.contains(ConnectivityResult.none);
      connectionStatusController.add(isConnected);
    });

    final initialResult = await _connectivity.checkConnectivity();
    final bool isConnected = initialResult.contains(ConnectivityResult.none);
    connectionStatusController.add(isConnected);
  }

  static Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.none);
  }
}
