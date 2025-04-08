// connectivity_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService with ChangeNotifier {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  ConnectivityResult get connectionStatus => _connectionStatus;

   ConnectivityService() {
    // Listen to changes in network connectivity
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Handle the first element in the list (you can adjust based on your needs)
      _connectionStatus = results.isNotEmpty ? results[0] : ConnectivityResult.none;
      notifyListeners(); // Notify listeners when the connectivity changes
    });
  }
}
