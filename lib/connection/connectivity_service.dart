import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService {
  // Singleton pattern
  static final ConnectivityService _instance = ConnectivityService._internal();
  static ConnectivityService get instance => _instance;
  ConnectivityService._internal();

  // Expose the current status as a ValueNotifier
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(true);
  StreamSubscription<InternetConnectionStatus>? _subscription;

  // Initialize the stream listener
  void initialize() {
    _subscription?.cancel();
    
    // Check initial connection status
    InternetConnectionChecker.instance.hasConnection.then((hasConnection) {
      isConnected.value = hasConnection;
    });

    // Listen for periodic updates
    _subscription = InternetConnectionChecker.instance.onStatusChange.listen((InternetConnectionStatus status) {
      switch (status) {
        case InternetConnectionStatus.connected:
        case InternetConnectionStatus.slow:
          isConnected.value = true;
          break;
        case InternetConnectionStatus.disconnected:
          isConnected.value = false;
          break;
      }
    });
  }

  // Force a manual check if needed
  Future<bool> checkConnection() async {
    final hasConnection = await InternetConnectionChecker.instance.hasConnection;
    isConnected.value = hasConnection;
    return hasConnection;
  }

  // Clean up subscription if service is disposed
  void dispose() {
    _subscription?.cancel();
  }
}
